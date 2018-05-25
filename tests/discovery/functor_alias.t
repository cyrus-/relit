  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we put our definition in a functor and access it
after we instatiate the functor?

  $ caml $TESTDIR/functor_alias
  (Or (Or (String a) (String b)) (String c))

