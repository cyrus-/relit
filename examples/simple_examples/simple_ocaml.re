open Regex_example;

let regex = RegexNotation.$regex `(a|b|c)`;

let () = print_endline(Regex.show(regex));
