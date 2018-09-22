open Regex_example;

module Funct = (A: {let x: int;}) => {
  module NotationAlias = Regex_notation;
};
module M =
  Funct({
    let x = 0;
  });
open M.NotationAlias;
let regex = $regex `(a|b|c)`;
let () = print_endline(Regex.show(regex));
