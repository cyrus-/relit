let unique_int_state = ref 0
let unique_int () =
  unique_int_state := 1 + !unique_int_state;
  !unique_int_state
