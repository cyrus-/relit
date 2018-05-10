  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Can we include the TLM inside a module inside a functor
and then open an instance of that functor?

  $ caml << END
  > $prefix
  > module Obscure(A : sig val x : int end) = struct
  >   module Notation = struct
  >     module Test = struct let y = A.x end
  >     module Alias = struct
  >       include RegexTLM
  >     end
  >   end
  > end
  > module Ob = Obscure(struct let x = 2 end)
  > open Ob.Notation.Alias
  > let () =
  >   let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
  >   print_endline (Regex.show regex)
  > END
  (Or (String a) (String b))
