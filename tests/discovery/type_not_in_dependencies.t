  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure we get an error when the type annotation is inconsistent 

  $ caml $TESTDIR/type_not_in_dependencies
  Warning 20: this argument will not be used by the function.
  Error: Unbound type constructor fake_type
