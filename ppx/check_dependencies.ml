
(* check_dependencies.ml is the file for checking
 * the dependencies of a given piece of generated
 * code are valid *)

let rec lident_of_path path =
  let open Path in
  let open Longident in
  match path with
  | Pident ident -> Lident (Ident.name ident)
  | Pdot (rest, name, _) -> Ldot (lident_of_path rest, name)
  | Papply (a, b) -> Lapply (lident_of_path a, lident_of_path b)

let module_expr_of_expr expr =
  let open Parsetree in
  let open Longident in
  let loc = !Ast_helper.default_loc in

  Ast_helper.Mod.structure [{pstr_desc =
     (* like saying `let _ = $expr`, since
      * there doesn't seem to be a way to
      * type an expression that's not in a module *)
     Pstr_value (Nonrecursive,
                 [{pvb_pat = {ppat_desc = Ppat_any;
                              ppat_loc = loc;
                              ppat_attributes = []};
                   pvb_expr = expr;
                   pvb_loc = loc;
                   pvb_attributes = [];
                  }]);
    pstr_loc = loc}]

let open_dependencies_for def_path expr =
  let open Migrate_parsetree.OCaml_404.Ast in
  let open Parsetree in
  let loc = !Ast_helper.default_loc in
  {pexp_desc = Pexp_open (
       Fresh,
       {txt = Ldot (lident_of_path def_path,
                    "Dependencies"); loc },
       expr);
   pexp_loc = loc;
   pexp_attributes = []}

let rec path_starts_with path  prefix =
  (Path.head path).name = prefix

module Check_mapper (A : sig val dependencies : Relit_call.dependency list end) = TypedtreeIter.MakeIterator(struct
    include TypedtreeIter.DefaultIteratorArgument

    let check_path loc p =
      if Ident.name (Path.head p) = "Pervasives" then () else

        (* Does this path start with any of the dependencies *)
      if A.dependencies
         |> List.map (fun Relit_call.{name; _} -> name.name)
         |> List.map (path_starts_with p)
         |> List.mem true
      then () (* then no problem! *)
      else begin (* otherwise, we do have a problem *)
        Location.print_error Format.std_formatter loc ;
        raise (Failure "This TLM used a dependency it should not have here.")
      end

    let check_ident loc_ident env =
      let open Location in
      let ident_path, _ = Env.lookup_value loc_ident.txt env in
      check_path loc_ident.loc ident_path

    let check_construct i e = match Env.lookup_constructor Location.(i.txt) e with
      | Types.{cstr_res = {desc = Tconstr (p, _, _); _}} -> check_path i.loc p
      | _ -> raise (Failure "Bug: how does looking up a constructor not return a constructor?")

    let enter_expression e =
      let open Typedtree in
      match e.exp_desc with
      | Texp_ident (p, i, _) ->
        check_path e.exp_loc p;
        check_ident i e.exp_env
      | Texp_new (p, i, _) ->
        check_path e.exp_loc p;
        check_ident i e.exp_env
      | Texp_construct (i, _, _) ->
        check_construct i e.exp_env
      | Texp_instvar (p1, p2, _) -> check_path e.exp_loc p1; check_path e.exp_loc p2
      | Texp_override (p, ps) ->
        check_path e.exp_loc p;
        List.iter (fun (p, _, _) -> check_path e.exp_loc p) ps
      | _ -> ()
  end)

let check_all_paths dependencies mod_tree =
  (* we want to run this check against the typed tree instead
   * of the parsetree because it has semantic paths rather
   * than syntactic identifiers *)
  match mod_tree with
    (* extract the expression *)
  | Typedtree.{mod_desc = Tmod_structure {str_items = [{str_desc =
      Tstr_value (_, [{vb_expr = expr; _}]) ; _}]; _}; _} ->
    let module M = Check_mapper (struct let dependencies = dependencies end) in
    M.iter_expression expr
  | _ -> raise (Failure "Bug: we literally just constructed this")

let check_expr (dependencies : Relit_call.dependency list) def_path expr =
  let env = ref Env.empty in
  List.iter (fun Relit_call.{name; module_declaration; _} ->
      env := Env.add_module_declaration ~check:true name module_declaration !env
    ) dependencies;

  (* we've got to use the current tree to run the typechecker *)
  expr |> Convert.To_current.copy_expression
       (* |> (fun e -> ensure_context_indenpendence e) *)
       |> module_expr_of_expr
       |> Typemod.type_module !env
       |> check_all_paths dependencies;
  open_dependencies_for def_path expr
