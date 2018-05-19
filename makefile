
# we need this environment variable because
# cram runs everything in a temp directory and
# we want to share some functionality between tests.
test: build_ppx build_install
	find tests -name '*.t' | ORIGINAL_DIR=`pwd` xargs cram

test_i: build_ppx build_install
	ORIGINAL_DIR=`pwd` cram -i `find tests -name '*.t' | xargs echo`

build_ppx:
	jbuilder build ppx/ppx_relit.exe

build_examples: build_ppx build_install
	ocamlbuild -use-ocamlfind -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" -pkg regex_notation examples/simple_ocaml.native

build_install:
	jbuilder build @install
	jbuilder install regex_notation >/dev/null
	jbuilder install relit_helper >/dev/null
	jbuilder install ppx_relit >/dev/null

clean:
	@rm -rf _build
	@rm -f ppx/ppx_relit.cmx
	@rm -f ppx/ppx_relit.cmi
	@rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
