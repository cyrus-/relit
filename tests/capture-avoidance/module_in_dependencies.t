  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

The TLM should be able to depend on a module in an external package that is explicitly listed in the dependencies.

  $ caml $TESTDIR/module_in_dependencies "-package extlib"
  42 (no-eol)
