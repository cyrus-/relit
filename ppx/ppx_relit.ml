
(* This file first defines a transformations on typed trees,
 * then an ppx ast_mapper that calls this transformation by
 * doing some typechecking trickery. *)

let ppx_name = "relit"

open Ast_mapper
open Parsetree

open Typedtree
open Asttypes

module TypedMap = TypedtreeMap.MakeMap(struct

    include TypedtreeMap.DefaultMapArgument
    let enter_expression expr =
      let open Path in
      match expr.exp_desc with
      | Texp_apply (
          (* match against the "raise" *)
          { exp_desc = Texp_ident (Pdot (Pident { name = "Pervasives" ; _ }, "raise", _), _, _) ; _ },
          [(_label, Some ({exp_attributes = [({txt = "relit"; _}, _)]; exp_desc = Texp_construct (
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
        let mod_type = (Env.find_module path exp_env).md_type in
        Printtyp.modtype
          Format.std_formatter
          mod_type;

        (* return the desired new expression *)
        { expr with exp_desc = Texp_constant (Const_int 3) }
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
  in
  { default_mapper with structure = structure_mapper }

let () =
  register ppx_name ppx_mapper
