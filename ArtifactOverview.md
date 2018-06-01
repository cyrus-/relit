# Getting Started

The artifact takes the form of a VirtualBox image where our fork of the Reason
parser and all other necessary dependencies have been pre-installed.

After starting the virtual machine in the usual manner, open the terminal. 
There are two directories of interest under the home directory:

  * `reason` contains our fork of the Reason parser and pretty-printer. We have
    already set up opam (the OCaml package manager) to refer to this directory 
    for the reason package, so nothing needs to be done here.

  * `relit` contains the Relit PPX, several examples and our tests.

To get started, simply run `make` within the `relit` directory. This will 
compile the examples and run all of the tests in the `relit/tests` directory. 
A confirmation that all tests passed will be printed to the terminal.

We use the `cram` command line testing utility. Each test consists of a 
`.t` file that briefly describes the test and a `.re` file that contains 
the corresponding code. The tests load the example packages from the 
`relit/examples` directory (see `relit/makefile` to see how).

NOTE: If necessary, the username/password for the VM is relit/relit.

# Evaluation Steps

The purpose of this artifact is to demonstrate the "core features" of the 
system described in the companion paper. In particular, the artifact supports
expression TLMs and maintains all six of the abstract reasoning principles that 
are central to the paper. To verify this, the reader should do the following
after verifying that the tests all pass as described above:

 - Read the definitions in the `relit/examples/regex_example` directory, 
   and compare them to Fig. 3a, Fig. 3b and Fig. 5. Some minor changes have
   been made since the time of the paper submission mainly having to do with 
   explicitly packaging the lexer and parser. These changes will be included
   in the final version of the paper.
   
   The only major change has to do with the parser definition in Fig. 5. The 
   Menhir parser generator does not yet support the use of Reason within .mly
   files, so we cannot yet use a quasiquotation TLMs as shown in Fig. 5b. 
   Instead, we use a PPX-based quasiquotation system (metaquot) to achieve 
   the same meaning in the file:
   
     `relit/examples/regex_example/regex_parser/parser.mly`

 - Read the test in `relit/tests/figure3c.t` and `relit/tests/figure3c.re`
   and compare to Fig. 3c.

 - Read the other tests in the tests directory, which demonstrate the various
   mechanisms related to the reasoning principles from the paper.

   Some of these tests use the "testing TLM" defined in `examples/test_example`
   as a utility to demonstrate various features of the system in a simple 
   setting.

If the reader wishes to define new tests for the same examples, they can do so 
by copying an existing test and modifying the path after the call to `reason`
to refer to the corresponding new Reason file -- the makefile will find all `.t`
files in the `tests` directory.

If the reader wishes to define a new TLM package, they can do so by 

  (1) copying the `relit/examples/regex_example` directory and changing the 
      file names appropriately in all of the files, and
  
  (2) copying the lines related to loading this example in `makefile` to load
      the new package into each test analagously.

We also include a few lightweight examples in `examples/simple_examples` that
do not use `cram`. You can run `make examples` to compile these. To add new 
lightweight examples, simply define a new `.re` file and copy the corresponding
lines in the `makefile`.

If the reader wishes to examine the source code, it is included in the 
`reason` and `relit` directories (which are git repos). In particular, the file

  relit/ppx_relit/ppx_relit.ml

can be read starting from the bottom to understand the process of TLM
expansion. We also include a short write-up describing the implementation 
(which was submitted to the OCaml Workshop) on the desktop, for the
curious reader.

# Unimplemented Features

The following features are described in the paper, but they are not 
implemented in this artifact as submitted.

- Pattern TLMs
- `open notation` for implicit TLM application
- Notation for TLM definitions in signatures
- Explicit parametric TLMs (the alternative encoding in Sec. 4 is possible)
- MetaOCaml-based examples

In addition, the error messages are not very good yet.

These are all "secondary features" -- the core idea of the paper has to do 
with maintaining the six reasoning principles, which we demonstrate with 
the main regex example and the additional tests as described above.

(We plan to have these remaining features, as well as substantial additional
examples and conveniences, by the time of the conference.)
