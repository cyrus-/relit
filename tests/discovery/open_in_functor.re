open Regex_example;

module Obscure = (A: {let x: int;}) => {
  module Notation = {
    module Test = {
      let y = A.x;
    };
    module Alias = {
      include RegexNotation;
    };
  };
};
module Ob =
  Obscure({
    let x = 2;
  });
open Ob.Notation.Alias;
let () = {
  let regex = $regex `(a|b)`;
  print_endline(Regex.show(regex));
};
