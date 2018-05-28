
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
  (String.escaped call.source)
  (Path.name call.parser)
  (Path.name call.lexer)

let include_dirs () : string =
  !Clflags.include_dirs
  |> List.map (fun n -> " -I " ^ n )
  |> String.concat ""

let packages tmp_ml =
  let immediate_deps =
    Utils.with_process ("ocamldep -native -one-line" ^ include_dirs () ^ " " ^ tmp_ml)
    (fun (pout, _) ->
       match List.nth_opt (Utils.split_on " : " (input_line pout)) 1 with
       | Some deps -> Utils.split_on " " deps
                      |> List.map Filename.dirname
                      |> List.map Filename.basename (* last dir *)
       | None -> raise (Failure "bug: mistake in parsing ocamldep")
    )
  in

  let deps = immediate_deps
  |> List.map (fun dep ->
       Utils.with_process ("ocamlfind query -p-format -recursive " ^ dep) Utils.lines)
  |> List.flatten
  |> List.merge String.compare immediate_deps
  |> String.concat ","
  in "-package " ^ deps

let compile contents =
  (* write ocaml to a temporary file, compile it
   * to an executable, then return the name of the
   * executable. *)
  let tmp = Utils.tmp_file () in
  let tmp_ml = tmp ^ ".ml" in
  Utils.write_file tmp_ml contents;
  Utils.command "ocamlfind" (
    "ocamlc -linkpkg -o " ^ tmp ^ " " ^
    include_dirs () ^ " " ^
    packages tmp_ml ^ " " ^
    tmp_ml);
  tmp

(* TODO memoize this compilation *)
let parse (call : Call_record.t)
  : Parsetree.expression =

  let parser = compile (parser_file call) in

  let ast = Utils.with_process ("./" ^ parser)
    Utils.(fun (pout, _) ->
      let signal = input_line pout in
      match signal with
      | "ast" -> Marshal.from_channel pout
      | "error" -> raise (Failure "TLM error in parser")
      | _ -> raise (Failure "unknown parser format")
    )
  in Convert.To_current.copy_expression ast
