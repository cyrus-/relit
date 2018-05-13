  $ . $ORIGINAL_DIR/tests/helpers/absurd_prefix.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ caml << END
  > $prefix
  > open TLM
  > let out =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "number") [@relit])
  > END
  File "{cram test file}", line 16, characters 23-26:
  Error: This expression has type int but an expression was expected of type
           string
