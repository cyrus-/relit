
(* This file first defines a transformations on typed trees,
 * then an ppx ast_mapper that calls this transformation by
 * doing some typechecking trickery. *)

let ppx_name = "relit"

open Ast_mapper
open Parsetree
open Typedtree
open Asttypes

open Relit_call

(* TODO: move to its own file *)
module Convert = struct
  open Migrate_parsetree

  module To_current = Convert(OCaml_404)(OCaml_current)
  module From_current = Convert(OCaml_current)(OCaml_404)
end


module LocMap = Map.Make(struct
    type t = Location.t
    let compare a b = let open Location in
      compare
        (a.loc_start, a.loc_end, a.loc_ghost)
        (b.loc_start, b.loc_end, b.loc_ghost)
  end)

let loc_to_relit_call : relit_call LocMap.t ref = ref LocMap.empty

let load_top_module path =
  let toplevel_module = Ident.name (Path.head path) in
  let filename = String.lowercase_ascii toplevel_module ^ ".cma" in
  (* The boolean returned is just whether or not it was
   * already loaded *)
  Topdirs.load_file Format.std_formatter filename |> ignore

let parse_fn_from_module lexer_path parser_path env =
  Toploop.initialize_toplevel_env ();
  load_top_module lexer_path;
  load_top_module parser_path;

  ("let value : Lexing.lexbuf -> Migrate_parsetree.Ast_404.Parsetree.expression = "
  ^ Path.name parser_path  ^ ".literal "
  ^ Path.name lexer_path  ^ ".read;;")
    |> Lexing.from_string
    |> Parse.toplevel_phrase
    |> Toploop.execute_phrase false Format.std_formatter
    |> fun x -> if not x then raise (Failure "while trying to execute phrase");
  (Obj.magic (Toploop.getvalue "value") : (Lexing.lexbuf -> Migrate_parsetree.Ast_404.Parsetree.expression))

module Iter_and_extract = TypedtreeIter.MakeIterator(struct
    include TypedtreeIter.DefaultIteratorArgument

    let enter_expression expr =
      let open Path in
      match expr.exp_desc with
      | Texp_apply (
          (* match against the "raise" *)
          { exp_desc = Texp_ident
                (Pdot (Pident { name = "Pervasives" ; _ },
                       "raise", _), _, _) ; _ },
          [(_label,
            Some (
              {exp_attributes = [({txt = "relit"; _}, payload)];
               exp_desc = Texp_construct (
                   loc,

                   (* extract the module name and the
                    * remaining path of the module it's from *)
                   { cstr_tag = Cstr_extension (Pdot
                                                  (Pdot
                                                     (path, name, _),
                                                   "Call", _),
                                                _some_bool); _ },
                   _err_info::{
                     exp_desc = Texp_constant
                         Const_string (source, _other_part );
                     exp_env;
                   }::_ ); _ }))]) ->

        let relit_call = relit_call_of_modtype exp_env path source in


        loc_to_relit_call := LocMap.add expr.exp_loc relit_call !loc_to_relit_call;

      | _ -> ()
  end)


let purely_parsing_mapper =
  let open Migrate_parsetree.OCaml_404.Ast in
  let open Parsetree in
  let expr_mapper mapper expr =
    match LocMap.find_opt expr.pexp_loc !loc_to_relit_call with
    | Some call (* the relit_call struct *) ->
      let parse = parse_fn_from_module call.lexer call.parser_ call.env in
      parse (Lexing.from_string call.source)
    | None -> expr
  in { Ast_mapper.default_mapper with
       expr = expr_mapper }

let typing_mapper _cookies =
  let structure_mapper _x structure =

    (* useful definitions for the remaining part *)
    let fname =
      (List.hd structure).pstr_loc.Location.loc_start.Lexing.pos_fname in
    let without_extension = Filename.remove_extension fname in

    (* initialize the typechecking environment *)
    Compmisc.init_path false;
    let module_name = Compenv.module_of_filename
        Format.std_formatter fname without_extension in
    Env.set_unit_name module_name;
    let initial_env = Compmisc.initial_env () in

    (* typecheck and extract type information *)
    structure
    |> Typemod.type_implementation
      fname without_extension module_name initial_env
    |> fst |> Iter_and_extract.iter_structure;

    (* TODO: with ocaml-migrate-parsetree, map over ast
     * and generate call to lexer *)
    structure
    |> Convert.From_current.copy_structure
    |> purely_parsing_mapper.structure purely_parsing_mapper
    |> Convert.To_current.copy_structure
  in
  { default_mapper with structure = structure_mapper }

let () =
  register ppx_name typing_mapper
