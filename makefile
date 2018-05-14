
# we need this environment variable because
# cram runs everything in a temp directory and
# we want to share some functionality between tests.
test: build_ppx install_regex_notation install_ppx_relit
	find tests -name '*.t' | ORIGINAL_DIR=`pwd` xargs cram

test_i: build_ppx install_regex_notation install_ppx_relit
	ORIGINAL_DIR=`pwd` cram -i `find tests -name '*.t' | xargs echo`

build_ppx:
	jbuilder build ppx/ppx_relit.exe

install_regex_notation: build_install
	jbuilder install regex_notation >/dev/null

install_ppx_relit: build_install
	jbuilder install ppx_relit >/dev/null

build_install:
	jbuilder build @install

clean:
	@rm -rf _build
	@rm -f ppx/ppx_relit.cmx
	@rm -f ppx/ppx_relit.cmi
	@rm -f ppx/ppx_relit.o

.PHONY: build run build_ppx
