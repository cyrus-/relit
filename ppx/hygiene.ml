
(* check_dependencies.ml is the file for checking
 * the dependencies of a given piece of generated
 * code is valid. We do this through typechecking
 * the generated code, and then a manual checking
 * of all the modules that can be accessed there.
 * *)

module StringSet = Set.Make(String)

module Check_mapper (A : sig val disallowed : StringSet.t end) = TypedtreeIter.MakeIterator(struct
    include TypedtreeIter.DefaultIteratorArgument

    let enter_expression e =
      let open Typedtree in
      let env = e.exp_env in

      let check_path loc p =
        if StringSet.mem (Ident.name (Path.head p)) A.disallowed then begin
          Location.print_error Format.std_formatter loc ;
          raise (Failure "This TLM used a dependency it should not have here.")
        end
      in

      let check_ident loc_ident =
        let open Location in
        let ident_path, _ = Env.lookup_value loc_ident.txt env in
        check_path loc_ident.loc ident_path
      in

      let check_construct i = match Env.lookup_constructor Location.(i.txt) env with
        | Types.{cstr_res = {desc = Tconstr (p, _, _); _}} -> check_path i.loc p
        | _ -> raise (Failure "Bug: how does looking up a constructor not return a constructor?")
      in

      match e.exp_desc with
      | Texp_ident (p, i, _) ->
        check_path e.exp_loc p;
        check_ident i
      | Texp_new (p, i, _) ->
        check_path e.exp_loc p;
        check_ident i
      | Texp_construct (i, _, _) ->
        check_construct i
      | Texp_instvar (p1, p2, _) -> check_path e.exp_loc p1; check_path e.exp_loc p2
      | Texp_override (p, ps) ->
        check_path e.exp_loc p;
        List.iter (fun (p, _, _) -> check_path e.exp_loc p) ps
      | _ -> ()
  end)

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
  Ast_helper.Mod.structure
    [%str let _ = [%e expr ] ]

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

let check_all_paths disallowed mod_tree =
  (* we want to run this check against the typed tree instead
   * of the parsetree because it has semantic paths rather
   * than syntactic identifiers. Also we've got to typecheck
   * anyways as part of context independence. *)

  match mod_tree with
  | Typedtree.{ mod_desc = Tmod_structure
          {str_items = [{str_desc = Tstr_value (_, [{vb_expr = expr; _}])}]} } ->
    let module M = Check_mapper (struct let disallowed = disallowed end) in
    (* Printtyped.implementation Format.std_formatter structure; *)
    M.iter_expression expr
  | _ -> raise (Failure "Bug: we literally just constructed this")

let map_expr (dependencies : Relit_call.dependency list) def_path expr =
  let env = ref (Compmisc.initial_env ()) in

  List.iter (function
    | Relit_call.Module (name, module_declaration) ->
      env := Env.add_module_declaration ~check:true name module_declaration !env
    | Relit_call.Type (name, type_declaration) ->
      env := Env.add_type ~check:true name type_declaration !env
    ) dependencies;

  let importable = StringSet.of_list (Env.imports () |> List.map fst) in
  let allowed = dependencies
                |> List.filter (function Relit_call.Module _ -> true | _ -> false)
                |> List.map (function (Relit_call.Module (name, _)) -> Ident.name name
                                      | _ -> raise (Failure "impossible, just filtered them"))
                |> StringSet.of_list in

  let disallowed = StringSet.diff importable allowed in
  let disallowed = StringSet.remove "Pervasives" disallowed in

  expr |> Convert.To_current.copy_expression
       |> module_expr_of_expr
       |> Typemod.type_module !env
       |> check_all_paths disallowed;
  open_dependencies_for def_path expr
