open Regex_notation
open RegexTLM

let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|$(Regex.String \"okay\")|c") [@relit])

let () = print_endline (Regex.show regex)
