open Regex_example;

module DNA = {
  open Regex_notation;
  module R = Regex;
  module Regex = {};
  let any_base = $regex `(a|$(R.Str("okay"))|c)`;
};
let () = print_endline(Regex.show(DNA.any_base));
