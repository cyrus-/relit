%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident

  let loc = !Ast_helper.default_loc

%}
%token <string> VAR
%token EOF

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

literal:
  | s = VAR EOF
    {
      match s with
      | "number" -> [%expr 0]
      | "x" -> [%expr x]
      | "module" -> [%expr String.blit]
      | "typed_fn" -> [%expr fun (a : new_type) -> a * a ]
      | "badly_typed_fn" -> [%expr fun (a : fake_type) -> a * a ]
      | _ -> raise (Failure "no parse defined")
    }
  | EOF { [%expr 0 ] }
