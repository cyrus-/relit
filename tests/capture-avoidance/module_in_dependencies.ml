open Test_example
open TestNotation

let x = "hi there"
module Std = struct end (* aliases at the application site should not matter *)
let out =
  raise (RelitInternalDefn_extlib_dep.Call ("Forgot ppx...", "module") [@relit])
let () = print_int 42
