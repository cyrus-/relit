
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
      match expr.exp_desc with
      | Texp_letmodule (
          ident,
          loc,
          ({ mod_desc = Tmod_ident (path, _loc); mod_env; _ } as module_expr),
          ({ exp_desc = Texp_apply (_raise_expr, [(_lbl, Some (
               { exp_desc = Texp_construct (_loc', _desc, _err_info::{
                     exp_desc = Texp_constant Const_string (source, _other_part ); _
                   }::_); _ }
             ))]); _ } as top_expression)
        ) when Ident.name ident = "RelitInternalDefn" ->
        print_endline source;
        let mod_type = (Env.find_module path mod_env).md_type in
        Printtyp.modtype
          Format.std_formatter
          mod_type;
        { expr with exp_desc = Texp_letmodule (
              ident,
              loc,
              module_expr,
              { top_expression with exp_desc = Texp_constant (Const_int 3)} ) }
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
