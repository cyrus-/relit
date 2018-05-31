  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

A spliced expression should evaluate to the same type that the
parser returns for it.

  $ caml $TESTDIR/splice_type
  Error: This expression has type int but an expression was expected of type
           string
