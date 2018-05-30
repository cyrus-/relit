open Regex_example;

module DNA = {
  open RegexNotation;
  let any_base =
    $regex `(aa|$( { /* these {}'s are how you chain reasn syntax */
                     /* they aren't necessary for a single expression */
      print_endline("Look at me, ma!");
      $regex `($(Regex.Str("mmm"))xx$( Regex.Str("zzz")) yy)`
    })|bb)`;
};

let () = print_endline(Regex.show(DNA.any_base));
