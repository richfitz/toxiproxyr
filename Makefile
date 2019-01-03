RSCRIPT = Rscript --no-init-file

test:
	TOXIPROXYR_SERVER_BIN_PATH=${PWD}/.toxiproxy ${RSCRIPT} -e 'library(methods); devtools::test()'

roxygen:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

install_toxiproxy:
	TOXIPROXYR_SERVER_INSTALL=true inst/server/install-server.R .toxiproxy

uninstall_toxiproxy:
	rm -rf .toxiproxy

build:
	R CMD build .

check:
	_R_CHECK_CRAN_INCOMING_=FALSE make check_all

check_all:
	TOXIPROXYR_SERVER_BIN_PATH=${PWD}/.toxiproxy ${RSCRIPT} -e "rcmdcheck::rcmdcheck(args = c('--as-cran', '--no-manual'))"

vignettes_src/%.Rmd: vignettes_src/%.R
	${RSCRIPT} -e 'library(sowsear); sowsear("$<", output="$@")'

vignettes/toxiproxyr.Rmd: vignettes_src/toxiproxyr.Rmd
	cd vignettes_src && Rscript -e 'knitr::knit("toxiproxyr.Rmd")'
	mv vignettes_src/toxiproxyr.md $@
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

vignettes/packages.Rmd: vignettes_src/packages.Rmd
	cd vignettes_src && Rscript -e 'knitr::knit("packages.Rmd")'
	mv vignettes_src/packages.md $@
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

vignettes_install: vignettes/toxiproxyr.Rmd vignettes/packages.Rmd
	Rscript -e 'library(methods); devtools::build_vignettes()'

vignettes:
	make vignettes_install

README.md: README.Rmd
	Rscript -e "options(warnPartialMatchArgs=FALSE); knitr::knit('$<')"
	sed -i.bak 's/[[:space:]]*$$//' README.md
	rm -f $@.bak

pkgdown:
	Rscript -e "library(methods); pkgdown::build_site()"

website: pkgdown
	./scripts/update_web.sh


.PHONY: test roxygen install build check check_all vignettes
