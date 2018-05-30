  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

This test shows off our lexer and parsers:
we can have splices all the way down.

  $ reason $TESTDIR/splice_inception
  Look at me, ma!
  (Or (Or (String aa) (String mmm) ; (String xx) ; (String zzz) ; (String  yy)) (String bb))
