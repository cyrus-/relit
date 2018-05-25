  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ caml $TESTDIR/return_type
  Error: This expression has type int but an expression was expected of type
           string
