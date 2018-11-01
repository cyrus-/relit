open Migrate_parsetree
module To_current = Convert(OCaml_404)(OCaml_current)
module From_current = Convert(OCaml_current)(OCaml_404)
