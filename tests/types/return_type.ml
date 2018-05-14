open Regex_notation

open AbsurdTLM
let x = "hi there"
let out =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "number") [@relit])
let () = print_endline out;

