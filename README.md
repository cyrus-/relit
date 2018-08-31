# Relit: Typed Literal Macros for Reason

[Reason](https://reasonml.github.io/) is an increasingly popular alternative syntax for OCaml designed (initially by engineers at Facebook) to make OCaml more notationally familiar to contemporary programmers. However, Reason, like OCaml, builds in literals for only a few common data structures, e.g. list literals like `[x, y, z]`, array literals like `[|x, y, z|]`, and [JSX literals](https://reasonml.github.io/docs/en/jsx), which support a variation on HTML notation. This approach is unsatisfying because there are many other possible data structures for which literal notation may be useful, e.g. for finite maps, regular expressions, SQL queries, syntax tree representations, and specialized scientific data structures, e.g. the [SMILES notation](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system) in chemistry, to name just a few possibilities.

In [a paper at ICFP 2018](https://github.com/cyrus-/ptsms-paper/raw/master/icfp18/omar-icfp18-final.pdf), we address this problem by introducing *typed literal macros (TLMs)* into Reason. TLMs allow a library provider to define new literal notation, of nearly arbitrary design, for expressions and patterns of any type at all. 

## Example: Regex Notation

For example, say that we have defined a recursive datatype `Regex.t` classifying simple regular expressions:
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

Applying these constructors directly is notationally costly, so let's define a TLM named `$regex` that implements POSIX-style regex notation as follows (GitHub does not yet know how to highlight our extensions to Reason):
```reason
module Regex_notation = { 
  notation $regex at Regex.t {
    lexer Regex_parser.Lexer
    parser Regex_parser.Parser.start 
    in package regex_parser;
    dependencies = {
      module Regex = Regex;
    };
  };
};
```

The client can apply `$regex` as follows to construct a value of type `Regex.t`:
```reason
let r = Regex_notation.$regex `(a*bbb|ab)`;
```
The lexer and parser specified by the applied TLM is delegated responsibility at compile-time for parsing and expanding the literal body, here `a*bbb|ab`, to an OCaml expression (see below for more details on the TLM provider's perspective). In this case, the expansion is the following much more verbose and obscure expression:
```reason
Regex.(Seq(Star(Str("a")), Seq(Str("b"), Seq(Str("b"), Seq(Or(Str("b"), Str("a")), Str("b")))))
```

### Abbreviations
To make things even more concise, we can open the module containing the notation definition to bring it into scope:
```reason
open Regex_notation;
let r = $regex `(a*bbb|ab)`;
```
or abbreviate the notation definition:
```reason
notation $r = Regex_notation.$regex;
let r = $r `(a*bbb|ab)`;
```

or implicitly apply `$regex` to all bare literals in scope by opening it:
```reason
open notation Regex_notation.$regex;
let r = `(a*bbb|ab)`;
```

### Splicing

The example above didn't contain any sub-expressions, but sometimes we'll want to construct a regex value compositionally. To support this, Relit allows TLMs to _splice_ expressions out of the literal body for inclusion in the expansion. The TLM decides how it will recognize a spliced expression. For example, `$regex` recognizes the notation `$(e)` for spliced regex values, and `$$(e)` for spliced string values, where `e` is a Reason expression of arbitrary form (in particular, `e` can itself apply TLMs). For example, we can splice one regex, `DNA.any_base`, into another, `bisA`, as follows:

```reason
open notation Regex_notation.$regex;
module DNA = {
  let any_base = `(A|T|G|C)`;
};
let bisA = `(GC$(DNA.any_base)GC)`;
```

(Splicing is also sometimes called interpolation or unquotation/antiquotation.)

### Abstract Reasoning Principles

_TODO - everything below_

From the client programmer's perspective, TLMs are nice because they come equipped with powerful abstract reasoning principles—when you encounter a TLM application, you do not need to peek at the underlying expansion or the responsible parser to reason about types and binding. Instead, the system requires a type annotation on each TLM definition and maintains a strictly hygienic binding discipline to simplify life for client programmers, particularly when they encounter unfamiliar notation.

### Provider Perspective

The lexer and parser are defined...

## More Examples and Tests

We've got an `examples` directory that is the home of any example
notations we've defined using Relit.

Run `make` to run the corresponding test suite, in the `test` directory.

The tests are written to use [cram](https://bitheap.org/cram/), which makes
assertions about the output of commands executed at the terminal (in our 
case, the compiler with the Relit preprocessor enabled).

## Installation

First, make sure you have [opam](https://opam.ocaml.org/) and OCaml 4.04+ by running `opam switch`.

Then, install the necessary dependencies:

```
opam install ppxlib jbuilder menhir ocamlbuild extlib base64
```

Next, you need our fork of the Reason parser:

```
opam remove reason
git clone https://github.com/charlesetc/reason
cd reason
git checkout reason-d-etre
make
make install
```

To run the tests you also need the `cram` library. You can install this using `pip`.

```
pip install cram
```

Finally, you can clone the Relit repo and `make`, which will install the relit ppx and execute the tests:

```
git clone https://github.com/cyrus-/relit
cd relit
make
```

Note that while Relit should in theory work on Windows, we have not tested
this. If you get it to work, let us know!

## How It Works


The ppx execution starts in `ppx_relit/ppx_relit.ml` at the very last line
of the file. Generally reading up from there will give you a good idea
of what's going on, and specifically the function `relit_expansion_pass`
is supposed to provide a high-level overview.


## Current Limitations

 * Relit does not currently implement pattern TLMs or parametric TLMs.
 * TODO: other stuff 
 * The warning 

      ```
      [WARNING] Interface topdirs.cmi occurs in several directories: /home/ygrek/.opam/4.02.1/lib/ocaml/compiler-libs, /home/ygrek/.opam/4.02.1/lib/ocaml
      ```

   is due to a [bug in OCaml](https://caml.inria.fr/mantis/view.php?id=6754).

## Contributors

 * Cyrus Omar
 * Charles Chamberlain

