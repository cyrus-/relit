%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident
  open Parsetree

  let loc = Relit_helper.loc

%}
%token <Relit_helper.Segment.t> SPLICED_EXP
%token EOF
%token<int> NUMBER
%token SECONDS

%start <Migrate_parsetree.Ast_404.Parsetree.expression> timeline
%%

timeline:
  | n = NUMBER SECONDS splice = SPLICED_EXP timeline = timeline
    { let n = Ast_helper.Const.int n |> Ast_helper.Exp.constant ~loc in
    [%expr {Timeline.happened =
      (fun () -> [%e Relit_helper.ProtoExpr.spliced splice [%type: unit]]);
      at = Timeline.Seconds [%e n]} :: [%e timeline]] }
  | EOF
    { [%expr []] }
