
(* This file first defines a transformations on typed trees,
 * then an ppx ast_mapper that calls this transformation by
 * doing some typechecking trickery. *)

let ppx_name = "relit"

open Ast_mapper
open Parsetree
open Typedtree
open Asttypes

module LocMap = Map.Make(struct
    type t = Location.t
    let compare a b = let open Location in
      compare
        (a.loc_start, a.loc_end, a.loc_ghost)
        (b.loc_start, b.loc_end, b.loc_ghost)
  end)

let loc_to_relit_call : Relit_call.t LocMap.t ref = ref LocMap.empty

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
              {exp_attributes = [({txt = "relit"; _}, _)];
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

        let relit_call = Relit_call.of_modtype exp_env path source in
        loc_to_relit_call := LocMap.add expr.exp_loc relit_call !loc_to_relit_call;
      | _ -> ()
  end)

(* Used for error handling in parsing *)
let print_position outx lexbuf =
  let open Lexing in
  let pos = lexbuf.lex_curr_p in
  Format.fprintf outx "%d:%d"
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let record_splices splices =
  let open Migrate_parsetree.OCaml_404.Ast in
  let open Parsetree in
  let expr_mapper mapper e = match e with
      | [%expr (raise (ignore ([%e? {pexp_desc = Pexp_constant (Pconst_integer (start_pos, _)); _} ],
                               [%e? {pexp_desc = Pexp_constant (Pconst_integer (end_pos, _)); _} ]);
                       Failure "RelitInternal__Spliced")
                 : [%t? expected_type ]) ] ->
         let start_pos = int_of_string start_pos in
         let end_pos = int_of_string end_pos in
         let variable_name = "RelitInternal__SplicedVar" ^ string_of_int (Utils.unique_int ()) in
         splices := (variable_name, Relit_helper.Segment.{start_pos ; end_pos}) :: !splices;
         Ast_helper.Exp.ident {loc = !Ast_helper.default_loc; txt = Longident.Lident variable_name}
      | e -> Ast_mapper.default_mapper.expr mapper e
  in { Ast_mapper.default_mapper with
       expr = expr_mapper }

let into_protoexpansion =

  let open Migrate_parsetree.OCaml_404.Ast in
  let open Parsetree in
  let expr_mapper mapper initial_expr =

    (* If we've matched and typed this location in the previous run, replace it *)
    match LocMap.find initial_expr.pexp_loc !loc_to_relit_call with
    | call (* the relit_call struct *) ->

      (* load the lexer and parser *)
      let parse = Loading.menhir_from_module call.lexer call.parser in
      let lexbuf = Lexing.from_string call.source in

      (* call the parser on the source & ensure dependencies are respected *)
      begin try
        let expr = parse lexbuf in
        let expr = Hygiene.map_expr call expr in

        let splices = ref [] in (* START splices is mutable - todo clean this up. *)
        let mapper = record_splices splices in
        let body_of_lambda = mapper.expr mapper expr in

        let index_by_position (_, Relit_helper.Segment.{start_pos; end_pos}) =
          let length = end_pos - start_pos in
          String.sub call.source start_pos length
        in

        let parse_reason source =
          source |> Lexing.from_string
                 |> Reason_parser.parse_expression Reason_lexer.token
        in

        let splices = !splices in (* END splices is not mutable *)
        let spliced_sources = List.map index_by_position splices in

        let parsetrees = List.map parse_reason spliced_sources in
        let respective_names = splices
          |> List.map fst
          |> List.map (fun a -> Ast_helper.Pat.var {txt = a ; loc = !Ast_helper.default_loc})
        in

        (* there's a constraint on the parsetree to only have
         * tuples of multiple values. So we have to use unit
         * when there's no values to pass and a regular fn call
         * when there's only one. *)
        let (pattern, argument) = match List.length splices with
        | 0 -> let unit_ = {txt = Longident.Lident "()"; loc = !Ast_helper.default_loc} in
               (Ast_helper.Pat.construct unit_ None,
                Ast_helper.Exp.construct unit_ None)
        | 1 -> (List.hd respective_names, List.hd parsetrees)
        | _ -> (Ast_helper.Pat.tuple respective_names, Ast_helper.Exp.tuple parsetrees) in

        let lambda = Ast_helper.Exp.fun_ Asttypes.Nolabel None pattern body_of_lambda in
        Ast_helper.Exp.apply lambda [(Asttypes.Nolabel, argument)]

      with e ->
        Format.fprintf Format.std_formatter "%a: tlm error\n" print_position lexbuf;
        raise e
      end
    | exception Not_found ->
        (* continue down that expression *)
        Ast_mapper.default_mapper.expr mapper initial_expr
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

    (* map over ast and generate call to lexer *)
    structure
    |> Convert.From_current.copy_structure
    |> into_protoexpansion.structure into_protoexpansion
    |> Convert.To_current.copy_structure
  in
  { default_mapper with structure = structure_mapper }

let () =
  register ppx_name typing_mapper
