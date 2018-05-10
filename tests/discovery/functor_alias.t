  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Can we put our definition in a functor and access it
after we instatiate the functor?

  $ caml << END
  > $prefix
  > module Funct(A : sig val x : int end) = struct
  >   module NotationAlias = RegexTLM
  > end
  > module Alias = Funct(struct let x = 0 end)
  > open Alias.NotationAlias
  > let regex =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  > let () = print_endline (Regex.show regex)
  > END
  (Or (Or (String a) (String b)) (String c))
