#!/bin/bash
# N=2 compatibility: the same document set with the kernel's \twocolumn
# (kernel.tex) and with ncolumn loaded (ncolumn.tex) must give identical
# pages.  Pages are rasterised and compared pixel by pixel.
# Needs pdftoppm (poppler) and magick (ImageMagick).
# usage: ./compare.sh [engine ...]     (default: all five)
cd "$(dirname "$0")" || exit 1
root=$(cd ../.. && pwd)
engines=${@:-pdflatex lualatex xelatex platex uplatex}
status=0
for e in $engines; do
  out=build/$e; mkdir -p "$out"; rm -f "$out"/*.png "$out"/*.pdf
  for f in kernel ncolumn; do
    for i in 1 2 3; do
      TEXINPUTS="$root//:" $e -interaction=nonstopmode -halt-on-error \
        -output-directory="$out" $f.tex >/dev/null 2>&1 || { echo "$e: $f.tex failed"; status=1; break; }
    done
    case $e in platex|uplatex) (cd "$out" && dvipdfmx -q $f.dvi 2>/dev/null) ;; esac
    [ -f "$out/$f.pdf" ] && pdftoppm -r 60 -png "$out/$f.pdf" "$out/$f"
  done
  n=0; bad=""
  for a in "$out"/kernel-*.png; do
    b=${a/kernel-/ncolumn-}; n=$((n+1))
    d=$(magick compare -metric AE "$a" "$b" null: 2>&1 | awk '{print $1}')
    [ "$d" != "0" ] && bad="$bad ${a##*-}"
  done
  m=$(ls "$out"/ncolumn-*.png 2>/dev/null | wc -l | tr -d ' ')
  echo "$e: pages kernel=$n ncolumn=$m differing:${bad:- none}"
  [ -n "$bad" ] || [ "$n" != "$m" ] && status=1
done
exit $status
