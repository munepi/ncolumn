-- l3build configuration for ncolumn
module = "ncolumn"

sourcefiles  = {"ncolumn.sty"}
installfiles = {"ncolumn.sty"}
unpackfiles  = {}
typesetfiles = {"ncolumn-doc.tex"}
typesetexe   = "lualatex"
textfiles    = {"README.md"}

-- pdfLaTeX, LuaLaTeX, XeLaTeX, pLaTeX, upLaTeX
checkengines = {"pdftex", "luatex", "xetex", "ptex", "uptex"}
stdengine    = "pdftex"
-- the "span" footnote mode needs the .aux file of the previous runs
checkruns    = 6
