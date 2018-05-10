
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

module R = Regex_notation.Regex


module RegexTLM = struct
  module RelitInternalDefn_regex = struct
    type t = Regex_notation.Regex.t
    module Lexer = Regex_notation.Lexer
    module Parser = Regex_notation.Parser (* assume starting non-terminal is called start *)
    module Dependencies = struct
      module Regex = Regex_notation.Regex
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
  let expect eq a b =
    let success = eq a b in
    if success
    then print_string "\027[1;36m►\027[0m "
    else print_string "\027[1;31m►\027[0m ";
    success
  let regex = expect R.eq
end

module Test1 = struct
  open RegexTLM
  module DNA = struct
    let any_base =
      raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
  end


  let () = assert (Check.regex DNA.any_base (R.Or (R.Or (R.Str "a", R.Str "b"), R.Str "c")))

end

module Test2 = struct

  open RegexTLM

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", ".b|c") [@relit]) in
    assert (Check.regex regex (R.Or (R.Seq (R.AnyChar, R.Str "b"), R.Str "c")))

end

module Test3 = struct

  module Alias = RegexTLM
  open Alias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

end

module Test4 = struct

  module Funct(A : sig val x : int end) = struct
    module NotationAlias = RegexTLM
  end

  module Alias = Funct(struct let x = 0 end)
  open Alias.NotationAlias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

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
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

end

module Test6 = struct


  module Obscure(A : sig val x : int end) = struct
    module Notation = struct
      module Test = struct let y = A.x end
      module Alias = struct
        include RegexTLM
      end
    end
  end

  module Ob = Obscure(struct let x = 2 end)
  open Ob.Notation.Alias

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))



end

module Test7 = struct

  module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
    module RelitInternalDefn_regex = A.B
  end

  module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
  open X

  let () =
    let regex = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

end

module Test8 = struct

  module Funct(A : sig val x : int end) = struct
    module NotationAlias = RegexTLM.RelitInternalDefn_regex
  end

  module Alias = Funct(struct let x = 0 end)
  open Alias

  let () =
    let regex = raise (NotationAlias.Call ("Forgot ppx...", "a|b") [@relit]) in
    assert (Check.regex regex (R.Or (R.Str "a", R.Str "b")))

end

module Test9 = struct

  module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
    let parsed = raise (A.B.Call ("Forgot ppx...", "a|b") [@relit])
  end

  module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
  open X

  let () =
    assert (Check.regex parsed (R.Or (R.Str "a", R.Str "b")))

end

module Test10 = struct

  module Middle = struct
    module Regex = struct
      let x = 2
    end
    let parsed = raise (RegexTLM.RelitInternalDefn_regex.Call ("Forgot ppx...", "a<>b") [@relit])
  end

  let () =
    assert (Check.regex Middle.parsed (R.Empty))

end
