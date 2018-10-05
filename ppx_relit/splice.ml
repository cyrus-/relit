
(* This file is responsible for replacing the internal representations of
 * splices in a given ast with unique variables that point to the splices
 * they are immediately applied to. This is how we ensure that the splices
 * don't have access to any local bindings the TLMs generate code may contain.
 * Yay for hygiene!
 *
 * See the large comment in `fill_in_splices` for some more detail.
 * *)

type t = {
  variable_name: string;
  segment: Relit.Segment.t;
  expected_type: Parsetree.core_type; 
}

let validate_splices splices length =
  let segments = List.map (fun x -> x.segment) splices in
  Relit.Segment.validate segments length

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
         segment = Relit.Segment.mk (start_pos, end_pos);
       } in
       splices := splice :: !splices;
       let loc = e.pexp_loc in

       (* Apply unit to the variable: it'll be a thunk *)
       Ast_helper.Exp.apply ~loc
         (Ast_helper.Exp.ident ~loc {loc; txt = Lident variable_name})
         [(Asttypes.Nolabel, (Ast_helper.Exp.construct ~loc {loc; txt = Lident "()"} None))]

    | e -> Ast_mapper.default_mapper.expr mapper e
  in { Ast_mapper.default_mapper with
       expr = expr_mapper }

let take_splices_out expr =
  let splices = ref [] in
  let mapper = remove_splices_mapper splices in
  let ast_with_vars_not_splices = mapper.expr mapper expr in
  (!splices, ast_with_vars_not_splices)

let run_reason_parser_against splices body =
  let index_by_position Relit.Segment.{start_pos; end_pos} =
    let length = end_pos - start_pos in
    String.sub body start_pos length
  in
  List.map (
    fun splice -> (splice, splice.segment
      |> index_by_position
      |> Lexing.from_string
      |> Reason_parser.parse_expression Reason_lexer.token
      |> Convert.To_current.copy_expression)
    ) splices

let open_module_in ~loc mod_lident expr =
  let open Parsetree in

  {pexp_desc = Pexp_open (
       Fresh,
       {txt = mod_lident; loc },
       expr);
   pexp_loc = loc;
   pexp_attributes = [{txt="warning"; loc},
     PStr [{pstr_desc = Pstr_eval ({pexp_desc = Pexp_constant (Pconst_string ("-33", None)) ; pexp_loc = loc; pexp_attributes = []}, []); pstr_loc = loc}]]}

let fill_in_splices ~loc ~body_of_lambda ~spliced_asts ~longident =
  (* splices are represented as "thunks", i.e. a lambda that takes unit.
   *
   * this ensures that an side-effects happen if and when the code that the splice
   * is generated into is run. For example, if a TLM took a splice and put it into
   * a closure, then the side effects should occur when that closure is called, not
   * when it's defined. See the Timeline example for a more applied use case.
   *
   * some things to be aware of:
   * spliced_asts starts out life in this function as a list of splices and their respective
   * ast's, but is redefined at one point to be just the ast's. (the splices are used to form the
   * variable names)
   *
   * a good way to read this function is from the bottom-up. I hope the last 5 lines provide
   * a higher level picture: Essentially, we start out with a body ast and some splices. We then
   * wrap this ast with a function that's immediately applied to each of the asts.
   *
   * The "body" already has references to the arguments of the function we construct here:
   * they are put there in `take_out_splices`.
   * *)

  let respective_names = List.map (fun (splice, _) ->
        let pat = Ast_helper.Pat.var { txt = splice.variable_name ; loc } in
        let ty = Ast_helper.Typ.arrow ~loc Asttypes.Nolabel
          (Ast_helper.Typ.constr ~loc Location.{txt = Longident.Lident "unit"; loc} [])
          splice.expected_type
        in
        Ast_helper.Pat.constraint_ ~loc pat ty
  ) spliced_asts in

  let spliced_asts = List.map (fun (_, ast) ->
    Ast_helper.Exp.fun_
      Asttypes.Nolabel
      None
      (Ast_helper.Pat.construct Location.{txt = Longident.Lident "()"; loc} None)
      ast
  ) spliced_asts in

  (* there's a constraint on the parsetree to only have
   * tuples of multiple values. So we have to use unit
   * when there's no values to pass and a regular fn call
   * when there's only one. *)
  let (pattern, argument) = match List.length spliced_asts with
  | 0 ->
    let unit_ = Location.{txt = Longident.Lident "()"; loc } in
    (Ast_helper.Pat.construct unit_ None,
     Ast_helper.Exp.construct unit_ None)
  | 1 ->
    (List.hd respective_names,
     List.hd spliced_asts)
  | _ ->
    (Ast_helper.Pat.tuple respective_names,
     Ast_helper.Exp.tuple spliced_asts)
  in
  let wrap_as_fun = Ast_helper.Exp.fun_ Asttypes.Nolabel None in
  let apply_arg arg l = Ast_helper.Exp.apply l [(Asttypes.Nolabel, arg)] in

  body_of_lambda
  |> wrap_as_fun pattern
  |> open_module_in ~loc (Lident "Pervasives")
  |> open_module_in ~loc (Ldot (longident, "Dependencies"))
  |> apply_arg argument
