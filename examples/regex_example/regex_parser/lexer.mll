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
let not_special = _#special

(* part 4 *)
rule read =
  parse
  | "."    { DOT }
  | "|"    { BAR }
  | "*"    { STAR }
  | escape as s { STR (unescape s) }
  | not_special+ as s { STR (s) }
  | "$(" {
    let segment = Relit_helper.Segment.read_to ")" lexbuf in
    SPLICED_REGEX(segment) }
  | "$$(" {
    let segment = Relit_helper.Segment.read_to ")" lexbuf in
    SPLICED_STRING(segment) }
  | "\n"  { next_line lexbuf; read lexbuf }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
