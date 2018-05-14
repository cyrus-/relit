
Welcome to a cram file!
Everything not indented is a comment.

This includes some ocaml-specific testing utilities:

  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Verify we can test OCaml.

  $ caml << END
  > print_endline "Hello world"
  > END
  Hello world

