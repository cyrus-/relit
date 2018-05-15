module Segment = struct 
  (* segments are [left_bound, right_bound) *)
  type t = {left_bound: int; right_bound: int}


  (* 
  (* Checking the segment bounds *)
  type check_result = 
    | OK
    | NonPositiveLength of t
    | OutOfBounds of t
    | Overlapping of t * t
    | BadSeparation of t * t 

  let check segs len = 
    let sorted = sort segs (* TODO *) in 
    

  (* Tests *)
  assert check [] _ = OK
  assert check [ (-1, 1) ] 5 = OutOfBounds (-1, 1)
  assert check [ (0, 1) ] 0 = OutOfBounds (0, 1) 
  assert check [ (0, 1) ] 1 = OK
  assert check [ (0, 0) ] 1 = NonPositiveLength (0, 0)
  assert check [ (1, 0) ] 2 = NonPositiveLength (1, 0)
  assert check [ (0, 2), (1, 3) ] 4 = Overlapping (0, 2) (1, 3)
  assert check [ (1, 3), (0, 2) ] 4 = Overlapping (0, 2) (1, 3)
  assert check [ (0, 2), (2, 3) ] 4 = BadSeparation (0, 2) (2, 3)
  assert check [ (0, 2), (4, 5), (2, 3) ] 6 = BadSeparation (0, 2) (2, 3)
  assert check [ (0, 2), (4, 5), (3, 4) ] 6 = BadSeparation (3, 4) (4, 5)
  assert check [ (0, 2), (4, 5), (6, 9) ] 10 = OK
  *)

  let read_to end_delim buf = 0
end

(* raise this exception to report a TLM-specific error *)
type expansion_error_data = {msg: string; loc: Segment.t option} 
exception ExpansionError of expansion_error_data

module ProtoExpr = struct
  type t = Parsetree.expression

  let const_of_int i = 
    Ast_helper.Exp.constant (
      Ast_helper.Const.int i)  

  let spliced seg ty = 
    let start_pos_c = const_of_int Segment.(seg.start_pos) in 
    let end_pos_c = const_of_int Segment.(seg.end_pos) in 
    let open Parsetree in 
    let loc = !Ast_helper.default_loc in 
    [%expr (raise (RelitInternal__Spliced ([%e start_pos_c], [%e end_pos_c])) : [%t ty])]
end

