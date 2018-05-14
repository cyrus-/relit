open Regex_notation

module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
  let regex = raise (A.B.Call ("Forgot ppx...", "a|b") [@relit])
end
module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
open X
let () = print_endline (Regex.show regex)
