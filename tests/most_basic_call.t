  $ . $ORIGINAL_DIR/tests/setup_regex.sh

A simple call to a Relit TLM

  $ caml << END
  > $prefix
  > module DNA = struct
  >   open RegexTLM
  >   let any_base =
  >   raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  > end
  > let () = print_endline (Regex.show DNA.any_base)
  > END
  (Or (Or (String a) (String b)) (String c))
