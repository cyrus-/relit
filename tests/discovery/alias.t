  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we store the definition in an alias before opening it?

  $ cat $ORIGINAL_DIR/tests/discovery/alias.ml | caml
  (Or (Or (String a) (String b)) (String c))
