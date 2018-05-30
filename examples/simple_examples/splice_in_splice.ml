open Regex_example
open RegexNotation

(*
module DNA = {
  let any_base = $regex `(A|T|G|C)`
};

let bisA = $regex `(GC$(DNA.any_base)GC)`;
*)
module DNA = struct
  let any_base =
    raise (RelitInternalDefn_regex.Call
      ("Forgot ppx...",  "A|T|G|C") [@relit])
end

let bisA = raise (RelitInternalDefn_regex.Call
             ("Forgot ppx...", "GC$(DNA.any_base)GC") [@relit])

let () = print_endline (Regex.show bisA)
