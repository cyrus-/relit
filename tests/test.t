
Welcome to a cram file!
Everything not indented is a comment.

Function that compiles our ocaml code:

  $ caml() {
  >   tmp=$(tempfile)
  >   cat > $tmp.ml
  >   # Get rid of annoying ocamlfind warning
  >   OCAMLFIND_IGNORE_DUPS_IN=~/.opam/$(ocaml -vnum)/lib/ocaml/compiler-libs \
  >   ocamlfind ocamlc regex_notation.cma $tmp.ml -o $tmp \
  >     -ppx ppx_relit \
  >     -package regex_notation \
  >      >/dev/null
  >   $tmp
  > }

Verify we can test OCaml.

  $ caml << END
  > print_endline "Hello world"
  > END
  Hello world

Define a prefix we will include in our tests.

  $ prefix="
  > module Regex = Regex_notation.Regex
  > module RegexTLM = struct
  >   module RelitInternalDefn_regex = struct
  >     type t = Regex.t
  >     module Lexer = Regex_notation.Lexer
  >     module Parser = Regex_notation.Parser (* assume starting non-terminal is called start *)
  >     module Dependencies = struct
  >       module Regex = Regex
  >     end
  >     exception Call of (* error message *) string * (* body *) string
  >   end
  > end
  > "

Basic test to verify that $prefix works

  $ caml << END
  > $prefix 
  > type t = RegexTLM.RelitInternalDefn_regex.t
  > let () = print_int 5
  > END
  5 (no-eol)

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
