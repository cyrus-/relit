  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access the TLM through a module synonym before applying it?

  $ reason $TESTDIR/alias
  (Or (Or (String a) (String b)) (String c))
