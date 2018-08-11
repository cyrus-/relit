module TestTLM = {
  notation $test at string {
    lexer Test_parser.Lexer
    parser Test_parser.Parser.literal
    in package test_parser;
    dependencies = {};
  };
};
open TestTLM;

let out = {
  $test `(number)`;
  print_endline("Failed");
};
