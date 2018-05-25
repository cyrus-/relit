open Regex_example

open Test_example.TestNotation
let x = "hi there"
let out =
  raise (RelitInternalDefn_absurd_int.Call ("Forgot ppx...", "number") [@relit])
let () = print_endline out;

