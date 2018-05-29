
# we need this environment variable because
# cram runs everything in a temp directory and
# we want to share some functionality between tests.
test: ppx_relit install
	@echo Running `find tests -name '*.t' | wc -l` tests
	@find tests -name '*.t' | ORIGINAL_DIR=`pwd` xargs cram

test_i: ppx_relit install
	ORIGINAL_DIR=`pwd` cram -i `find tests -name '*.t' | xargs echo`

ppx_relit:
	jbuilder build ppx_relit/ppx_relit.exe

simple_ocaml: ppx_relit install
	ocamlbuild -use-ocamlfind \
		-cflags "-ppx `pwd`/_build/default/ppx_relit/ppx_relit.exe" \
		-pkg regex_example examples/simple_examples/simple_ocaml.native

spliced_ocaml: ppx_relit install
	ocamlbuild -use-ocamlfind \
		-cflags "-ppx `pwd`/_build/default/ppx_relit/ppx_relit.exe" \
		-pkg regex_example examples/simple_examples/spliced_ocaml.native

splice_in_splice: ppx_relit install
	ocamlbuild -use-ocamlfind \
		-cflags "-ppx `pwd`/_build/default/ppx_relit/ppx_relit.exe" \
		-pkg regex_example examples/simple_examples/splice_in_splice.native

examples:  simple_ocaml spliced_ocaml splice_in_splice

install:
	jbuilder build @install
	jbuilder install regex_parser >/dev/null
	jbuilder install test_parser >/dev/null
	jbuilder install regex_example >/dev/null
	jbuilder install test_example >/dev/null
	jbuilder install relit_helper >/dev/null
	jbuilder install ppx_relit >/dev/null

clean:
	@rm -rf _build
	@rm -f ppx/ppx_relit.cmx
	@rm -f ppx/ppx_relit.cmi
	@rm -f ppx/ppx_relit.o

.PHONY: build run ppx px install clean test test_i
