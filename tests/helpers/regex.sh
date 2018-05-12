
# the function that compiles our ocaml code
. $ORIGINAL_DIR/tests/helpers/caml.sh

# Define a prefix we will include in our tests.

export prefix="
module Regex = Regex_notation.Regex
module RegexTLM = struct
  module RelitInternalDefn_regex = struct
    type t = Regex.t
    module Lexer = Regex_notation.Lexer
    module Parser = Regex_notation.Parser (* assume starting non-terminal is called literal *)
    module Dependencies = struct
      module Regex = Regex
    end
    exception Call of (* error message *) string * (* body *) string
  end
end
"
