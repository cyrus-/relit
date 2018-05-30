open Regex_example

open Test_example.TestNotation
let x = "hi there"
module Std = struct (* should not matter *)
  let unique () = 0
end
let out =
  raise (RelitInternalDefn_extlib_nodep.Call ("Forgot ppx...", "module") [@relit])
let () = print_endline out;

