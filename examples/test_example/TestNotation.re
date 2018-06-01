notation $absurd_int at int {
  lexer Test_parser.Lexer 
  parser Test_parser.Parser.literal 
  in package test_parser;
  dependencies = {
   type new_type = int;
 };
};

notation $absurd_int_arrow_int at int => int {
  lexer Test_parser.Lexer 
  parser Test_parser.Parser.literal 
  in package test_parser;
  dependencies = {
    type new_type = int;
  };
};

notation $extlib_nodep at int {
  lexer Test_parser.Lexer 
  parser Test_parser.Parser.literal 
  in package test_parser;
  dependencies = {
    type new_type = int;
  };
};

notation $extlib_dep at int {
  lexer Test_parser.Lexer 
  parser Test_parser.Parser.literal 
  in package test_parser;
  dependencies = {
    type new_type = int;
    module Std = Std;
  };
};

module TestModule = {
  type t = int;
};

notation $local_nodep at TestModule.t {
  lexer Test_parser.Lexer 
  parser Test_parser.Parser.literal 
  in package test_parser;
  dependencies = {
    type new_type = int;
    module Std = Std;
  };
};

