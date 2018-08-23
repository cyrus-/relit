%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident
  open Parsetree

  let loc = Relit_helper.loc

  let make_event time splice =
    let splice = Relit_helper.ProtoExpr.spliced splice [%type: unit -> unit ] in
    [%expr {Timeline.happened: [%e splice]; at: [%e time]} ]

  let seconds n =
    let n = Ast_helper.Const.int n |> Ast_helper.Exp.constant ~loc in
    [%expr Timeline.Seconds [%e n]]

  let minutes n =
    let n = Ast_helper.Const.int n |> Ast_helper.Exp.constant ~loc in
    [%expr Timeline.Minutes [%e n]]

%}
%token <Relit_helper.Segment.t> SPLICED_EXP
%token EOF
%token<int> NUMBER
%token MINUTES
%token SECONDS

%start <Migrate_parsetree.Ast_404.Parsetree.expression> start
%%

start:
  | r = timeline { r }

timeline:
  | n = NUMBER MINUTES splice = SPLICED_EXP timeline = timeline
    { [%expr [%e make_event (minutes n) splice]
        :: [%e timeline]]
    }
  | n = NUMBER SECONDS splice = SPLICED_EXP timeline = timeline
    { [%expr [%e make_event (seconds n) splice]
        :: [%e timeline]]
    }
  | EOF
    { [%expr []] }
