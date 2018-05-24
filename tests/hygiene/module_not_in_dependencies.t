  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access variables from generated code?

  $ cat $TESTDIR/module_not_in_dependencies.ml | caml
  (Failure "This TLM used a dependency it should not have here.")
  Error: Error while running external preprocessor
  
