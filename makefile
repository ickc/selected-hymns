SHELL = /usr/bin/env bash

# LaTeX
latexmkEngine = xelatex
# pandoc
pandocEngine = xelatex
# HTML
HTMLVersion = html5
# ePub
ePubVersion = epub3

CSS = css/common.min.css

# Args #########################################################################

# LaTeX args
latexmkArg = -$(latexmkEngine) -quiet

# pandoc args
pandocArgCommon = --toc
### pandoc workflow
pandocArgStandalone = $(pandocArgCommon) --toc-depth=4 -s -M date="`date "+%B %e, %Y"`"

# used in rules below
pandocArgePub = $(pandocArgCommon) --toc-depth=4 -s --css=$(CSS) -t $(ePubVersion) --epub-chapter-level=4 --self-contained
pandocArgHTML = $(pandocArgStandalone) -t $(HTMLVersion) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/$(CSS) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/fonts/fonts.min.css
pandocArgTeX = $(pandocArgStandalone) --top-level-division=chapter --pdf-engine=$(pandocEngine)
# docx output rely on pandoc to HTML and then ebook-convert from html to docx
pandocArgDocx = -t $(HTMLVersion) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/$(CSS) -c https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/fonts/fonts.min.css
# GitHub README
pandocArgReadmeGitHub = $(pandocArgCommon) --toc-depth=2 -s -t markdown_github --reference-location=block
# for cleanup only
pandocArgMD = -f markdown+abbreviations+autolink_bare_uris+markdown_attribute+mmd_header_identifiers+mmd_link_attributes+mmd_title_block-latex_macros-auto_identifiers -t markdown+raw_tex-native_spans-simple_tables-multiline_tables-grid_tables-latex_macros -s --wrap=none --column=999 --atx-headers --reference-location=block --file-scope

# Lists ########################################################################

MD = en.md zh-Hant.md zh-Hans.md zh-Hant-en.md zh-Hans-en.md
HTML = $(patsubst %.md,docs/%.html,$(MD))
EPUB = $(patsubst %.md,%.epub,$(MD))
TeX = $(patsubst %.md,%.tex,$(MD))
PDF = $(patsubst %.md,%.pdf,$(MD))

logosMD = en-logos.md zh-Hant-logos.md zh-Hans-logos.md zh-Hant-en-logos.md zh-Hans-en-logos.md
logosDOCX = $(patsubst %.md,%.docx,$(logosMD))

ZH-Hans = zh-Hans.md zh-Hans-logos.md zh-Hans-en.md zh-Hans-en-logos.md

DOCS = docs/index.html README.md

# Main Targets #################################################################

all: $(DOCS) $(HTML) $(EPUB) $(TeX) $(PDF) $(ZH-Hans) $(logosDOCX)
docs: $(DOCS) html
html: $(HTML)
epub: $(EPUB)
tex: $(TeX)
pdf: $(PDF)
docx: $(logosDOCX)

clean:
	latexmk -c -f $(TeX)
	rm -f $(ZH-Hans) $(MD) $(TeX)
	find \( -type f -name '*.py[co]' -o -type d -name '__pycache__' \) -delete

Clean: clean
	latexmk -C -f $(TeX)
	rm -f $(DOCS) $(HTML) $(EPUB) $(PDF) $(MD) $(logosMD) data2.yml $(logosDOCX) *-logos.html
	rm -rf css fonts

# sanity check 848 hymns are included and not duplicated
check:
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
	sed -i -e 's/zh-Hant/zh-Hans/g' -e 's/Kaiti TC/Kaiti SC/g' $@

docs/%.html: %.md
	pandoc $(pandocArgHTML) -o $@ $<

%.epub: %.md $(CSS)
	pandoc $(pandocArgePub) -o $@ $<

%.tex: %.md
	pandoc $(pandocArgTeX) -o $@ $<

%.docx: %.md
	# pandoc -o $@ $<
	pandoc $(pandocArgDocx) -o $*.html $<
	ebook-convert $*.html $@

# %.pdf: %.tex
# 	latexmk $(latexmkArg) $<
%.pdf: %.md
	pandoc $(pandocArgTeX) -o $@ $<

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
	mkdir -p $(@D) && cd $(@D) && wget https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/$@

# Scripts ######################################################################

# epubcheck
epubcheck: $(EPUB)
	find . -iname '*.epub' | xargs -i -n1 -P8 epubcheck {}

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

print-%:
	$(info $* = $($*))
