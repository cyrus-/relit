
(* a relit_call is stored for each tlm call in the ocaml source
 * after the typing ppx phase, and then is used in the parsetree
 * mapper to actaully call the tlm. This file is concerned with
 * the building of a relit_call from the definitions. *)

type relit_call = {
  (* name: string; *)
  source: string;
  lexer: Path.t;
  parser: Path.t;
  env: Env.t;
  dependencies: (string * Path.t) list;
  (* Not sure if this should be a string or what yet.
    * type': string; *)
}

let rec signature_of_module env path =
  signature_of_md_type env (Env.find_module path env).md_type
and signature_of_md_type env = function
  | Types.Mty_signature [Sig_module (_name, {
      md_type =  Mty_signature signature ; _
    }, _)] -> signature
  | Types.Mty_signature [Sig_module (_name, {
      md_type ; _
    }, _)] -> signature_of_md_type env md_type
  | Types.Mty_signature signature -> signature
  | Types.Mty_alias (_, path) -> signature_of_module env path
  | Types.Mty_ident path -> signature_of_module env path
  | modtype ->
    Printtyp.modtype Format.std_formatter modtype;
    raise (Failure "Bug: I haven't seen this come up before.")

let extract_dependencies signature : (string * Path.t) list =
  List.map (function
        Types.Sig_module ({ name ; _ },
                        { md_type = Mty_alias (_, path) ; _ }, _) ->
        (name, path)
      | _ -> raise (Failure "Dependencies: expected only aliases in relit definition")
      )
    signature

type ('a, 'b) either = Left of 'a | Right of 'b

let relit_call_of_modtype env path source : relit_call =
  let unwrap = function
    | Left o -> o
    | Right name -> raise
        (Failure ("Unwrap: Malformed relit definition no " ^
                  name ^ " field"))
  in
  let lexer = ref (Right "lexer") in
  let parser = ref (Right "parser") in
  let dependencies = ref (Right "dependencies") in
  let signature = signature_of_module env path in

  List.iter (function
      | Types.Sig_module ({ name = "Lexer" ; _},
                          { md_type = Mty_alias (_, path); _ }, _) ->
        lexer := Left path
      | Types.Sig_module ({ name = "Parser" ; _},
                          { md_type = Mty_alias (_, path); _ }, _) ->
        parser := Left path
      | Types.Sig_module ({ name = "Dependencies" ; _},
                          { md_type = Mty_signature signature; _ }, _) ->
        dependencies := Left (extract_dependencies signature)
      | _ -> ()
    )
    signature ;

  { lexer = unwrap !lexer ;
    parser = unwrap !parser;
    dependencies = unwrap !dependencies;
    source = source ;
    env = env}
