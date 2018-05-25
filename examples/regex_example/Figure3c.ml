module RelitInternalDefn_regex = RegexNotation.RelitInternalDefn_regex
module DNA = struct
  let any_base = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "A|T|G|C") [@relit])
end
let bisA = raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "GC$(DNA.any_base)GC") [@relit])
let restriction_template gene = 
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "$(bisA)$(DNA.any_base)*$$(gene)$(DNA.any_base)*$(bisA)") [@relit])
