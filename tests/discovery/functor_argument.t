  $ . $ORIGINAL_DIR/tests/helpers/regex.sh

Can we pass our TLM to a functor and still use it?

  $ caml << END
  > $prefix
  > module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
  >   module RelitInternalDefn_regex = A.B
  > end
  > module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
  > open X
  > let regex =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  > let () = print_endline (Regex.show regex)
  > END
  (Or (Or (String a) (String b)) (String c))
