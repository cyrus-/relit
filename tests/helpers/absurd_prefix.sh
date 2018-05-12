
# the function that compiles our ocaml code
. $ORIGINAL_DIR/tests/helpers/caml.sh

# Define a prefix we will include in our tests.

export prefix="
module TLM = struct
  module RelitInternalDefn_regex = struct
    type t = string
    module Lexer = Regex_notation.Absurd_lexer
    module Parser = Regex_notation.Absurd_parser (* assume starting non-terminal is called literal *)
    module Dependencies = struct end
    exception Call of (* error message *) string * (* body *) string
  end
end
"
