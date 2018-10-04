type t =
  | Empty
  | AnyChar
  | Str(string)
  | Seq(t, t)
  | Or(t, t)
  | Star(t);

let rec show = t =>
  switch (t) {
  | Empty => "Empty"
  | Str(str) => "(String \"" ++ str ++ "\")"
  | AnyChar => "Any"
  | Seq(a, b) => show(a) ++ " ; " ++ show(b)
  | Or(a, b) => "(Or " ++ show(a) ++ " " ++ show(b) ++ ")"
  | Star(t) => "(Star " ++ show(t) ++ ")"
  };

let rec eq = (a, b) =>
  switch (a, b) {
  | (Empty, Empty) => true
  | (AnyChar, AnyChar) => true
  | (Str(s), Str(r)) => s == r
  | (Or(a, b), Or(c, d)) => eq(a, c) && eq(b, d)
  | (Seq(a, b), Seq(c, d)) => eq(a, c) && eq(b, d)
  | (Star(a), Star(b)) => eq(a, b)
  | _ => false
  };
