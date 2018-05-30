open Regex_example

module DNA = struct
  open RegexNotation
  module R = Regex
  module Regex = struct end 
  let any_base =
    raise (RelitInternalDefn_regex.Call
     ("Forgot ppx...", "a|$(R.Str(\"okay\"))|c") [@relit])
end
let () = print_endline (Regex.show DNA.any_base)

