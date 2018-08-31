
type time = Seconds of int

type event =
  { happened : unit -> unit
  ; at : time }

type t = event list

let rec to_string = function
  | [] -> ""
  | ({at = Seconds i; _})::rest ->
      "(Seconds " ^ string_of_int i ^ ")" ^ to_string rest

let rec execute = function
  | [] -> ()
  | {at = Seconds i; happened = f}::rest ->
      Unix.sleep i;
      f ();
      execute rest
