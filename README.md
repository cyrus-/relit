# Relit

[Reason](https://reasonml.github.io/) is an increasingly popular alternative syntax for OCaml designed (initially by engineers at Facebook) to make OCaml more notationally familiar to contemporary programmers. However, Reason, like OCaml, builds in literal notation for only a few standard data structures, e.g. list literals like `[x, y, z]`, array literals like `[|x, y, z|]`, and [JSX literals](https://reasonml.github.io/docs/en/jsx), which support a variation on HTML notation. This approach is unsatisfying because there are many other possible literal notations that may be useful, e.g. for finite maps, regular expressions, SQL queries, syntax tree representations, and specialized scientific data structures, e.g. the SMILES notation in chemistry, to name just a few possibilities.

In [a paper at ICFP 2018](https://github.com/cyrus-/ptsms-paper/raw/master/icfp18/omar-icfp18-final.pdf), we address this problem by introducing *typed literal macros (TLMs)* into Reason. TLMs allow a library provider to define new literal notation, of nearly arbitrary design, for expressions and patterns of any type at all. "Relit" is what we call this implementation of TLMs for Reason.

The ICFP paper includes a thorough and accessible tutorial, from the perspectives of both the library provider and the client programmer. The paper also defines the system's type and hygiene discipline in formal detail. In this README, though, let's stick to a simple example that will demonstrate the essential ideas.

## Example: Regex Notation

Say that we have defined a recursive datatype `Regex.t` classifying simple regular expressions:
```reason
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

Then we can define a TLM definition as follows — Relit introduces the new `notation` keyword:
```reason
module Regex_notation = { 
  /* a TLM can be defined anywhere a module can be defined */
  notation $regex at Regex.t {
    lexer  Lexer 
    parser Parser 
    in package regex_parser;
    dependencies = {
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
open notation Regex_notation.$regex;
let r = `(a*bbb|ab)`;
```


### Splicing

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

From the client programmer's perspective, TLMs are nice because they come equipped with powerful abstract reasoning principles—when you encounter a TLM application, you do not need to peek at the underlying expansion or the responsible parser to reason about types and binding. Instead, the system requires a type annotation on each TLM definition and maintains a strictly hygienic binding discipline to simplify life for client programmers, particularly when they encounter unfamiliar notation.

## More Examples and Tests

We've got an `examples` directory that is the home of any example
notations we've defined using Relit.

Run `make` to run the corresponding test suite, in the `test` directory.

The tests are written to use [cram](https://bitheap.org/cram/), which makes
assertions about the output of commands executed at the terminal (in our 
case, the compiler with the Relit preprocessor enabled).

## Installation

```opam install ppxlib jbuilder menhir reason ocamlbuild extlib base64```

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

Note that while Relit should in theory work on Windows, we have not tested
this. If you get it to work, let us know!

## How It Works

The ppx execution starts in `ppx_relit/ppx_relit.ml` at the very last line
of the file. Generally reading up from there will give you a good idea
of what's going on, and specifically the function `relit_expansion_pass`
is supposed to provide a high-level overview.


## Notes
The warning 

```[WARNING] Interface topdirs.cmi occurs in several directories: /home/ygrek/.opam/4.02.1/lib/ocaml/compiler-libs, /home/ygrek/.opam/4.02.1/lib/ocaml```

is due to a [bug in OCaml](https://caml.inria.fr/mantis/view.php?id=6754).
