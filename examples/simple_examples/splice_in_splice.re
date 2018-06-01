open Regex_example;
open RegexNotation;

/*
 module DNA = {
   let any_base = $regex `(A|T|G|C)`
 };

 let bisA = $regex `(GC$(DNA.any_base)GC)`;
 */
module DNA = {
  let any_base = $regex `(A|T|G|C)`;
};

let bisA = $regex `(GC$(DNA.any_base)GC)`;

let () = print_endline(Regex.show(bisA));
