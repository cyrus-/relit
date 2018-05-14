  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we put our definition in a functor and access it
after we instatiate the functor?

  $ cat $ORIGINAL_DIR/tests/discovery/functor_alias.ml | caml
  (Or (Or (String a) (String b)) (String c))

