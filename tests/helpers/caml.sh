caml() {
  # Get rid of annoying ocamlfind warning
  echo $TESTDIR;
  echo ocamlbuild -I "$TESTDIR" "$1.byte" \
    -cflags "-ppx ppx_relit" \
    -pkg regex_example \
    -pkg test_example \
    2>&1 \
    | sed '/File .*, line .*:$/d' \
    | grep -v 'Command line: ppx_relit' \
    | grep -v 'File "_none_", line' \
    | grep -v 'Interface topdirs\.cmi occurs in several'
    # the above are slight hacks to remove random tmp names
  if [ -x "$1.byte" ]; then "$1.byte"; fi
}
