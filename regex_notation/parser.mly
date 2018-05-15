%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident

  let loc = !Ast_helper.default_loc

%}
%token <string> STR
%token DOT
%token BAR
%token STAR
%token MISC
%token DOLLAR
%token <Relit_helper.Segment.t> PARENS
%token EOF

%left BAR
%left SEQ

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

literal:
  | r = regex EOF { r }
  | EOF { [%expr Regex.Empty ] }

regex:
  | a = regex BAR b = regex
      (* { [%expr let x = Regex.Empty in x ] } *)
      (* { [%expr let open Regex in Empty ] } *)
      (* { [%expr String.blit ] } *)
      (* { [%expr let open String in blit ] } *)
      (* { [%expr let module X = struct let x = () end in X.x ] } *)
      (* { [%expr 2 + 2 ] } *)

      { [%expr Regex.Or ([%e a], [%e b]) ] }
  | a = regex b = regex %prec SEQ
      { [%expr Regex.Seq ([%e a], [%e b]) ] }
  | s = STR
      { [%expr Regex.Str [%e (E.constant (C.string s))] ] }
  | DOLLAR a = PARENS
      (* also fails with s/Regex.t/string/ *)
      { Relit_helper.ProtoExpr.spliced a [%type: Regex.t ] }
  | DOT
      { [%expr Regex.AnyChar ] }
