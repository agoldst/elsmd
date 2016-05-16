
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

pdfs := $(notes_pdf) $(scripts_pdf) $(slides_pdf) $(handouts_notes_pdf)

$(notes_tex): lectures/%.tex: notes/%.md
	mkdir -p lectures
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V nup=4 \
	    -V beamer-notes=true \
	    -V fontsize=8pt \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(scripts_tex): lectures/%.tex: scripts/%.md
	mkdir -p lectures
	pandoc $< \
	    -t beamer \
	    --template scuro_talk.latex \
	    --slide-level 2 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(slides_notes_tex): slides/%.tex: notes/%.md
	mkdir -p slides
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    --slide-level 1 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(slides_scripts_tex): slides/%.tex: scripts/%.md
	mkdir -p slides
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    --slide-level 2 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

$(handouts_notes_tex): handouts/%.tex: notes/%.md
	mkdir -p handouts
	pandoc $< \
	    -t beamer \
	    --template scuro_slides.latex \
	    -V nup=4 \
	    --slide-level 1 \
	    --latex-engine xelatex \
	    --filter overlay_filter \
	    -o $@

.PHONY: $(pdfs) all clean reallyclean
$(pdfs): %.pdf: %.tex
	cd $(dir $<); \
	    latexmk -xelatex $(if $(latex_verbose),-verbose) $(notdir $<)

all: $(pdfs)


# clean up everything except final pdfs
clean:
	for (d in lectures slides handouts); do \
	    cd $$d;\
	    latexmk -c;\
	    rm -rf *.nav *.snm *.tex;\
	done


# clean up everything including pdfs
reallyclean:
	for (d in lectures slides handouts); do \
	    cd $$d;\
	    latexmk -C;\
	    rm -rf *.nav *.snm *.tex;\
	done

.DEFAULT_GOAL := all
