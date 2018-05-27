
(* the machinery for loading the parser and lexer
 * at the ppx's run-time and then parsing the tlm's source *)

open Call_record

let write_to_file f text =
  let out = open_out f in
  Printf.fprintf out "%s" text;
  flush out;
  close_out out

let with_process cmd lambda =
  let p = Unix.open_process cmd in
  let out = lambda p in
  Unix.close_process p |> ignore;
  out

let split_on sep = Str.split (Str.regexp sep)

let command name args =
  let success = Sys.command (name ^ " " ^ args) in
  if success <> 0 then raise (Failure ("bug: " ^ name ^ " failed"))

let parse_lines (out, _) =
  let rec lp out =
    match input_line out with
    | line -> line :: lp out
    | exception End_of_file -> []
  in lp out

let generated_file call = Printf.sprintf
  {| let source = "%s"
     let parsetree = %s.literal %s.read (Lexing.from_string source)
     let () = Marshal.to_channel stdout parsetree []
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
    with_process ("ocamldep -native -one-line " ^ include_dirs () ^ " " ^ tmp_ml)
    (fun (pout, _) ->
       match List.nth_opt (split_on " : " (input_line pout)) 1 with
       | Some deps -> split_on " " deps
                      |> List.map Filename.basename
                      |> List.map Filename.remove_extension
       | None -> raise (Failure "bug: mistake in parsing ocamldep")
    )
  in

  let deps = immediate_deps
  |> List.map (fun dep ->
       with_process ("ocamlfind query -p-format -recursive " ^ dep) parse_lines)
  |> List.flatten
  |> List.merge String.compare immediate_deps
  |> String.concat ","
  in "-package " ^ deps

(* TODO memoize this compilation *)
let parse (call : Call_record.t)
  : Parsetree.expression =
  let tmp = "relit_tmp_" ^ Utils.unique_string () in
  let tmp_ml = tmp ^ ".ml" in
  write_to_file tmp_ml (generated_file call);

  command "ocamlfind" (
    "ocamlc -linkpkg -o " ^ tmp ^ " " ^
    include_dirs () ^ " " ^
    packages tmp_ml ^ " " ^
    tmp_ml);

  let ast = with_process ("./" ^ tmp)
      (fun (pout, _) -> Marshal.from_channel pout)
  in Convert.To_current.copy_expression ast
