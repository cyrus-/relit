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
%token PLUS
%token OPEN_PAREN
%token CLOSE_PAREN
%token EOF

%left BAR

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

literal:
  | r = regex EOF { r }
  | EOF { E.ident (loc (Ldot (Lident "Regex", "Empty"))) }

regex:
  | DOT
    { E.construct (loc (Ldot (Lident "Regex", "AnyChar"))) None}
  | s = STR
    { E.construct (loc (Ldot (Lident "Regex", "Str"))) (Some (E.constant (C.string s))) }
  | a = regex BAR b = regex
    { E.construct (loc (Ldot (Lident "Regex", "Or"))) (Some (E.tuple [a; b])) }
