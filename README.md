# ELSMD: Easy Lecture Slides Made Difficult

This setup, created by a Keynote refugee, uses pandoc and some Beamer bells and whistles to generate presentation materials. It is designed for two kinds of talking:

1. *Lecturing from notes*. You speak impromptu from slides, with perhaps some extra notes in your hands, keyed to the slides.

2. *Lecturing from a script*. You write out a talk and read it, stepping through slides as you go.

In either case you may wish to distribute a handout with your slides to your listeners.

## Requirements

- [pandoc](https://pandoc.org). Most recently tested with v2.7.2. Earlier versions may not work. 
- TeX Live, including xelatex, latexmk, and pdfjam (for speaker notes). Most recently tested with MacTeX 2018. 
- Make.

The pdfjam program is used to create 4-up speaker notes (two slides and two pages of notes on each page). One can't use the `pgfpages` package for this because beamer's `\note` is not compatible with `pgfpages` layouts under xelatex. `pgfpages` *is* used to create the handouts (with two slides on the left and blank space on the right, for audiences), since handouts hide `\notes` anyway.

latexmk is used to control xelatex and biber. This has the advantage of automating the multiple passes needed for using biblatex citations. It has the disadvantage of creating many auxiliary files. The Make rules here wipe out all the auxiliary files once the PDF has been created. This trades reduced clutter for speed, since it means that latexmk can never skip any passes after an initial run. It will take several seconds to generate even a small slideshow. Modern computing!

## Installation

You could simply clone or download this repository for each family of talks (e.g. a course of lectures). If you'd rather not proliferate copies of everything here, then you can instead 

1. Place [noslide.lua](noslide.lua) where pandoc looks for filters (by default, `$HOME/.pandoc/filters`)
2. Place [elsmd-slides.latex](elsmd-slides.latex) and [beamerarticle.latex](beamerarticle.latex) where pandoc looks for templates (by default, `$HOME/.pandoc/templates`).
3. Copy over the [Makefile](Makefile) and create a folder `notes` or `scripts` or both to put your markdown in.


## Usage

See the Pandoc documentation [under "Producing slide shows"](https://pandoc.org/MANUAL.html#producing-slide-shows-with-pandoc) for general guidance on formatting markdown for slide shows. 

### Lectures from notes

Create markdown files in the `notes` directory, on the model of [notes/notes-sample.md](notes/notes-sample.md). Using `make` then generates the following PDF files (links go to the results of `make` on this repository):

1. `lectures/*.pdf`: slides and notes interleaved, two slides and two note-pages to a sheet, for the lecturer. Example: [lectures/notes-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/notes-sample.pdf).
1. `slides/*.pdf`: slides. Example: [slides/notes-sample.pdf](http://andrewgoldstone.com/elsmd/slides/notes-sample.pdf).
1. `handouts/*.pdf`: sheets with two slides on the left and blank space on the right for audience notes. Example: [handouts/notes-sample.pdf](http://andrewgoldstone.com/elsmd/handouts/notes-sample.pdf).

To add notes that will appear only on the speaker notes version of the presentation, use the special pandoc Div

```markdown
::: notes
Formatted speaker notes *here.*

Etc.
:::
```

You can also use beamer's `\note` command; inside `\note{...}`, use LaTeX, not markdown. The main reason to choose `\note` would be to specify different notes for incremental lists or pauses using Beamer overlays (`\note<2>{...}`).

Handouts use the Beamer class option `handout`, which collapses incremental slides into one to save paper and (possibly) confusion.

### Lectures from slides

For lectures from scripts, create markdown files in the `scripts` directory, on the model of [scripts/script-sample.md](scripts/script-sample.md). Using `make` then generates:

1. `lectures/*.pdf`: a talk script to read out (rather than script pages). Example: [lectures/script-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/script-sample.pdf).
1. `slides/*.pdf`: slides, as above. Example: [slides/script-sample.pdf](http://andrewgoldstone.com/elsmd/slides/script-sample.pdf).
1. `handouts/*.pdf`: slide handout, as above. Example: [handouts/script-sample.pdf](http://andrewgoldstone.com/elsmd/handouts/script-sample.pdf).

Paragraphs of script to appear only on the speaker's version should go inside the special pandoc Div with class `noslide`

```markdown
::: noslide
Here is my script.
:::
```

The [noslide.lua](noslide.lua) filter removes this text from the slideshow and handout outputs; in the script output, these Divs are retained. 

### Everything at once

`make all` generates all possible PDFs from all markdown files in `notes` and `scripts`. If you have a file `notes/X.md` or `scripts/X.md`, `make X` (no extension) generates all three PDFs corresponding to `X`.

### Screening the presentation

I use [Présentation](http://iihm.imag.fr/blanch/software/osx-presentation/), a free program with an excellent presentation mode for PDFs, controllable from the keyboard.

I used to use Keynote as a presentation viewer (first converting PDFs using [PDF to Keynote](http://www.cs.hmc.edu/~oneill/freesoftware/pdftokeynote.html)), but Keynote is sadly diminished these days.

# More detail on the source markdown

The PDFs are generated from two custom [pandoc templates](http://pandoc.org/README.html#templates), which are included here. [elsmd-slides.latex](elsmd-slides.latex) is the template for slides, notes, and handouts. [beamerarticle.latex](beamerarticle.latex) is the template for a lecture script. Both are based on pandoc's default Beamer template, but the latter takes advantage of the beamerarticle LaTeX package (included with Beamer) to convert Beamer slideshow code into an ordinary document with continuous text.

My templates allow a few extra YAML metadata variables to be set in the source markdown.

## Typeface

Set the typeface for the slides:

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
biblatex: true
biblatex-chicago: true
biblatexoptions: [notes, noibid]
bibliography: ../sources.bib
```

and cite using LaTeX `\cite{citekey}` commands rather than pandoc-style `[@citekey]` commands. I do not normally include slides with bibliographic listings, but these are generated (as many slides as are needed) if you set the `biblio-title` metadata variable:

```yaml
biblio-title: Bibliography
```

Other biblatex styles should work fine (omit the `biblatex-chicago: true` and use pandoc's usual variables). If you really want to use pandoc-style `[@citekey]`s, it is possible but requires additional tweaking. Staying within biblatex, you'd adjust the Makefile's `PANDOC_OPTIONS` variable to `--biblatex -H preamble.tex` and create a `preamble.tex` file with the line `\DeclareAutociteCommand{footnote}{\cite}{\cites}` or similar (unless you want footnotes on slides). Or if you insist on pandoc-citeproc then set `PANDOC_OPTIONS := --filter pandoc-citeproc` instead.

## Slide numbering

To display a slide count on each slide, use

```yaml
slide-numbers: true
```

## Laying a slide out on a grid

There are two options for more elaborate slide layouts than markdown allows you to express. You can use the beamer `columns` environment, just like any other LaTeX within markdown. The templates used here also set up a 9x8 `textpos` grid. See [notes-sample.md](notes/notes-sample.md) and [script-sample.md](scripts/script-sample.md) for details on how to use this grid.

The rationale for doing this is explained in a blog post about an earlier version of this setup: ["Easy Lecture Slides Made Difficult with Pandoc and Beamer."](http://andrewgoldstone.com/blog/2014/12/24/slides/)

## Colors

I have set this up to meet my preference for dark slides with light text, which I call "scuro" (I use that name for an [R package](http://github.com/agoldst/scuro) with the same purpose for R markdown-based slides).  If that is not your preference, note that this color scheme is specified in [elsmd-slides.latex](elsmd-slides.latex#45) and then turned on by the Makefile when it sets `scuro=true` in the invocation of pandoc to generate slides.

## Note on editing

I use the [vim-pandoc](http://github.com/vim-pandoc/vim-pandoc) and [vim-pandoc-syntax](https://github.com/vim-pandoc/vim-pandoc-syntax) modules for editing markdown in Vim. However, the syntax highlighting has trouble with things like multiline `\note{}`s. A small kludge to the syntax highlighting is supplied here in [vim-pandoc-syntax/after/syntax/pandoc.vim](vim-pandoc-syntax/after/syntax/pandoc.vim), which will work if you adopt the convention of closing `\note{` with a `}` on its own line. The highlighting will then remind you that presentation notes are not markdown but raw TeX. 
