%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident

  let loc = Relit.loc

%}
%token <string> CHAR
%token EOF

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

literal:
  | s = text EOF
    {
      match s with
      | "number" -> [%expr 0]
      | "x" -> [%expr x]
      | "module" -> [%expr Std.unique () ]
      | "typed_fn" -> [%expr fun (a : new_type) -> a * a ]
      | "badly_typed_fn" -> [%expr fun (a : fake_type) -> a * a ]
      | "$( 2 )" ->
          [%expr [%e Relit.ProtoExpr.spliced
            (Relit.Segment.mk (2, 4)) [%type: string ]
          ] |> ignore ; 5 ]
      | "2 bad_splice_type" ->
          [%expr [%e Relit.ProtoExpr.spliced
            (Relit.Segment.mk (0, 1)) [%type: string]
          ] |> ignore ; 5 ]
      | "bad_splice_bounds" ->
          Relit.ProtoExpr.spliced
            (Relit.Segment.mk (2, 3040)) [%type: int]
      | "bad_splice_overlap" ->
          [%expr
            [%e Relit.ProtoExpr.spliced
              (Relit.Segment.mk (2, 5)) [%type: int ] ];
            [%e Relit.ProtoExpr.spliced
              (Relit.Segment.mk (4, 7)) [%type: int ] ] ]
      | _ -> raise (Failure "no parse defined")
    }
  | EOF { [%expr 0 ] }

text:
  | a = CHAR { a }
  | a = text b = CHAR { a ^ b }
