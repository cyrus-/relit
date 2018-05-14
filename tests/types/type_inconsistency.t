  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure we get an error when the type annotation is inconsistent 

  $ cat $TESTDIR/type_inconsistency.ml | caml
  Warning 21: this statement never returns (or has an unsound type.)
  (Failure "parser returned wrong type")
  1:7: tlm error
  Error: Error while running external preprocessor
  
