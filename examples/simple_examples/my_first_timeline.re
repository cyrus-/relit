open Timeline_example;
open Timeline_notation;

module Timeline_example = {};

let timeline =
  $timeline `(
    0 sec (print_endline("This should print second."))
    2 sec (print_endline("This should print third."))
  )`;

let () = {
  print_endline("This should print first.");
  Timeline.execute(timeline);
};
