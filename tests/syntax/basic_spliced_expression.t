  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

A simple call to a Relit TLM

  $ cat $TESTDIR/basic_spliced_expression.ml | caml
  (Or (Or (String a) (String okay)) (String c))
