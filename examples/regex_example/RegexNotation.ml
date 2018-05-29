
(*
notation $regex at Regex.t {
  lexer Regex_parser.Lexer and parser Regex_parserParser in regex_example.parser;
  dependencies = {
    module Regex = Regex
  };
}
*)

module RelitInternalDefn_regex = struct
  type t = Regex.t
  module Lexer_Regex_parser__RelitInternal_dot__Lexer = struct end
  module Parser_Regex_parser__RelitInternal_dot__Parser = struct end
  module Package_regex_parser = struct end
  module Dependencies = struct
    module Regex = Regex
  end
  exception Call of (* error message *) string * (* body *) string
end
