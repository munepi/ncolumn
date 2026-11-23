NCOLVER := $(shell awk '/ProvidesExplPackage\{ncolumn\}/{getline; split($$0, a, "[{}]"); print a[4]}' ncolumn.sty)

DOCS := ncolumn.pdf

## The TeX Live to test with: the directory of its binaries, e.g.
##   make test TEXBIN=/usr/local/texlive/2026/bin/universal-darwin
## (default: the one in PATH)
TEXBIN ?=

## A test is run again while its log asks for it ("Rerun to get ..."),
## at most this number of times: footnotes=span takes the height of
## the footnote area of each page from the .aux file.
MAXRUNS ?= 8

## The tcbpagefootnote and tcbnestbreak packages, for the tests with
## them (skipped if they are not there).  These tests take the packages
## from these directories, not from the TeX Live.
TPF ?= ../tcbpagefootnote
TNB ?= ../tcbnestbreak
HASTPF := $(wildcard $(TPF)/tcbpagefootnote.sty)
HASTNB := $(wildcard $(TNB)/tcbnestbreak.sty)

.PHONY: ctanzip
ctanzip: ncolumn.zip ## Archive for CTAN upload
ncolumn.zip: clean $(DOCS)
	git archive --format=tar --prefix=ncolumn/ HEAD | gtar -x
	## remove unpacked files
	cd ncolumn/ && \
		rm -f .gitignore Makefile ctan.toml
	## then, now just make archive
	zip -9 -r ncolumn.zip ncolumn/*
	rm -rf ncolumn
	@echo finished

.PHONY: ncolumn.pdf
ncolumn.pdf: ncolumn.tex ncolumn.sty
	pdflatex -interaction=nonstopmode -halt-on-error $<
	pdflatex -interaction=nonstopmode -halt-on-error $<

## Run the test suite ($(NCOLVER)):
##  * every test compiles without errors
##  * TESTS: NCOL-RESULT OK and no NCOL-* NG (see test-common.tex):
##      - test-basic, test-switch, test-footnote, test-footnote-span,
##        test-footnote-switch, test-samepage, test-marks, test-tate:
##        the state of the package for each page (the heights that are
##        reserved in each column, the spanning material and the marks
##        of each column) is the one that is expected;
##      - every footnote text is on the page of its mark;
##    and, after the last run, no ncolumn warning (but the one on
##    stfloats, which jlreq loads with LuaTeX)
##  * test-tate-*, test-japanese-tate-*: vertical writing (tarticle,
##    utarticle, ltjtarticle, jlreq)
##  * TWOCOLUMN: test-twocolumn.tex gives the same pages, pixel by
##    pixel (pdftoppm), with ncolumn and with \twocolumn of the LaTeX
##    kernel
##  * TCBPF, TCBNB: test-tcbpagefootnote.tex and test-tcbnestbreak.tex
##    (tcolorbox with the page footnotes of tcbpagefootnote and the
##    nested breakable boxes of tcbnestbreak, with each value of
##    "footnotes", with tagging and in vertical writing): as TESTS,
##    every footnote text has the width of the footnotes of the page,
##    and there is no overfull \vbox, no "% split" of \tracingpages (a
##    footnote that is split or held over) and no warning of the two
##    packages
##  * test-errors-*: the expected error message
## A test is "<engine>:<jobname>:<input>".  The output of the engine and
## of (x)dvipdfmx is kept in <jobname>.term.
TESTS := \
  pdflatex:test-basic-pdflatex:'\input test-basic' \
  xelatex:test-basic-xelatex:'\input test-basic' \
  lualatex:test-basic-lualatex:'\input test-basic' \
  platex:test-basic-platex:'\input test-basic' \
  uplatex:test-basic-uplatex:'\input test-basic' \
  pdflatex:test-switch-pdflatex:'\input test-switch' \
  xelatex:test-switch-xelatex:'\input test-switch' \
  lualatex:test-switch-lualatex:'\input test-switch' \
  platex:test-switch-platex:'\input test-switch' \
  uplatex:test-switch-uplatex:'\input test-switch' \
  pdflatex:test-footnote-pdflatex:'\input test-footnote' \
  xelatex:test-footnote-xelatex:'\input test-footnote' \
  lualatex:test-footnote-lualatex:'\input test-footnote' \
  platex:test-footnote-platex:'\input test-footnote' \
  uplatex:test-footnote-uplatex:'\input test-footnote' \
  pdflatex:test-footnote-span-pdflatex:'\input test-footnote-span' \
  xelatex:test-footnote-span-xelatex:'\input test-footnote-span' \
  lualatex:test-footnote-span-lualatex:'\input test-footnote-span' \
  platex:test-footnote-span-platex:'\input test-footnote-span' \
  uplatex:test-footnote-span-uplatex:'\input test-footnote-span' \
  pdflatex:test-footnote-switch-pdflatex:'\input test-footnote-switch' \
  xelatex:test-footnote-switch-xelatex:'\input test-footnote-switch' \
  lualatex:test-footnote-switch-lualatex:'\input test-footnote-switch' \
  platex:test-footnote-switch-platex:'\input test-footnote-switch' \
  uplatex:test-footnote-switch-uplatex:'\input test-footnote-switch' \
  pdflatex:test-samepage-pdflatex:'\input test-samepage' \
  xelatex:test-samepage-xelatex:'\input test-samepage' \
  lualatex:test-samepage-lualatex:'\input test-samepage' \
  platex:test-samepage-platex:'\input test-samepage' \
  uplatex:test-samepage-uplatex:'\input test-samepage' \
  pdflatex:test-marks-pdflatex:'\input test-marks' \
  xelatex:test-marks-xelatex:'\input test-marks' \
  lualatex:test-marks-lualatex:'\input test-marks' \
  platex:test-marks-platex:'\input test-marks' \
  uplatex:test-marks-uplatex:'\input test-marks' \
  platex:test-tate-platex:'\input test-tate' \
  uplatex:test-tate-uplatex:'\def\CLS{utarticle}\input test-tate' \
  lualatex:test-tate-lualatex:'\input test-tate' \
  pdflatex:test-text-pdflatex:'\input test-text' \
  xelatex:test-text-xelatex:'\input test-text' \
  lualatex:test-text-lualatex:'\input test-text' \
  platex:test-text-platex:'\input test-text' \
  uplatex:test-text-uplatex:'\input test-text' \
  pdflatex:test-text-last-pdflatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-text' \
  lualatex:test-text-last-lualatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-text' \
  platex:test-text-last-platex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-text' \
  pdflatex:test-text-span-pdflatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-text' \
  lualatex:test-text-span-lualatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-text' \
  uplatex:test-text-span-uplatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-text' \
  pdflatex:test-text-span2-pdflatex:'\def\NCOLopt{columns=4,footnotes=span,footnote-columns=2}\input test-text' \
  xelatex:test-text-span2-xelatex:'\def\NCOLopt{columns=4,footnotes=span,footnote-columns=2}\input test-text' \
  pdflatex:test-tcolorbox-pdflatex:'\input test-tcolorbox' \
  lualatex:test-tcolorbox-lualatex:'\input test-tcolorbox' \
  platex:test-japanese-platex:'\input test-japanese' \
  uplatex:test-japanese-span-uplatex:'\def\CLSOPT{uplatex,dvipdfmx}\def\NCOLopt{columns=3,footnotes=span}\input test-japanese' \
  lualatex:test-japanese-last-lualatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-japanese' \
  lualatex:test-japanese-jlreq-span-lualatex:'\def\CLS{jlreq}\def\NCOLopt{columns=3,footnotes=span}\input test-japanese' \
  platex:test-japanese-tate-platex:'\def\CLS{tarticle}\input test-japanese' \
  uplatex:test-japanese-tate-last-uplatex:'\def\CLS{utarticle}\def\NCOLopt{columns=3,footnotes=last-column}\input test-japanese' \
  lualatex:test-japanese-tate-lualatex:'\def\CLS{ltjtarticle}\input test-japanese' \
  lualatex:test-japanese-jlreq-tate-lualatex:'\def\CLS{jlreq}\def\CLSOPT{tate}\input test-japanese'

TCBPF := \
  pdflatex:test-tcbpagefootnote-pdflatex:'\input test-tcbpagefootnote' \
  xelatex:test-tcbpagefootnote-xelatex:'\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-lualatex:'\input test-tcbpagefootnote' \
  platex:test-tcbpagefootnote-platex:'\input test-tcbpagefootnote' \
  uplatex:test-tcbpagefootnote-uplatex:'\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-last-pdflatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-last-lualatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbpagefootnote' \
  uplatex:test-tcbpagefootnote-last-uplatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-span-pdflatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-span-lualatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbpagefootnote' \
  platex:test-tcbpagefootnote-span-platex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-span2-pdflatex:'\def\NCOLopt{columns=4,footnotes=span,footnote-columns=2}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-span2-lualatex:'\def\NCOLopt{columns=4,footnotes=span,footnote-columns=2}\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-tagging-pdflatex:'\def\NCOLtagging{}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-tagging-lualatex:'\def\NCOLtagging{}\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-tagging-last-pdflatex:'\def\NCOLtagging{}\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-tagging-last-lualatex:'\def\NCOLtagging{}\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbpagefootnote' \
  pdflatex:test-tcbpagefootnote-tagging-span-pdflatex:'\def\NCOLtagging{}\def\NCOLopt{columns=3,footnotes=span}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-tagging-span-lualatex:'\def\NCOLtagging{}\def\NCOLopt{columns=3,footnotes=span}\input test-tcbpagefootnote' \
  platex:test-tcbpagefootnote-tate-platex:'\def\CLS{tarticle}\input test-tcbpagefootnote' \
  uplatex:test-tcbpagefootnote-tate-uplatex:'\def\CLS{utarticle}\input test-tcbpagefootnote' \
  lualatex:test-tcbpagefootnote-tate-lualatex:'\def\CLS{ltjtarticle}\input test-tcbpagefootnote'

TCBNB := \
  pdflatex:test-tcbnestbreak-pdflatex:'\input test-tcbnestbreak' \
  lualatex:test-tcbnestbreak-lualatex:'\input test-tcbnestbreak' \
  uplatex:test-tcbnestbreak-uplatex:'\input test-tcbnestbreak' \
  pdflatex:test-tcbnestbreak-last-pdflatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbnestbreak' \
  lualatex:test-tcbnestbreak-last-lualatex:'\def\NCOLopt{columns=3,footnotes=last-column}\input test-tcbnestbreak' \
  pdflatex:test-tcbnestbreak-span-pdflatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbnestbreak' \
  lualatex:test-tcbnestbreak-span-lualatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbnestbreak' \
  uplatex:test-tcbnestbreak-span-uplatex:'\def\NCOLopt{columns=3,footnotes=span}\input test-tcbnestbreak'

TWOCOLUMN := \
  pdflatex:test-twocolumn-pdflatex:'\input test-twocolumn' \
  xelatex:test-twocolumn-xelatex:'\input test-twocolumn' \
  lualatex:test-twocolumn-lualatex:'\input test-twocolumn' \
  platex:test-twocolumn-platex:'\input test-twocolumn' \
  uplatex:test-twocolumn-uplatex:'\input test-twocolumn'

## "<case>:<error message>" of test-errors.tex (pdflatex)
ERRORS := \
  package:"redefines the same parts" \
  columns:"can only be set in the preamble"

## Choose the TeX Live
SETUP = \
  $(if $(TEXBIN),export PATH="$(TEXBIN):$$PATH";) \
  echo "== `pdflatex --version | head -1`"

## Compile $$in with $$eng as $$job, again while the log asks for it
## (+ (x)dvipdfmx), and check for errors.  max_print_line: the lines
## of the log are not broken (see test-common.tex).  $$texenv: more of
## the environment (TCBENV).
RUN = \
  rm -f $$job.aux $$job.dvi $$job.xdv $$job.pdf; \
  opt=; if [ $$eng = xelatex ]; then opt=-no-pdf; fi; \
  n=0; while :; do \
    n=`expr $$n + 1`; \
    env max_print_line=1000 $$texenv $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >$$job.term 2>&1 || true; \
    grep -q 'Rerun to get' $$job.log || break; \
    [ $$n -lt $(MAXRUNS) ] || break; \
  done; \
  if [ -f $$job.dvi ]; then dvipdfmx $$job.dvi >>$$job.term 2>&1; fi; \
  if [ -f $$job.xdv ]; then xdvipdfmx $$job.xdv >>$$job.term 2>&1; fi; \
  if grep -q '^!' $$job.log; then echo "NG: error in $$job.log"; exit 1; fi

## Check the result of test-common.tex in $$job.log
RESULT = \
  if grep -q '^NCOL-.* NG' $$job.log; then grep '^NCOL-.* NG' $$job.log; exit 1; fi; \
  grep -q '^NCOL-RESULT OK' $$job.log || \
    { echo "NG: no NCOL-RESULT OK in $$job.log"; exit 1; }; \
  if grep 'ncolumn Warning' $$job.log | grep -v "'stfloats'"; then \
    echo "NG: ncolumn warning in $$job.log"; exit 1; fi

## The tests of TCBPF and TCBNB take the two packages from $(TPF) and
## $(TNB) (tcbpagefootnote.lua as well)
TCBENV = TEXINPUTS=.:$(TPF):$(TNB):$$TEXINPUTS LUAINPUTS=$(TPF):$$LUAINPUTS

## Check $$job.log of a test of TCBPF or TCBNB
TCBRESULT = \
  if grep -q 'Overfull .vbox' $$job.log; then \
    echo "NG: overfull \\vbox in $$job.log"; exit 1; fi; \
  if grep -q '^% split' $$job.log; then \
    echo "NG: a footnote is split or held over in $$job.log"; exit 1; fi; \
  if grep -q 'tcbpagefootnote Warning\|tcbnestbreak Warning' $$job.log; then \
    echo "NG: warning in $$job.log"; exit 1; fi

.PHONY: test
test:
	@set -e; \
	$(SETUP); \
	texenv=; \
	for t in $(TESTS); do \
	  eng=$${t%%:*}; rest=$${t#*:}; job=$${rest%%:*}; in=$${rest#*:}; \
	  echo "== $$eng $$job"; \
	  $(RUN); \
	  $(RESULT); \
	done; \
	$(if $(HASTPF),,echo "== skipped: test-tcbpagefootnote and test-tcbnestbreak (no $(TPF)/tcbpagefootnote.sty)";) \
	$(if $(HASTPF),$(if $(HASTNB),,echo "== skipped: test-tcbnestbreak (no $(TNB)/tcbnestbreak.sty)";)) \
	texenv="$(TCBENV)"; \
	for t in $(if $(HASTPF),$(TCBPF) $(if $(HASTNB),$(TCBNB))); do \
	  eng=$${t%%:*}; rest=$${t#*:}; job=$${rest%%:*}; in=$${rest#*:}; \
	  echo "== $$eng $$job"; \
	  $(RUN); \
	  $(RESULT); \
	  $(TCBRESULT); \
	done; \
	texenv=; \
	for t in $(TWOCOLUMN); do \
	  eng=$${t%%:*}; rest=$${t#*:}; on=$${rest%%:*}; input=$${rest#*:}; \
	  echo "== $$eng $$on"; \
	  job=$$on; in="$$input"; $(RUN); \
	  job=$$on-off; in="\def\NCOLoff{1}$$input"; $(RUN); \
	  rm -f $$on-[0-9]*.png $$on-off-[0-9]*.png; \
	  pdftoppm -r 72 -png $$on.pdf $$on; \
	  pdftoppm -r 72 -png $$on-off.pdf $$on-off; \
	  non=`ls $$on-[0-9]*.png | wc -l`; noff=`ls $$on-off-[0-9]*.png | wc -l`; \
	  [ $$non -eq $$noff ] || \
	    { echo "NG: $$on.pdf has" $$non "pages, $$on-off.pdf has" $$noff; exit 1; }; \
	  for a in $$on-off-[0-9]*.png; do \
	    b=`echo $$a | sed 's/-off-/-/'`; \
	    cmp -s $$a $$b || { echo "NG: $$b differs from $$a"; exit 1; }; \
	  done; \
	done; \
	for e in $(ERRORS); do \
	  c=$${e%%:*}; msg=$${e#*:}; job=test-errors-$$c; \
	  echo "== pdflatex $$job"; \
	  pdflatex -interaction=nonstopmode -jobname=$$job "\def\CASE{$$c}\input test-errors" >$$job.term 2>&1 || true; \
	  grep -q "^! Package ncolumn Error: .*$$msg" $$job.log || \
	    { echo "NG: no expected error in $$job.log"; exit 1; }; \
	done; \
	echo "All tests passed ($(NCOLVER))"

.PHONY: clean
clean: ## Clean this repository
	rm -rf ncolumn.zip ncolumn
	rm -f *.aux *.log *.out *.toc *.dvi *.xdv *.synctex.gz *.term
	rm -f test-*.pdf test-*.png
	find . -type f -name "*~" -delete
