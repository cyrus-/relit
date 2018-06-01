open Regex_example;

module Middle = {
  module Regex = {
    /* notice this doesn't shadow Regex */
    let x = 2;
  };
  let parsed = RegexNotation.$regex `(a|b)`;
};
let () = print_endline(Regex.show(Middle.parsed));
