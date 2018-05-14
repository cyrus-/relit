  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ cat $TESTDIR/type_in_dependencies.ml | caml
  Warning 20: this argument will not be used by the function.
  25 (no-eol)
