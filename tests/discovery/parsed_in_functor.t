  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Can we pass the TLM definition as an argument to
a functor directly, changing what the call will look like?

  $ cat $ORIGINAL_DIR/tests/discovery/parsed_in_functor.ml | caml
  (Or (String a) (String b))
