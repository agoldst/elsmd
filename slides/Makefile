
notedir := ../notes

notes := $(wildcard $(notedir)/*.md)
slides_tex := $(patsubst $(notedir)/%.md,%.tex,$(notes))
slides_pdf := $(patsubst %.tex,%.pdf,$(slides_tex)) 
slides_key := $(patsubst %.pdf,%.key,$(slides_pdf)) 

$(slides_tex): %.tex: $(notedir)/%.md preamble-slides.tex
	pandoc $< \
	    -t beamer \
	    --slide-level 1 \
	    -H preamble-slides.tex \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(slides_pdf): %.pdf: %.tex
	latexmk -xelatex $(basename $<)

$(slides_key): %.key: %.pdf
	rm -f $@
	open -a "PDF To Keynote" $<
	osascript -e 'tell application "PDF To Keynote"' \
	    -e 'save document 1 in "$(abspath ./$(basename $@))"' \
	    -e 'end tell'

all: $(slides_pdf)

.DEFAULT_GOAL := all

.PHONY: all 
