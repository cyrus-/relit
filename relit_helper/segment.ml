(* segments are [start_pos, end_pos) *)
type t = {start_pos: int; end_pos: int}

let mk (n1, n2) = {start_pos=n1; end_pos=n2}

let read_to delim lexbuf =
  let open Lexing in
  if String.contains delim '\n'
  then raise (Invalid_argument {|
    newlines in delemeters aren't supported at the moment...
  |}); (* TODO fixing this requires changing the line_num intelligently. *)
  let delim = ExtString.String.explode delim in

  let start_pos = lexbuf.lex_abs_pos + lexbuf.lex_curr_pos in

  let module Lex = struct

    type token = Paren | Brace | Bracket

    module P = Reason_parser

    let rec matches_prefix delim index = match delim with
      | [] -> true
      | c :: delim ->
          try
            let c' = Lexing.sub_lexeme_char lexbuf (index ) in
            (c = c' && matches_prefix delim (index + 1))
          with (Invalid_argument txt) as e ->
            if String.equal txt "index out of bounds" 
               && index >= lexbuf.lex_buffer_len
            then false
            else if String.equal txt "index out of bounds"
            then (
              lexbuf.refill_buff lexbuf;
              matches_prefix delim index
            ) else raise e

    let success () = 
      let end_pos = Lexing.lexeme_end lexbuf in
      let offset = List.length delim in
      lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos + offset;
      lexbuf.lex_curr_p <-
        { lexbuf.lex_curr_p with
          pos_cnum = lexbuf.lex_curr_p.pos_cnum + offset;
          pos_bol = lexbuf.lex_curr_p.pos_bol + offset };
      {start_pos; end_pos}

    let at_end stack =
      lexbuf.lex_curr_pos >= lexbuf.lex_buffer_len ||
      (matches_prefix delim lexbuf.lex_curr_pos && stack = [])

    let read_to stack =
      let stack = ref stack in

      while not (at_end !stack) do
        match Reason_lexer.token_with_comments lexbuf with
        | P.LPAREN ->
            stack := (Paren :: !stack)
        | P.LBRACKET -> stack := (Bracket :: !stack)
        | P.LBRACE -> stack := (Brace :: !stack)
        | P.RPAREN ->
            (match !stack with
             | Paren :: rest -> stack := rest
             | _ -> raise (Failure "unbalanced parens in reason"))
        | P.RBRACKET ->
            (match !stack with
             | Bracket :: rest -> stack := rest
             | _ -> raise (Failure "unbalanced brackets in reason"))
        | P.RBRACE ->
            (match !stack with
             | Brace :: rest -> stack := rest
             | _ -> raise (Failure "unbalanced braces in reason"))
        | _ -> ()
      done;
      (* we don't have to check if there's anything left on the stack
       * the reason parser will through a better error than we can muster. *)
      success ()

  end in
  Lex.read_to []

module Read_to_tests = struct

  let show_t t : unit =
    Printf.fprintf stderr "[%d, %d]" t.start_pos t.end_pos

  let lex_assert str delim a b =
    let lexbuf = Lexing.from_string str in
    lexbuf.Lexing.lex_curr_pos <- a;
    let t = read_to delim lexbuf in
    assert (t.start_pos = a);
    assert (t.end_pos = b)

  let () = lex_assert "(hi) there" ")" 1 3
  let () = lex_assert "((hi)) there" "))" 2 4
  (* let () = lex_assert "( hi ) there" "}" 1 3 *)

end

(* Validating the segment bounds *)
type invalid_segmentation =
  | NonPositiveLength of t
  | OutOfBounds of t
  | BadSeparation of t * t
exception InvalidSegmentation of invalid_segmentation

let validate_seg seg len =
  let {start_pos; end_pos} = seg in
  if start_pos < 0 then
    raise (InvalidSegmentation (OutOfBounds seg))
  else if start_pos >= len then
    raise (InvalidSegmentation (OutOfBounds seg))
  else if end_pos <= start_pos then
    raise (InvalidSegmentation (NonPositiveLength seg))
  else if end_pos > len then
    raise (InvalidSegmentation (OutOfBounds seg))
  else ()

let validate_seg_pair seg1 seg2 len =
  let () = validate_seg seg1 len in
  let () = validate_seg seg2 len in
  let end_pos1 = seg1.end_pos in
  let start_pos2 = seg2.start_pos in
  if end_pos1 >= start_pos2 then
    raise (InvalidSegmentation (BadSeparation (seg1, seg2)))
  else ()

let validate segs len =
  let rec validate_sorted sorted len =
    match sorted with
    | [] -> ()
    | seg :: [] -> validate_seg seg len
    | seg1 :: ((seg2 :: _) as tl) ->
      let () = validate_seg_pair seg1 seg2 len in
      validate_sorted tl len in
  let sort = List.sort
    (fun seg1 seg2 -> compare seg1.start_pos seg2.start_pos) in
  validate_sorted (sort segs) len

(* Tests *)
let validation_tests () =
  let validate_ok segs len =
    match validate segs len with
    | () -> true
    | exception (InvalidSegmentation _) -> false in

  let validate_raises segs len result =
    match validate segs len with
    | () -> false
    | exception (InvalidSegmentation e) -> e = result in

  begin
    assert (validate_ok [] 10);
    assert (validate_raises [ mk (-1, 1) ] 5 (OutOfBounds (mk (-1, 1))));
    assert (validate_raises [ mk (0, 1) ] 0 (OutOfBounds (mk (0, 1))));
    assert (validate_ok [ mk (0, 1) ] 1);
    assert (validate_raises [ mk (0, 0) ] 1 (NonPositiveLength (mk (0, 0))));
    assert (validate_raises [ mk (1, 0) ] 2 (NonPositiveLength (mk (1, 0))));
    assert (validate_raises [ mk (0, 2); mk (1, 3) ] 4 (BadSeparation (mk (0, 2), mk (1, 3))));
    assert (validate_raises [ mk (1, 3); mk (0, 2) ] 4 (BadSeparation (mk (0, 2), mk (1, 3))));
    assert (validate_raises [ mk (0, 2); mk (2, 3) ] 4 (BadSeparation (mk (0, 2), mk (2, 3))));
    assert (validate_raises [ mk (0, 2); mk (4, 5); mk (2, 3) ] 6 (BadSeparation (mk (0, 2), mk (2, 3))));
    assert (validate_raises [ mk (0, 2); mk (4, 5); mk (3, 4) ] 6 (BadSeparation (mk (3, 4), mk (4, 5))));
    assert (validate_ok [ mk (0, 2); mk (4, 5); mk (6, 9) ] 10)
  end

let _ = validation_tests ()
