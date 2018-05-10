
test:
	cram tests/*.t

old_tests: build_ppx install_regex_notation install_ppx_relit
	ocamlbuild -use-ocamlfind -cflags "-ppx ppx_relit" \
		-pkg regex_notation \
		tests/regex_internal.native
	./regex_internal.native

build_ppx:
	jbuilder build ppx/ppx_relit.exe

install_regex_notation: build_install
	jbuilder install regex_notation

install_ppx_relit: build_install
	jbuilder install ppx_relit

build_install:
	jbuilder build @install

clean:
	rm -rf _build
	rm -f ppx/ppx_relit.cmx
	rm -f ppx/ppx_relit.cmi
	rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
