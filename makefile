SHELL := /usr/bin/env bash

# configure engine
## LaTeX engine
### LaTeX workflow: pdf; xelatex; lualatex
latexmkEngine := xelatex
### pandoc workflow: pdflatex; xelatex; lualatex
pandocEngine := xelatex
## HTML
HTMLVersion := html5
## ePub
ePubVersion := epub3

# Paths
CSSURL:=https://ickc.github.io/markdown-latex-css
# command line arguments
pandocArgCommon := -f markdown+autolink_bare_uris-fancy_lists --toc --normalize -S -V linkcolorblue -V citecolor=blue -V urlcolor=blue -V toccolor=blue --latex-engine=$(pandocEngine) -M date="`date "+%B %e, %Y"`"
# Workbooks
## MD
pandocArgMD := -f markdown+abbreviations+autolink_bare_uris+markdown_attribute+mmd_header_identifiers+mmd_link_attributes+mmd_title_block+tex_math_double_backslash-latex_macros-auto_identifiers -t markdown+raw_tex-native_spans-simple_tables-multiline_tables-grid_tables-latex_macros --normalize -s --wrap=none --column=999 --atx-headers --reference-location=block --file-scope
## TeX/PDF
### LaTeX workflow
latexmkArg := -$(latexmkEngine)
pandocArgFragment := $(pandocArgCommon) --top-level-division=chapter
### pandoc workflow
pandocArgStandalone := $(pandocArgFragment) --toc-depth=1 -s
## HTML/ePub
pandocArgHTML := $(pandocArgFragment) -t $(HTMLVersion) --toc-depth=2 -s -c $(CSSURL)/css/common.css -c $(CSSURL)/fonts/fonts.css
pandocArgePub := $(pandocArgFragment) --toc-depth=2 -s -c $(CSSURL)/css/common.css -c $(CSSURL)/fonts/fonts.css -t $(ePubVersion) --epub-chapter-level=2 --self-contained
# GitHub README
pandocArgReadmeGitHub := $(pandocArgCommon) --toc-depth=2 -s -t markdown_github --reference-location=block

# Lists #######################################################################

EN := $(wildcard en/*.md)
ZH-Hant := $(wildcard zh-Hant/*.md)

MD := zh-Hant.md en.md
HTML := $(patsubst %.md,docs/%.html,$(MD))
EPUB := $(patsubst %.md,%.epub,$(MD))
TeX := $(patsubst %.md,%.tex,$(MD))
PDF := $(patsubst %.md,%.pdf,$(MD))

# Main Targets ################################################################

all: $(MD) $(HTML) $(EPUB) $(TeX) $(PDF)
md: $(MD)
html: $(HTML)
epub: $(EPUB)
tex: $(TeX)
pdf: $(PDF)

clean:
	latexmk -c -f $(TeX)
	rm -f $(MD) $(EPUB) $(TeX)

Clean:
	latexmk -C -f $(TeX)
	rm -f $(MD) $(HTML) $(EPUB) $(TeX) $(PDF)

# Making dependancies #########################################################

en.md: metadata.yml en/000.yml $(EN)
	cat metadata.yml en/000.yml > $@
	find en/ -iname '*.md' | sort | xargs cat >> $@
 zh-Hant.md:  metadata.yml zh-Hant/000.yml $(ZH-Hant)
	cat metadata.yml zh-Hant/000.yml > $@
	find zh-Hant/ -iname '*.md' | sort | xargs cat >> $@

docs/%.html: %.md
	pandoc $(pandocArgHTML) -o $@ $<

%.epub: %.md
	pandoc $(pandocArgePub) -o $@ $<

%.tex: %.md
	pandoc $(pandocArgStandalone) -o $@ $<

%.pdf: %.tex
	latexmk $(latexmkArg) $<

# Scripts #####################################################################

cleanup: style normalize
## Normalize white spaces:
### 1. Add 2 trailing newlines
### 2. transform non-breaking space into (explicit) space
### 3. temporarily transform markdown non-breaking space `\ ` into unicode
### 4. delete all CONSECUTIVE blank lines from file except the first; deletes all blank lines from top and end of file; allows 0 blanks at top, 0,1,2 at EOF
### 5. delete trailing whitespace (spaces, tabs) from end of each line
### 6. revert (3)
normalize:
	find . -iname "*.md" | xargs -i -n1 -P8 bash -c 'printf "\n\n" >> "$$0" && sed -i -e "s/ / /g" -e '"'"'s/\\ / /g'"'"' -e '"'"'/./,/^$$/!d'"'"' -e '"'"'s/[ \t]*$$//'"'"' -e '"'"'s/ /\\ /g'"'"' $$0' {}
## pandoc cleanup:
### 1. pandoc from markdown to markdown
### 2. transform unicode non-breaking space back to `\ `
style:
	find . -iname "*.md" | xargs -i -n1 -P8 bash -c 'pandoc $(pandocArgMD) -o $$0 $$0 && sed -i -e '"'"'s/ /\\ /g'"'"' $$0' {}
