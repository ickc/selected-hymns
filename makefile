.DEFAULT_GOAL = help
SHELL = /usr/bin/env bash

# LaTeX
latexmkEngine = lualatex
# pandoc
pandocEngine = lualatex
# HTML
HTMLVersion = html5
# ePub
ePubVersion = epub3

CSS = css/common.min.css

# for bump2version, valid options are: major, minor, patch
PART ?= patch

# Args #########################################################################

# LaTeX args
latexmkArg = -$(latexmkEngine) -quiet

# pandoc args
pandocArgCommon = --toc -F pantable
### pandoc workflow
pandocArgStandalone = $(pandocArgCommon) --toc-depth=4 -s -M date="`date "+%B %e, %Y"`"

# used in rules below
pandocArgePub = $(pandocArgCommon) --toc-depth=4 -s --css=$(CSS) -t $(ePubVersion) --epub-chapter-level=4 --self-contained
pandocArgHTML = $(pandocArgStandalone) -t $(HTMLVersion) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/$(CSS) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/fonts/fonts.min.css
pandocArgTeX = $(pandocArgStandalone) --top-level-division=chapter --pdf-engine=$(pandocEngine)
# docx output rely on pandoc to HTML and then ebook-convert from html to docx
# GitHub README
pandocArgReadmeGitHub = $(pandocArgCommon) --toc-depth=2 -t gfm --reference-location=block
# for cleanup only
pandocArgMD = -f markdown+abbreviations+autolink_bare_uris+markdown_attribute+mmd_header_identifiers+mmd_link_attributes+mmd_title_block-latex_macros-auto_identifiers -t markdown+raw_tex-native_spans-simple_tables-multiline_tables-grid_tables-latex_macros -s --wrap=none --column=999 --atx-headers --reference-location=block --file-scope

# Lists ########################################################################

