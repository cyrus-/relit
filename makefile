
## The basics

test:
	dune runtest

build:
	dune build

## Some simple examples for your convienence!

simple_example:
	dune build simple_tests/simple_example.exe
	dune exec simple_tests/simple_example.exe

spliced_ocaml:
	dune build simple_tests/spliced_ocaml.exe
	dune exec simple_tests/spliced_ocaml.exe

splice_in_splice:
	dune build simple_tests/splice_in_splice.exe
	dune exec simple_tests/splice_in_splice.exe

my_first_timeline:
	dune build simple_tests/my_first_timeline.exe
	dune exec simple_tests/my_first_timeline.exe

install:
	dune build @install
	dune install regex_parser
	dune install test_parser
	dune install timeline_parser
	dune install regex_example
	dune install timeline_example
	dune install test_example
	dune install relit_helper
	dune install ppx_relit

clean:
	@rm -rf _build

.PHONY: build test install clean simple_example spliced_ocaml splice_in_splice my_first_timeline
