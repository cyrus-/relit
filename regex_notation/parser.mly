%{
  open Migrate_parsetree.Ast_404
  module E = Ast_helper.Exp
  module C = Ast_helper.Const
  open Longident

  let loc txt : Ast_helper.lid = {loc = !Ast_helper.default_loc; txt}


%}
%token <string> STR
%token DOT
%token BAR
%token QUESTION
%token STAR
%token OPEN_PAREN
%token CLOSE_PAREN
%token EOF

%left BAR
%left SEQ

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

literal:
  | r = regex EOF { r }
  | EOF { E.ident (loc (Ldot (Lident "Regex", "Empty"))) }

regex:
  | a = regex BAR b = regex
    (* { E.ident (loc (Ldot (Lident "String", "blit"))) } *)
    { E.construct (loc (Ldot (Lident "Regex", "Or"))) (Some (E.tuple [a; b])) }
  | a = regex b = regex %prec SEQ
    { E.construct (loc (Ldot (Lident "Regex", "Seq"))) (Some (E.tuple [a; b])) }
  | s = STR
    { E.construct (loc (Ldot (Lident "Regex", "Str"))) (Some (E.constant (C.string s))) }
  | DOT
    { E.construct (loc (Ldot (Lident "Regex", "AnyChar"))) None}
