  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we pass our TLM to a functor and still use it?

  $ caml $TESTDIR/functor_argument
  (Or (Or (String a) (String b)) (String c))

