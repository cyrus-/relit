open Regex_example;
open Test_example;

open Test_example.Test_notation;
let x = "hi there";
type fake_type = int; /* should not matter that this is defined 'correctly' */
let square = $absurd_int_arrow_int `(badly_typed_fn)`;
let () = print_int(square(5));
