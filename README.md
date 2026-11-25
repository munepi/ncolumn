# ncolumn Package

**LaTeX: N columns in the way of `\twocolumn`, with spanning material**

`multicol` collects the material of all columns and splits it into the columns afterwards. Ordinary floats cannot be used in it, and packages that look at the room that is left on the page, such as tcolorbox with `breakable`, need extra care.

`\twocolumn` of LaTeX works in another way: it builds the columns one after another. A column is a page for TeX, and the finished columns are put side by side when the last one is done. So `figure` and `table`, footnotes, `\marginpar` and such packages work in it as on a page.

The ncolumn package makes the output routine of `\twocolumn` work for three, four or more columns, and adds two things:

1. **Spanning material.** Floats, headings and boxes can span k columns from one of the four corners of the page.
2. **Footnotes.** The footnotes of a page are put into each column, into the last column, or into an area of M columns across the page.

With two columns and without the new keys, the pages are those of `\twocolumn`.

* **Supported formats/engines:** pdfLaTeX, XeLaTeX, LuaLaTeX (with or without LuaTeX-ja), pLaTeX, upLaTeX (+ dvipdfmx); yoko and tate

## Usage

```latex
\documentclass{article}
\usepackage[columns=3]{ncolumn}   % three columns for the whole document
\begin{document}
...
\end{document}
```

If the package is loaded without `columns` in a document whose class has the option `twocolumn`, the document has two columns as before.

### Changing the number of columns

```latex
\ncolumn{4}                               % a new page with four columns
\ncolumn{3}[\section{A heading across all columns}]  % like \twocolumn[...]
\onecolumn                                % one column
\twocolumn                                % back to the columns used before
```

`\twocolumn` does not mean "two columns" but "the columns of this document": the classes call it after `\maketitle` or an index to go back to the columns.

### Spanning floats

```latex
\begin{figure*}[t]               % all columns, at the top (as before)
\begin{figure*}[b]               % all columns, at the bottom (not allowed by LaTeX)
\begin{figure*}[span=2,at=tl]    % two columns from the first one, at the top
\begin{figure*}[span=2,at=br]    % two columns up to the last one, at the bottom
\begin{figure*}[!,span=2,at=tr]  % ! as for ordinary floats
```

An argument of `figure*` or `table*` with a `=` is read as a list of keys. `span` is the number of columns and `at` is the corner: `tl`, `tr`, `bl` or `br`. The corner is given in the directions of the text: `t` and `b` are the top and the bottom of a column, `l` and `r` are the side of the first and of the last column. In yoko this is what it looks like (top left, top right, bottom left, bottom right). In tate the first column is the upper one and the top of a column is on the right, so `tl` is the upper right corner of the page.

The starred floats of other packages take the same arguments, as they are made with the same macro of LaTeX (`\@dblfloat`) as `figure*` and `table*`. `algorithm*` of the algorithmlite package is tested.

A page can have several pieces of spanning material. A piece is put on a page only if the columns it covers have the same height reserved so far; otherwise it would leave a hole, and it goes to the next page.

As in LaTeX, a spanning float is put on a later page than the one where it is met. With `same-page-spans`, it is put on the page where it is met

* at the top, if none of the columns it covers is begun;
* at the bottom, if it covers only the current column and columns after it, and the current column has room.

No spanning float is put at the top of a page that begins with the material of `\ncolumn{N}[...]` or with a `\spanblock` at the top, as with `\twocolumn[...]` in LaTeX.

In one column, `span` and `at` are ignored and the float is an ordinary one.

### Spanning blocks

```latex
\spanblock[span=3,at=tl]{\section{A large heading}}  % a new page, with the block on it
\spanblock*[span=2,at=br]{...}                       % on a later page, like a float
```

`\spanblock` puts material that is not a float, such as a heading or a tcolorbox, across columns.

### Footnotes

```latex
\usepackage[columns=3,footnotes=last-column]{ncolumn}
\ncolumnsetup{footnotes=span,footnote-columns=2}
```

| Value | Where the footnotes are put | Runs |
|---|---|---|
| `column` (default) | at the bottom of the column of their marks (as in LaTeX) | 1 |
| `last-column` | all footnotes of a page at the bottom of its last column (as ftnright does for two columns) | 1 |
| `span` | in an area across all columns at the bottom of the page, in M columns with `footnote-columns=M` | several |

With `span`, the columns that are finished cannot be made shorter for a footnote of a later column. So the height of the footnote area of each page is written to the `.aux` file and is taken off all columns in the next run. The package warns to run again when a height has changed.

