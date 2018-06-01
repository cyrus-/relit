notation $regex at Regex.t {
  lexer Regex_parser.Lexer
  parser Regex_parser.Parser.start 
  in package regex_parser;
  dependencies = {
    module Regex = Regex;
  };
};

