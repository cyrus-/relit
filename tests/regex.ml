type t = Empty | AnyChar | Str of string | Seq of t * t | Or of t * t | Star of t

let rec to_string r = match r with
  | Empty -> "<Empty>"
  | AnyChar -> "<AnyChar>"
  | Str s -> s
  | Or (a, b) -> "(" ^ to_string a ^ "|" ^ to_string b ^ ")"
  | Seq (a, b) -> to_string a ^ to_string b
  | Star a -> to_string a ^ "*"
