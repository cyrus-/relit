open Regex_example;

module DNA = {
  open RegexNotation;
  module Regex = {}; /* should not matter */
  let any_base = $regex `(a+|b*c*)`;
};
let () = print_endline(Regex.show(DNA.any_base));
