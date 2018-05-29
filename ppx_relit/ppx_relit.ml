
(* 
 * 
 * *)

let ppx_name = "relit"

open Ast_mapper
open Parsetree
open Typedtree
open Asttypes

open Call_record

let fully_expanded structure =
  let exception YesItDoes in
  let open Parsetree in
  let open Longident in
  let expr_mapper mapper e = match e.pexp_desc with
    | Pexp_apply (
        {pexp_desc = Pexp_ident {txt = Lident "raise"; _}},
        [(_, {pexp_attributes = ({txt = "relit"}, _) :: _;
              pexp_desc = Pexp_construct ({txt = Ldot (_, "Call"); _},
              Some {pexp_desc = Pexp_tuple [_ ;
                {pexp_desc = Pexp_constant (Pconst_string _); _}]; _} )})]
      ) ->
        raise YesItDoes
    | _ -> Ast_mapper.default_mapper.expr mapper e
  in
  let mapper = { Ast_mapper.default_mapper with expr = expr_mapper } in
  match mapper.structure mapper structure with
  | _ -> true
  | exception YesItDoes -> false

let open_dependencies_in expr def_path  =
  let open Parsetree in
  let open Longident in

  let rec lident_of_path path =
    let open Path in
    match path with
    | Pident ident -> Lident (Ident.name ident)
    | Pdot (rest, name, _) -> Ldot (lident_of_path rest, name)
    | Papply (a, b) -> Lapply (lident_of_path a, lident_of_path b)
  in

  let loc = !Ast_helper.default_loc in
  {pexp_desc = Pexp_open (
       Fresh,
       {txt = Ldot (lident_of_path def_path,
                    "Dependencies"); loc },
       expr);
   pexp_loc = loc;
   pexp_attributes = []}

let map_structure f call_records structure =
  let open Parsetree in
  let expr_mapper mapper expr =

    (* If we've matched and typed this location
     * in the previous run, replace it *)
    match Locmap.find expr.pexp_loc call_records with
    | call_record ->
      f call_record
    | exception Not_found ->
        (* continue down that expression *)
        Ast_mapper.default_mapper.expr mapper expr
  in
  let mapper = { Ast_mapper.default_mapper with expr = expr_mapper } in
  mapper.structure mapper structure

(* Overarching view of what's happening.
 * Reading this is crucial. *)
let relit_transformation structure =
  if fully_expanded structure then None else
  let call_records = Extract_call_records.from structure in

  let for_each call_record =
    let tlm_ast = Loading.parse call_record in
    Hygiene.check call_record tlm_ast;
    let tlm_ast = open_dependencies_in tlm_ast call_record.definition_path in
    let (splices, tlm_ast) = Splice.take_splices_out tlm_ast in
    let spliced_asts =
      Splice.run_reason_parser_against splices call_record.source in
    Splice.fill_in_splices tlm_ast spliced_asts
  in Some (map_structure for_each call_records structure)

let rec relit_mapper =
  (* run the relit transformation until there are no more tlms *)
  let structure_mapper _x structure =
    match relit_transformation structure with
    | None -> default_mapper.structure relit_mapper structure
    | Some structure -> relit_mapper.structure relit_mapper structure
  in
  { default_mapper with structure = structure_mapper }

let () =
  register ppx_name (fun _cookies -> relit_mapper)
