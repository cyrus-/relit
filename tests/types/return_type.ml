open Regex_notation

open AbsurdTLM
let x = "hi there"
let out =
  raise (RelitInternalDefn_absurd_int.Call ("Forgot ppx...", "number") [@relit])
let () = print_endline out;

