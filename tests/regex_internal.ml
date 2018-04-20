
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

module Test3 = struct

  module Alias = RegexTLM
  open Alias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex "(a|b)")

end

module Test4 = struct

  module Funct(A : sig val x : int end) = struct
    module NotationAlias = RegexTLM
  end

  module Alias = Funct(struct let x = 0 end)
  open Alias.NotationAlias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex "(a|b)")

end

module Test5 (* Hard Test *) = struct

  module Obscure(A : sig val x : int end) = struct
    module NotationAlias = struct
      (* module Test = struct let y = A.x end *)
      include RegexTLM
    end
  end

  module Alias1 = Obscure(struct let x = 2 end)
  module Alias2 = Alias1
  module Alias3 = Alias2
  module Alias4 = Alias3


  open Alias4.NotationAlias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex "(a|b)")

end

module Test6 (* Unfortunate Test *) = struct


  module Obscure(A : sig val x : int end) = struct
    module Notation = struct
      module Alias = struct
        include RegexTLM
      end

      module Test = struct let y = A.x end
    end
  end

  module Ob = Obscure(struct let x = 2 end)
  open Ob.Notation.Alias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex "(a|b)")



end
