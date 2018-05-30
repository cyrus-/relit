module TestTLM = struct
  (* 
  notation $test at int {
    lexer = Regex_example.Absurd_lexer
    parser = Regex_example.Absurd_parser.literal
    expansions require { }
  }
  *)
  module RelitInternalDefn_test = struct
    type t = string
    module Lexer_Test_parser__RelitInternal_dot__Lexer = struct end
    module Parser_Test_parser__RelitInternal_dot__Parser = struct end
    module Package_test_parser = struct end
    module Nonterminal_literal = struct end
    module Dependencies = struct end
    exception Call of string * string
  end
end
open TestTLM

let out = 
  raise (RelitInternalDefn_test.Call ("Forgot ppx...", "number") [@relit]);
  print_endline "Failed"
  
