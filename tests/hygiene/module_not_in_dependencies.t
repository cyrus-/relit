  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we access variables from generated code?

  $ cat $ORIGINAL_DIR/tests/hygiene/module_not_in_dependencies.ml | caml
  (Failure "This TLM used a dependency it should not have here.")
  Error:1:7: tlm syntax error
  File "{cram test file}", line 1:
  Error: Error while running external preprocessor
  
