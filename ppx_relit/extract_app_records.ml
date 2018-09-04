
open App_record

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
        | Types.Sig_module (name,
                            { md_type = Mty_alias (_, path) ; _ }, _) ->
            Module (name, (Env.find_module path env))
        | Types.Sig_type (name, type_declaration, _) ->
            Type (name, type_declaration)
        | _ -> raise (Failure "Dependencies: expected only aliases \
                               in relit definition")
      ) signature

  type ('a, 'b) either = Left of 'a | Right of 'b

  let unescape_package package = package
        |> Utils.split_on "__RelitInternal_dot__"
        |> String.concat "."

  let of_modtype ~env ~path ~body ~loc : t =
    let unwrap = function
      | Left o -> o
      | Right name -> raise
          (Failure ("Unwrap: Malformed relit definition no " ^
                    name ^ " field"))
    in
    let lexer = ref (Right "lexer") in
    let parser = ref (Right "parser") in
    let dependencies = ref (Right "dependencies") in
    let package = ref (Right "package") in
    let nonterminal = ref (Right "nonterminal") in
    let signature = signature_of_path env path in

    List.iter (function
    | Types.Sig_module ({ name = "Dependencies" ; _},
                        { md_type = Mty_signature signature; _ }, _) ->
      dependencies := Left (extract_dependencies env signature)
    | Types.Sig_module ({ name ; _},
                        { md_type = Mty_signature signature; _ }, _)
        when Utils.has_prefix ~prefix:"Nonterminal_" name ->
      nonterminal := Left (unescape_package (Utils.remove_prefix ~prefix:"Nonterminal_" name))
    | Types.Sig_module ({ name ; _},
                        { md_type = Mty_signature signature; _ }, _)
        when Utils.has_prefix ~prefix:"Lexer_" name ->
      lexer := Left (unescape_package (Utils.remove_prefix ~prefix:"Lexer_" name))
    | Types.Sig_module ({ name ; _},
                        { md_type = Mty_signature signature; _ }, _)
        when Utils.has_prefix ~prefix:"Parser_" name ->
      parser := Left (unescape_package (Utils.remove_prefix ~prefix:"Parser_" name))
    | Types.Sig_module ({ name ; _},
                        { md_type = Mty_signature signature; _ }, _)
        when Utils.has_prefix ~prefix:"Package_" name ->
      package := Left (unescape_package (Utils.remove_prefix ~prefix:"Package_" name))
    | _ -> ()
    ) signature ;

    { lexer = unwrap !lexer
    ; parser = unwrap !parser
    ; dependencies = unwrap !dependencies
    ; nonterminal = unwrap !nonterminal
    ; package = unwrap !package
    ; path
    ; loc
    ; env
    ; body
    }


end

module App_finder(A : sig
    val app_records : App_record.t Locmap.t ref
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
                    * and the relit source of this application. *)
                   { cstr_tag =
                       Cstr_extension (Pdot (path, "App", _),
                                                _some_bool); _ },
                   _err_info::{
                     exp_desc = Texp_constant
                         Const_string (body, _other_part );
                     exp_env = env;
                   }::_ ); _ }))]) ->

        let app_record =
          Make_record.of_modtype ~loc:expr.exp_loc ~env ~path ~body
        in
        A.app_records := Locmap.add expr.exp_loc
                                     app_record
                                     !A.app_records;
      | _ -> ()
  end)

let typecheck structure =
  let open Parsetree in

  (* initialize the typechecking environment *)
  let filename =
    (List.hd structure).pstr_loc.Location.loc_start.Lexing.pos_fname in
  let without_extension = Filename.remove_extension filename in
  Compmisc.init_path false;
  let module_name = Compenv.module_of_filename
      Format.std_formatter filename without_extension in
  Env.set_unit_name module_name;
  let initial_env = Compmisc.initial_env () in

  (* turn off some warnings, since we use exceptions to fill in for any type *)
  let warning_state = Warnings.backup () in
  Warnings.parse_options false "-20-21";

  (* typecheck and extract type information *)
  let (typed_structure, _) =
    Typemod.type_implementation filename without_extension module_name
      initial_env structure
  in
  Warnings.restore warning_state;
  typed_structure

let from structure =
  let typed_structure = typecheck structure in
  let app_records = ref Locmap.empty in
  let module App_finder =
    App_finder(struct let app_records = app_records end)
  in
  App_finder.iter_structure typed_structure;
  !app_records
