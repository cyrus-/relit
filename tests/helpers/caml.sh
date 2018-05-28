caml() {
  # Get rid of annoying ocamlfind warning
  cp $1.ml .
  ocamlbuild "`basename $1`.byte" \
    -quiet \
    -r \
    -cflags "-ppx ppx_relit" \
    -pkg regex_example \
    -pkg test_example \
    | sed '/File .*, line .*:$/d' \
    | grep -v 'Command line: ppx_relit' \
    | grep -v 'File "_none_", line' \
    | grep -v 'Interface topdirs\.cmi occurs in several' \
    | grep -v '/bin/ocamlc.opt' \
    | grep -v '^Command exited with code 2.$'
    # the above are slight hacks to remove random tmp names
  if [ -x "./`basename $1`.byte" ]; then "./`basename $1`.byte"; fi
}
