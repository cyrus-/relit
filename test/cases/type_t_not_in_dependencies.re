open Regex_example;
open Test_example;

open Test_example.Test_notation;
let square = $absurd_int_arrow_int `(type_t_fn)`;
let () = print_int(square(5));
