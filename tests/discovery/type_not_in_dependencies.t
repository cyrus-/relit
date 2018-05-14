  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ cat $ORIGINAL_DIR/tests/discovery/type_not_in_dependencies.ml | caml
  File "{cram test file}", line 7, characters 27-28:
  Warning 20: this argument will not be used by the function.
  1:15: tlm syntax error
  Error: Unbound type constructor fake_type
