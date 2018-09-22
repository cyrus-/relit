open Regex_example;
open Regex_notation;

module DNA = {
  let any_base = $regex `(a|$(Regex.Str("okay"))|c)`;
};

let () = print_endline(Regex.show(DNA.any_base));
