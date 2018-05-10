  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Can we include the TLM in a different module and
use that one? Along with some aliases and a functor...

  $ caml << END
  > $prefix
  > module Obscure(A : sig val x : int end) = struct
  >   module NotationAlias = struct
  >     (* module Test = struct let y = A.x end *)
  >     include RegexTLM
  >   end
  > end
  > module Alias1 = Obscure(struct let x = 2 end)
  > module Alias2 = Alias1
  > module Alias3 = Alias2
  > module Alias4 = Alias3
  > open Alias4.NotationAlias
  > let regex =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  > let () = print_endline (Regex.show regex)
  > END
  (Or (Or (String a) (String b)) (String c))
