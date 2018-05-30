# Relit

Relit is an implementation of Typed Literal Macros (TLMs) for Reason.
TLMs allow a programmer to define a new `notation` by providing a lexer
and parser. These notations can be imported, opened, and aliased the same
way modules can be in Reason. The killer feature is that the parser
can specify a way to "splice" in Reason code in a context independent
and capture avoiding way.

# Basic usage


This is a notation definition:
```reason
module Notation 

  notation $regex at Regex.t {
    lexer Lexer and parser Parser in regex_parser;
    dependencies {
      module Regex = Regex;
    };
  };

end
```

And then you can use the notation:
```reason
let r = Notation.$regex `(a*bbb|ab)`;
```

Or import the notation:
```reason
open Notation;
let r = $regex `(a*bbb|ab)`;
```

Or open the notation:
```reason
open Notation.$regex;
let r = `(a*bbb|ab)`;
```

# Splicing

Relit allows parser to return a splice of the TLM's body, which gets parsed
as Reason code. For example, our regex lexer could choose `$()` to indicate a splice.
(The provided example, in fact, does.)

This allows for spliced notation like so:

```reason
module DNA_match {
  open Notation.$regex

  let any_base = `(A|C|T|G)`;

};

/* a segment of dna */
let bis_a = `(GC$( /* this is a splice */ DNA_match.any_base)GC)`;
```

# Tests

Run `make` to run the test suite.

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
splicing syntax. To get this, `git clone https://github.com/charlesetc/reason`
and checkout the `reason-d-etre` branch. Then run `make && make install`.

Our goal is to get everything on opam to make this process smoother.

# Notes
The warning 

```[WARNING] Interface topdirs.cmi occurs in several directories: /home/ygrek/.opam/4.02.1/lib/ocaml/compiler-libs, /home/ygrek/.opam/4.02.1/lib/ocaml```

is due to a [https://caml.inria.fr/mantis/view.php?id=6754](bug in OCaml).

# Windows

Theoretically supported but not tested on Windows.
