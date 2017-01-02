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

# command line arguments
pandocArgCommon := -f markdown+autolink_bare_uris-fancy_lists --toc --normalize -S -V linkcolorblue -V citecolor=blue -V urlcolor=blue -V toccolor=blue --latex-engine=$(pandocEngine) -M date="`date "+%B %e, %Y"`" -F pantable
# Workbooks
## MD
pandocArgMD := -f markdown+abbreviations+autolink_bare_uris+markdown_attribute+mmd_header_identifiers+mmd_link_attributes+mmd_title_block+tex_math_double_backslash-latex_macros-auto_identifiers -t markdown+raw_tex-native_spans-simple_tables-multiline_tables-grid_tables-latex_macros --normalize -s --wrap=none --column=999 --atx-headers --reference-location=block --file-scope
## TeX/PDF
### LaTeX workflow
latexmkArg := -$(latexmkEngine) -quiet
pandocArgFragment := $(pandocArgCommon) --top-level-division=chapter
### pandoc workflow
pandocArgStandalone := $(pandocArgFragment) --toc-depth=1 -s
### TeX output (for TeX only header)
pandocArgTeX := $(pandocArgStandalone) -H metadata.tex
## HTML/ePub
pandocArgHTML := $(pandocArgFragment) -t $(HTMLVersion) --toc-depth=2 -s -c https://ickc.github.io/markdown-latex-css/css/common.css -c https://ickc.github.io/markdown-latex-css/fonts/fonts.css
pandocArgePub := $(pandocArgFragment) --toc-depth=2 -s --epub-stylesheet=css/epub.css -t $(ePubVersion) --epub-chapter-level=2 --self-contained
# GitHub README
pandocArgReadmeGitHub := $(pandocArgCommon) --toc-depth=2 -s -t markdown_github --reference-location=block

# Lists #######################################################################

EN := $(wildcard en/*.md)
ZH-Hant := $(wildcard zh-Hant/*.md)
ZH-Hans := $(patsubst zh-Hant/%.md,zh-Hans/%.md,$(ZH-Hant))

MD := en.md zh-Hant.md zh-Hans.md en-zh-Hant.md en-zh-Hans.md
HTML := $(patsubst %.md,docs/%.html,$(MD))
EPUB := $(patsubst %.md,%.epub,$(MD))
TeX := $(patsubst %.md,%.tex,$(MD))
PDF := $(patsubst %.md,%.pdf,$(MD))

DOCS := docs/index.html README.md

CSS := css/common.css fonts/fonts.css

# Main Targets ################################################################

all: $(DOCS) $(MD) $(HTML) $(EPUB) $(TeX) $(PDF)
docs: $(DOCS) html
md: $(MD)
html: $(HTML)
epub: $(EPUB)
tex: $(TeX)
pdf: $(PDF)

clean:
	latexmk -c -f $(TeX)
	rm -f $(ZH-Hans) $(MD) $(TeX)

Clean:
	latexmk -C -f $(TeX)
	rm -f $(ZH-Hans) $(DOCS) $(MD) $(HTML) $(EPUB) $(TeX) $(PDF)
	rm -rf css fonts

# Making dependancies #########################################################

en.md: metadata.yml en/000.yml $(EN)
	cat metadata.yml en/000.yml > $@
	find en/ -iname '*.md' | sort | xargs cat >> $@
zh-Hant.md:  metadata.yml zh-Hant/000.yml $(ZH-Hant)
	cat metadata.yml zh-Hant/000.yml > $@
	find zh-Hant/ -iname '*.md' | sort | xargs cat >> $@
# Tranditional to Simplified Chinese
zh-Hans/%.md: zh-Hant/%.md
	opencc -c t2s.json -i $< -o $@
zh-Hans.md:  metadata.yml zh-Hans/000.yml $(ZH-Hans)
	cat metadata.yml zh-Hans/000.yml > $@
	find zh-Hans/ -iname '*.md' | sort | xargs cat >> $@
# Bilingual
en-zh-Hant.md: metadata.yml zh-Hant/000.yml $(ZH-Hant) $(EN)
	cat metadata.yml zh-Hant/000.yml > $@
	printf "%s\n" "~~~table" "---" "width: [0.5, 0.5]" "header: False" "markdown: True" "..." >> $@
	find en -iname '*.md' | sort | cut -sd / -f 2- | xargs -I {} -n1 bash -c 'echo "\"" >> $@; cat zh-hant/$$0 | sed "s/\"/\"\"/g" >> $@; echo "\",\"" >> $@; cat en/$$0 | sed "s/\"/\"\"/g" >> $@; echo "\"" >> $@' {}
	echo "~~~" >> $@
en-zh-Hans.md: metadata.yml zh-Hans/000.yml $(ZH-Hans) $(EN)
	cat metadata.yml zh-Hans/000.yml > $@
	printf "%s\n" "~~~table" "---" "width: [0.5, 0.5]" "header: False" "markdown: True" "..." >> $@
	find en -iname '*.md' | sort | cut -sd / -f 2- | xargs -I {} -n1 bash -c 'echo "\"" >> $@; cat zh-hans/$$0 | sed "s/\"/\"\"/g" >> $@; echo "\",\"" >> $@; cat en/$$0 | sed "s/\"/\"\"/g" >> $@; echo "\"" >> $@' {}
	echo "~~~" >> $@

docs/%.html: %.md
	pandoc $(pandocArgHTML) -o $@ $<

%.epub: %.md css/epub.css
	pandoc $(pandocArgePub) -o $@ $<

%.tex: %.md
	pandoc $(pandocArgTeX) -o $@ $<

%.pdf: %.tex
	latexmk $(latexmkArg) $<

# readme
## index.html
docs/index.html: docs/badges.markdown docs/README.md
	pandoc $(pandocArgHTML) $^ -o $@
## GitHub README
README.md: docs/badges.markdown docs/README.md
	printf "%s\n\n" "<!--This README is auto-generated from \`docs/README.md\`. Do not edit this file directly.-->" > $@
	pandoc $(pandocArgReadmeGitHub) $^ >> $@

# download CSS
%.css:
	dir=$@; mkdir -p $${dir%/*} && cd $${dir%/*} && wget https://ickc.github.io/markdown-latex-css/$@
# cat css
css/epub.css: $(CSS)
	cat $^ > $@

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
	find . -iname "*.md" | xargs -I {} -n1 -P8 bash -c 'printf "\n\n" >> "$$0" && sed -i -e "s/ / /g" -e '"'"'s/\\ / /g'"'"' -e '"'"'/./,/^$$/!d'"'"' -e '"'"'s/[ \t]*$$//'"'"' -e '"'"'s/ /\\ /g'"'"' $$0' {}
## pandoc cleanup:
### 1. pandoc from markdown to markdown
### 2. transform unicode non-breaking space back to `\ `
style:
	find . -iname "*.md" | xargs -I {} -n1 -P8 bash -c 'pandoc $(pandocArgMD) -o $$0 $$0 && sed -i -e '"'"'s/ /\\ /g'"'"' $$0' {}

# get the Chinese categories
cat:
	grep -hr '^\#' ./zh-Hant/ | sed 's/^# ... \(.*\)——.*$$/\1/g' | uniq > zh-Hant-category.txt
