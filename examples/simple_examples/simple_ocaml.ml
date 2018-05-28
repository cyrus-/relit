open Regex_example
open RegexNotation

let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])

let () = print_endline (Regex.show regex)
