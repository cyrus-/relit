open Regex_example;

/* lol, a strange thing to do since the type annotation for the notation
   must be exactly the notation that you pass in but you can still do it!  */
module Funct = (A: {notation $b = Regex_notation.$regex;}) => {
  let regex = A.$b `(a|b)`;
};

module X =
  Funct({
    notation $b = Regex_notation.$regex;
  });

open X;

let () = print_endline(Regex.show(regex));
