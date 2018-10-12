let write_to_file ~file ~text =
  let c = open_out file in
  Printf.fprintf c "%s" text;
  close_out c

let with_process cmd lambda =
  let p = Unix.open_process_in cmd in
  let out = lambda p in
  Unix.close_process_in p |> ignore;
  out

let line_stream_of_channel channel =
  Stream.from (fun _ -> try Some (input_line channel) with End_of_file -> None);;

let matches_regex fst snd =
  try Str.search_forward (Str.regexp snd) fst 0 |> ignore; true
  with Not_found -> false

let is_spam s =
  matches_regex s "Interface topdirs.cmi occurs in several directories" ||
  matches_regex s "cd _build/default &&" ||
  matches_regex s "ocaml.*test/cases/\\..*eobjs" ||
  matches_regex s "Command line: .ppx/ppx_relit/ppx.exe"

let compile_and_run ~name =
  Unix.chdir (Sys.getenv "PWD");
  let dune = open_out "test/cases/dune" in
  Printf.fprintf dune {|
  (executable
    (name %s)
    (preprocess (staged_pps ppx_relit))
    (modules %s)
    (libraries regex_example test_example timeline_example extlib)
  )
  |} name name;
  close_out dune;

  let file = Filename.concat "test/cases" (name ^ ".exe") in
  with_process (Printf.sprintf "dune build %s 2>&1 && dune exec %s 2>&1" file file)
  (fun pout ->
    line_stream_of_channel pout
    |> Stream.iter (fun line -> if not (is_spam line) then print_endline line)
  )
