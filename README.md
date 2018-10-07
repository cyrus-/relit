# Relit: Typed Literal Macros for Reason

<img src="./blazelit-small.png" alt="Blazelit: the cute logo for Relit" align='right' />

[Reason](https://reasonml.github.io/) is an increasingly popular alternative syntax for OCaml designed by engineers at Facebook to make OCaml more notationally comfortable for contemporary programmers. However, Reason, following OCaml, builds in literal notation for only a few common data structures, e.g. list literals like `[x, y, z]`, array literals like `[|x, y, z|]`, and [JSX literals](https://reasonml.github.io/docs/en/jsx), which support an extension of HTML notation. This approach is unsatisfying because there are many other possible data structures for which literal notation might be useful, e.g. for finite maps, regular expressions, SQL queries, syntax tree representations, and chemical structures expressed using [SMILES notation](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system), to name just a few possibilities.

In [our ICFP 2018 paper](https://github.com/cyrus-/ptsms-paper/raw/master/icfp18/omar-icfp18-final.pdf) ([.bib](https://github.com/cyrus-/relit/blob/master/relit.bib), [video](https://www.youtube.com/watch?v=F_0yKqb1uEA), [slides](https://github.com/cyrus-/relit/raw/master/tlms-icfp18.pdf)), we address this problem by introducing **typed literal macros (TLMs)** into Reason. TLMs allow the programmer to define new literal notation, of nearly arbitrary design, for expressions and patterns of any type at all.

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

Applying these constructors directly is notationally costly, so let's define a TLM named `$regex` (pronounced "lit regex") that implements the familiar POSIX-style regex notation. The definition of `$regex`, which we place by convention into a module named `Regex_notation`, is outlined below (note that GitHub does not yet know how to highlight our extensions to Reason).
```reason
module Regex_notation = {
  notation $regex at Regex.t { /* ... full definition given under "TLM Definitions" below ... */ }
};
```

The client programmer can apply `Regex_notation.$regex` as follows to construct a value of type `Regex.t`:
```reason
let r = Regex_notation.$regex `(a*bb(b|a)b)`;
```
The applied TLM is responsible at compile-time for parsing and expanding the *literal body*, here `a*bb(b|a)b`, to an OCaml expression. The literal body can be any character sequence as long as any occurrences of the outer delimiters, `` `( `` and `` )` ``, are balanced. In this case, the expansion is the following expression, which is clearly more notationally costly (by a variety of measures) than the TLM application above:
```reason
Regex.(Seq(Star(Str("a")), Seq(Str("b"), Seq(Str("b"), Seq(Or(Str("b"), Str("a")), Str("b")))))
```

### Abbreviations
To make TLM applications even more concise, we can `open Regex_notation` as usual to bring `$regex` into scope:
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

Sometimes we want to construct a regex value compositionally, i.e. by "splicing together" other values. To support this, `$regex` recognizes the notation `$(e)` for a spliced regex value, and `$$(e)` for a spliced string value, where `e` is a Reason expression of arbitrary form (so `e` might even itself apply TLMs). For example, we can splice one regex, `DNA.any_base`, into another, `bisI` (BisI is a restriction enzyme, see [here](https://pythonforbiologists.com/regular-expressions/)), as follows:

```reason
open notation Regex_notation.$regex;
module DNA = {
  let any_base = `(A|T|G|C)`;
};
let bisI = `(GC$(DNA.any_base)GC)`;
```

Each TLM decides for itself how it recognizes spliced expressions.

Keep in mind that the literal body is expanded at compile-time, so using TLMs together with composite representations of data structures like regexes and SQL queries can help programmers avoid [string injection attacks](https://en.wikipedia.org/wiki/Code_injection) without giving up the notational benefits of string representations.

Splicing is also sometimes called interpolation because it generalizes [string interpolation](https://en.wikipedia.org/wiki/String_interpolation) as featured in many languages. Splicing is also sometimes called unquotation or antiquotation because it generalizes the unquotation forms in code quotation systems, like those in various [Lisp dialects](https://en.wikipedia.org/wiki/Lisp_(programming_language)#Self-evaluating_forms_and_quoting) and many other languages.

### Typing, Hygiene and Segmentation

User-defined notation is great when you are familiar with it, but what about when you encounter an unfamiliar  notation? TLMs were carefully designed to be uniquely reasonable in this situation. In particular, you do not need to peek at the generated expansion or the details of the parser to reason about types and binding in a program that uses TLMs. Instead, the system maintains the following important abstract reasoning principles:

  * **Expansion Typing**: Each notation definition specifies a type annotation—`at Regex.t` on `$regex` above—that determines the type of the generated expansion.
  * **Context Independence**: The expansion is guaranteed to be context independent, meaning that it does not make any assumptions about which variables (including module variables) are in scope at the application site. Therefore, clients can rename variables and manage imports without thinking about the expansion's dependencies. For example, the `Regex` module can be shadowed, or even out of scope entirely, when applying `$regex`, even though the expansion uses the constructors defined in the `Regex` module (see below for more on how dependencies are managed).
  * **Capture Avoidance**: Spliced expressions are capture avoiding, meaning that any variables that appear in a spliced expression cannot capture bindings internal to the expansion. Consider the following example:

     ```reason
     let tmp = DNA.any_base;
     let bisI = $regex `(GC$(tmp)GC)`
     ```

     Even if the expansion generated by the TLM above happens to bind a variable named `tmp` for internal use, the system ensures that the reference to `tmp` in the spliced expression will always refer to the binding of `tmp` on the first line.

     The context independence and capture avoidance principles together are referred to as the hygiene principles. Relit is strictly hygienic—there is no way for a TLM to opt out of these restrictions.
  * **Segmentation**: Spliced expressions must be separated by at least one character. This ensures that there is always a unique segmentation of every literal body into spliced expressions and characters parsed in some other way by the TLM.

  * **Segment Typing**: Each spliced expression is also labeled with an expected type by the applied TLM. This information is currently used when reporting type errors. In the future, we expect to convey the segmentation and segment typing information interactively within the program editor.

The ICFP paper investigates these reasoning principles in formal detail (i.e. with a typed lambda calculus and proofs).

### TLM Definitions
Let us now consider the full definition of `Regex_notation.$regex`, given below.

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
#### Scoping

A TLM definition can appear anywhere a module definition can appear, and TLM definitions follow the same scoping rules as modules (internally, they are implemented as modules with singleton signatures; see the paper).

#### Lexing and Parsing

Each TLM must specify a lexer, here `Regex_parser.Lexer`, and a parser, here `Regex_parser.Parser.start`, where `start` is the name of the starting non-terminal.
The lexer and parser will be loaded and invoked at compile-time. To cleanly facilitate this, the lexer and parser must be packaged into a named [ocamlfind](http://projects.camlcity.org/projects/findlib.html) package, here indicated by `in package regex_parser`.

The lexer must be generated by (or satisfy the same interface as lexers generated by) [ocamllex](https://caml.inria.fr/pub/docs/manual-ocaml/lexyacc.html) and the parser must be generated by (or satisfy the same interface as parsers generated by) [Menhir](http://gallium.inria.fr/~fpottier/menhir/), which is a modernized derivative of ocamlyacc. These are the most popular and mature lexer and parser generators within the OCaml ecosystem, and notably, Reason itself is implemented using these same generators. [Chapter 16](https://v1.realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html) of *Real World OCaml* nicely introduces both.

We will not detail the regex lexer and parser definitions here, but the ICFP paper (Sec. 2.2) does cover them. The full definitions can be found alongside the rest of the definitions above in the [`example_tlms/regex_example`](https://github.com/cyrus-/relit/tree/master/example_tlms/regex_example) directory. For the most part, they are entirely standard lexer and parser definitions. The only interesting bit has to do with splicing: the paper describes how splicing is implemented at the level of the lexer by invoking a helper function, `Relit.Segment.read_to`, in the `relit_helper` package. Ultimately, the parser generates [standard OCaml parse trees](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Parsetree.html), with a special representation for tracking spliced expressions (see paper). We rely on the [`metaquot` library](https://github.com/ocaml-ppx/ppxlib#metaquot-and-metaquot_lifters) to make the generation of parse trees notationally tractable. (In the future, we might switch to TLMs as suggested in the paper, but the existing library is more mature.)

#### Dependencies
Each TLM definition also provides a listing of expansion dependencies, i.e. types and modules from the definition site that expansions generated by the parser might need access to (other than `Pervasives`, which are implicitly opened). In the example above, there is a single dependency on the `Regex` module, which expansions can refer to internally also as `Regex` (the internal name can differ in general). The system ensures that the dependencies are available at all application sites, including those where `Regex` might be unbound or bound to a different module. This maintains the context independence principle described above.

The paper further motivates this design decision, but briefly, explicit dependencies serve to ensure that renamings need not propagate into the parse trees constructed in the parser (where variables are represented using strings), and it also serves to maintain the abstraction discipline of the OCaml module system (making all bindings at the definition site implicitly available at application sites would require violating abstraction).

## More Examples and Tests

We've got an `examples_tlms` directory that is the home of several example notations we've defined using Relit.

To see some simple uses of these examples, look under `simple_tests`. To build and run them:

```
make {simple_example,spliced_ocaml,splice_in_splice,my_first_timeline}
```

Run `make` to run the full test suite. Those tests are pretty clear to read! Check out `test/test.ml`.

There is also a [standlone repository that defines a TLM for lists](https://github.com/charlesetc/example-tlm) and can be used as a project template for TLM providers.

## Installation

First, make sure you have [opam](https://opam.ocaml.org/). Then make sure you have **OCaml 4.06.1** by running `opam switch`.

Next install the very latest version of dune (version 1.3.0 had a bug that we fixed, so the next release of Dune should be fine):

```
git clone https://github.com/ocaml/dune
opam pin add ./dune
```

Then, install the rest of the dependencies:

```
opam install ppxlib.0.3.0 menhir extlib base64 ppx_expect
```

Next, you need to install our fork of the Reason parser:

```
opam remove reason
git clone https://github.com/charlesetc/reason
cd reason
git checkout reason-d-etre
make
make install
cd ..
```

Finally, check out this repository and run the following:

```
git clone https://github.com/cyrus-/relit
cd relit
make install
make test
```

To use Relit in your own project, you just have to include the Relit ppx, `ppx_relit`, in your build process.
With dune (which we strongly recommend), use `(preprocess (staged_pps ppx_relit))` as you can see in `simple_tests/dune`. Note that you need
to use the `staged_pps` option.

Note that while Relit should in theory work on Windows, we have not tested
this. If you get it to work, let us know!

## How It Works

The ppx execution starts in `ppx_relit/ppx_relit.ml` at the very last line
of the file. Generally reading up from there will give you a good idea
of what's going on, and specifically the function `relit_expansion_pass`
is supposed to provide a high-level overview.

There's also a [four page talk proposal](./relit-ocaml-workshop.pdf) and [slides](http://files.narwhal.space/relit/talk.html) that cover the implementation in a little more detail.
We're happy to discuss the implementation with anyone who wants to work on it or implement TLMs in another language!

### Debug Mode

Relit does provide a way to peek at the underlying expansion of macros when the need arises.

Setting the environment variable `RELIT_DEBUG=true` within the build environment will trigger the Relit PPX to print its fully-expanded AST to stderr. For example, a file that looks like :

```reason
open Regex_example;

let regex = Regex_notation.$regex `(a|b*)`;

let () = print_endline(Regex.show(regex));
```

will cause the Relit PPX to print out the following (comments added here for clarity):

```reason

open Regex_example;

/* type annotation (moved to the let binding by the pretty-printer) ensures
   that the expansion is of the expected type */
let regex: Regex_notation.RelitInternalDefn_regex.t =
  (
    /* open this first to avoid edge case where path to TLM is through a 
       shadowed module in Pervasives */
    [@warning "-33"] /* suppresses warnings when a dependency is not used */
    Regex_notation.RelitInternalDefn_regex.( 
      [@warning "-33"]
      Pervasives.(
        [@warning "-33"]
        Dependencies.( /* open the dependencies */
          () => /* no spliced expressions, so this is an empty argument list */
            /* the generated expansion itself */
            Regex.Or(
              Regex.Or(Regex.Str("a"), Regex.Str("b")),
              Regex.Str("c"),
            )
        )
      )
    )
  )();

let () = print_endline(Regex.show(regex));
```

This ends up showing a lot of the implementation details of Relit.
Relit is designed to ensure that TLM readers and users
should rarely have to look at the expansion of a TLM application.
Debug mode is mainly targeted towards authors of TLM definitions: it allows
TLM writers to debug their parsers easily.

## Current Limitations

 * Relit does not yet implement pattern TLMs.
 * Relit does not yet implement parametric TLMs. As a somewhat awkward workaround, you can use parameterized modules (functors), e.g. see [this example of a TLM for lists](https://github.com/charlesetc/example-tlm).
 * Relit doesn't work within the toploop/rtop/utop.
 * The following warning will come up a lot: 

      ```
      [WARNING] Interface topdirs.cmi occurs in several directories: /home/cyrus/.opam/4.06.1/lib/ocaml/compiler-libs, /home/cyrus/.opam/4.06.1/lib/ocaml
      ```

   It is harmless. It is due to a [bug in OCaml](https://caml.inria.fr/mantis/view.php?id=6754).

## Contributors

 * Charles Chamberlain
 * Cyrus Omar

