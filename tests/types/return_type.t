  $ . $ORIGINAL_DIR/tests/helpers/absurd_prefix.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ caml << END
  > $prefix
  > open TLM
  > let x = "hi there"
  > let out =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "number") [@relit])
  > let () = print_endline out;
  > END
  File "{cram test file}.ml", line 16, characters 23-26:
  Error: This expression has type int but an expression was expected of type
           string
