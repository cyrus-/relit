open Regex_notation

module DNA = struct
  open RegexTLM
  let any_base =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
end
let () = print_endline (Regex.show DNA.any_base)

