  $ . $ORIGINAL_DIR/tests/helpers/absurd_prefix.sh

This parser returns an integer on input "number",
which is expected to be a string in this context.

  $ caml << END
  > $prefix
  > open TLM
  > let x = "hi there"
  > let square =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "badly_typed_fn") [@relit])
  > let () = print_int (square 5)
  > END
  File "{cram test file}", line 18, characters 27-28:
  Warning 20: this argument will not be used by the function.
  1:15: tlm syntax error
  Error: Unbound type constructor fake_type
