
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

let remove_splices_mapper splices =
  let open Parsetree in
  let expr_mapper mapper e =
    match e with
    | [%expr (raise (ignore (
        [%e? {pexp_desc =
                Pexp_constant (Pconst_integer (start_pos, _)); _} ],
        [%e? {pexp_desc =
                Pexp_constant (Pconst_integer (end_pos, _)); _} ]);
           Failure "RelitInternal__Spliced") : [%t? expected_type ]) ] ->
       let start_pos = int_of_string start_pos in
       let end_pos = int_of_string end_pos in
       let variable_name =
         "RelitInternal__SplicedVar"
         ^ Utils.unique_string () in
       splices :=
         (variable_name, Relit_helper.Segment.{start_pos ; end_pos})
         :: !splices;
       Ast_helper.Exp.ident {loc = !Ast_helper.default_loc;
                             txt = Longident.Lident variable_name}
    | e -> Ast_mapper.default_mapper.expr mapper e
  in { Ast_mapper.default_mapper with
       expr = expr_mapper }

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

let take_splices_out expr =
  let splices = ref [] in
  let mapper = remove_splices_mapper splices in
  let ast_with_vars_not_splices = mapper.expr mapper expr in
  (!splices, ast_with_vars_not_splices)

let run_reason_parser_against splices source =
  let index_by_position Relit_helper.Segment.{start_pos; end_pos} =
    let length = end_pos - start_pos in
    String.sub source start_pos length
  in
  List.map (
    fun (var, splice) ->
      (var, splice
            |> index_by_position
            |> Lexing.from_string
            |> Reason_parser.parse_expression Reason_lexer.token
            |> Convert.To_current.copy_expression)
    ) splices

let fill_in_splices body_of_lambda spliced_asts =
  let respective_names = spliced_asts
    |> List.map fst
    |> List.map (fun a -> Ast_helper.Pat.var {
                            txt = a ;
                            loc = !Ast_helper.default_loc})
  in
  let spliced_asts = List.map snd spliced_asts in

  (* there's a constraint on the parsetree to only have
   * tuples of multiple values. So we have to use unit
   * when there's no values to pass and a regular fn call
   * when there's only one. *)
  let (pattern, argument) = match List.length spliced_asts with
  | 0 ->
    let unit_ = {txt = Longident.Lident "()";
                 loc = !Ast_helper.default_loc} in
    (Ast_helper.Pat.construct unit_ None,
     Ast_helper.Exp.construct unit_ None)
  | 1 ->
    (List.hd respective_names,
     List.hd spliced_asts)
  | _ ->
    (Ast_helper.Pat.tuple respective_names,
     Ast_helper.Exp.tuple spliced_asts)
  in

  let lambda =
    Ast_helper.Exp.fun_ Asttypes.Nolabel None pattern body_of_lambda in
  Ast_helper.Exp.apply lambda [(Asttypes.Nolabel, argument)]

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
    let tlm_ast =
      open_dependencies_in tlm_ast call_record.definition_path in
    let (splices, tlm_ast) = take_splices_out tlm_ast in
    let spliced_asts =
      run_reason_parser_against splices call_record.source in
    fill_in_splices tlm_ast spliced_asts
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
