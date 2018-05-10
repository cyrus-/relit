  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Can we pass the TLM definition as an argument to
a functor directly, changing what the call will look like?

  $ caml << END
  > $prefix
  > module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
  >   let regex = raise (A.B.Call ("Forgot ppx...", "a|b") [@relit])
  > end
  > module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
  > open X
  > let () = print_endline (Regex.show regex)
  > END
  (Or (String a) (String b))
