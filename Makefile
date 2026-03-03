## ---- user config ----

# Set to anything non-empty to suppress most of latex's messaging.
# To diagnose LaTeX errors, do `make quiet=` for verbose output
quiet := true

# Set to anything non-empty to reprocess TeX files every time we make a PDF.
# Otherwise these files will be regenerated only when the source markdown
# changes; in that case, if you change other dependencies (e.g. a
# bibliography), you will have to use the -B option to make in order to force
# regeneration. If you have many talks it probably makes more to take this
# manual option.
# ALWAYS_LATEXMK := true
ALWAYS_LATEXMK := 

# Set to anything non-empty to use xelatex rather than pdflatex. I always do
# this in order to use system fonts and better Unicode support. pdflatex is
# faster, and there are some packages with which xelatex is incompatible.
XELATEX := true

# directories for markdown sources: notes and scripts
NOTES := notes
SCRIPTS := scripts

# output directories
SLIDES := slides
LECTURES := lectures
HANDOUTS := slide_handouts # because I often have an independent `handout` folder

# set to empty if you don't want to generate the handouts
# MAKE_HANDOUTS :=
MAKE_HANDOUTS := true

# default metadata added to all inputs; can be overridden, or leave empty to remove
# (multiple YAML files possible too)
SLIDE_YAML := slide-meta.yaml

# Set to anything non-empty to always use the "scuro" dark-on-light scheme
# on slides. Comment this out to turn this off (you can still turn it on
# in individual files with "scuro: true" in the YAML metadata)
SCURO := true

# Extra options to pandoc. Note that certain options set here are overridden.
PANDOC_OPTIONS := --biblatex

## ---- special external files ----

# Normally these do not need to be changed

# filter used to generate lecture script
# this specification works if lua script is local or ~/.pandoc/filters
NOSLIDE_LUA := noslide.lua

# filter used to process speaker notes with beamer overlays
NOTES_LUA := notes.lua

# this will work if this template file is local or in ~/.pandoc/templates
SLIDES_TMPL := elsmd-slides.latex

# used for `make install`

PARTIAL_TMPLS := biblatex-chicago.latex routput.latex
TMPL_DIR := $(HOME)/.pandoc/templates
FILTER_DIR := $(HOME)/.pandoc/filters

# temp file subdirectory (created in lectures, slides, slide_handouts)
# change this if you're using */tmp for something else
temp_dir := tmp

## ---- install ----

# copy templates and filter script to pandoc's default locations for these
install:
	cp -f $(SLIDES_TMPL) $(PARTIAL_TMPLS) $(TMPL_DIR)
	cp -f $(NOSLIDE_LUA) $(NOTES_LUA) $(FILTER_DIR)

## ---- pandoc and latexmk config ----

# pandoc 2 changes the latex-option name to pdf-engine, so:
pandoc2 := `pandoc -v | head -1 | grep '^pandoc 2'`
pandoc_xelatex := $(if $(XELATEX),$(if $(pandoc2),--pdf-engine,--latex-engine) xelatex)
PANDOC := pandoc $(pandoc_xelatex) $(PANDOC_OPTIONS) --lua-filter=$(NOTES_LUA)

LATEXMK := latexmk $(if $(XELATEX),-xelatex,-pdflatex="pdflatex %O %S") \
    -pdf -dvi- -ps- $(if $(quiet),-silent,-verbose) \
    -outdir=$(temp_dir)

NOSLIDE_FILTER := --lua-filter=$(NOSLIDE_LUA)

## ---- build rules ----

