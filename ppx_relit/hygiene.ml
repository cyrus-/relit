
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
  let open Longident in
  Ast_helper.Mod.structure
    [%str let _ = [%e expr ] ]

let tyexpr_of_module = function
  | Typedtree.{ mod_desc = Tmod_structure
          {str_items = [{str_desc = Tstr_value
                             (_, [{vb_expr = expr; _}])}]} } ->
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
    | Call_record.Module (name, module_declaration) ->
      env := Env.add_module_declaration
          ~check:true name module_declaration !env
    | Call_record.Type (name, type_declaration) ->
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
    |> List.filter (function Call_record.Module _ -> true | _ -> false)
    |> List.map (function
        | Call_record.Module (name, _) -> Ident.name name
        | _ -> raise (Failure "impossible, just filtered them"))
    |> StringSet.of_list
  in if StringSet.is_empty (StringSet.diff modules dependencies)
     then ()
     else raise (Failure "This TLM used a dependency it should not have here.")

let check Call_record.{dependencies;
                       path;
                       loc;
                       env = call_env} expr =
  (* This is an empty environment, but does have Pervasives. *)
  let env = Compmisc.initial_env () in
  let env = add_dependencies_to env dependencies in
  let tyexpr = typecheck_expression ~loc env expr in

  check_modules_used expr dependencies;

  let call_env = add_dependencies_to call_env dependencies in

  let open Types in
  let type_t = {
    desc = Tconstr (Path.Pdot (path, "t", 0 (* a position? *)),
                        [], ref Mnil);
    level = 2;
    id = 0
  } in 
  if not (Ctype.matches call_env type_t tyexpr.exp_type)
  then raise (Location.Error
    (Location.Error.createf ~loc "parser returned wrong type"))
  else ()
