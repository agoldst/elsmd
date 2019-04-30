---
title: A Sample Set of Slides
author: Your Name Here
date: Totally Not the Last Minute
sansfont: Gill Sans
slide-numbers: true
---

# An ordinary slide

With some text.

## And a block

And some text underneath.


\note{

Here are my notes.

}

# Another slide

- With a
- list.

::: notes

A note on my list.

:::

# A slide to show overlay tricks

\only<1,3>{This text appears on the first and third versions of the slide, but not the second.}

This uses beamer's highlighting command to \alert<2>{draw attention here}, but only on the second slide.

\note<1>{

Notes can also have overlay specs. First slide version note.

}

\note<2>{

Second.

}

\note<3>{

And third. Use \LaTeX\ macros in notes, like \emph{emphasis}.

}

# TeX-LOGO

\begin{textblock}{4}(0,1)
Grid demo UL
\end{textblock}

\begin{textblock}{4}(7,1)
Grid demo UR
\end{textblock}

\begin{textblock}{4}(0,5)
Grid demo LL
\end{textblock}

\begin{textblock}{4}(7,5)
\only<2>{Grid demo LR}
\end{textblock}

\note<2>{

To get overlay effects with materials placed using \texttt{textpos}, you have to specify the overlay within the \texttt{textblock} environment.

}
