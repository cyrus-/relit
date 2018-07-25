# Relit

[Reason](https://reasonml.github.io/) is an increasingly popular alternative syntax for OCaml designed to make OCaml more notationally familiar to contemporary programmers. However, Reason, like OCaml, builds in literal notation for only a few data structures, e.g. list literals (`[x, y, z]`) and array literals (`[|x, y, z|]`). This is unsatisfying because there are many other possible literal notations that may be useful to programmers in various domains where Reason/OCaml is semantically suitable but notationally unwieldy, e.g. for finite maps, regular expressions, HTML elements, SQL queries, syntax trees for various languages of interest, and specialized scientific notation, e.g. the SMILES notation for chemical structures.

In a paper at ICFP 2018 (link to come), Omar and Aldrich address this problem by introducing *typed literal macros (TLMs)*. TLMs allow a library provider to define new literal notation, of nearly arbitrary design, for any type or parameterized family of types. From the client's perspective, TLMs are nice because they come equipped with powerful abstract reasoning principles --- as a client, you do not need to peek at the underlying expansion or the parser implementation to reason about types and binding. The paper investigates these abstract reasoning principles in formal detail.

Relit is an implementation of TLMs for Reason.

# Example

Imagine we have defined a type `Regex.t` classifying simple regular expressions:
```
  module Regex = {
    type t = 
      | Empty
      | AnyChar 
      | Str(string)
      | Seq(t, t) 
      | Or(t, t) 
      | Star(t);
  };
```

Then we can define a TLM definition as follows -- Relit introduces the new `notation` keyword:
```reason
module Regex_notation = { 
  /* a TLM can be defined anywhere a module can be defined */
  notation $regex at Regex.t {
    lexer Lexer and parser Parser in regex_parser;
    dependencies {
      module Regex = Regex;
    };
  };
};
```

The client can apply the TLM as follows to construct a value, `r`, of type `Regex.t`:
```reason
let r = Regex_notation.$regex `(a*bbb|ab)`;
```
Parsing and expansion of the literal body, here `a*bbb|ab`, occurs at compile-time by the lexer and parser specified by the applied TLM (see below for the TLM provider's perspective).

To make things more concise, we can open the module containing the notation:
```reason
open Regex_notation;
let r = $regex `(a*bbb|ab)`;
```

Or even open the notation itself:
```reason
open Regex_notation.$regex;
let r = `(a*bbb|ab)`;
```

# Splicing

Relit allows parser to return a splice of the TLM's body, which gets parsed
as Reason code. For example, our regex lexer could choose `$()` to indicate a splice.
(The provided example, in fact, does.)

This allows for spliced notation like so:

```reason
module DNA_match = {
  open Notation.$regex

  let any_base = `(A|C|T|G)`;

};

/* a segment of dna */
let bis_a = `(GC$( /* this is a splice */ DNA_match.any_base)GC)`;
```

For more details about how this works, proofs and all, see
[this paper](https://github.com/cyrus-/ptsms-paper/raw/master/icfp18/syntax-icfp18.pdf).

```
Reasonably Programmable Literal Notation
Cyrus Omar, Jonathan Aldrich
International Conference on Functional Programming (ICFP)
```

# Examples

We've got an `examples` directory that is the home of any example
notations we've defined using Relit.

# Tests

Run `make` to run the test suite. See the `test` directory for all of them.

The tests are run using [cram](https://bitheap.org/cram/), which makes
assertions on the output of compiling and running many small ML files.

# Hacking / Reading

The ppx execution starts in `ppx_relit/ppx_relit.ml` at the very last line
of the file. Generally reading up from there will give you a good idea
of what's going on, and specifically the function `relit_expansion_pass`
is supposed to provied a high-level overview.

# Installation

```opam install ppxlib jbuilder menhir reason ocamlbuild extlib```

Then `git clone` this repository.

You will also want our fork of the Reason parser to support the
splicing syntax:

```
git clone https://github.com/charlesetc/reason
cd reason
make
make install
jbuilder install rebuild 
```

To get this, `git clone https://github.com/charlesetc/reason`
and checkout the `reason-d-etre` branch. Then run `make && make install`.

Our goal is to get everything on opam to make this process smoother.

# Notes
The warning 

```[WARNING] Interface topdirs.cmi occurs in several directories: /home/ygrek/.opam/4.02.1/lib/ocaml/compiler-libs, /home/ygrek/.opam/4.02.1/lib/ocaml```

is due to a [bug in OCaml](https://caml.inria.fr/mantis/view.php?id=6754).

# Windows

Theoretically supported but not tested on Windows.
