" Tweaks to vim-pandoc-syntax
" Andrew Goldstone, 2016
"
" beamer's \note{} command body can be multiline LaTeX
" This is not syntactically proper since there is no rule that says that a }
" on its own line has to close a note. But I follow this convention.
syn region beamernote matchgroup=Delimiter start="^\\note{" end="^}" contains=@texCmdGroup keepend

