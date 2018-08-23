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
}

(* part 4 *)
rule read =
  parse
  | "\d"    { NUMBER(Lexing.lexeme lexbuf |> int_of_string) }
  | "min"    { MINUTES }
  | "sec"    { SECONDS }
  | "(" {
    let segment = Relit_helper.Segment.read_to ")" lexbuf in
    SPLICED_EXP(segment) }
  | "\n"  { next_line lexbuf; read lexbuf }
  | " " { read lexbuf }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof      { EOF }
