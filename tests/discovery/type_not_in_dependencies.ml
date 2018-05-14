open Regex_notation

open AbsurdTLM
let x = "hi there"
let square =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "badly_typed_fn") [@relit])
let () = print_int (square 5)

