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

# directories for markdown sources: notes and scripts
NOTES := notes
SCRIPTS := scripts

# default metadata added to all slides and handouts; leave empty to remove
SLIDE_YAML := slide-meta.yaml

# Set to anything non-empty to always use the "scuro" dark-on-light scheme
# on slides. Comment this out to turn this off (you can still turn it on
# in individual files with "scuro: true" in the YAML metadata)
SCURO := true

# Extra options to pandoc. Note that certain options set here are overridden.
PANDOC_OPTIONS := 

## ---- special external files ----

# Normally these do not need to be changed

# filter used to generate lecture script
# this specification works if lua script is local or ~/.pandoc/filters
NOSLIDE_LUA := noslide.lua

# filter used to process speaker notes with beamer overlays
NOTES_LUA := notes.lua

# these work if the two templates are local or in ~/.pandoc/templates
SLIDES_TMPL := elsmd-slides.latex
SCRIPT_TMPL := beamerarticle.latex

# used for `make install`

TMPL_DIR := $(HOME)/.pandoc/templates
FILTER_DIR := $(HOME)/.pandoc/filters

# temp file subdirectory (created in lectures, slides, handouts)
# change this if you're using */tmp for something else
temp_dir := tmp

## ---- install ----

# copy templates and filter script to pandoc's default locations for these
install:
	cp -f $(SLIDES_TMPL) $(SCRIPT_TMPL) $(TMPL_DIR)
	cp -f $(NOSLIDE_LUA) $(NOTES_LUA) $(FILTER_DIR)

## ---- commands ----

# Change these only to really change the behavior of the whole setup

# pandoc 2 changes the latex-option name to pdf-engine, so:
pandoc2 := `pandoc -v | head -1 | grep '^pandoc 2'`
pandoc_xelatex := $(if $(xelatex),$(if $(pandoc2),--pdf-engine,--latex-engine) xelatex)
PANDOC := pandoc $(pandoc_xelatex) $(PANDOC_OPTIONS) --lua-filter=$(NOTES_LUA)

LATEXMK := latexmk $(if $(xelatex),-xelatex,-pdflatex="pdflatex %O %S") \
    -pdf -dvi- -ps- $(if $(latex_quiet),-silent,-verbose) \
    -outdir=$(temp_dir)

NOSLIDE_FILTER := --lua-filter=$(NOSLIDE_LUA)

## ---- build rules ----

notes_md := $(wildcard $(NOTES)/*.md)
scripts_md := $(wildcard $(SCRIPTS)/*.md)

notes_tex := $(patsubst $(NOTES)/%.md,lectures/%.tex,$(notes_md))
notes_pdf := $(patsubst %.tex,%.pdf,$(notes_tex)) 
scripts_tex := $(patsubst $(SCRIPTS)/%.md,lectures/%.tex,$(scripts_md))
scripts_pdf := $(patsubst %.tex,%.pdf,$(scripts_tex)) 
slides_notes_tex := $(patsubst $(NOTES)/%.md,slides/%.tex,$(notes_md))
slides_scripts_tex := $(patsubst $(SCRIPTS)/%.md,slides/%.tex,$(scripts_md))
slides_pdf := $(patsubst %.tex,%.pdf,$(slides_notes_tex) $(slides_scripts_tex))
handouts_notes_tex := $(patsubst $(NOTES)/%.md,handouts/%.tex,$(notes_md))
handouts_notes_pdf := $(patsubst %.tex,%.pdf,$(handouts_notes_tex))
handouts_scripts_tex := $(patsubst $(SCRIPTS)/%.md,handouts/%.tex,$(scripts_md))
handouts_scripts_pdf := $(patsubst %.tex,%.pdf,$(handouts_scripts_tex))

# notes_pdf is handled separately
pdfs := $(scripts_pdf) $(slides_pdf) $(handouts_notes_pdf) \
    $(handouts_scripts_pdf)

$(notes_tex): lectures/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p lectures
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    -V beamer-notes=true \
	    -V fontsize=10pt \
	    -V scuro="" \
	    -o $@ $^

$(scripts_tex): lectures/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p lectures
	$(PANDOC) -t beamer --template $(SCRIPT_TMPL) \
	    $(NOSLIDE_FILTER) \
	    -M hide_noslide=false \
	    -V fontsize=12pt \
	    -V scuro="" \
	    -V section-titles="" \
	    -o $@ $^

$(slides_notes_tex): slides/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p slides
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(if $(SCURO),-V scuro=true) \
	    -o $@ $^

$(slides_scripts_tex): slides/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p slides
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(NOSLIDE_FILTER) \
	    $(if $(SCURO),-V scuro=true) \
	    -V section-titles="" \
	    -o $@ $^

$(handouts_notes_tex): handouts/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p handouts
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    -V scuro="" \
	    -o $@ $^

$(handouts_scripts_tex): handouts/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p handouts
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(NOSLIDE_FILTER) \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    -V scuro="" \
	    -V section-titles="" \
	    -o $@ $^

phony_pdfs := $(if $(always_latexmk),$(pdfs) $(notes_pdf))

# phony targets to make all three PDFS for a single source
pdfsets := $(notdir $(basename $(notes_md) $(scripts_md)))

$(pdfsets): %:lectures/%.pdf slides/%.pdf handouts/%.pdf

.PHONY: $(phony_pdfs) $(pdfsets) all clean reallyclean install

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

