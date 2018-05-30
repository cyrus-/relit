open Regex_example

open Test_example.TestNotation
type new_type = string (* should not matter what this is *)
let square =
  raise (RelitInternalDefn_absurd_int_arrow_int.Call ("Forgot ppx...", "typed_fn") [@relit])
let () = print_int (square 5)

