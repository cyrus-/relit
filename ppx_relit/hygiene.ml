
(* hygiene.ml's the file we use in relit to check
 * the dependencies of a given piece of generated
 * code is valid. We do this through typechecking
 * the generated code, and then a manual checking
 * of all the modules that can be accessed there.
 * *)
module Location = Ppxlib.Location

module StringSet = Set.Make(String)

let module_expr_of_expr ~loc expr =
  let open Parsetree in
  Ast_helper.Mod.structure
    [%str let _ = [%e expr ] ]

let tyexpr_of_module = function
  | Typedtree.{ mod_desc = Tmod_structure
          {str_items = [{str_desc = Tstr_value
                             (_, [{vb_expr = expr; _}]); _}]; _}; _ } ->
            expr
  | _ -> raise (Failure "Bug: we literally just constructed this")

let typecheck_expression ~loc env expr =
  (* To typecheck an expression:
   * 1. make a module 2. typecheck it 3. extract expr from module *)
  let mod_expr = module_expr_of_expr ~loc expr in
  let typed_mod = Typemod.type_module env mod_expr in
  tyexpr_of_module typed_mod

let add_dependencies_to env dependencies =
  let env = ref env in
  List.iter (function
    | App_record.Module (name, module_declaration) ->
      env := Env.add_module_declaration
          ~check:true name module_declaration !env
    | App_record.Type (name, type_declaration) ->
      env := Env.add_type ~check:true name type_declaration !env
    ) dependencies;
  !env

let check_modules_used expr dependencies =
  let tmp = Utils.tmp_file () ^ ".ml" in
  Utils.write_file tmp (Pprintast.string_of_expression expr);
  let line = Utils.with_process ("ocamldep -modules " ^ tmp)
      (fun (out, _) -> input_line out) in
  let modules = line
    (* |> (fun x -> print_endline x; x) *)
    |> Utils.split_on ": "
    |> (fun l -> match List.nth l 1 with
        | x -> x
        | exception _ -> "" (* excellent, it used no dependencies *))
    |> Utils.split_on " "
    |> StringSet.of_list
  in
  let dependencies = dependencies
    |> List.filter (function App_record.Module _ -> true | _ -> false)
    |> List.map (function
        | App_record.Module (name, _) -> Ident.name name
        | _ -> raise (Failure "impossible, just filtered them"))
    |> StringSet.of_list
  in
  let extras = StringSet.diff modules dependencies in
  if StringSet.is_empty extras
  then ()
  else (
    Printf.fprintf stderr
      "This TLM depends on the following module that it did not have access to: %s\n"
      (StringSet.elements extras |> String.concat ", ");
    exit 1
  )


let check App_record.{dependencies;
                       path;
                       loc;
                       env = _app_env; _} expr =
  (* This is an empty environment, but does have Pervasives. *)
  let env = Compmisc.initial_env () in
  let env = add_dependencies_to env dependencies in
  let _ = typecheck_expression ~loc env expr in
  check_modules_used expr dependencies;

  Ast_helper.Exp.constraint_ ~loc
    expr
    (Ast_helper.Typ.constr ~loc
    {txt = Longident.(Ldot (Utils.lident_of_path path, "t")) ; loc }
    [])
