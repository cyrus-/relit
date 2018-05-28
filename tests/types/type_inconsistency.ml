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
    module Lexer = Test_example.Test_lexer
    module Parser = Test_example.Test_parser
    module Dependencies = struct end
    exception Call of string * string
  end
end
open TestTLM

let out = 
  raise (RelitInternalDefn_test.Call ("Forgot ppx...", "number") [@relit]);
  print_endline "Failed"
  
