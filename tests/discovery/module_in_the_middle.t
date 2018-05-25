  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we do the parse in another module?

  $ cat $TESTDIR/module_in_the_middle.ml | caml
  (Or (String a) (String b))

