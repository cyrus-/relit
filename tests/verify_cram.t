
Welcome to a cram file!
Everything not indented is a comment.

This includes some ocaml-specific testing utilities:

  $ . $ORIGINAL_DIR/tests/setup_regex.sh

Verify we can test OCaml.

  $ caml << END
  > print_endline "Hello world"
  > END
  Hello world

Basic test to verify that $prefix imports
the regex notation.

  $ caml << END
  > $prefix
  > type t = RegexTLM.RelitInternalDefn_regex.t
  > let () = print_int 5
  > END
  5 (no-eol)
