  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure we get an error when the type annotation is inconsistent 

  $ cat $TESTDIR/type_not_in_dependencies.ml | caml
  Warning 20: this argument will not be used by the function.
  1:15: tlm error
  Error: Unbound type constructor fake_type
