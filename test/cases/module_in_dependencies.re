open Test_example;
open Test_notation;

let x = "hi there";
module Std = {}; /* aliases at the application site should not matter */
let out = $extlib_dep `(module)`;
let () = print_int(42);
