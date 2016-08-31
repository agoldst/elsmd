# Markdown to lecture slides

Using pandoc, with some Beamer bells and whistles, by a Keynote refugee.

This setup is designed for two kinds of talking:

1. *Lecturing from notes*. You speak impromptu from slides, with perhaps some extra notes in your hands, keyed to the slides.

2. *Lecturing from a script*. You write out a talk and read it, stepping through slides as you go.

In either case you may wish to distribute a handout with your slides to your listeners.

For lectures from notes, create markdown files in the `notes` directory, on the model of [notes/notes-sample.md](notes/notes-sample.md). Using `make` then generates the following PDF files (links go to the results of `make` on this repository):

1. `lectures/*.pdf`: slides and notes interleaved, two slides and two note-pages to a sheet, for the lecturer. Example: [lectures/notes-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/notes-sample.pdf).
1. `slides/*.pdf`: slides. Example: [slides/notes-sample.pdf](http://andrewgoldstone.com/elsmd/slides/notes-sample.pdf).
1. `handouts/*.pdf`: sheets with two slides on the left and blank space on the right for audience notes. Example: [handouts/notes-sample.pdf](http://andrewgoldstone.com/elsmd/handouts/notes-sample.pdf).

For lectures from scripts, create markdown files in the `scripts` directory, on the model of [scripts/script-sample.md](scripts/script-sample.md). Using `make` then generates:

1. `lectures/*.pdf`: a talk script to read out (rather than script pages). Example: [lectures/script-sample.pdf](http://andrewgoldstone.com/elsmd/lectures/script-sample.pdf).
1. `slides/*.pdf`: slides, as above. Example: [slides/script-sample.pdf](http://andrewgoldstone.com/elsmd/slides/script-sample.pdf).
1. `handouts/*.pdf`: slide handout, as above. Example: [handouts/script-sample.pdf](http://andrewgoldstone.com/elsmd/handouts/script-sample.pdf).

`make all` generates all possible PDFs from all markdown files in `notes` and `scripts`. If you have a file `notes/X.md` or `scripts/X.md`, `make X` (no extension) generates all three PDFs corresponding to `X`.

I used to use Keynote as a presentation viewer (first converting PDFs using [PDF to Keynote](http://www.cs.hmc.edu/~oneill/freesoftware/pdftokeynote.html)). I don't like the presentation mode in the most recent Keynote, and I have switched to using [Présentation](http://iihm.imag.fr/blanch/software/osx-presentation/), a free program with an excellent presentation mode for PDFs, controllable from the keyboard.

# Installation

You could simply clone or download this repository for each family of talks (e.g. a course of lectures). If you'd rather not proliferate copies of everything here, then you can instead 

1. Place [overlay_filter](overlay_filter) in your `PATH`.
2. Place [elsmd-slides.latex](elsmd-slides.latex) and [beamerarticle.latex](beamerarticle.latex) where pandoc looks for templates (by default, `$HOME/.pandoc/templates`).
3. Copy over the [Makefile](Makefile) and create a folder `notes` or `scripts` or both to put your markdown in.

## System requirements

- pandoc
- TeX Live, including xelatex, latexmk, and pdfjam (for speaker notes)
- python
- make

The pdfjam program is used to create 4-up speaker notes (two slides and two pages of notes on each page). One can't use the `pgfpages` package for this because beamer's `\note` is not compatible with `pgfpages` layouts under xelatex. `pgfpages` *is* used to create the handouts (with two slides on the left and blank space on the right, for audiences), since handouts hide `\notes` anyway.

latexmk is used to control xelatex and biber. This has the advantage of automating the multiple passes needed for using biblatex citations. It has the disadvantage of creating many auxiliary files. The Make rules here wipe out all the auxiliary files once the PDF has been created. This trades reduced clutter for speed, since it means that latexmk can never skip any passes after an initial run. It will take several seconds to generate even a small slideshow. Modern computing!

# More detail on the source markdown

A bit more detail on the source markdown can be found in the sample files: [notes/notes-sample.md](notes/notes-sample.md) for a lecture from notes and [scripts/script-sample.md](scripts/script-sample.md) for a lecture from a script.

The PDFs are generated from two custom [pandoc templates](http://pandoc.org/README.html#templates), which are included here. [elsmd-slides.latex](elsmd-slides.latex) is the template for slides, notes, and handouts. [beamerarticle.latex](beamerarticle.latex) is the template for a lecture script. Both are based on pandoc's default Beamer template. My templates allow a few extra YAML metadata variables to be set in the source markdown:

Note that slides from scripts set the pandoc slide level to 2 (second-level headers start a new slide). For slides from notes, this level is 1 by default but can be changed by changing the variable `NOTES_SLIDE_LEVEL` in the [Makefile](Makefile#L34).

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

For generating citations, I use `biblatex-chicago`. Set this up with

```yaml
biblatex: true
biblatex-chicago: true
biblatexoptions: [notes, noibid]
bibliography: ../sources.bib
```

You can then cite using either pandoc-style `[@citekey]` or LaTeX `\cite{citekey}`. (pandoc-citeproc is not adequate to citation in the humanities.)

## Lecturing from notes: adding notes

To add notes, use beamer's `\note` command (inside `\note{...}`, use LaTeX, not markdown).


Handouts use the Beamer class option `handout`, which collapses incremental slides into one to save paper and (possibly) confusion.

## Lecturing from a script: demarcating slides

pandoc's slide generation is not really designed with lecturing from a script in mind. But a quirk of pandoc allows us to set this up fairly easily. Write paragraphs of markdown for the lecture script as normal. To specify a slide, begin with either a horizontal rule (three or more hyphens) or a *second-level* header. They end *either* with the start of another slide *or* with a *first-level* header. Examples:

An untitled slide:

```markdown
-----

- The cognitive style
- of PandocPoint

# 

Script text.
```

A titled slide:

```markdown
## Bite-size pieces

- The cognitive style
- of PandocPoint

# bold note to self in script

Script text.
```

The first-level headers can be empty, as in the first example, or contain text, as in the second example. Since this text will only appear in the script, not on the slides, it is useful for "stage directions." Note that if you want to write script text between the first (title) slide and the second, you should begin your markdown with a first-level header.

## Using beamer overlays and modes

Beamer's "overlay specifications" allow you to create a series of slides that incrementally reveal or hide material. In LaTeX, one writes, for example

```latex
\begin{frame}

Shown three times.

\only<1,3>{Shown, hidden, shown}.

\end{frame}
```

In this setup, you write `{<...>}` for `<...>`:

```markdown
Shown three times.

\only{<1,3>}{Shown, hidden, shown}.
```

If you are writing a lecture script, the same substitution applies to a mode specification, which is used to designate material included in the slides but not in the script:

```markdown
\mode{<presentation>}

## Slides only

This material is entirely omitted from the script.

#

\mode*
```

`\mode*` takes us back to the original parsing state.

## Laying a slide out on a grid

There are two options for more elaborate slide layouts than markdown allows you to express. You can use the beamer `columns` environment, just like any other LaTeX within markdown. The templates used here also set up a 9x8 `textpos` grid. See [notes-sample.md](notes/notes-sample.md) and [script-sample.md](scripts/script-sample.md) for details on how to use this grid.

The rationale for doing this is explained in a blog post about an earlier version of this setup: ["Easy Lecture Slides Made Difficult with Pandoc and Beamer."](http://andrewgoldstone.com/blog/2014/12/24/slides/)

## Colors

I have set this up to meet my preference for dark slides with light text, which I call "scuro" (I use that name for an [R package](http://github.com/agoldst/scuro) with the same purpose for R markdown-based slides).  If that is not your preference, note that this color scheme is specified in [elsmd-slides.latex](elsmd-slides.latex#45) and then turned on by the Makefile when it sets `scuro=true` in the invocation of pandoc to generate slides.

