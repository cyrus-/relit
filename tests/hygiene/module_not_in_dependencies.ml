open Regex_notation

open AbsurdTLM
let x = "hi there"
let out =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "module") [@relit])
let () = print_endline out;

