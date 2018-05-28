module RelitInternalDefn_absurd_int = struct
  type t = int
  module Lexer = Test_lexer
  module Parser = Test_parser (* assume starting non-terminal is called literal *)
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end

module RelitInternalDefn_absurd_int_arrow_int = struct
  type t = int -> int
  module Lexer = Test_lexer
  module Parser = Test_parser (* assume starting non-terminal is called literal *)
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end

module RelitInternalDefn_absurd_cons = struct
  type t = int -> int list -> int list
  module Lexer = Test_lexer
  module Parser = Test_parser (* assume starting non-terminal is called literal *)
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end
