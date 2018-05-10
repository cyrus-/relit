  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Can we store the definition in an alias before opening it?

  $ caml << END
  > $prefix
  > module Alias = RegexTLM
  > open Alias
  > let regex =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  > let () = print_endline (Regex.show regex)
  > END
  (Or (Or (String a) (String b)) (String c))
