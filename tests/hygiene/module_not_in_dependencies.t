  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can the tlm generate a module it should not have access to?

  $ caml $TESTDIR/module_not_in_dependencies "-package extlib"
  (Failure "This TLM used a dependency it should not have here.")
  Error: Error while running external preprocessor
  
