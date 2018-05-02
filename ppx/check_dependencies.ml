let rec lident_of_path path =
  let open Path in
  let open Longident in
  match path with
  | Pident ident -> Lident (Ident.name ident)
  | Pdot (rest, name, _) -> Ldot (lident_of_path rest, name)
  | Papply (a, b) -> Lapply (lident_of_path a, lident_of_path b)

let module_expr_of_expr expr =
  let open Parsetree in
  let open Longident in
  let loc = !Ast_helper.default_loc in

  Ast_helper.Mod.structure [{pstr_desc =
     (* like saying `let _ = $expr  *)
     Pstr_value (Nonrecursive,
                 [{pvb_pat = {ppat_desc = Ppat_any;
                              ppat_loc = loc;
                              ppat_attributes = []};
                   pvb_expr = expr;
                   pvb_loc = loc;
                   pvb_attributes = [];
                  }]);
    pstr_loc = loc}]

let open_dependencies_for def_path expr =
  let open Migrate_parsetree.OCaml_404.Ast in
  let open Parsetree in
  let loc = !Ast_helper.default_loc in
  {pexp_desc = Pexp_open (Fresh,
                          {txt = Ldot (lident_of_path def_path, "Dependencies"); loc },
                          expr);
   pexp_loc = loc;
   pexp_attributes = []}

let check_expr def_path expr =
  let env = Env.empty in
  (* we've got to use the current tree to run the typechecker *)
  expr |> Convert.To_current.copy_expression
       (* |> (fun e -> ensure_context_indenpendence e) *)
       |> module_expr_of_expr
       |> Typemod.type_module env;
  open_dependencies_for def_path expr
