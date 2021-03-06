open Runner

(*
 * Capture Avoidence
 * =================
 *)

let%expect_test "local_variable" =
  compile_and_run ~name:"local_variable";
  [%expect{|
    File "test/cases/local_variable.re", line 5, characters 10-23:
    Error: Unbound value x |}]

let%expect_test "module_not_in_dependencies" =
  compile_and_run ~name:"module_not_in_dependencies";
  [%expect{|
    This TLM depends on the following module that it did not have access to: Std
    File "test/cases/module_not_in_dependencies.re", line 1:
    Error: Error while running external preprocessor |}]

let%expect_test "module_in_dependencies" =
  compile_and_run ~name:"module_in_dependencies";
  [%expect{| 42 |}]

let%expect_test "type_t_not_in_dependencies" =
  compile_and_run ~name:"type_t_not_in_dependencies";
  [%expect{|
    File "test/cases/type_t_not_in_dependencies.re", line 5, characters 13-48:
    Error: Unbound type constructor t |}]

let%expect_test "type_not_in_dependencies" =
  compile_and_run ~name:"type_not_in_dependencies";
  [%expect{|
    File "test/cases/type_not_in_dependencies.re", line 7, characters 13-53:
    Error: Unbound type constructor fake_type |}]

let%expect_test "type_in_dependencies" =
  compile_and_run ~name:"type_in_dependencies";
  [%expect{| 25 |}]

(*
 * Discovery
 * =========
 *)

let%expect_test "alias" =
  compile_and_run ~name:"alias";
  [%expect{| (Or (Or (String "a") (String "b")) (String "c")) |}]

let%expect_test "many_aliases" =
  compile_and_run ~name:"many_aliases";
  [%expect{| (Or (Or (String "a") (String "b")) (String "c")) |}]

let%expect_test "module_shadowing" =
  compile_and_run ~name:"module_shadowing";
  [%expect{| (Or (String "a") (String "b")) |}]

let%expect_test "functor_alias" =
  compile_and_run ~name:"functor_alias";
  [%expect{| (Or (Or (String "a") (String "b")) (String "c")) |}]

let%expect_test "functor_argument" =
  compile_and_run ~name:"functor_argument";
  [%expect{| (Or (Or (String "a") (String "b")) (String "c")) |}]

let%expect_test "open" =
  compile_and_run ~name:"open";
  [%expect{|
    (Or (Or (String "a") (String "b")) (String "c"))
    (Or (Or (String "aa") (String "bb")) (String "cc")) |}]

let%expect_test "parsed_in_functor" =
  compile_and_run ~name:"parsed_in_functor";
  [%expect{| (Or (String "a") (String "b")) |}]

let%expect_test "open_in_functor" =
  compile_and_run ~name:"open_in_functor";
  [%expect{| (Or (String "a") (String "b")) |}]

(*
 * Syntax
 * ======
 *)

let%expect_test "basic_spliced_expression" =
  compile_and_run ~name:"basic_spliced_expression";
  [%expect{| (Or (Or (String "a") (String "okay")) (String "c")) |}]

let%expect_test "invalid_splice_bounds" =
  compile_and_run ~name:"invalid_splice_bounds";
  [%expect{|
    Invalid_segmentation (Out_of_bounds seg)
    File "test/cases/invalid_splice_bounds.re", line 1:
    Error: External preprocessor does not produce a valid file |}]

let%expect_test "invalid_splice_overlap" =
  compile_and_run ~name:"invalid_splice_overlap";
  [%expect{|
    File "test/cases/invalid_splice_overlap.re", line 2, characters 10-44:
    Warning 10: this expression should have type unit.
    Invalid_segmentation (Bad_separation (seg1, seg2))
    File "test/cases/invalid_splice_overlap.re", line 2, characters 10-44:
    Error: This expression has type int but an expression was expected of type
             unit
           because it is in the left-hand side of a sequence |}]

let%expect_test "most_basic_app" =
  compile_and_run ~name:"most_basic_app";
  [%expect{| (Or (String "a") ; (Star (String "a")) (Star (String "b")) ; (Star (String "c"))) |}]

let%expect_test "reason_spliced_expression" =
  compile_and_run ~name:"reason_spliced_expression";
  [%expect{| (Or (Or (String "a") (String "okay")) (String "c")) |}]

let%expect_test "splice_inception" =
  compile_and_run ~name:"splice_inception";
  [%expect{|
    Look at me!!
    (Or (Or (String "aa") (String "mmm") ; (String "xx") ; (String "zzz") ; (String " yy")) (String "bb")) |}]


(*
 * Types
 * =====
 *)

let%expect_test "effects" =
  compile_and_run ~name:"effects";
  [%expect{| (Seconds 2)(Seconds 4) |}]

let%expect_test "splice_effects" =
  compile_and_run ~name:"splice_effects";
  [%expect{|
    Look at me!!
    (Or (Or (String "aa") (String "mmm") ; (String "xx") ; (String "zzz") ; (String " yy")) (String "bb")) |}]

let%expect_test "return_type" =
  compile_and_run ~name:"return_type";
  [%expect{|
    File "test/cases/return_type.re", line 4, characters 23-26:
    Error: This expression has type int but an expression was expected of type
             string |}]

let%expect_test "splice_type" =
  compile_and_run ~name:"splice_type";
  [%expect{|
    File "", line 1, characters 0-1:
    Error: This expression has type int but an expression was expected of type
             string |}]

let%expect_test "return_type_shadowed" =
  compile_and_run ~name:"return_type_shadowed";
  [%expect{| 42 |}]

let%expect_test "type_inconsistency" =
  compile_and_run ~name:"type_inconsistency";
  [%expect{|
    File "test/cases/type_inconsistency.re", line 12, characters 2-18:
    Error: This expression has type int but an expression was expected of type
             string |}]

let%expect_test "figure_3c" =
  compile_and_run ~name:"figure_3c";
  [%expect{| (String "GC") ; (Or (Or (Or (String "A") (String "T")) (String "G")) (String "C")) ; (String "GC") ; (Star (Or (Or (Or (String "A") (String "T")) (String "G")) (String "C"))) ; (String "AAAA") ; (Star (Or (Or (Or (String "A") (String "T")) (String "G")) (String "C"))) ; (String "GC") ; (Or (Or (Or (String "A") (String "T")) (String "G")) (String "C")) ; (String "GC") |}]
