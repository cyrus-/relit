  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we rename the TLM definition to a new module... within a functor?

  $ cat $TESTDIR/rename_in_module.ml | caml
  (Or (Or (String a) (String b)) (String c))
