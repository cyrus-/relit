  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

The TLM should not be able to depend on a module it does not list as a dependency.

  $ reason $TESTDIR/module_not_in_dependencies "-package extlib"
  (Failure "This TLM used a dependency it should not have here.")
  Error: Error while running external preprocessor
  
