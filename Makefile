## ---- user config ----

# Set to anything non-empty to suppress most of latex's messaging. To diagnose LaTeX errors, you may want to do `make latex_quiet=""` to get verbose output
latex_quiet := true

# Set to anything non-empty to reprocess TeX files every time we make a PDF.
# Otherwise these files will be regenerated only when the source markdown
# changes; in that case, if you change other dependencies (e.g. a
# bibliography), you will have to use the -B option to make in order to force
# regeneration. If you have many talks it probably makes more to take this
# manual option.
# always_latexmk := true
always_latexmk := 

# Set to anything non-empty to use xelatex rather than pdflatex. I always do
# this in order to use system fonts and better Unicode support. pdflatex is
# faster, and there are some packages with which xelatex is incompatible.
xelatex := true

## ---- end config ----

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
handouts_scripts_tex := $(patsubst scripts/%.md,handouts/%.tex,$(scripts_md))
handouts_scripts_pdf := $(patsubst %.tex,%.pdf,$(handouts_scripts_tex))

# notes_pdf is handled separately
pdfs := $(scripts_pdf) $(slides_pdf) $(handouts_notes_pdf) \
    $(handouts_scripts_pdf)

PANDOC := pandoc -t beamer $(if $(xelatex),--latex-engine xelatex) \
    --filter overlay_filter

$(notes_tex): lectures/%.tex: notes/%.md
	mkdir -p lectures
	$(PANDOC) --template elsmd-slides.latex \
	    -V beamer-notes=true \
	    -V fontsize=10pt \
	    -o $@ $<

$(scripts_tex): lectures/%.tex: scripts/%.md
	mkdir -p lectures
	$(PANDOC) --template beamerarticle.latex \
	    --slide-level 2 \
	    -V fontsize=12pt \
	    -o $@ $<

$(slides_notes_tex): slides/%.tex: notes/%.md
	mkdir -p slides
	$(PANDOC) --template elsmd-slides.latex \
	    -V scuro=true \
	    --slide-level 1 \
	    -o $@ $<

$(slides_scripts_tex): slides/%.tex: scripts/%.md
	mkdir -p slides
	$(PANDOC) --template elsmd-slides.latex \
	    -V scuro=true \
	    --slide-level 2 \
	    -o $@ $<

$(handouts_notes_tex): handouts/%.tex: notes/%.md
	mkdir -p handouts
	$(PANDOC) --template elsmd-slides.latex \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    --slide-level 1 \
	    -o $@ $<

$(handouts_scripts_tex): handouts/%.tex: scripts/%.md
	mkdir -p handouts
	$(PANDOC) --template elsmd-slides.latex \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    --slide-level 2 \
	    -o $@ $<

phony_pdfs := $(if $(always_latexmk),$(pdfs) $(notes_pdf))

temp_dir := tmp
LATEXMK := latexmk $(if $(xelatex),-xelatex,-pdflatex="pdflatex %O %S") \
    -pdf -dvi- -ps- $(if $(latex_quiet),-silent,-verbose) \
    -outdir=$(temp_dir)

.PHONY: $(phony_pdfs) all clean reallyclean
$(pdfs): %.pdf: %.tex
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	mv $(dir $@)$(temp_dir)/$(notdir $@) $@
	rm -r $(dir $@)$(temp_dir)

$(notes_pdf): %.pdf: %.tex
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	pdfjam --nup 2x2 --landscape $(dir $@)$(temp_dir)/$(notdir $@) -o $@
	rm -r $(dir $@)$(temp_dir)

all: $(pdfs) $(notes_pdf)

# clean up everything except final pdfs
clean:
	rm -rf lectures/$(temp_dir) slides/$(temp_dir) handouts/$(temp_dir)
	rm -f $(notes_tex) $(scripts_tex) \
	    $(slides_notes_tex) $(slides_scripts_tex) \
	    $(handouts_notes_tex) $(handouts_scripts_tex) 

# clean up everything including pdfs
reallyclean: clean
	rm -f $(pdfs) $(notes_pdf)

.DEFAULT_GOAL := all
