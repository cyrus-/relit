  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

A simple call to a Relit TLM

  $ cat $TESTDIR/most_basic_call.ml | caml
  (Or (Or (String a) (String b)) (String c))
