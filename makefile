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
