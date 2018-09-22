open Regex_example;

open Test_example.Test_notation;
type new_type = string; /* should not matter what this is */
let square = $absurd_int_arrow_int `(typed_fn)`;
let () = print_int(square(5));
