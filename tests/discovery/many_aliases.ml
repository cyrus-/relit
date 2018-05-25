open Regex_example

module Obscure(A : sig val x : int end) = struct
  module NotationAlias = struct
    (* module Test = struct let y = A.x end *)
    include RegexNotation
  end
end
module Alias1 = Obscure(struct let x = 2 end)
module Alias2 = Alias1
module Alias3 = Alias2
module Alias4 = Alias3
open Alias4.NotationAlias
let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)

