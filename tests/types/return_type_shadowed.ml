open Test_example.TestNotation
let x = "hi there"
type t' = TestModule.t 
module TestModule = struct 
  type t = string
end
let out =
  raise (RelitInternalDefn_local_nodep.Call ("Forgot ppx...", "number") [@relit])
let () = print_endline "42";

