  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access variables from generated code?

  $ cat $TESTDIR/local_variable.ml | caml
  1:2: tlm error
  Error: Unbound value x
