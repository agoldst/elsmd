# Markdown to lecture slides

(with some beamer bells and whistles, by a Keynote refugee)

Create notes in the `notes/` directory, on the model of [classnotes.md](notes/classnotes.md). Then generate a PDF of slides with

```Make
make -C slides classnotes.pdf
```

If you have Keynote and want to use it as a presentation PDF viewer, install [PDF to Keynote](http://www.cs.hmc.edu/~oneill/freesoftware/pdftokeynote.html) and then do

```Make
make -C slides classnotes.key
```

To generate notes (note pages interleaved with slide pages):

```Make
make -C notes classnotes.pdf
```

I like to print these 4-up in landscape.

