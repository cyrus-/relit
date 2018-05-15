{
open Lexing
open Parser
open Relit_helper

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

let unescape s = String.sub s 1 1
}

let special = ['\\' '.' '|' '*' '^'
               '+' '*' '(' ')' '$']
let escape = '\\' special
let ident = ['a'-'z' 'A'-'Z' '_' ' '] ['a'-'z' 'A'-'Z' '0'-'9' '_' ' ']*

(* match the text between a pair of parentheses *)
let paren_literal = '(' [^ ')' ]* ')'

(* part 4 *)
rule read =
  parse
  | "."    { DOT }
  | "$"    { DOLLAR }
  | "|"    { BAR }
  | escape as s { STR(unescape(s)) }
  | paren_literal { PARENS({start_pos = Lexing.lexeme_start lexbuf;
                            end_pos = Lexing.lexeme_end lexbuf}) }
  | "\n"  { next_line lexbuf; read lexbuf }
  | ident    { STR (Lexing.lexeme lexbuf) }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
