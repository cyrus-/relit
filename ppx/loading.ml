
(* the machinery for loading the parser and lexer
 * at the ppx's run-time and then parsing the tlm's source *)

let load_top_module path =
  let toplevel_module = Ident.name (Path.head path) in
  let filename = String.lowercase_ascii toplevel_module ^ ".cma" in
  (* The boolean returned is just whether or not it was
   * already loaded *)
  Topdirs.load_file Format.std_formatter filename |> ignore

let menhir_from_module lexer_path parser_path env =
  Toploop.initialize_toplevel_env ();
  load_top_module lexer_path;
  load_top_module parser_path;

  ("let value : Lexing.lexbuf -> Migrate_parsetree.Ast_404.Parsetree.expression = "
  ^ Path.name parser_path  ^ ".literal "
  ^ Path.name lexer_path  ^ ".read;;")
    |> Lexing.from_string
    |> Parse.toplevel_phrase
    |> Toploop.execute_phrase false Format.std_formatter
    |> fun x -> if not x then raise (Failure "while trying to execute phrase");
  (Obj.magic (Toploop.getvalue "value")
   : (Lexing.lexbuf -> Migrate_parsetree.Ast_404.Parsetree.expression))
