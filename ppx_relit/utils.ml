let unique_int_state = ref 0
let unique_int () =
  unique_int_state := 1 + !unique_int_state;
  !unique_int_state

let unique_string () = string_of_int (unique_int ())

let tmp_file () = "relit_tmp_" ^ unique_string ()

let write_file f text =
  let out = open_out f in
  Printf.fprintf out "%s" text;
  flush out;
  close_out out

let with_process cmd lambda =
  let p = Unix.open_process cmd in
  let out = lambda p in
  Unix.close_process p |> ignore;
  out

let split_on sep = Str.split (Str.regexp sep)

let command name c =
  let success = Sys.command c in
  if success <> 0 then raise (Failure ("bug: " ^ name ^ " failed"))

let has_prefix ~prefix str =
  String.sub (Ident.name str) 0 (String.length prefix) = prefix

let remove_prefix ~prefix str =
  let plen = String.length prefix in
  String.sub (Ident.name str) plen (String.length (Ident.name str) - plen)

let add_type_assertion expected_type parsetree =
  Ast_helper.Exp.constraint_ parsetree expected_type

let rec lident_of_path path =
  let open Path in
  let open Longident in
  match path with
  | Pident ident -> Lident (Ident.name ident)
  | Pdot (rest, name, _) -> Ldot (lident_of_path rest, name)
  | Papply (a, b) -> Lapply (lident_of_path a, lident_of_path b)

let maybe_print f x =
  let parsetree = f x in
  match Sys.getenv_opt "RELIT_DEBUG" with
  | Some "true" ->
      Reason_pprint_ast.configure ~width:80
        ~assumeExplicitArity:true ~constructorLists:[];
      (Reason_pprint_ast.createFormatter ())#structure
        [] Format.err_formatter
        (Convert.From_current.copy_structure parsetree);
      parsetree
  | _ -> parsetree
