open Regex_notation
open RegexTLM

let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])

let () = print_endline (Regex.show regex)
