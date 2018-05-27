  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can the tlm generate a module it should have access to?

  $ cat $TESTDIR/module_in_dependencies.ml | caml -package extlib
  (Failure "parser returned wrong type")
  Error: Error while running external preprocessor
