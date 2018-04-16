
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

module Check = struct
  let expect actual expected =
    let success = actual = expected in
    if success
    then print_string "\027[1;36m►\027[0m "
    else print_string "\027[1;31m►\027[0m ";
    print_endline (actual ^ ", " ^ expected);
    success

  let regex r = expect (Regex.to_string r)
end

module Test1 = struct
  open RegexTLM
  module DNA = struct
    let any_base =
      raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  end

  
  let () = assert (Check.regex DNA.any_base "((a|b)|c)")

end

module Test2 = struct

  open RegexTLM

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex "(a|b)")

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a.b|c") [@relit]) in
    assert (Check.regex regex "(a<AnyChar>b|c)")

end
