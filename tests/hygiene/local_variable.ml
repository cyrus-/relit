open Regex_notation

open AbsurdTLM
let x = "hi there"
let out =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "x") [@relit])
let () = print_endline out;

