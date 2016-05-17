
latex_verbose := 

notes_md := $(wildcard notes/*.md)
scripts_md := $(wildcard scripts/*.md)

notes_tex := $(patsubst notes/%.md,lectures/%.tex,$(notes_md))
notes_pdf := $(patsubst %.tex,%.pdf,$(notes_tex)) 
scripts_tex := $(patsubst scripts/%.md,lectures/%.tex,$(scripts_md))
scripts_pdf := $(patsubst %.tex,%.pdf,$(scripts_tex)) 
slides_notes_tex := $(patsubst notes/%.md,slides/%.tex,$(notes_md))
slides_scripts_tex := $(patsubst scripts/%.md,slides/%.tex,$(scripts_md))
slides_pdf := $(patsubst %.tex,%.pdf,$(slides_notes_tex) $(slides_scripts_tex))
handouts_notes_tex := $(patsubst notes/%.md,handouts/%.tex,$(notes_md))
handouts_notes_pdf := $(patsubst %.tex,%.pdf,$(handouts_notes_tex))
handouts_script_tex := $(patsubst scripts/%.md,handouts/%.tex,$(scripts_md))
handouts_script_pdf := $(patsubst %.tex,%.pdf,$(handouts_script_tex))

# notes_pdf is handled separately
pdfs := $(scripts_pdf) $(slides_pdf) $(handouts_notes_pdf) \
    $(handouts_script_pdf)

$(notes_tex): lectures/%.tex: notes/%.md
	mkdir -p lectures
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V beamer-notes=true \
	    -V fontsize=10pt \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(scripts_tex): lectures/%.tex: scripts/%.md
	mkdir -p lectures
	pandoc $< \
	    -t beamer \
	    --template beamerarticle.latex \
	    --slide-level 2 \
	    -V fontsize=12pt \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(slides_notes_tex): slides/%.tex: notes/%.md
	mkdir -p slides
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V scuro=true \
	    --slide-level 1 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(slides_scripts_tex): slides/%.tex: scripts/%.md
	mkdir -p slides
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V scuro=true \
	    --slide-level 2 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(handouts_notes_tex): handouts/%.tex: notes/%.md
	mkdir -p handouts
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    --slide-level 1 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(handouts_script_tex): handouts/%.tex: scripts/%.md
	mkdir -p handouts
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    --slide-level 2 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

.PHONY: $(pdfs) $(notes_pdf) all clean reallyclean
$(pdfs): %.pdf: %.tex
	cd $(dir $<); \
	    latexmk -xelatex $(if $(latex_verbose),-verbose) \
	       -outdir=tmp $(notdir $<)
	mv $(dir $@)tmp/$(notdir $@) $@
	rm -r $(dir $@)tmp

$(notes_pdf): %.pdf: %.tex
	cd $(dir $<); \
	    latexmk -xelatex $(if $(latex_verbose),-verbose) $(notdir $<)
	pdfjam --nup 2x2 --landscape $(dir $@)tmp/$(notdir $@) -o $@
	rm -r $(dir $@)tmp

all: $(pdfs) $(notes_pdfs)

# clean up everything except final pdfs
clean:
	rm -rf lectures/tmp slides/tmp handouts/tmp
	rm -f lectures/*.tex
	rm -f slides/*.tex
	rm -f handouts/*.tex

# clean up everything including pdfs
reallyclean: clean
	rm -f lectures/*.pdf
	rm -f slides/*.pdf
	rm -f handouts/*.pdf

.DEFAULT_GOAL := all
