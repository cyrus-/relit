open Timeline_example;
open TimelineNotation;

let timeline = $timeline `()`;

let () = print_endline(Timeline.to_string(timeline));
