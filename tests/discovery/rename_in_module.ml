open Regex_notation

module Funct(A : sig val x : int end) = struct
  module NotationAlias = RegexTLM.RelitInternalDefn_regex
end
module Alias = Funct(struct let x = 0 end)
open Alias
let regex =
  raise (NotationAlias.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)
