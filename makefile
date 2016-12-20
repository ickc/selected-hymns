DOC := $(wildcard *.doc)
DOCX := $(patsubst %.doc,%.docx,$(DOC))
MD := $(patsubst %.doc,%.md,$(DOC))

all: $(DOCX) $(MD)
docx: $(DOCX)
md: $(MD)

# clean does not delete docx files
clean:
	rm -f $(MD)

Clean:
	rm -f $(DOCX) $(MD)

# assume bin/doc2docx.workflow from [ickc/doc2docx: Batch converts `.doc` to `.docx` using Microsoft Office 2011 for Mac](https://github.com/ickc/doc2docx) in Applications folder
%.docx: %.doc
	automator -i $< /Applications/doc2docx.workflow

%.md: %.docx
	~/.cabal/bin/pandoc -F pantable2csv -s -o $@ $<

## Normalize white spaces:
### 1. Add 2 trailing newlines
### 2. transform non-breaking space into (explicit) space
### 3. temporarily transform markdown non-breaking space `\ ` into unicode
### 4. delete all CONSECUTIVE blank lines from file except the first; deletes all blank lines from top and end of file; allows 0 blanks at top, 0,1,2 at EOF
### 5. delete trailing whitespace (spaces, tabs) from end of each line
### 6. revert (3)
normalize:
	find . -maxdepth 2 -mindepth 2 -iname "*.md" | xargs -i -n1 -P8 bash -c 'printf "\n\n" >> "$$0" && sed -i -e "s/ / /g" -e '"'"'s/\\ / /g'"'"' -e '"'"'/./,/^$$/!d'"'"' -e '"'"'s/[ \t]*$$//'"'"' -e '"'"'s/ /\\ /g'"'"' $$0' {}
