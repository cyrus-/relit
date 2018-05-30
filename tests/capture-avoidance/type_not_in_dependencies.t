  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure we get an error when using a type that is not given in the dependencies,
but that is defined at the application site as would be necessary.

  $ caml $TESTDIR/type_not_in_dependencies
  Warning 20: this argument will not be used by the function.
  Error: Unbound type constructor fake_type
