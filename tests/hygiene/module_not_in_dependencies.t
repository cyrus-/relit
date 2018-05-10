  $ . $ORIGINAL_DIR/tests/helpers/absurd_prefix.sh

Can we access variables from generated code?

  $ caml << END
  > $prefix
  > open TLM
  > let x = "hi there"
  > let out =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "module") [@relit])
  > let () = print_endline out;
  > END
  (Failure "This TLM used a dependency it should not have here.")
  File "_none_", line 1:
  Error:1:7: tlm syntax error
  File "{cram test file}.ml", line 1:
  Error: Error while running external preprocessor
  Command line: ppx_relit '{cram test file}'
  
