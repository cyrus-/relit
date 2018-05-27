
(* hygiene.ml's the file we use in relit to check
 * the dependencies of a given piece of generated
 * code is valid. We do this through typechecking
 * the generated code, and then a manual checking
 * of all the modules that can be accessed there.
 * *)

module StringSet = Set.Make(String)

module Check_mapper (A : sig val disallowed : StringSet.t end) =
  TypedtreeIter.MakeIterator(struct
    include TypedtreeIter.DefaultIteratorArgument

    let enter_expression e =
      let open Typedtree in
      let env = e.exp_env in

      let check_path loc p =
        if StringSet.mem (Ident.name (Path.head p)) A.disallowed then (
          Location.print_error Format.std_formatter loc ;
          raise (Failure "This TLM used a dependency \
                          it should not have here.")
        )
      in

      let check_ident loc_ident =
        let open Location in
        let ident_path, _ = Env.lookup_value loc_ident.txt env in
        check_path loc_ident.loc ident_path
      in

      let check_construct i =
        match Env.lookup_constructor Location.(i.txt) env with
        | Types.{cstr_res = {desc = Tconstr (p, _, _); _}} ->
          check_path i.loc p
        | _ -> raise (Failure "Bug: how does looking up a constructor\
                               not return a constructor?")
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
      | Texp_instvar (p1, p2, _) ->
        check_path e.exp_loc p1; check_path e.exp_loc p2
      | Texp_override (p, ps) ->
        check_path e.exp_loc p;
        List.iter (fun (p, _, _) -> check_path e.exp_loc p) ps
      | _ -> ()
  end)

let module_expr_of_expr expr =
  let open Parsetree in
  let open Longident in
  let loc = !Ast_helper.default_loc in
  Ast_helper.Mod.structure
    [%str let _ = [%e expr ] ]

let tyexpr_of_module = function
  | Typedtree.{ mod_desc = Tmod_structure
          {str_items = [{str_desc = Tstr_value
                             (_, [{vb_expr = expr; _}])}]} } ->
            expr
  | _ -> raise (Failure "Bug: we literally just constructed this")

let typecheck_expression env expr =
  (* To typecheck an expression:
   * 1. make a module 2. typecheck it 3. extract expr from module *)
  let mod_expr = module_expr_of_expr expr in
  let typed_mod = Typemod.type_module env mod_expr in
  tyexpr_of_module typed_mod

let run_dependency_checker disallowed expr =
  let module M = Check_mapper (struct let disallowed = disallowed end) in
  (* Printtyped.implementation Format.std_formatter structure; *)
  M.iter_expression expr

let add_dependencies_to env dependencies =
  let env = ref env in
  List.iter (function
    | Call_record.Module (name, module_declaration) ->
      env := Env.add_module_declaration
          ~check:true name module_declaration !env
    | Call_record.Type (name, type_declaration) ->
      env := Env.add_type ~check:true name type_declaration !env
    ) dependencies;
  !env


let initialize_environment () =
  let print_nothing = Format.formatter_of_buffer (Buffer.create 1000) in

  (* we need to load a file into the toplevel so that
   * we know what modules to disallow *)
  Toploop.initialize_toplevel_env ();
  ignore (Topdirs.load_file print_nothing "relit_helper.cma")

let check Call_record.{dependencies;
                         return_type;
                         env = call_env} expr =
  initialize_environment ();
  let env = Compmisc.initial_env () in
  let env = add_dependencies_to env dependencies in

  let importable = StringSet.of_list (Env.imports () |> List.map fst) in
  let allowed = dependencies
    |> List.filter (function Call_record.Module _ -> true | _ -> false)
    |> List.map (function
        | Call_record.Module (name, _) -> Ident.name name
        | _ -> raise (Failure "impossible, just filtered them"))
    |> StringSet.of_list in

  let disallowed = StringSet.diff importable allowed in
  let disallowed = StringSet.remove "Pervasives" disallowed in

  let tyexpr = typecheck_expression env expr in

  run_dependency_checker disallowed tyexpr;

  let env = add_dependencies_to call_env dependencies in

  if not (Ctype.matches env return_type tyexpr.exp_type)
  then raise (Failure "parser returned wrong type")
  else ()
