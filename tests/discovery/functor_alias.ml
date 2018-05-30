open Regex_example 

module Funct(A : sig val x : int end) = struct
  module NotationAlias = RegexNotation
end
module M = Funct(struct let x = 0 end)
open M.NotationAlias
let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)
