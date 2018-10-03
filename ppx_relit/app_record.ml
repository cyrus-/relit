
(* a applicaton record is stored for each tlm application after the typing ppx
 * phase, and then is used in the parsetree mapper to actually apply the tlm.
 * This file is kept sparse so that it may be opened without concern and we
 * don't have to qualify every index into a application record's data. *)

type dependency = Module of Ident.t * Types.module_declaration
                | Type of Ident.t * Types.type_declaration

type t = {
  body: string;
  longident: Longident.t;
  lexer: string;
  parser: string;
  nonterminal: string;
  package: string;
  dependencies: dependency list;
  env: Env.t;
  loc: Location.t;
}
