
(* the machinery for loading the parser and lexer
 * at the ppx's run-time and then parsing the tlm's source *)

open Call_record

let parser_file call = Printf.sprintf
  {|
let source = "%s"
let parsetree () = %s.literal %s.read (Lexing.from_string source)
let () = match parsetree () with
         | parsetree -> print_endline "ast";
                        Marshal.to_channel stdout parsetree []
         | exception e -> print_endline "error"; raise e
  |}
  (String.escaped call.source) call.parser call.lexer

let compile contents package =
  (* write ocaml to a temporary file, compile it
   * to an executable, then return the name of the
   * executable. *)
  let tmp = Utils.tmp_file () in
  Utils.write_file (tmp ^ ".ml") contents;

  Utils.command "compiling the parser"
    ("ocamlbuild -no-hygiene -quiet -use-ocamlfind -pkg " ^ package ^
     " " ^ tmp ^ ".native");
  tmp ^ ".native"

(* TODO memoize this compilation *)
let parse (call : Call_record.t)
  : Parsetree.expression =

  let parser = compile (parser_file call) call.package in

  let ast = Utils.with_process ("./" ^ parser)
    Utils.(fun (pout, _) ->
      let signal = input_line pout in
      match signal with
      | "ast" -> Marshal.from_channel pout
      | "error" -> raise (Failure "TLM error in parser")
      | _ -> raise (Failure "unknown parser format")
    )
  in Convert.To_current.copy_expression ast
