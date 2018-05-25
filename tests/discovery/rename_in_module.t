  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we rename the TLM definition to a new module... within a functor?

  $ caml $TESTDIR/rename_in_module
  (Or (Or (String a) (String b)) (String c))
