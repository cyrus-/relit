
type time = Minutes of int | Seconds of int

type event =
  { happened : unit -> unit
  ; at : time }

type t = event list

let rec to_string = function
  | [] -> ""
  | (Minutes i)::rest -> "(Minutes " ^ string_of_int i ^ ")" ^ to_string rest

let execute t = (raise (Failure "unimplemented")) 
