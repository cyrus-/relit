open Regex_example;

notation $regex at string {
                            lexer Hi and parser There.literal in this_thing;
                            dependencies = {};
                          };

notation $r = RegexNotation.$regex;

module DNA = {
  notation $regex = $r;
  let any_base =
    $regex `(aa|$( { /* these {}'s are how you chain reasn syntax */
                     /* they aren't necessary for a single expression */
      print_endline("Look at me!!");
      $r `($(Regex.Str("mmm"))xx$( Regex.Str("zzz")) yy)`
    })|bb)`;
};

let () = print_endline(Regex.show(DNA.any_base));
