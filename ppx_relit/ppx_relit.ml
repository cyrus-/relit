
(* 
 * This is the starting place for the Relit ppx transformation.
 * This file is best read bottom-to-top, diving into any modules
 * where you're curious as to the implementation.
 *
 * See https://github.com/cyrus-/relit for an overview of Relit.
 * *)

let ppx_name = "relit"

open Ast_mapper
open Asttypes

open App_record

let fully_expanded structure =
  let exception HasRelitApp in
  let open Parsetree in
  let open Longident in
  let expr_mapper mapper e = match e.pexp_desc with
    | Pexp_apply (
      {pexp_desc = Pexp_ident {txt = Lident "raise"; _}; _},
        [(_, {pexp_attributes = ({txt = "relit"; _}, _) :: _;
              pexp_desc = Pexp_construct ({txt = Ldot (_, "Apply"); _},
              Some {pexp_desc = Pexp_tuple [_ ;
                {pexp_desc = Pexp_constant (Pconst_string _); _}]; _} ); _})]
      ) ->
        raise HasRelitApp
    | _ -> Ast_mapper.default_mapper.expr mapper e
  in
  let mapper = { Ast_mapper.default_mapper with expr = expr_mapper } in
  match mapper.structure mapper structure with
  | _ -> true
  | exception HasRelitApp -> false

let map_structure f app_records structure =
  let open Parsetree in
  let module Location = Ppxlib.Location in
  let expr_mapper mapper expr =

    (* If we've matched and typed this location
     * in the previous run, replace it *)
    try match f (Locmap.find expr.pexp_loc app_records) with
    | a -> a
    | exception Location.Error loc_error ->
        let extension = Location.Error.to_extension loc_error in
        Ast_helper.Exp.extension ~loc:expr.pexp_loc extension
    with Not_found -> (* continue down that expression *)
        Ast_mapper.default_mapper.expr mapper expr
  in
  let mapper = { Ast_mapper.default_mapper with expr = expr_mapper } in
  mapper.structure mapper structure

(* Overarching view of what's happening.
 * Reading this is crucial. *)
let relit_expansion_pass structure =
  let app_records = Extract_app_records.from structure in
  let for_each app_record =
    let proto_expansion = Expansion.expand_app app_record in
    let proto_expansion = Hygiene.check app_record proto_expansion in

    (* We ensure capture avoidance by replacing each splice reference
     * with a fresh variable... *)
    let (splices, open_expansion) =
      Splice.take_splices_out proto_expansion in
    Splice.validate_splices splices (String.length app_record.body);
    let spliced_asts =
      Splice.run_reason_parser_against splices app_record.body in

    (* ... and then wrap the body in a function that is immediately applied
     * to these splices. *)
    Splice.fill_in_splices
      ~body_of_lambda:open_expansion
      ~spliced_asts
      ~loc:app_record.loc
      ~longident:app_record.longident
  in map_structure for_each app_records structure

let rec structure_mapping structure =
  if Ast_mapper.tool_name () = "ocamldep" then structure else
  if fully_expanded structure then structure else
  let structure = relit_expansion_pass structure in
  structure_mapping structure

let () =
  Ppxlib.Driver.register_transformation
    ~impl:(Utils.maybe_print structure_mapping)
    (* ~intf *)
    ppx_name
