caml() {
  tmp=$(mktemp /tmp/cram.XXXXXXX)
  cat > $tmp.ml
  # Get rid of annoying ocamlfind warning
  ocamlfind ocamlc regex_notation.cma $tmp.ml -o $tmp \
    -ppx ppx_relit \
    -package regex_notation \
    2>&1 \
    | sed 's/\/tmp\/cram.*\.ml/\{cram test file\}/g' \
    | grep -v 'Command line: ppx_relit' \
    | grep -v 'Interface topdirs\.cmi occurs in several'
    # the above are slight hacks to remove random tmp names
  if [ -x "$tmp" ]; then "$tmp"; fi
}
