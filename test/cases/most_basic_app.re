open Regex_example;

module DNA = {
  open Regex_notation;
  module Regex = {}; /* should not matter */
  let any_base = $regex `(a+|b*c*)`;
};
let () = print_endline(Regex.show(DNA.any_base));
