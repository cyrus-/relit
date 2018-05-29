
include Map.Make(struct
  type t = Location.t
  let compare a b = let open Location in
    compare
      (a.loc_start, a.loc_end, a.loc_ghost)
      (b.loc_start, b.loc_end, b.loc_ghost)
end)

