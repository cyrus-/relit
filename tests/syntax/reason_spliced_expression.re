open Regex_example;

module DNA = {
  open RegexNotation;
  let any_base = $regex `(a|$(Regex.Str("okay"))$|c)`;
};

let () = print_endline(Regex.show(DNA.any_base));
