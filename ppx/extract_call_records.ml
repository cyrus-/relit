
open Call_record

module Make_record = struct

  let rec signature_of_md_type env =  function
    | Types.Mty_signature signature -> signature
    | Types.Mty_alias (_, path) -> signature_of_path env path
    | Types.Mty_ident path -> signature_of_path env path
    | modtype ->
      Printtyp.modtype Format.std_formatter modtype;
      raise (Failure "Bug: I haven't seen this come up before.")
  and signature_of_path env path =
    (Env.find_module path env).md_type
    |> Mtype.scrape env
    |> signature_of_md_type env

  let extract_dependencies env signature : dependency list =
    List.map (function
          Types.Sig_module (name,
                            { md_type = Mty_alias (_, path) ; _ }, _) ->
            Module (name, (Env.find_module path env))
        | Types.Sig_type (name, type_declaration, _) ->
            Type (name, type_declaration)
        | _ -> raise (Failure "Dependencies: expected only aliases \
                               in relit definition")
        )
      signature

  type ('a, 'b) either = Left of 'a | Right of 'b

  let of_modtype env path source : t =
    let unwrap = function
      | Left o -> o
      | Right name -> raise
          (Failure ("Unwrap: Malformed relit definition no " ^
                    name ^ " field"))
    in
    let lexer = ref (Right "lexer") in
    let return_type = ref (Right "return_type") in
    let parser = ref (Right "parser") in
    let dependencies = ref (Right "dependencies") in
    let signature = signature_of_path env path in

    List.iter (function
    | Types.Sig_module ({ name = "Lexer" ; _},
                        { md_type = Mty_alias (_, path); _ }, _) ->
      lexer := Left path
    | Types.Sig_module ({ name = "Parser" ; _},
                        { md_type = Mty_alias (_, path); _ }, _) ->
      parser := Left path
    | Types.Sig_module ({ name = "Dependencies" ; _},
                        { md_type = Mty_signature signature; _ }, _) ->
      dependencies := Left (extract_dependencies env signature)
    | Types.Sig_type ({ name = "t" ; _},
                      {type_manifest = Some type_expr}, _) ->
      return_type := Left type_expr
    | _ -> ()
    ) signature ;

    { lexer = unwrap !lexer ;
      parser = unwrap !parser;
      definition_path = path;
      dependencies = unwrap !dependencies;
      return_type = unwrap !return_type;
      env = env;
      source = source }

end

module Call_finder(A : sig
    val call_records : Call_record.t Locmap.t ref
  end) = TypedtreeIter.MakeIterator(struct
    include TypedtreeIter.DefaultIteratorArgument

    let enter_expression expr =
      let open Path in
      let open Typedtree in
      match expr.exp_desc with
      | Texp_apply (
          (* match against the "raise" *)
          { exp_desc = Texp_ident
                (Pdot (Pident { name = "Pervasives" ; _ },
                       "raise", _), _, _) ; _ },
          [(_label,
            Some (
              {exp_attributes = ({txt = "relit"; _}, _) :: _;
               exp_desc = Texp_construct (
                   loc,

                   (* extract the path of our TLM definition
                    * and the relit source of this call. *)
                   { cstr_tag =
                       Cstr_extension (Pdot (path, "Call", _),
                                                _some_bool); _ },
                   _err_info::{
                     exp_desc = Texp_constant
                         Const_string (source, _other_part );
                     exp_env;
                   }::_ ); _ }))]) ->

        let call_record = Make_record.of_modtype exp_env path source in
        A.call_records := Locmap.add expr.exp_loc
                                     call_record
                                     !A.call_records;
      | _ -> ()
  end)

let typecheck structure =
  let open Parsetree in
  let filename =
    (List.hd structure).pstr_loc.Location.loc_start.Lexing.pos_fname in
  let without_extension = Filename.remove_extension filename in
  Compmisc.init_path false;
  let module_name = Compenv.module_of_filename
      Format.std_formatter filename without_extension in
  Env.set_unit_name module_name;
  let initial_env = Compmisc.initial_env () in

  (* typecheck and extract type information *)
  let (typed_structure, _) =
    Typemod.type_implementation filename without_extension module_name
                                initial_env structure in
  typed_structure

let from structure =
    (* initialize the typechecking environment *)
  let typed_structure = typecheck structure  in
  let call_records = ref Locmap.empty in
  let module Call_finder = Call_finder(
    struct let call_records = call_records end) in
  Call_finder.iter_structure typed_structure;
  !call_records
