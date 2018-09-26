open Migrate_parsetree
module To_current = Convert(OCaml_404)(OCaml_406)
module From_current = Convert(OCaml_406)(OCaml_404)
