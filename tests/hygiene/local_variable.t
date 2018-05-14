  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access variables from generated code?

  $ cat $ORIGINAL_DIR/tests/hygiene/local_variable.ml | caml
  1:2: tlm syntax error
  Error: Unbound value x
