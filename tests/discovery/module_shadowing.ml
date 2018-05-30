open Regex_example

module Middle = struct
  module Regex = struct (* notice this doesn't shadow Regex *)
    let x = 2
  end
  let parsed = raise (RegexNotation.RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b") [@relit])
end
let () = print_endline (Regex.show Middle.parsed)
