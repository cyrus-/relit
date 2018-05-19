
(* the machinery for loading the parser and lexer
 * at the ppx's run-time and then parsing the tlm's source *)


let print_nothing = Format.formatter_of_buffer (Buffer.create 1000)

let load_top_module path =
  let toplevel_module = Ident.name (Path.head path) in
  let basename = String.lowercase_ascii toplevel_module in
  if Topdirs.load_file print_nothing (basename ^ ".cma")
  then ()
  else Topdirs.load_file print_nothing (basename ^ ".cmo") |> ignore

let menhir_from_module lexer_path parser_path =
  Toploop.initialize_toplevel_env ();
  Topdirs.load_file print_nothing "relit_helper.cma";
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
