  $ . $ORIGINAL_DIR/tests/helpers/absurd_prefix.sh

Can we access variables from generated code?

  $ caml << END
  > $prefix
  > open TLM
  > let x = "hi there"
  > let out =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "x") [@relit])
  > let () = print_endline out;
  > END
  1:2: tlm syntax error
  Error: Unbound value x
