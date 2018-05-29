build() {
  $3 "`basename $1`.byte" $2 \
    -quiet \
    -r \
    -cflags "-ppx ppx_relit" \
    -pkg regex_example \
    -pkg test_example \
    | sed '/File .*, line .*:$/d' \
    | grep -v 'Command line: ppx_relit' \
    | grep -v 'File "_none_", line' \
    | grep -v 'Interface topdirs\.cmi occurs in several' \
    | grep -v 'ocamlc.opt -c -ppx ppx_relit' \
    | grep -v 'ocamlfind ocaml' \
    | grep -v '^Command exited with code 2.$'
    # the above are slight hacks to remove random tmp names
  if [ -x "./`basename $1`.byte" ]; then "./`basename $1`.byte"; fi
}

caml() {
  cp $1.ml .
  build "$1" "$2" ocamlbuild
}

reason () {
  cp $1.re .
  build "$1" "$2" rebuild
}
