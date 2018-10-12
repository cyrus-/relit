open Regex_example;

module Obscure = (A: {let x: int;}) => {
  module NotationAlias = {
    include Regex_notation;
  };
  let () = ignore(A.x);
};
module Alias1 =
  Obscure({
    let x = 2;
  });
module Alias2 = Alias1;
module Alias3 = Alias2;
module Alias4 = Alias3;
open Alias4.NotationAlias;
let regex = $regex `(a|b|c)`;
let () = print_endline(Regex.show(regex));
