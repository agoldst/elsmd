---
title: Written-out Talk
author: |
  Scripted Talker  
  University of Careful Planning
date: May 1, 1894
mainfont: Hoefler Text
mainfontoptions:
 - Numbers=OldStyle
sansfont: Gill Sans
biblatex: true
biblatex-chicago: true
biblatexoptions: [notes, noibid]
bibliography: ../sources.bib
---

# 0:00

This is the beginning of the script. Neither this text nor the first-level heading appears in the slides.

-----

But vertical motion predominates in reading for those who have really acquired the skill.

\cite[163]{bringhurst:elements}.

# 

Now the script continues. A first-level heading is needed to terminate the markdown for the slide. It can be blank, as in this example. Slides start with either a bunch of dashes (as above) or second-level headings:

## Titled slide

\begin{center}
\includegraphics[width=5\TPHorizModule]{../media/proj.pdf}

\cite{diablo:projector}.
\end{center}

# 0:04

I like to use the top-level headings to mark my planned timing.
Notice the use of LaTeX rather than markdown for the image. This lets us specify the width in terms of the `textpos` grid. On the slides, the grid is a 9 $\times$ 8 grid with outer margins of 10 and 8 mm. Beamer slides are "physically" 128 mm $\times$ 96 mm. The resulting grid units are `\TPHorizModule` at 12 mm and `\TPVertModule` at 10 mm. In the script, these dimensions are about 1/2 in and 3/8 in, which should usually yield reasonable results.

-----

> - incremental material
> - yields multiple
> - slides

\only{<2>}{This will only appear on the second of three slides here.}

#

But the script will only show a single slide, collapsing the increments together. This is not completely ideal, and you may want to add a

# note to self: BUILD

to remind you to advance the slide. More complex "builds" are possible using beamer overlays. Beamer overlay specifications go in between `{<...>}` rather than just `<...>` as they would in LaTeX.

# Grid layouts

For fine layout control for images or other material that can't just be set like ordinary text in slides, use `textpos`:

## Image positioning

\begin{textblock}{4.5}(0,0.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}
\begin{textblock}{4.5}(4.5,0.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}
\begin{textblock}{4.5}(4.5,4.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}

\vspace*{8\TPVertModule}

#

More complex layouts can use the `textblock` environment from `textpos`. Unfortunately the script text can then overprint the images, becoming unreadable. A kludgy but not too exhausting solution is to insert a `\vspace*` command of the same total height as the grid (`8\TPVertModule`). Notice that if you provide the slide with a header, the top of the grid will overprint it (hence the top row of images here has been given a vertical origin of 0.25).

Alternatively, you can use `beamer`'s facilities for conditional compilation, the `\mode` commands. As with overlays, in markdown we have to write `{<...>}` for `<...>`. Switching modes within a slide sometimes gives errors, for reasons that are unclear to me. However, switching modes outside a slide (i.e. before the initial `-----` or `##` or after the terminating `#`) will be fine. `<presentation>` is the slides mode, `<article>` is the script mode. `\mode*` returns things to normal (in this case).

\mode{<presentation>}

## Slides only

\begin{textblock}{4.5}(0,0.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}

\begin{textblock}{4.5}(4.5,0.25)
Text on the grid works too.
\end{textblock}

\begin{textblock}{4.5}(4.5,4.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}

# does not appear anywhere

\mode*

# Slides only slide here

Again I suggest including a note to yourself that a slide has been omitted. Note that the terminating top level header of the slide is not found in the script.

An alternative to textpos is Beamer's `columns` environment, which lets you construct many layouts. You may still find it useful to use the textpos grid units rather than multiples of `\textwidth` (which will take up a lot of space in the script).

## Beamer columns

\begin{columns}[T]
\begin{column}{4.5\TPHorizModule}
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{column}
\begin{column}{4.5\TPHorizModule}
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{column}
\end{columns}

#

For an example of the interaction between `textpos` and overlay specifications, see `notes/notes-sample.md`.