MD = en.md zh-Hant.md zh-Hans.md zh-Hant-en.md zh-Hans-en.md
TXT = en.txt zh-Hant.txt
HTML = $(patsubst %.md,docs/%.html,$(MD))
EPUB = $(patsubst %.md,%.epub,$(MD))
TeX = $(patsubst %.md,%.tex,$(MD))
PDF = $(patsubst %.md,%.pdf,$(MD))
MD_SLIDE = $(wildcard slide/*.md)
HTML_SLIDE = $(patsubst slide/%.md,docs/slide/%.html,$(MD_SLIDE))

logosMD = en-logos.md zh-Hant-logos.md zh-Hans-logos.md zh-Hant-en-logos.md zh-Hans-en-logos.md
logosDOCX = $(patsubst %.md,%.docx,$(logosMD))

ZH-Hans = zh-Hans.md zh-Hans-logos.md zh-Hans-en.md zh-Hans-en-logos.md

DOCS = docs/index.html README.md

# Main Targets #################################################################

all_but_pdf: docs epub tex docx $(ZH-Hans)  ## generate all except PDF targets
all: all_but_pdf $(PDF)  ## generate all
docs: $(DOCS) html html_slide  ## generate all HTML targets
html: $(HTML)  ## generate single file HTML targets
html_slide: $(HTML_SLIDE)  ## generate HTML slides
epub: $(EPUB)  ## generate ePub targets
tex: $(TeX)  ## generate LaTeX targets
pdf: $(PDF)  ## generate PDF targets
docx: $(logosDOCX)  ## generate DOCX targets
txt: $(TXT)  ## generate text files (mainly for LLMs)

clean:  ## clean up generated files
	latexmk -c -f $(TeX)
	rm -f $(ZH-Hans) $(MD) $(TeX)
	find \( -type f -name '*.py[co]' -o -type d -name '__pycache__' \) -delete

clean_tex:  ## clean up generated LaTeX files
	find -name '*.tex' -exec latexmk -C {} +

Clean: clean  ## clean up all generated files including targets
	latexmk -C -f $(TeX)
	rm -f $(DOCS) $(HTML) $(EPUB) $(PDF) $(MD) $(logosMD) data2.yml $(logosDOCX) *-logos.html
	rm -rf css fonts

check:  ## sanity check 848 hymns are included and not duplicated
	grep -oE '^1\. |' en.md | wc -l
	grep -oE '^1\. |' en-logos.md | wc -l
	grep -oE '^1\. |' zh-Hant.md | wc -l
	grep -oE '^1\. |' zh-Hant-logos.md | wc -l
	grep -oE '^1\. |' zh-Hans.md | wc -l
	grep -oE '^1\. |' zh-Hans-logos.md | wc -l
	grep -oE '^1\. |' zh-Hant-en.md | wc -l
	grep -oE '^1\. |' zh-Hant-en-logos.md | wc -l
	grep -oE '^1\. |' zh-Hans-en.md | wc -l
	grep -oE '^1\. |' zh-Hans-en-logos.md | wc -l

# Making dependancies ##########################################################

# Tranditional to Simplified Chinese
zh-Hans%md: zh-Hant%md
	opencc -c t2s.json -i $< -o $@
	sed -i -e 's/zh-Hant/zh-Hans/g' -e 's/Noto Sans CJK TC/Noto Sans CJK SC/g' $@

docs/%.html: %.md
	pandoc $(pandocArgHTML) -o $@ $<

%.epub: %.md
	pandoc $(pandocArgePub) -o $@ $<

%.tex: %.md
	pandoc $(pandocArgTeX) -o $@ $<

# Logos doesn't support gapless double English emdash
%.docx: %.md
	# pandoc -o $@ $<
	sed 's/——/⸺/g' $< | pandoc $(pandocArgePub) -f markdown -o $*.epub
	ebook-convert $*.epub $@

%.pdf: %.tex
	latexmk $(latexmkArg) $<
# %.pdf: %.md
# 	pandoc $(pandocArgTeX) -o $@ $<
%.txt: %.md
	pandoc -t plain -o $@ $<

# readme
## index.html
docs/index.html: docs/badges.markdown docs/README.md docs/download-all.csv docs/download-en.csv docs/download-zh-Hant.csv docs/download-zh-Hans.csv
	pandoc $(pandocArgHTML) docs/badges.markdown docs/README.md -o $@
## GitHub README
README.md: docs/badges.markdown docs/README.md docs/download-all.csv
	printf "%s\n\n" "<!--This README is auto-generated from \`docs/README.md\`. Do not edit this file directly.-->" > $@
	pandoc $(pandocArgReadmeGitHub) docs/badges.markdown docs/README.md >> $@
 docs/download-en.csv:
	@echo recall that $@ should be generated after a new GitHub Release
	docs/download.py -o $@ --formats .epub .pdf --versions en
 docs/download-zh-Hant.csv:
	@echo recall that $@ should be generated after a new GitHub Release
	docs/download.py -o $@ --formats .epub .pdf --versions zh-Hant zh-Hant-en
 docs/download-zh-Hans.csv:
	@echo recall that $@ should be generated after a new GitHub Release
	docs/download.py -o $@ --formats .epub .pdf --versions zh-Hans zh-Hans-en
 docs/download-all.csv:
	@echo recall that $@ should be generated after a new GitHub Release
	docs/download.py -o $@

# download CSS
css: $(CSS)  ## download CSS from markdown-latex-css
%.css:
	mkdir -p $(@D) && cd $(@D) && wget https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/$@

# Slides

# reveal.js doesn't support gapless double English emdash
# run convert_slide.ipynb first
docs/slide/%.html: slide/%.md docs/slide/
	# pandoc -s -o $@ $< -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/css/common.min.css -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/fonts/fonts.min.css -t slidy
	sed 's/——/⸺/g' $< | pandoc -s -o $@ --html-q-tags -t revealjs -V slideNumber=true -V hash=true -V totalTime=2700 -V theme=league -V transitionSpeed=slow -c ../slide.css -M revealjs-url=https://unpkg.com/reveal.js@^5

docs/slide/:
	mkdir -p docs/slide/

# Scripts ######################################################################

# epubcheck
epubcheck: $(EPUB)  ## check ePub files
	find . -iname '*.epub' | xargs -i -n1 -P8 epubcheck {}

cleanup: style normalize  ## cleanup markdown files
## Normalize white spaces:
### 1. Add 2 trailing newlines
### 2. transform non-breaking space into (explicit) space
### 3. temporarily transform markdown non-breaking space `\ ` into unicode
### 4. delete all CONSECUTIVE blank lines from file except the first; deletes all blank lines from top and end of file; allows 0 blanks at top, 0,1,2 at EOF
### 5. delete trailing whitespace (spaces, tabs) from end of each line
### 6. revert (3)
normalize:  ## normalize white spaces
	find . -iname "*.md" | xargs -I {} -n1 -P8 bash -c 'printf "\n\n" >> "$$0" && sed -i -e "s/ / /g" -e '"'"'s/\\ / /g'"'"' -e '"'"'/./,/^$$/!d'"'"' -e '"'"'s/[ \t]*$$//'"'"' -e '"'"'s/ /\\ /g'"'"' $$0' {}
## pandoc cleanup:
### 1. pandoc from markdown to markdown
### 2. transform unicode non-breaking space back to `\ `
style:  ## style markdown files using pandoc
	find . -iname "*.md" | xargs -I {} -n1 -P8 bash -c 'pandoc $(pandocArgMD) -o $$0 $$0 && sed -i -e '"'"'s/ /\\ /g'"'"' $$0' {}

cat:  ## get the Chinese categories
	grep -hr '^\#' ./zh-Hant/ | sed 's/^# ... \(.*\)——.*$$/\1/g' | uniq > zh-Hant-category.txt

print-%:
	$(info $* = $($*))

# ipynb ########################################################################

prepare: convert convert-bilingual slide/  ## generate various intermediate products using python

data2.yml: data.yml
	python list_to_dict.py

convert: data2.yml
	python convert.py

convert-bilingual: data2.yml
	python convert-bilingual.py

# this also make docs/slide.csv
slide/:
	python convert_slide.py

sync:  ## sync all notebooks
	find \! -path '*/.ipynb_checkpoints/*' -name '*.ipynb' -exec jupytext --sync --pipe black --pipe 'isort - --treat-comment-as-code "# %%" --float-to-top' {} +

# releasing ####################################################################

bump:  ## bump version
	bump2version $(PART)
	git push --follow-tags

release:  ## release to GitHub
	gh release create v0.11.1 \
	en-logos.docx en.epub en.pdf zh-Hans-en-logos.docx zh-Hans-en.epub zh-Hans-en.pdf zh-Hans-logos.docx zh-Hans.epub zh-Hans.pdf zh-Hant-en-logos.docx zh-Hant-en.epub zh-Hant-en.pdf zh-Hant-logos.docx zh-Hant.epub zh-Hant.pdf \
	--title 'Selected Hymns v0.11.1' \
	--generate-notes

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
