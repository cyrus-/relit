open Regex_example

module Alias = RegexNotation
open Alias
let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)

