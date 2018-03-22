type t = AnyChar | Str of string | Seq of t * t | Or of t * t | Star of t
