open Test_example.TestNotation;
let x = "hi there";
type t' = TestModule.t;
module TestModule = {
  type t = string;
};
let out = $local_nodep `(number)`;
let () = print_endline("42");
