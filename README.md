# Relit: Typed Literal Macros for Reason

[Reason](https://reasonml.github.io/) is an increasingly popular alternative syntax for OCaml designed by engineers at Facebook to make OCaml more notationally comfortable for contemporary programmers. However, Reason, like OCaml, builds in literal notation for only a few common data structures, e.g. list literals like `[x, y, z]`, array literals like `[|x, y, z|]`, and [JSX literals](https://reasonml.github.io/docs/en/jsx), which support an extension of HTML notation. This centralized approach to literal notation is unsatisfying because there are many other possible data structures for which literal notation might be useful, e.g. for finite maps, regular expressions, SQL queries, syntax tree representations, and chemical structures expressed using [SMILES notation](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system), to name just a few possibilities.

In [our ICFP 2018 paper](https://github.com/cyrus-/ptsms-paper/raw/master/icfp18/omar-icfp18-final.pdf) ([.bib](https://github.com/cyrus-/relit/blob/master/relit.bib)), we address this problem by introducing **typed literal macros (TLMs)** into Reason. TLMs allow a library provider to define new literal notation, of nearly arbitrary design, for expressions and patterns of any type at all. 

## Tutorial: Regex Notation

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

Applying these constructors directly is notationally costly, so let's define a TLM named `$regex` (pronounced "lit regex") that implements POSIX-style regex notation. The definition of `$regex`, which we place by convention into a module named `Regex_notation`, is outlined below (note that GitHub does not yet know how to highlight our extensions to Reason).
```reason
module Regex_notation = { 
  notation $regex at Regex.t { /* ... full definition given under "TLM Definitions" below ... */ }
};
```

A client programmer can apply `Regex_notation.$regex` as follows to construct a value of type `Regex.t`:
```reason
let r = Regex_notation.$regex `(a*bb(b|a)b)`;
```
The applied TLM is responsible at compile-time for parsing and expanding the *literal body*, here `a*bb(b|a)b`, to an OCaml expression. The literal body can be any character sequence as long as any occurrences of the outer delimiters, `` `( `` and `` )` ``, are balanced. In this case, the expansion is the following expression, which is clearly more notationally costly (by a variety of measures) than the TLM application above:
```reason
Regex.(Seq(Star(Str("a")), Seq(Str("b"), Seq(Str("b"), Seq(Or(Str("b"), Str("a")), Str("b")))))
```

### Abbreviations
To make TLM application even more concise, we can open `Regex_notation` to bring `$regex` into scope:
```reason
open Regex_notation;
let r = $regex `(a*bb(b|a)b)`;
```
or define the abbreviation `$r` for `Regex_notation.$regex`:
```reason
notation $r = Regex_notation.$regex;
let r = $r `(a*bb(b|a)b)`;
```

or implicitly apply `Regex_notation.$regex` to all bare literals in scope of the `open notation` directive:
```reason
open notation Regex_notation.$regex;
let r = `(a*bb(b|a)b)`;
```
or use the alternative parenthesis-delimited version of `open notation` for the same purpose:
```reason
let r = Regex_notation.$regex.( `(a*bb(b|a)b)` )
```

### Splicing

Sometimes we will want to construct a regex value compositionally, i.e. by building up from other values. To support this, `$regex` recognizes the notation `$(e)` for a spliced regex value, and `$$(e)` for a spliced string value, where `e` is a Reason expression of arbitrary form (in particular, `e` might itself apply TLMs). For example, we can splice one regex, `DNA.any_base`, into another, `bisI` (BisI is a restriction enzyme, see [here](https://pythonforbiologists.com/regular-expressions/)), as follows:

```reason
open notation Regex_notation.$regex;
module DNA = {
  let any_base = `(A|T|G|C)`;
};
let bisI = `(GC$(DNA.any_base)GC)`;
```

Each TLM decides for itself how it recognizes spliced expressions within the literal body. 

Keep in mind that the literal body is expanded at compile-time, so using TLMs together with composite representations of data structures like regexes and SQL queries can help programmers avoid [injection attacks](https://en.wikipedia.org/wiki/Code_injection) without giving up the notational benefits of string representations.

Splicing is also sometimes called interpolation because it generalizes [string interpolation](https://en.wikipedia.org/wiki/String_interpolation) as featured in many languages. Splicing is also sometimes called unquotation or antiquotation because it generalizes the unquotation forms in code quotation systems, like those in various [Lisp dialects](https://en.wikipedia.org/wiki/Lisp_(programming_language)#Self-evaluating_forms_and_quoting) and many other languages. 

### Typing, Hygiene and Segmentation

When you encounter an unfamiliar notation, you do not need to peek at the underlying expansion or the parser to reason about types and binding. Instead, the system maintains the following abstract reasoning principles:

  1. **Expansion Typing**: Each TLM has a type annotation—`at Regex.t` on `$regex` above—that determines the type of the generated expansion.
  2. **Context Independence**: The expansion is context independent, meaning that it does not make any assumptions about which variables (including module variables) are in scope. Therefore, you can name and rename variables or imports without thinking about the expansion's dependencies (see below for more on how dependencies are managed).
  3. **Segmentation**: Spliced expressions must be non-overlapping and separated by at least one character. This ensures that there is always a unique segmentation of every literal body into spliced expressions and expressions parsed in some other way by the applied TLM.

  4. **Segment Typing**: Each spliced expression is labeled with an expected type by the applied TLM. This information is currently used when reporting type errors. In the future, we expect to convey segmentation and segment typing information interactively within the editor.
  5. **Capture Avoidance**: Spliced expressions are capture avoiding, meaning that any variables that appear in a spliced expression cannot capture bindings internal to the expansion. Consider the following example:

     ```reason
     let tmp = DNA.any_base;
     let bisI = $regex `(GC$(tmp)GC)`
     ```

     Even if the expansion generated by the TLM above happens to bind a variable named `tmp`, the system ensures that the reference to `tmp` in the spliced expression will always refer to the visible binding of `tmp` on the first line.

     The context independence and capture avoidance principles together are sometimes referred to as the hygiene principles. Relit is strictly hygienic—there is no way for a TLM to opt out of these restrictions.

The ICFP paper investigates these reasoning principles in formal detail (i.e. with a typed lambda calculus and proofs).

### TLM Definitions
_TODO - everything below_


```reason
module Regex_notation = { 
  notation $regex at Regex.t { /* full definition given under "TLM Provider Perspective" below */ }
    lexer Regex_parser.Lexer
    parser Regex_parser.Parser.start 
    in package regex_parser;
    dependencies = {
      module Regex = Regex;
    };
  };
};
```

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

Finally, you can clone the Relit repo and `make`, which will install the Relit ppx and execute the tests:

```
git clone https://github.com/cyrus-/relit
cd relit
make
```

To use Relit, make sure you include the Relit ppx in your build process.

Note that while Relit should in theory work on Windows, we have not tested
this. If you get it to work, let us know!

## How It Works


The ppx execution starts in `ppx_relit/ppx_relit.ml` at the very last line
of the file. Generally reading up from there will give you a good idea
of what's going on, and specifically the function `relit_expansion_pass`
is supposed to provide a high-level overview.


## Current Limitations

 * Relit does not currently implement pattern TLMs or parametric TLMs.
 * Does not currently work with Dune (jbuilder)
 * TODO: other stuff and issue links
 * The warning 

      ```
      [WARNING] Interface topdirs.cmi occurs in several directories: /home/ygrek/.opam/4.02.1/lib/ocaml/compiler-libs, /home/ygrek/.opam/4.02.1/lib/ocaml
      ```

   is due to a [bug in OCaml](https://caml.inria.fr/mantis/view.php?id=6754).

## Contributors

 * Cyrus Omar
 * Charles Chamberlain

