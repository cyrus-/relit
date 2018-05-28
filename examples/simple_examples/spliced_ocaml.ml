open Regex_example
open RegexNotation

module DNA = struct
  let any_base =
    raise (RelitInternalDefn_regex.Call
             ("Forgot ppx...", "a|$( raise([@relit] RelitInternalDefn_regex.Call(\"Forgot ppx...\", \"d|e\")) )$|c")) [@relit])
end
let () = print_endline (Regex.show DNA.any_base)
