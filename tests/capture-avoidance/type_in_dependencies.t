  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

The test parser returns an int -> int function on input "typed_fn",
but using the type alias new_type in the dependencies. This should be ok.

  $ caml $TESTDIR/type_in_dependencies
  Warning 20: this argument will not be used by the function.
  25 (no-eol)
