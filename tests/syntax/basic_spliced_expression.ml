open Regex_example

module DNA = struct
  open RegexNotation
  let any_base =
    raise (RelitInternalDefn_regex.Call
     ("Forgot ppx...", "a|$(Regex.Str(\"okay\"))|c") [@relit])
end
let () = print_endline (Regex.show DNA.any_base)

