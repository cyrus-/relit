module TestTLM = struct
  (* 
  notation $test at int {
    lexer = Regex_notation.Absurd_lexer
    parser = Regex_notation.Absurd_parser.literal
    expansions require { }
  }
  *)
  module RelitInternalDefn_test = struct
    type t = string
    module Lexer = Regex_notation.Absurd_lexer
    module Parser = Regex_notation.Absurd_parser
    module Dependencies = struct end
    exception Call of string * string
  end
end
open TestTLM

let out = 
  raise (RelitInternalDefn_test.Call ("Forgot ppx...", "number") [@relit]);
  print_endline "Failed"
  
