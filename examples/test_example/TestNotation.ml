module RelitInternalDefn_absurd_int = struct
  type t = int
  module Lexer_Test_parser__RelitInternal_dot__Lexer = struct end
  module Parser_Test_parser__RelitInternal_dot__Parser = struct end
  module Package_test_parser = struct end
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end

module RelitInternalDefn_absurd_int_arrow_int = struct
  type t = int -> int
  module Lexer_Test_parser__RelitInternal_dot__Lexer = struct end
  module Parser_Test_parser__RelitInternal_dot__Parser = struct end
  module Package_test_parser = struct end
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end

module RelitInternalDefn_extlib_nodep = struct
  type t = int -> int list -> int list
  module Lexer_Test_parser__RelitInternal_dot__Lexer = struct end
  module Parser_Test_parser__RelitInternal_dot__Parser = struct end
  module Package_test_parser = struct end
  module Dependencies = struct
    type new_type = int
  end
  exception Call of (* error message *) string * (* body *) string
end

module RelitInternalDefn_extlib_dep = struct
  type t = int -> int list -> int list
  module Lexer_Test_parser__RelitInternal_dot__Lexer = struct end
  module Parser_Test_parser__RelitInternal_dot__Parser = struct end
  module Package_test_parser = struct end
  module Dependencies = struct
    type new_type = int
    module Std = Std
  end
  exception Call of (* error message *) string * (* body *) string
end
