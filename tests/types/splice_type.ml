open Regex_example

open Test_example.TestNotation
let out =
  raise (RelitInternalDefn_absurd_int.Call ("Forgot ppx...", "$( 2 )") [@relit])
let () = print_endline out;

