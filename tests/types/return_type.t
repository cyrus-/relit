  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ cat $ORIGINAL_DIR/tests/types/return_type.ml | caml
  File "{cram test file}", line 7, characters 23-26:
  Error: This expression has type int but an expression was expected of type
           string
