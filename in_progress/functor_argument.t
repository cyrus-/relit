  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we pass the TLM definition through a functor and still apply it?

  $ reason $TESTDIR/functor_argument
  (Or (Or (String a) (String b)) (String c))
