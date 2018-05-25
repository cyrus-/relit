  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure we get an error when the type annotation is inconsistent 

  $ caml $TESTDIR/type_inconsistency
  Warning 21: this statement never returns (or has an unsound type.)
  (Failure "parser returned wrong type")
  Error: Error while running external preprocessor
  
