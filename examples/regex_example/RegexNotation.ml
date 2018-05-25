module RelitInternalDefn_regex = struct
  type t = Regex.t
  module Lexer = Lexer
  module Parser = Parser (* assume starting non-terminal is called literal *)
  module Dependencies = struct
    module Regex = Regex
  end
  exception Call of (* error message *) string * (* body *) string
end

