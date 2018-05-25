open Regex_example 

module Funct(A : sig val x : int end) = struct
  module NotationAlias = RegexNotation
end
module Alias = Funct(struct let x = 0 end)
open Alias.NotationAlias
let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)
