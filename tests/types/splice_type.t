  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure the splices are type checked.

  $ caml $TESTDIR/splice_type
  Error: This expression has type int but an expression was expected of type
           string
