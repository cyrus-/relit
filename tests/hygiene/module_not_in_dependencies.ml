open Regex_example

open Test_example.TestNotation
let x = "hi there"
let out =
  raise (RelitInternalDefn_extlib_nodep.Call ("Forgot ppx...", "module") [@relit])
let () = print_endline out;

