
open Migrate_parsetree.Ast_404

(* raise this exception to report a TLM-specific error *)
type expansion_error_data = {msg: string; loc: Segment.t option} 

exception ExpansionError of expansion_error_data


module Location = struct
  let location : Location.t option ref = ref None

  let get () =
    match !location with
    | Some l -> l
    | None -> raise (Failure "bug: Relit helper should not be called outside of the Relit TLM context")
end

module ProtoExpr = struct
  type t = Parsetree.expression

  let const_of_int i =
    Ast_helper.Exp.constant ( Ast_helper.Const.int i)

  let spliced seg ty = 
    let start_pos_c = const_of_int Segment.(seg.start_pos) in 
    let end_pos_c = const_of_int Segment.(seg.end_pos) in 
    let open Parsetree in 
    let loc = Location.get () in
    [%expr (raise (ignore ([%e start_pos_c], [%e end_pos_c]);
                   Failure "RelitInternal__Spliced") : [%t ty])]
end

module Segment = Segment
