{
open Lexing
open Absurd_parser

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

}

let ident = ['a'-'z' 'A'-'Z' '_' ' '] ['a'-'z' 'A'-'Z' '0'-'9' '_' ' ']*

(* part 4 *)
rule read =
  parse
  | ident { VAR (Lexing.lexeme lexbuf) }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
