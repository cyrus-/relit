open Regex_notation

open AbsurdTLM
let x = "hi there"
let out =
  raise (RelitInternalDefn_extlib_dep.Call ("Forgot ppx...", "module") [@relit])
