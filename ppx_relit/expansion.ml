
(* the machinery for loading the parser and lexer
 * at the ppx's run-time and then parsing the tlm's source *)

open App_record

let parser_file app = Printf.sprintf
  {|
let body = "%s"
let lexbuf = Lexing.from_string body
let parsetree () = %s.%s %s.read lexbuf
let () =
  match parsetree () with
  | parsetree ->
    print_endline "ast";
    Marshal.to_channel stdout parsetree []
  | exception e ->
    print_endline "error";
    let pos = lexbuf.lex_curr_p in
    Printf.printf "parsing error %%s:%%d:%%d:\n"
      pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1);
    raise e
  |}
  (String.escaped app.body)
  app.parser
  app.nonterminal
  app.lexer

let compile contents package =
  (* write ocaml to a temporary file, compile it
   * to an executable, then return the name of the
   * executable. *)
  let tmp = Utils.tmp_file () in
  Utils.write_file (tmp ^ ".ml") contents;

  Utils.command "compiling the parser"
    ("ocamlfind ocamlc -linkpkg -package unix -package " ^ package ^
     " " ^ tmp ^ ".ml -o " ^ tmp ^ ".byte");
  tmp ^ ".byte"

let expand_app (app : App_record.t)
  : Parsetree.expression =

  (* TODO memoize this compilation *)
  let parser = compile (parser_file app) app.package in

  (* this is base64-encoded in order to be passed to an environment variable. *)
  let serialized_location = Marshal.to_string app.loc [] ^ "\n" |> B64.encode in
  Unix.putenv "RELIT_INTERNAL_LOCATION" serialized_location;

  let ast = Utils.with_process ("./" ^ parser) (fun (pout, _pin) ->
      let signal = input_line pout in
      match signal with
      | "ast" ->
          Marshal.from_channel pout
      | "error" ->
          (* begin try while true do *)
          (*   input_line stdin |> print_endline *)
          (* done with _ -> () end; *)
          raise (Failure "TLM error in parser")
      | fmt -> raise (Failure ("unknown parser format " ^ fmt))
    )
  in Convert.To_current.copy_expression ast
