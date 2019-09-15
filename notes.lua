--[[

A filter for speaker notes with beamer overlay specifications. A native Div with a class of the form note<...> will be translated into a beamer \note<...>{...}.

pandoc's builtin conversion of ::: notes Divs continues to work the same way.

--]]
function Div (e)
    local cmd = e.attr.classes[1]
    if (cmd == "note" or string.match(cmd, "^note<[0-9+,-]*>")) then
        return {
            pandoc.RawBlock("latex", "\\" .. cmd .. "{"),
            pandoc.Div(e.content),
            pandoc.RawBlock("latex", "}")
        }
    end
end

