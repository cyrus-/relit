caml() {
  tmp=$(tempfile)
  cat > $tmp.ml
  # Get rid of annoying ocamlfind warning
  OCAMLFIND_IGNORE_DUPS_IN=~/.opam/$(ocaml -vnum)/lib/ocaml/compiler-libs \
  ocamlfind ocamlc regex_notation.cma $tmp.ml -o $tmp \
    -ppx ppx_relit \
    -package regex_notation \
    2>&1 \
    | sed 's/\/tmp\/cramtests.*\/file\w*/\{cram test file\}/g' \
    | sed 's/\/tmp\/cramtests.*\/camlppx\w*/\{cram test file\}/g'
    # the above are slight hacks to remove random tmp names
  if [ -x "$tmp" ]; then "$tmp"; fi
}
