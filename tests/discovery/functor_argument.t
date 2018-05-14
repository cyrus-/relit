  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we pass our TLM to a functor and still use it?

  $ cat $ORIGINAL_DIR/tests/discovery/functor_argument.ml | caml
  (Or (Or (String a) (String b)) (String c))

