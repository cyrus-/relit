(* testing MetaOCaml *)

(* installation instructions

  $ opam update
  $ opam switch 4.04.0+BER
  $ eval `opam config env`

then you can run 

  $ metaocaml MetaOCamlTest.ml

or use the compiler

  $ metaocamlc MetaOCamlTest.ml -o MetaOCamlTest.out
  $ ./MetaOCamlTest.out

The result should be the printed AST. *)

let x = Regex.Empty;;

let code_Empty = .<x>.;;
let code_AnyChar = .<Regex.AnyChar>.;;
let code_Str s = .<Regex.Str s>.;;
let code_Seq e1 e2 = .<Regex.Seq (.~e1, .~e2)>.;;
let code_Or e1 e2 = .<Regex.Or (.~e1, .~e2)>.;;
let code_Star e1 = .<Regex.Star .~e1>.;;

(* let to_ast (e : Regex.t code) = Print_code.close_code e;;

let test1 = code_Or (code_Str "test1") (code_Str "test2");;
Print_code.print_code_as_ast (to_ast test1);;
*)
