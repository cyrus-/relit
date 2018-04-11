
run: build
	./regex_internal.native

build: build_ppx install_regex_notation
	ocamlbuild -use-ocamlfind -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" \
		-pkg regex_notation \
		tests/regex_internal.native

build_ppx:
	jbuilder build ppx/ppx_relit.exe

install_regex_notation:
	jbuilder build @install
	jbuilder install regex_notation

clean:
	rm -rf _build
	rm -f ppx/ppx_relit.cmx
	rm -f ppx/ppx_relit.cmi
	rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
