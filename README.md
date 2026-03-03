# ELSMD: Easy Lecture Slides Made Difficult

This setup, created by a Keynote refugee, uses pandoc and some Beamer bells and whistles to generate presentation materials. It is designed for two kinds of talking:

1. *Lecturing from notes*. You speak impromptu from slides, with perhaps some extra notes in your hands, keyed to the slides.

2. *Lecturing from a script*. You write out a talk and read it, stepping through slides as you go.

In either case you may wish to distribute a handout with your slides to your listeners to take notes on. I don't really do this anymore, but I spent some time hacking it together and it may be useful once again for teaching in these laptop-banning days (2026 as I write).

## Requirements

- [pandoc](https://pandoc.org). Most recently tested with v3.8.3. Earlier versions may not work. 
- TeX Live, including xelatex, latexmk, and pdfjam (for speaker notes). Most recently tested with MacTeX 2025. 
- Make.

The pdfjam program is used to create 4-up speaker notes (two slides and two pages of notes on each page). One can't use the `pgfpages` package for this because beamer's `\note` is not compatible with `pgfpages` layouts under xelatex. `pgfpages` *is* used to create the handouts (with two slides on the left and blank space on the right, for audiences), since handouts hide `\notes` anyway.

latexmk is used to control xelatex and biber. This has the advantage of automating the multiple passes needed for using biblatex citations. It has the disadvantage of creating many auxiliary files. The Make rules here wipe out all the auxiliary files once the PDF has been created. This trades reduced clutter for speed, since it means that latexmk can never skip any passes after an initial run. It will take several seconds to generate even a small slideshow. Modern computing!

## Installation

You could simply clone or download this repository for each family of talks (e.g. a course of lectures), but I don't like proliferating copies of everything here, so instead, I suggest cloning this once, and running `make install`, which copies the lua filters and pandoc template files to `$HOME/.pandoc/{filters,templates}`. Then, for each new family of talks, copy over the [Makefile](Makefile) and create a folder `notes` or `scripts` or both to put your markdown in.

(You can change the names of either or both of those source-markdown directories in the Makefile: the names are the variables `NOTES` and `SCRIPTS`. You can set one or the other to `.` to dispense with the extra subdirectory layer.)

## Usage

See the Pandoc documentation [under "Producing slide shows"](https://pandoc.org/MANUAL.html#producing-slide-shows-with-pandoc) for general guidance on formatting markdown for slide shows. 

### Lectures from notes

Create markdown files in the `notes` directory, on the model of [notes/notes-sample.md](notes/notes-sample.md). Using `make` then by default generates the following PDF files (links go to the results of `make` on this repository):

1. `lectures/*.pdf`: slides and notes interleaved, two slides and two note-pages to a sheet, for the lecturer. Example: [lectures/notes-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/notes-sample.pdf).
1. `slides/*.pdf`: slides. Example: [slides/notes-sample.pdf](http://andrewgoldstone.com/elsmd/slides/notes-sample.pdf).
1. `slide-handouts/*.pdf`: sheets with two slides on the left and blank space on the right for audience member notes. Example: [slide-handouts/notes-sample.pdf](http://andrewgoldstone.com/elsmd/slide-handouts/notes-sample.pdf).

To add notes that will appear only on the speaker notes version of the presentation, use the special pandoc Div

```markdown
::: notes
Formatted speaker notes *here.*

Etc.
:::
```

To add notes with a beamer overlay, decorate the Div as follows:

```markdown
::: note<2>
This note will only be associated with the *second* stage of a frame.
:::
```

This is translated to `\note<2>{This note...}` by pandoc. You can also use beamer's `\note` command; inside `\note{...}`, use LaTeX, not markdown. 

Handouts use the Beamer class option `handout`, which collapses incremental slides into one to save paper and (possibly) confusion.

### Lectures from scripts

For lectures from scripts, create markdown files in the `scripts` directory, on the model of [scripts/script-sample.md](scripts/script-sample.md). Using `make` then generates:

1. `lectures/*.pdf`: a talk script to read out (rather than script pages). Example: [lectures/script-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/script-sample.pdf).
1. `slides/*.pdf`: slides, as above. Example: [slides/script-sample.pdf](http://andrewgoldstone.com/elsmd/slides/script-sample.pdf).
1. `slide-handouts/*.pdf`: slide handout, as above. Example: [slide-handouts/script-sample.pdf](http://andrewgoldstone.com/elsmd/slide-handouts/script-sample.pdf).

Paragraphs of script to appear only on the speaker's version should go inside the special pandoc Div with class `noslide`

```markdown
::: noslide
Here is my script.
:::
```

The [noslide.lua](noslide.lua) filter removes this text from the slideshow and handout outputs; in the script output, these Divs are retained. 

### Everything at once

`make all` generates all possible PDFs from all markdown files in `notes` and `scripts`. If you have a file `notes/X.md` or `scripts/X.md`, `make X` (no extension) generates all three PDFs corresponding to `X`.

If you set `MAKE_HANDOUT=` (empty) in the Makefile, the slide handout will not be generated.

### Screening the presentation

I use [Présentation](http://iihm.imag.fr/blanch/software/osx-presentation/), a free program with an excellent presentation mode for PDFs, controllable from the keyboard.

# More detail on the source markdown

The PDFs are generated from a custom [pandoc template](http://pandoc.org/README.html#templates),  [elsmd-slides.latex](elsmd-slides.latex). This is based on pandoc's default Beamer template, with some switches to manage outputting the different formats. To produce a lecture script, the template uses the beamerarticle LaTeX package to convert Beamer slideshow code into an ordinary document with continuous text. It's not perfectly elegant but it works.

My templates allow a few extra YAML metadata variables to be set in the source markdown. For convenience in producing multiple sets of slides (e.g. a course of lectures), you may use the file [slide-meta.yaml](slide-meta.yaml) for metadata that is to be added to every set of slides. Metadata settings in this file are overriden if they are respecified in the file for an individual presentation.

## Typeface

Set the typeface for the slides. The default in [slide-meta.yaml](slide-meta.yaml) is:

```yaml
sansfont: Gill Sans
```

Keynote gave me a taste for Gill Sans. If you don't have or like Gill, [Fira Sans](https://www.mozilla.org/en-US/styleguide/products/firefox-os/typeface/) is free and worth considering. The beamer default is not nice. To use the `mainfont` rather than the `sansfont` on slides, adjust the `usefonttheme` command in the [slides template](elsmd-slides.latex).

## Lecture-script typeface

```yaml
mainfont: Hoefler Text
```

The `mainfont` is only used for lecture scripts. If you omit this, you'll get  Computer Modern, which is a bit spindly for a script you have to read from while talking and gesticulating. Choose something you find easy to read. A document font size of 12pt is set in the Makefile.

## Bibliography

For generating citations, I use `biblatex-chicago`. (I find that pandoc-citeproc is not adequate to citation in the humanities.) Set this up with

```yaml
biblatex: false
biblatex-chicago: true
biblatexoptions: [notes, noibid]
bibliography: ../sources.bib
```

Though you _are_ using biblatex, set `biblatex: false`. To keep up with pandoc templates changes, my templates incorporate pandoc's default "partial" templates; these partials include vanilla `biblatex` code that is incompatible with `biblatex-chicago`. Hence the complicated switching. (Even more complicatedly, you should still pass `--biblatex` as a pandoc command line option! The Makefile does this.) You can cite with pandoc-style `[@citation]` commands, which will produce in-text citations rather than footnotes (by altering the behavior of `\autocite`). I do not normally include slides with bibliographic listings, but these are generated (as many slides as are needed) if you set the `biblio-title` metadata variable:

```yaml
biblio-title: Bibliography
```

Other biblatex styles should work fine (omit the `biblatex-chicago: true` and use pandoc's usual variables). 

## Slide numbering

To display a slide count on each slide, use

```yaml
slide-numbers: true
```

## Laying a slide out on a grid

There are two options for more elaborate slide layouts than markdown allows you to express. You can use the beamer `columns` environment, just like any other LaTeX within markdown. But the templates used here also set up a 9x8 `textpos` grid. See [notes-sample.md](notes/notes-sample.md) and [script-sample.md](scripts/script-sample.md) for details on how to use this grid. That lets you simply put material at specific coordinates on the slide. 

## Colors

I have set this up to meet my preference for dark slides with light text, which I call "scuro" (I use that name for an [R package](http://github.com/agoldst/scuro) with the same purpose for R markdown-based slides).  If that is not your preference, note that this color scheme is specified in [elsmd-slides.latex](elsmd-slides.latex#45) and then turned on by the Makefile when it sets `scuro=true` in the invocation of pandoc to generate slides.

## Quotations

I include a snippet defining an `lquote` environment for quotations which may run to more than one paragraph. Unlike the bad beamer/LaTeX defaults, this environment uses the full width of the textblock, does not indent the first paragraph, and _does_ indent subsequent paragraphs. To use without breaking your markdown flow, take advantage of an extra markdown feature implemented by [notes.lua](notes.lua): a native Div with a class of the form `l:env` is turned into a LaTeX `\begin{env}`. So: `::: l:quote ... :::`.

Last significant update: March 2026
