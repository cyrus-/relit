type t = Empty | AnyChar
       | Str of string | Seq of t * t
       | Or of t * t | Star of t

let rec show t = match t with
  | Empty -> "Empty"
  | Str str -> "(String " ^ str ^ ")"
  | AnyChar -> "Any"
  | Seq (a, b) -> show a ^ " ; " ^ show b
  | Or (a, b) -> "(Or " ^ show a ^ " " ^ show b ^ ")"
  | Star t -> "(Star " ^ show t ^ ")"

let rec eq a b = match (a, b) with
  | (Empty, Empty) -> true
  | (AnyChar, AnyChar) -> true
  | (Str s, Str r) -> s = r
  | (Or (a, b), Or (c, d)) -> (eq a c) && (eq b d)
  | (Seq (a, b), Seq (c, d)) -> (eq a c) && (eq b d)
  | (Star a, Star b) -> eq a b
  | _ -> false
