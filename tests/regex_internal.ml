
(* 
module RegexTLM = {
  notation $regex at Regex.t {
    lexer RegexLexer;
    parser RegexParser;
    expansions require
      module Regex as Regex;
  };
};
*)


module RegexTLM = struct
  module RelitInternalDefn_regex = struct
    type t = Regex.t
    module Lexer = Regex_notation.Lexer
    module Parser = Regex_notation.Parser (* assume starting non-terminal is called start *)
    module Dependencies = struct
      module Regex = Regex
    end
    exception Call of (* error message *) string * (* body *) string
  end
end

(*
module Test1 = {
  open RegexTLM;
  module DNA = {
    let any_base = $regex `(A|T|G|C)`
  };
};
*)

module Test1 = struct
  open RegexTLM
  module DNA = struct
    let any_base =
      raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  end

  let () =
    assert (Regex.to_string DNA.any_base = "((a|b)|c)")

end

module Test2 = struct

  open RegexTLM

  let () =
    let any_base = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Regex.to_string any_base = "(a|b)")

end