Reserving the room can move the line of the mark to the next page, and not reserving it brings it back. If the package finds this, it keeps the room reserved (the page is then shorter by a footnote area that it does not have). Up to about five runs can be needed. `footnote-reserve=<length>` reserves a fixed height on every page and does not use the `.aux` file.

`footnotes` can differ from page to page: give it to `\ncolumnsetup` right after `\ncolumn{N}`, which starts a new page.

In tate with jlreq, `last-column` is the default, as jlreq puts the footnotes at the bottom of the last column.

### Marginal notes

With three or more columns, a `\marginpar` goes to the nearer margin: to the margin on the side of the first column from the first half of the columns, to the other margin from the second half. The notes of columns that share a margin do not overlap.

### tcolorbox

A tcolorbox with `breakable` is broken across columns as it is across pages. Two packages for tcolorbox are tested with ncolumn:

* tcbpagefootnote (v1.4 or later): with the key `page footnote`, the footnotes of a box are footnotes of the text. `footnotes` puts them as it puts the others, for each part of a box that is broken across columns, and in a tagged PDF too.
* tcbnestbreak (v0.2): breakable boxes inside a breakable box are broken across columns as well.

A box in spanning material cannot have footnotes of the text (see Limitations).

### Options

| Key | Where | Meaning |
|---|---|---|
| `columns=N` | `\usepackage` (preamble) | the number of columns of the document |
| `footnotes=column\|last-column\|span` | `\usepackage`, `\ncolumnsetup` | where the footnotes are put |
| `footnote-columns=M` | `\usepackage`, `\ncolumnsetup` | the columns of the footnote area with `span` |
| `footnote-reserve=<length>` | `\usepackage`, `\ncolumnsetup` | a fixed height of the footnote area with `span` |
| `same-page-spans` | `\usepackage`, `\ncolumnsetup` | put spanning floats on the page where they are met, if possible |

The parameters of LaTeX for two columns are used as they are: `\columnsep`, `\columnseprule`, `dbltopnumber`, `\dbltopfraction`, `\dblfloatsep`, `\dbltextfloatsep`, `\dblfigrule`. For spanning material at the bottom, there are `dblbotnumber` (default 2) and `\dblbotfraction` (default 0.5).

## How it works

1. **N columns.** `\@outputdblcol` keeps the finished columns in N boxes instead of one. `\if@twocolumn` stays true and `\if@firstcolumn` is true in the first column only, so code that tests them works as before.
2. **Spanning material.** Each column has a height that is reserved at its top and one at its bottom, and the height of the column (`\@colht`) is set for each column. The spanning material is laid over the columns when the page is put together.
3. **Footnotes.** `\@makecol` and `\@outputpage` are not redefined: pLaTeX has its own versions for tate, LuaTeX-ja uses their hooks, and so does the tagging code of LaTeX (`\DocumentMetadata`). The package takes `\box\footins` at the beginning of `\output` instead.
4. **Marks.** The code of ltmarks that updates the marks for two columns is replaced by one for N columns (the marks of each column are also in the regions `mcol-1`, `mcol-2`, ...). This is the only place where internal variables of another module are used.

## Files

| File | Description |
|---|---|
| `ncolumn.sty` | The package |
| `ncolumn.tex` / `.pdf` | Documentation |
| `test-*.tex` | Test suite (see below) |

## Requirements

* LaTeX 2025-06-01 or later
* Tested with TeX Live 2026 (LaTeX2e 2026-11-01). The package redefines internal macros of the output routine of LaTeX; they are listed at the top of `ncolumn.sty`.

## Installation

Copy `ncolumn.sty` to your local TeX tree:
`$TEXMF/tex/latex/ncolumn/`

## Limitations

* Material spans columns from the corners of the page only. It cannot be put in the middle of a page with text above and below it: the columns would have to be balanced for that. The columns of the last page are not balanced either.
* When the floats are put out by `\clearpage`, a float that spans some of the columns is not put into its corner but on a float page, at the side of the first or of the last column.
* With `footnotes=span`, a footnote is not split across pages.
* A footnote inside spanning material is not typeset, as in an ordinary float or in `\twocolumn[...]`. Put `\footnotemark` into the material and `\footnotetext` after it.
* In tate with jlreq, `footnotes=column` and `footnotes=span` do not work with the code of jlreq for its notes, which is written for two columns. Use `last-column`.

## Packages that cannot be used with ncolumn

These packages redefine the same macros; loading one of them with ncolumn is an error:

ftnright, nidanfloat, dblfloatfix, cuted, balance, flushend, pbalance, flowfram, dblfnote

