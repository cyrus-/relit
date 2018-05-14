module Regex = Regex
module Lexer = Lexer
module Parser = Parser
module Absurd_lexer = Absurd_lexer
module Absurd_parser = Absurd_parser

module RegexTLM = struct
  module RelitInternalDefn_regex = struct
    type t = Regex.t
    module Lexer = Lexer
    module Parser = Parser (* assume starting non-terminal is called literal *)
    module Dependencies = struct
      module Regex = Regex
    end
    exception Call of (* error message *) string * (* body *) string
  end
end

module AbsurdTLM = struct
  module RelitInternalDefn_regex = struct
    type t = string
    module Lexer = Absurd_lexer
    module Parser = Absurd_parser (* assume starting non-terminal is called literal *)
    module Dependencies = struct
      type new_type = int
    end
    exception Call of (* error message *) string * (* body *) string
  end
end

