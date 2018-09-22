open Regex_example;

module DNA = {
  open Regex_notation;
  let any_base = $regex `(a|$(Regex.Str("okay"))|c)`;
};

let () = print_endline(Regex.show(DNA.any_base));
