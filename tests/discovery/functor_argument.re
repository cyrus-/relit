open Regex_example;

module Funct = (A: {notation $b = RegexNotation.$regex;}) => {
  notation $regex = A.$b;
};

module X =
  Funct({
    notation $b = RegexNotation.$regex;
  });

open X;

let regex = $regex `(a|b|c)`;

let () = print_endline(Regex.show(regex));
