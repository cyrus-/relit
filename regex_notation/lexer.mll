{
open Lexing
open Parser

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

(* part 4 *)
rule read =
  parse
  | "."    { DOT }
  | "|"    { BAR }
  | "<>"   { MISC }
  | "|"    { BAR }
  | escape as s { STR(unescape(s)) }
  | "\n"  { next_line lexbuf; read lexbuf }
  | ident    { STR (Lexing.lexeme lexbuf) }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
