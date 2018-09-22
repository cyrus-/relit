open Regex_example;

module Funct = (A: {notation $b = Regex_notation.$regex;}) => {
  notation $regex = A.$b;
};

module X =
  Funct({
    notation $b = Regex_notation.$regex;
  });

open X;

let regex = $regex `(a|b|c)`;

let () = print_endline(Regex.show(regex));