notes_md := $(wildcard $(NOTES)/*.md)
scripts_md := $(wildcard $(SCRIPTS)/*.md)

lectures_notes_tex := $(patsubst $(NOTES)/%.md,$(LECTURES)/%.tex,$(notes_md))
lectures_notes_pdf := $(patsubst %.tex,%.pdf,$(lectures_notes_tex)) 
lectures_scripts_tex := $(patsubst $(SCRIPTS)/%.md,$(LECTURES)/%.tex,$(scripts_md))
lectures_scripts_pdf := $(patsubst %.tex,%.pdf,$(lectures_scripts_tex)) 

slides_notes_tex := $(patsubst $(NOTES)/%.md,$(SLIDES)/%.tex,$(notes_md))
slides_notes_pdf := $(patsubst %.tex,%.pdf,$(slides_notes_tex)) 
slides_scripts_tex := $(patsubst $(SCRIPTS)/%.md,$(SLIDES)/%.tex,$(scripts_md))
slides_scripts_pdf := $(patsubst %.tex,%.pdf,$(slides_scripts_tex)) 

handouts_notes_tex := $(patsubst $(NOTES)/%.md,$(HANDOUTS)/%.tex,$(notes_md))
handouts_notes_pdf := $(patsubst %.tex,%.pdf,$(handouts_notes_tex))
handouts_scripts_tex := $(patsubst $(SCRIPTS)/%.md,$(HANDOUTS)/%.tex,$(scripts_md))
handouts_scripts_pdf := $(patsubst %.tex,%.pdf,$(handouts_scripts_tex))

## ---- intermediate TeX file generation ----

$(lectures_notes_tex): $(LECTURES)/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p $(LECTURES)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    -V beamer-notes=true \
	    -V fontsize=10pt \
	    -V scuro="" \
	    -o $@ $^

$(lectures_scripts_tex): $(LECTURES)/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p $(LECTURES)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(NOSLIDE_FILTER) \
	    -V beamerarticle=true \
	    -M hide_noslide=false \
	    -V fontsize=12pt \
	    -V scuro="" \
	    -V section-titles="" \
	    -o $@ $^

$(slides_notes_tex): $(SLIDES)/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p $(SLIDES)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(if $(SCURO),-V scuro=true) \
	    -o $@ $^

$(slides_scripts_tex): $(SLIDES)/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p $(SLIDES)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(NOSLIDE_FILTER) \
	    $(if $(SCURO),-V scuro=true) \
	    -V section-titles="" \
	    -o $@ $^

$(handouts_notes_tex): $(HANDOUTS)/%.tex: $(SLIDE_YAML) $(NOTES)/%.md
	mkdir -p $(HANDOUTS)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    -V scuro="" \
	    -o $@ $^

$(handouts_scripts_tex): $(HANDOUTS)/%.tex: $(SLIDE_YAML) $(SCRIPTS)/%.md
	mkdir -p $(HANDOUTS)
	$(PANDOC) -t beamer --template $(SLIDES_TMPL) \
	    $(NOSLIDE_FILTER) \
	    -V beamer-handout=true \
	    -V classoption=handout \
	    -V scuro="" \
	    -V section-titles="" \
	    -o $@ $^

## ---- PDF typesetting ----

# pdfs1up is all pdfs except for lectures_notes_pdf,
# which needs separate treatment for 2x2up printing
pdfs1up := $(lectures_scripts_pdf) $(slides_notes_pdf) $(slides_scripts_pdf) \
	   $(handouts_notes_pdf) $(handouts_scripts_pdf)

pdfs := $(pdfs1up) $(lectures_notes_pdf)

# if always_latexmk is true, make all pdf targets phony
phony_pdfs := $(if $(ALWAYS_LATEXMK),$(pdfs))

# phony targets to make all PDFs for a single source,
# slides and lecture notes/script and (optionally) handouts
pdfsets := $(notdir $(basename $(notes_md) $(scripts_md)))

$(pdfsets): %:$(LECTURES)/%.pdf $(SLIDES)/%.pdf $(if MAKE_HANDOUTS,$(HANDOUTS)/%.pdf)

.PHONY: $(phony_pdfs) $(pdfsets) all clean reallyclean install

# most PDFs are simply latexmk (with some tmp dir movements)
$(pdfs1up): %.pdf: %.tex
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	mv $(dir $@)$(temp_dir)/$(notdir $@) $@
	rm -r $(dir $@)$(temp_dir)

# but for lecture notes, use pdfjam to create a 2x2up printout
$(lectures_notes_pdf): %.pdf: %.tex
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	pdfjam --nup 2x2 --landscape $(dir $@)$(temp_dir)/$(notdir $@) -o $@
	rm -r $(dir $@)$(temp_dir)


# clean up everything except final pdfs
clean:
	rm -rf $(LECTURES)/$(temp_dir) $(SLIDES)/$(temp_dir) $(HANDOUTS)/$(temp_dir)
	rm -f $(lectures_notes_tex) $(lectures_scripts_tex) \
	    $(slides_notes_tex) $(slides_scripts_tex) \
	    $(handouts_notes_tex) $(handouts_scripts_tex) 

# clean up everything including pdfs
reallyclean: clean
	rm -f $(pdfs)

all: $(pdfs)

.DEFAULT_GOAL := all

