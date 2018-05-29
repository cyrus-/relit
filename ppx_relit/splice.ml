
open Call_record

type t = {
  variable_name: string;
  segment: Relit_helper.Segment.t;
  expected_type: Parsetree.core_type; 
}

let validate_splices splices = () (* TODO *)

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
         "relitinternal__splicedvar"
         ^ Utils.unique_string () in
       let splice = {
         variable_name;
         expected_type;
         segment = Relit_helper.Segment.mk (start_pos, end_pos);
       } in
       splices := splice :: !splices;
       Ast_helper.Exp.ident {loc = !Ast_helper.default_loc;
                             txt = Longident.Lident variable_name}
    | e -> Ast_mapper.default_mapper.expr mapper e
  in { Ast_mapper.default_mapper with
       expr = expr_mapper }

let take_splices_out expr =
  let splices = ref [] in
  let mapper = remove_splices_mapper splices in
  let ast_with_vars_not_splices = mapper.expr mapper expr in
  (!splices, ast_with_vars_not_splices)

let run_reason_parser_against splices body =
  let index_by_position Relit_helper.Segment.{start_pos; end_pos} =
    let length = end_pos - start_pos in
    String.sub body start_pos length
  in
  List.map (
    fun splice -> (splice.variable_name, splice.segment
      |> index_by_position
      |> Lexing.from_string
      |> Reason_parser.parse_expression Reason_lexer.token
      |> Convert.To_current.copy_expression
      |> Utils.add_type_assertion splice.expected_type)
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
    let unit_ = Location.{txt = Longident.Lident "()";
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
