open Test_example.TestNotation
let out =
  raise (RelitInternalDefn_absurd_int.Call
    ("Forgot ppx...", "bad_splice_overlap") [@relit])
let () = print_endline (string_of_int out)

