
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

# if you don't have Keynote or don't want to generate the Keynote file
# but want to avoid errors when you use "make all" (the default),
# just set the slides_key variable to nothing by uncommenting this line:
#
# slides_key :=

$(slides_key): %.key: %.pdf
	rm -f $@
	open -a "PDF To Keynote" $<
	osascript -e 'tell application "PDF To Keynote"' \
	    -e 'save document 1 in "$(abspath ./$(basename $@))"' \
	    -e 'end tell'

all: $(slides_pdf)

all_key: $(slides_key)

# clean up everything except pdfs and keynote files 
clean:
	latexmk -c
	rm -rf *.nav *.snm
	rm -rf $(slides_tex)

# clean up everything including pdfs and keynote files 
reallyclean:
	latexmk -C
	rm -rf $(slides_tex)
	rm -rf *.nav *.snm
	rm -rf $(slides_key)

.DEFAULT_GOAL := all

.PHONY: all all_key clean reallyclean
