open Regex_notation

open AbsurdTLM
let x = 5
let out =
  raise (RelitInternalDefn_absurd_int.Call ("Forgot ppx...", "x") [@relit])
let () = print_endline out;

