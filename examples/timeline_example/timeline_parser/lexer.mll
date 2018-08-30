{
open Lexing
open Parser
open Relit

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

let digit =  ['0' - '9']

(* part 4 *)
rule read =
  parse
  |  digit* { NUMBER(Lexing.lexeme lexbuf |> int_of_string) }
  | "sec"    { SECONDS }
  | "(" {
    let segment = Relit.Segment.read_to ")" lexbuf in
    SPLICED_EXP(segment) }
  | "\n"  { next_line lexbuf; read lexbuf }
  | " " { read lexbuf }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
