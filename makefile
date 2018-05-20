
# we need this environment variable because
# cram runs everything in a temp directory and
# we want to share some functionality between tests.
test: ppx install
	find tests -name '*.t' | ORIGINAL_DIR=`pwd` xargs cram

test_i: ppx install
	ORIGINAL_DIR=`pwd` cram -i `find tests -name '*.t' | xargs echo`

ppx:
	jbuilder build ppx/ppx_relit.exe

simple_ocaml: ppx install
	ocamlbuild -use-ocamlfind -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" -pkg regex_notation examples/simple_ocaml.native

spliced_ocaml: ppx install
	ocamlbuild -use-ocamlfind -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" -pkg regex_notation examples/spliced_ocaml.native

splice_in_splice: ppx install
	ocamlbuild -use-ocamlfind -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" -pkg regex_notation examples/splice_in_splice.native

examples:  simple_ocaml spliced_ocaml splice_in_splice

install:
	jbuilder build @install
	jbuilder install regex_notation >/dev/null
	jbuilder install relit_helper >/dev/null
	jbuilder install ppx_relit >/dev/null

clean:
	@rm -rf _build
	@rm -f ppx/ppx_relit.cmx
	@rm -f ppx/ppx_relit.cmi
	@rm -f ppx/ppx_relit.o

.PHONY: build run ppx px install clean test test_i
