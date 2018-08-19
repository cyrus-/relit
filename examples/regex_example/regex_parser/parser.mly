%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident
  open Parsetree

  let loc = Relit_helper.Location.loc

%}
%token <string> STR
%token STAR
%token DOT
%token BAR
%token PLUS
%token QMARK
%token LPAREN
%token RPAREN
%token <Relit_helper.Segment.t> SPLICED_REGEX
%token <Relit_helper.Segment.t> SPLICED_STRING
%token EOF

%left BAR
%left SEQ

%start <Migrate_parsetree.Ast_404.Parsetree.expression> start
%%

start:
  | r = regex EOF { r }
  | EOF { [%expr Regex.Empty ] }

regex:
  | DOT
      { [%expr Regex.AnyChar ] }
  | s = STR
      { [%expr Regex.Str [%e (E.constant (C.string s))] ] }
  | a = regex b = regex %prec SEQ
      { [%expr Regex.Seq ([%e a], [%e b]) ] }
  | a = regex BAR b = regex
      { [%expr Regex.Or ([%e a], [%e b]) ] }
  | a = regex STAR
      { [%expr Regex.Star [%e a]] }
  | a = regex PLUS
      { [%expr let r = [%e a] in Regex.Seq (r, Regex.Star (r))] }
  | a = regex QMARK
      { [%expr Regex.Seq (Regex.Empty, Regex.Star ([%e a]))] }
  | LPAREN a = regex RPAREN
      { a }
  | a = SPLICED_REGEX
      { Relit_helper.ProtoExpr.spliced a [%type: Regex.t ] }
  | a = SPLICED_STRING
      { [%expr Regex.Str
          [%e Relit_helper.ProtoExpr.spliced a [%type: string ] ]] }
