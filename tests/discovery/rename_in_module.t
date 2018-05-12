  $ . $ORIGINAL_DIR/tests/helpers/regex.sh

Can we rename the TLM definition to a new module... within a functor?

  $ caml << END
  > $prefix
  > module Funct(A : sig val x : int end) = struct
  >   module NotationAlias = RegexTLM.RelitInternalDefn_regex
  > end
  > module Alias = Funct(struct let x = 0 end)
  > open Alias
  > let regex =
  >   raise (NotationAlias.Call ("Forgot ppx...", "a|b|c") [@relit])
  > let () = print_endline (Regex.show regex)
  > END
  (Or (Or (String a) (String b)) (String c))
