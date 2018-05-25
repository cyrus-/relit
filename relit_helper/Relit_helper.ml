
open Migrate_parsetree.Ast_404

module Segment = struct 
  (* segments are [start_pos, end_pos) *)
  type t = {start_pos: int; end_pos: int}

  let mk (n1, n2) = {start_pos=n1; end_pos=n2}

  (* Validating the segment bounds *)
  type invalid_segmentation = 
    | NonPositiveLength of t
    | OutOfBounds of t
    | BadSeparation of t * t 
  exception InvalidSegmentation of invalid_segmentation

  let sort = List.sort 
    (fun seg1 seg2 -> compare seg1.start_pos seg2.start_pos)

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

  let rec validate_seg_pair seg1 seg2 len =
    let () = validate_seg seg1 len in 
    let () = validate_seg seg2 len in 
    let end_pos1 = seg1.end_pos in 
    let start_pos2 = seg2.start_pos in
    if end_pos1 >= start_pos2 then 
      raise (InvalidSegmentation (BadSeparation (seg1, seg2)))
    else ()

  let rec validate_sorted sorted len = 
    match sorted with 
    | [] -> ()
    | seg :: [] -> validate_seg seg len 
    | seg1 :: ((seg2 :: _) as tl) -> 
      let () = validate_seg_pair seg1 seg2 len in
      validate_sorted tl len

  let validate segs len = validate_sorted (sort segs) len 

  (* Tests *)
  (* TODO move these into the test suite *)
  let tests () = 
    let validate_ok segs len = 
      match validate segs len with 
      | () -> true
      | exception (InvalidSegmentation e) -> false in 

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

  let read_to end_delim buf = 0
end

(* raise this exception to report a TLM-specific error *)
type expansion_error_data = {msg: string; loc: Segment.t option} 

exception ExpansionError of expansion_error_data

module ProtoExpr = struct
  type t = Parsetree.expression

  let const_of_int i =
    Ast_helper.Exp.constant ( Ast_helper.Const.int i)

  let spliced seg ty = 
    let start_pos_c = const_of_int Segment.(seg.start_pos) in 
    let end_pos_c = const_of_int Segment.(seg.end_pos) in 
    let open Parsetree in 
    let loc = !Ast_helper.default_loc in 
    [%expr (raise (ignore ([%e start_pos_c], [%e end_pos_c]);
                   Failure "RelitInternal__Spliced") : [%t ty])]
end

let _ = Segment.tests ()
