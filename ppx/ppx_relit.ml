
(* This file first defines a transformations on typed trees,
 * then an ppx ast_mapper that calls this transformation by
 * doing some typechecking trickery. *)

let ppx_name = "relit"

open Ast_mapper
open Parsetree

open Typedtree
open Asttypes

(* TODO: move to its own file *)
module Convert = struct
  open Migrate_parsetree

  module To_current = Convert(OCaml_404)(OCaml_current)
  module From_current = Convert(OCaml_current)(OCaml_404)
end

(* TODO: move to its own file *)
module Relit_call = struct

  type relit_call = {
    (* name: string; *)
    (* source: string; *)
    lexer: string;
    (* parser: string; *)
    (* Not sure if these should be strings or what yet.
     * dependencies: string;
     * type': string; *)
  } [@@deriving yojson]

  let relit_call_of_string (s : string) : relit_call =
    match relit_call_of_yojson (Yojson.Safe.from_string s) with
    | Result.Ok relit_call -> relit_call
    | Result.Error s -> raise (Failure ("found error while parsing json:" ^ s))

  let string_of_relit_call (r : relit_call) : string =
    Yojson.Safe.to_string (relit_call_to_yojson r)

  let signature_of_outer_modtype = function
    | Types.Mty_signature [Sig_module (_name, {
        md_type =  Mty_signature signature ; _
      }, _)] -> signature
    | _ -> raise (Failure "Expected a signature modtype for relit")

  let relit_call_of_modtype modtype : relit_call =
    let unwrap = function
      | Some o -> o
      | None -> raise (Failure "Unwrap: Malformed relit call site")
    and lexer = ref None in

    let signature = signature_of_outer_modtype modtype in
    List.iter (function
        | Types.Sig_module ({ name = "Lexer" ; _},
                            { md_type = Mty_alias (_alias_presence, path); _ }, _) ->
          lexer := Some (Path.name path)
        | _ -> ()
      )
      signature ;

    { lexer = unwrap !lexer }
end

open Relit_call

module TypedMap = TypedtreeMap.MakeMap(struct

    include TypedtreeMap.DefaultMapArgument
    let enter_expression expr =
      let open Path in
      match expr.exp_desc with
      | Texp_apply (
          (* match against the "raise" *)
          { exp_desc = Texp_ident (Pdot (Pident { name = "Pervasives" ; _ }, "raise", _), _, _) ; _ },
          [(_label, Some ({exp_attributes = [({txt = "relit"; _} as attr, payload)]; exp_desc = Texp_construct (
               loc,


               (* extract the module name and the remaining path of the module it's from *)
               { cstr_tag = Cstr_extension (Pdot (Pdot (path, name, _), "Call", _), _some_bool);
                 _ },
               _err_info::{
                 exp_desc = Texp_constant Const_string (source, _other_part );
                 exp_env;
               }::_ ); _ }))])

        when
          (* Make sure that it looks like a relit call *)
          (name |> String.split_on_char '_' |> List.hd) = "RelitInternalDefn"
        ->

        print_endline source;
        (* Look up and print the module's type *)
        let modtype = (Env.find_module path exp_env).md_type in
        let relit_call = relit_call_of_modtype modtype in

        (* return the desired new expression *)
        { expr with
          exp_desc = Texp_constant (Const_string (string_of_relit_call relit_call, None));
          exp_attributes = [({ attr with txt = "relit_iternal_information"}, payload)]
        }
      | e -> expr
  end)

let ppx_mapper _cookies =
  let structure_mapper _x structure =

    (* useful definitions for the remaining part *)
    let fname = (List.hd structure).pstr_loc.Location.loc_start.Lexing.pos_fname in
    let without_extension = Filename.remove_extension fname in

    (* initialize the typechecking environment *)
    Compmisc.init_path true;
    let module_name = Compenv.module_of_filename
        Format.std_formatter fname without_extension in

    Env.set_unit_name module_name;
    let initial_env = Compmisc.initial_env () in

    (* map to current ast; typecheck; map typed tree; map back to known version *)
    structure
    |> Typemod.type_implementation fname without_extension module_name initial_env
    |> fst |> TypedMap.map_structure
    (* |> fun x -> Printtyped.implementation Format.std_formatter x ; x *)
    |> Untypeast.untype_structure
    |> Convert.From_current.copy_structure
         (* TODO: do the mapping and generate call to lexer here *)
    |> Convert.To_current.copy_structure
  in
  { default_mapper with structure = structure_mapper }

let () =
  register ppx_name ppx_mapper
