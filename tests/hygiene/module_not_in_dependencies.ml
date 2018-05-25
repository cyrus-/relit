open Regex_example

open Test_example.TestNotation
let x = "hi there"
let out =
  raise (RelitInternalDefn_absurd_cons.Call ("Forgot ppx...", "module") [@relit])
let () = print_endline out;

