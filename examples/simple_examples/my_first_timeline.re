open Timeline_example;
open TimelineNotation;

let timeline =
  $timeline `(
    0 sec (print_endline("This should print second."))
    2 sec (print_endline("This should print third."))
  )`;

let () = {
  print_endline("This should print first.");
  Timeline.execute(timeline);
};