stfloats gives a warning only, as jlreq loads it with LuaLaTeX; ncolumn replaces its placement of the spanning floats.

## Testing

`make test` compiles the tests with pdfLaTeX, XeLaTeX, LuaLaTeX, pLaTeX and upLaTeX (+ dvipdfmx). `make test TEXBIN=<directory of the binaries>` runs them with another TeX Live than the one in `PATH`. A test is run again while its log asks for it. The tests check:

* no error and, after the last run, no warning of ncolumn;
* `NCOL-RESULT OK`: the state of the package for each page is the one that the test expects (the heights that are reserved at the top and at the bottom of each column, the spanning material, and the first and the last mark of each column), and every footnote text is on the page of its mark (see `test-common.tex`);
* `test-twocolumn`: every page is the same, pixel by pixel, with ncolumn and with `\twocolumn` of the LaTeX kernel (needs `pdftoppm`);
* `test-tcbpagefootnote`, `test-tcbnestbreak`: every footnote text also has the width of the footnotes of the page, and no footnote is split or held over. These tests take the two packages from `../tcbpagefootnote` and `../tcbnestbreak` (`make test TPF=<directory> TNB=<directory>` for other places) and are skipped if they are not there;
* `test-algorithmlite`: each algorithm is as wide as the columns it spans. This test is skipped if the TeX Live does not have the algorithmlite package;
* `test-errors`: the expected error message.

| Test | Engines | What it covers |
|---|---|---|
| `test-basic.tex` | all five | three columns; floats of one column; floats across all columns at the top and at the bottom; floats across two columns from two corners on one page; a float that has to wait because it would leave a hole; a float that is too high, with and without `!` |
| `test-switch.tex` | all five | `\ncolumn{4}[...]`, `\spanblock`, `\spanblock*`, `\twocolumn[...]`, `\cleardoublepage`, `\onecolumn`, `\ncolumn{2}` |
| `test-footnote.tex` | all five | `footnotes=last-column`, with float pages and a page that ends in its first column |
| `test-footnote-span.tex` | all five | `footnotes=span` with `footnote-columns=2` in four columns, with a float at the bottom; several runs |
| `test-footnote-switch.tex` | all five | `footnotes` and `footnote-reserve` changed with `\ncolumnsetup` from page to page: right after `\ncolumn`, and in the first column of a page that has text; several runs |
| `test-samepage.tex` | all five | `same-page-spans`: floats that are put on the page where they are met, and floats that are not |
| `test-marks.tex` | all five | the marks of a page of three columns, `\rightmark`, the regions `first-column` and `last-column` |
| `test-tate.tex` | platex (tarticle), uplatex (utarticle), lualatex (ltjtarticle) | spanning floats, `\spanblock` and `footnotes=last-column` in tate |
| `test-text.tex` | all five; each value of `footnotes` | a document with real text: sections, running heads, captions, floats from each of the four corners, `\spanblock`, footnotes, four columns with `same-page-spans` and `\marginpar` |
| `test-japanese.tex` | platex and uplatex (jsarticle, tarticle, utarticle), lualatex (ltjsarticle, ltjtarticle, jlreq in yoko and in tate) | a document with Japanese text, in yoko and in tate |
| `test-tcolorbox.tex` | pdflatex, lualatex | tcolorbox with `breakable` across columns and pages, in a spanning float and in a `\spanblock`; float (`[H]`), caption, hyperref, `\DocumentMetadata` |
| `test-algorithmlite.tex` | all five | a float of another package: `algorithm*` of algorithmlite across all columns at the top and at the bottom, across two columns with `span` and `at`; `algorithm` in a column, floating and with `[H]`; `\listofalgorithms` |
| `test-tcbpagefootnote.tex` | all five; each value of `footnotes`; pdflatex and lualatex with tagging; platex, uplatex and lualatex in tate | tcbpagefootnote: `page footnote` in a box that is not broken, in breakable boxes that are broken across columns and pages, and a box in a `\spanblock` |
| `test-tcbnestbreak.tex` | pdflatex, lualatex, uplatex; each value of `footnotes` | tcbnestbreak: breakable boxes inside a breakable box, three deep, across columns and pages, with `page footnote` |
| `test-twocolumn.tex` | all five | two columns: the same pages as `\twocolumn` of the LaTeX kernel |
| `test-errors.tex` | pdflatex | the errors of the package |

`test-common.tex` holds the helpers shared by the tests. The PDF files of `test-text`, `test-japanese` and `test-tcolorbox` are also meant to be looked at.

## License

This package is licensed under the conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl.txt), either version 1.3c of this license or any later version.

Copyright (c) 2026 Munehiro Yamamoto
