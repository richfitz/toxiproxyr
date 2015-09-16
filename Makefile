PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all:
	${RSCRIPT} -e 'library(methods); devtools::compile_dll()'

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

test_all:
	REMAKE_TEST_INSTALL_PACKAGES=true make test

roxygen:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

build:
	R CMD build .

README.md: README.Rmd
	Rscript -e 'library(methods); devtools::load_all(); knitr::knit("README.Rmd")'
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

check: build
	_R_CHECK_CRAN_INCOMING_=TRUE R CMD check --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

check_all:
	REMAKE_TEST_INSTALL_PACKAGES=true make check

clean:
	rm -f src/*.o src/*.so

vignettes/src/RedisAPI.Rmd: vignettes/src/RedisAPI.R
	${RSCRIPT} -e 'library(sowsear); sowsear("$<", output="$@")'

vignettes/RedisAPI.Rmd: vignettes/src/RedisAPI.Rmd
	cd vignettes/src && ${RSCRIPT} -e 'knitr::knit("RedisAPI.Rmd")'
	mv vignettes/src/RedisAPI.md $@
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

vignettes_install: vignettes/RedisAPI.Rmd
	${RSCRIPT} -e 'library(methods); devtools::build_vignettes()'

vignettes:
	rm -f vignettes/RedisAPI.Rmd
	make vignettes_install

.PHONY: clean all test document install vignettes
