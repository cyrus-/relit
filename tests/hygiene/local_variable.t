  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access variables from generated code?

  $ cat $TESTDIR/local_variable.ml | caml
  Error: Unbound value x
