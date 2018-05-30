
(* a call record is stored for each tlm call after the typing ppx phase,
 * and then is used in the parsetree mapper to actaully call the tlm.
 * This file is kept sparse so that it may be opened without concern and
 * we don't have to qualify every index into a call record's data. *)

type dependency = Module of Ident.t * Types.module_declaration
                | Type of Ident.t * Types.type_declaration

type t = {
  body: string;
  definition_path: Path.t;
  lexer: string;
  parser: string;
  nonterminal: string;
  package: string;
  dependencies: dependency list;
  env: Env.t;
}
