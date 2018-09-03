open Regex_example;

module Alias = RegexNotation;

open Alias;

let regex = {
  $regex.(`(a|b|c)`);
};
let () = print_endline(Regex.show(regex));

open notation $regex;
let regex = `(aa|bb|cc)`;
let () = print_endline(Regex.show(regex));
