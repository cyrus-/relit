let unique_int_state = ref 0
let unique_int () =
  unique_int_state := 1 + !unique_int_state;
  !unique_int_state

let unique_string () = string_of_int (unique_int ())

let tmp_file () = "relit_tmp_" ^ unique_string ()

let write_file f text =
  let out = open_out f in
  Printf.fprintf out "%s" text;
  flush out;
  close_out out

let with_process cmd lambda =
  let p = Unix.open_process cmd in
  let out = lambda p in
  Unix.close_process p |> ignore;
  out

let split_on sep = Str.split (Str.regexp sep)

let command name args =
  let success = Sys.command (name ^ " " ^ args) in
  if success <> 0 then raise (Failure ("bug: " ^ name ^ " failed"))

let lines (out, _) =
  let rec lp out =
    match input_line out with
    | line -> line :: lp out
    | exception End_of_file -> []
  in lp out
