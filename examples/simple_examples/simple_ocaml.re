open Regex_example;

let regex = Regex_notation.$regex `(a|b|c)`;

let () = print_endline(Regex.show(regex));
