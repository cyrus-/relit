open Regex_example;
open RegexNotation;

module DNA = {
  let any_base = $regex `(a|$(Regex.Str("okay"))|c)`;
};

let () = print_endline(Regex.show(DNA.any_base));
