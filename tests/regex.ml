type t = Empty | AnyChar | Str of string | Seq of t * t | Or of t * t | Star of t

let rec eq a b = match (a, b) with
  | (Empty, Empty) -> true
  | (AnyChar, AnyChar) -> true
  | (Str s, Str r) -> s = r
  | (Or (a, b), Or (c, d)) -> (eq a c) && (eq b d)
  | (Seq (a, b), Seq (c, d)) -> (eq a c) && (eq b d)
  | (Star a, Star b) -> eq a b
  | _ -> false
