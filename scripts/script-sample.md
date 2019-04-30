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
...

But vertical motion predominates in reading for those who have really acquired the skill.

\cite[163]{bringhurst:elements}.

::: noslide

The script begins here, after the second slide (with this setup, there is no way to get script text to print immediately after the title block).

:::

## Titled slide

\begin{center}
\includegraphics[width=5\TPHorizModule]{../media/proj.pdf}

\cite{diablo:projector}.
\end{center}

::: noslide
## 0:04

I like to use headings to mark my planned timing. Notice the use of LaTeX rather than markdown for the image in order to specify the width in terms of the `textpos` grid unit. On the slides, the grid is a 9 $\times$ 8 grid with outer margins of 10 and 8 mm. Beamer slides are "physically" 128 mm $\times$ 96 mm. The resulting grid units are `\TPHorizModule` at 12 mm and `\TPVertModule` at 10 mm. In the script, these dimensions are about 1/2 in and 3/8 in, which should usually yield reasonable results.

:::

-----

> - incremental material
> - yields multiple
> - slides

\only<2>{This will only appear on the second of three slides here.}

::: noslide

But the script will only show a single slide, collapsing the increments together. This is not always desirable, and you may want to add a

# note to self: BUILD

to remind you to advance the slideshow as you talk. More complex "builds" are possible using beamer overlays, which go between `<...>`.

# Grid layouts

For fine layout control for images or other material that can't just be set like ordinary text in slides, use `textpos`:

(Incidentally, if the script has bad page breaks, a `\newpage` works as it should.)

\newpage

:::

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

::: noslide

More complex layouts can use the `textblock` environment from `textpos`. Unfortunately the script text can then overprint the images, becoming unreadable. A kludgy but not too exhausting solution is to insert a `\vspace*` command of the same total height as the grid (`8\TPVertModule`). Notice that if you provide the slide with a header, the top of the grid will overprint it (hence the top row of images here has been given a vertical origin of 0.25).

Alternatively, you can use `beamer`'s facilities for conditional compilation, the `\mode` commands. However, some care is required to convince pandoc not to mangle these commands. A first `\mode<...>` command is fine, but, as the Beamer manual tells us, the next mode switch has to put `\mode` on a line by itself, with the specifier, like `<all>`, on the following line. As demonstrated here, to get this through we have to use pandoc's facility for an explicit raw LaTeX block. And we can't use `\mode*` since this must appear outside a frame environment, something pandoc won't allow us to do.
:::


## Slide with images hidden in the script

\mode<presentation>

\begin{textblock}{4.5}(0,0.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}

\begin{textblock}{4.5}(4.5,0.25)
Text on the grid works too.
\end{textblock}

\begin{textblock}{4.5}(4.5,4.25)
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{textblock}

```{=latex}
\mode
<all>
```

::: noslide

I suggest including a note to yourself in the script that material has been omitted, or this can look pretty funny. Note that the terminating top level header of the slide is not found in the script.

An alternative to textpos is Beamer's `columns` environment, which lets you construct many layouts. You may still find it useful to use the textpos grid units rather than multiples of `\textwidth` (which will take up a lot of space in the script).

:::

## Beamer columns

\begin{columns}[T]
\begin{column}{4.5\TPHorizModule}
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{column}
\begin{column}{4.5\TPHorizModule}
\includegraphics[width=4\TPHorizModule]{../media/proj.pdf}
\end{column}
\end{columns}

::: noslide

For an example of the interaction between `textpos` and overlay specifications, see `notes/notes-sample.md`.

:::
