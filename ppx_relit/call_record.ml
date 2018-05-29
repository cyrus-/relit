
(* a call record is stored for each tlm call after the typing ppx phase,
 * and then is used in the parsetree mapper to actaully call the tlm.
 * This file is kept sparse so that it may be opened without concern and
 * we don't have to qualify every index into a call record's data. *)

type dependency = Module of Ident.t * Types.module_declaration
                | Type of Ident.t * Types.type_declaration

type t = {
  source: string;
  definition_path: Path.t;
  return_type: Types.type_expr;
  lexer: string;
  parser: string;
  env: Env.t;
  dependencies: dependency list;
  package: string;
}
