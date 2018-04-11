
type relit_call = {
  (* name: string; *)
  source: string;
  lexer: Path.t;
  parser_: Path.t;
  env: Env.t;
  (* parser: string; *)
  (* Not sure if these should be strings or what yet.
    * dependencies: string;
    * type': string; *)
}

let signature_of_outer_modtype = function
  | Types.Mty_signature [Sig_module (_name, {
      md_type =  Mty_signature signature ; _
    }, _)] -> signature
  | _ -> raise (Failure "Expected a signature modtype for relit")

let relit_call_of_modtype env path source : relit_call =
  let unwrap = function
    | Some o -> o
    | None -> raise (Failure "Unwrap: Malformed relit call site") in
  let lexer = ref None in
  let parser_ = ref None in
  let modtype = (Env.find_module path env).md_type in
  let signature = signature_of_outer_modtype modtype in

  List.iter (function
      | Types.Sig_module ({ name = "Lexer" ; _},
                          { md_type = Mty_alias (_alias_presence, path); _ }, _) ->
        lexer := Some path
      | Types.Sig_module ({ name = "Parser" ; _},
                          { md_type = Mty_alias (_alias_presence, path); _ }, _) ->
        parser_ := Some path
      | _ -> ()
    )
    signature ;

  { lexer = unwrap !lexer ;
    parser_ = unwrap !parser_;
    source = source ;
    env = env}
