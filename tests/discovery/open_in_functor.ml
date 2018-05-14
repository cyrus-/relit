open Regex_notation

module Obscure(A : sig val x : int end) = struct
  module Notation = struct
    module Test = struct let y = A.x end
    module Alias = struct
      include RegexTLM
    end
  end
end
module Ob = Obscure(struct let x = 2 end)
open Ob.Notation.Alias
let () =
  let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
  print_endline (Regex.show regex)
