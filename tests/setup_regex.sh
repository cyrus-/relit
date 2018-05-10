
# the function that compiles our ocaml code
caml() {
  tmp=$(tempfile)
  cat > $tmp.ml
  # Get rid of annoying ocamlfind warning
  OCAMLFIND_IGNORE_DUPS_IN=~/.opam/$(ocaml -vnum)/lib/ocaml/compiler-libs \
  ocamlfind ocamlc regex_notation.cma $tmp.ml -o $tmp \
    -ppx ppx_relit \
    -package regex_notation \
     >/dev/null
  $tmp
}

# Define a prefix we will include in our tests.

export prefix="
module Regex = Regex_notation.Regex
module RegexTLM = struct
  module RelitInternalDefn_regex = struct
    type t = Regex.t
    module Lexer = Regex_notation.Lexer
    module Parser = Regex_notation.Parser (* assume starting non-terminal is called start *)
    module Dependencies = struct
      module Regex = Regex
    end
    exception Call of (* error message *) string * (* body *) string
  end
end
"
