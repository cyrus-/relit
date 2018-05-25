  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we include the TLM inside a module inside a functor
and then open an instance of that functor?

  $ cat $TESTDIR/open_in_functor.ml | caml
  (Or (String a) (String b))
