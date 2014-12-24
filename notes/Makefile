notes := $(wildcard *.md)
notes_tex := $(patsubst %.md,%.tex,$(notes))
notes_pdf := $(patsubst %.tex,%.pdf,$(notes_tex)) 

$(notes_tex): %.tex: %.md preamble-notes.tex
	pandoc $< \
	    -t beamer \
	    -H preamble-notes.tex \
	    -V fontsize=8pt \
	    --filter overlay_filter \
	    --latex-engine xelatex \
	    -o $@

$(notes_pdf): %.pdf: %.tex
	latexmk -xelatex $(basename $<)

all: $(notes_pdf)

.DEFAULT_GOAL := all

.PHONY: all

