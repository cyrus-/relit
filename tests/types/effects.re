open Timeline_example;
open TimelineNotation;
let timeline =
  $timeline `(

  2 sec
  (print_endline("hi there"))
  4 sec
  (print_endline("Awesome"))

  )`;
let () = print_endline(Timeline.to_string(timeline));
