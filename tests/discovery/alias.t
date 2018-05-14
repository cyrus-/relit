  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we store the definition in an alias before opening it?

  $ cat $TESTDIR/alias.ml | caml
  (Or (Or (String a) (String b)) (String c))
