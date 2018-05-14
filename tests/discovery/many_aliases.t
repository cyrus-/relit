  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we include the TLM in a different module and
use that one? Along with some aliases and a functor...

  $ cat $TESTDIR/many_aliases.ml | caml
  (Or (Or (String a) (String b)) (String c))
