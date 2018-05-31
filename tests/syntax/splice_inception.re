open Regex_example;

/* define a bad regex */
notation $regex at string {
                            lexer Hi parser There.literal in package this_thing;
                            dependencies = {};
                          };

notation $r = RegexNotation.$regex;

module DNA = {
  notation $regex2 = $r;

  let any_base = {
    notation $regex = $regex2;
    $regex `(aa|$({  /* these {}'s are how you chain reason syntax */
                     /* they aren't necessary for a single expression */
      print_endline("Look at me!!");
      $r `($(Regex.Str("mmm"))xx$(Regex.Str("zzz")) yy)`
    })|bb)`;
  };
};

let () = print_endline(Regex.show(DNA.any_base));
