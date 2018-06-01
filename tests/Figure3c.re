open Regex_example;

notation $regex = RegexNotation.$regex;
module DNA = { let any_base = $regex `(A|T|G|C)`; };
let bisA = $regex `(GC$(DNA.any_base)GC)`;
let restriction_template = (gene) => 
  $regex `($(bisA)$(DNA.any_base)$(DNA.any_base)$(bisA))`;

print_endline(Regex.show(restriction_template("AAAA")));

