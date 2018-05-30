open Regex_example

let regex =
  raise (RegexNotation.RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])

let () = print_endline (Regex.show regex)
