notes := $(wildcard *.md)
notes_tex := $(patsubst %.md,%.tex,$(notes))
notes_pdf := $(patsubst %.tex,%.pdf,$(notes_tex)) 

# output filename will be name-suffix.pdf
nup_suffix := 4up
nup_layout := 2x2
# for portrait, set to --no-landscape
nup_landscape := --landscape

notes_nup := $(patsubst %.pdf,%-$(nup_suffix).pdf,$(notes_pdf))

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

$(notes_nup): %-$(nup_suffix).pdf: %.pdf
	pdfjam $< \
	    $(nup_landscape) \
	    --nup $(nup_layout) \
	    --suffix $(nup_suffix)

all: $(notes_pdf) $(notes_nup)

# clean up everything except final pdfs
clean:
	latexmk -c
	rm -rf *.nav *.snm
	rm -rf $(notes_tex)

# clean up everything including pdfs
reallyclean:
	latexmk -C
	rm -rf *.nav *.snm
	rm -rf $(notes_tex)
	rm -rf $(notes_nup)

.DEFAULT_GOAL := all

.PHONY: all clean reallyclean

