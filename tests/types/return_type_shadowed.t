  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Should still work when a dependency of the type annotation on the TLM
has been shadowed at the application site.

  $ caml $TESTDIR/return_type_shadowed
  42
