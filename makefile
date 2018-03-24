
run: build
	./regex_internal.native

build: build_ppx
	ocamlbuild -cflags "-ppx `pwd`/ppx_relit" tests/regex_internal.native

build_ppx:
	ocamlfind ocamlopt -package compiler-libs ocamlcommon.cmxa ppx/ppx_relit.ml -o ppx_relit

clean:
	rm -rf _build
	rm -f ppx/ppx_relit.cmx
	rm -f ppx/ppx_relit.cmi
	rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
