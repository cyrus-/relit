%{
  open Migrate_parsetree.Ast_404
  open Ast_helper
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

%start <Migrate_parsetree.Ast_404.Parsetree.expression> literal
%%

(* THE NEXT STEP IS TO FINISH THIS PARSER. *)

literal:
  | EOF       { Exp.constant (Const.string "hi there") }
  | BAR       { Exp.constant (Const.string "hi there") }
  | s = STR p = literal { Exp.constant (Const.string "hi there, you") }
