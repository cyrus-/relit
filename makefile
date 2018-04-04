
run: build
	./regex_internal.native

build: build_ppx
	ocamlbuild -cflags "-ppx `pwd`/_build/default/ppx/ppx_relit.exe" \
		tests/regex_internal.native

build_ppx:
	jbuilder build ppx/ppx_relit.exe

clean:
	rm -rf _build
	rm -f ppx/ppx_relit.cmx
	rm -f ppx/ppx_relit.cmi
	rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
