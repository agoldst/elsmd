--[[

Lua filter for Easy Lecture Slides Made Difficult

Provides three additional markdown features:

- A native Div with a class of the form note<...> will be translated into a beamer \note<...>{...}. pandoc's builtin conversion of ::: notes Divs continues to work the same way.

- n@ at the start of a paragraph is converted to \footnotesize (for placing note-like text in the normal flow of text on the slide)

- a native Div with a class of the form l:ENV will be converted into a LaTeX environment \begin{ENV} ... \end{ENV} (so you can write markdown content inside a LaTeX environment...most of the time)

- a native Div with a class of the form l:ENV{PARAM} will be converted into a LaTeX environment \begin{ENV}{PARAM} ... \end{ENV}

    + no serious parsing is done of these commands: everything from the first non-alphanumeric character in ENV is simply placed after \begin{ENV}

--]]

local NN_MARK = "n@"

function Para(e)
    local result = e:clone()
    if e.content[1].text == NN_MARK then
        result.content[1] = pandoc.RawInline("latex", "\\footnotesize")
        table.insert(result.content, pandoc.RawInline("latex", "\\normalsize"))
        return result
    end
end

local ENV_PATTERN = "^l:(%S+)$"

function Div (e)
    local cmd = e.attr.classes[1]
    local _, _, env = string.find(cmd, ENV_PATTERN)
    if (cmd == "note" or string.match(cmd, "^note<[0-9+,-]*>")) then
        return {
            pandoc.RawBlock("latex", "\\" .. cmd .. "{"),
            pandoc.Div(e.content),
            pandoc.RawBlock("latex", "}")
        }
    elseif env then
        local _, _, env_name, param = string.find(env, "^(%w+)(%S*)$")
        local begin = "\\begin{" .. env_name .. "}"
        if param then
            begin = begin .. param
        end
        return {
            pandoc.RawBlock("latex", begin),
            pandoc.Div(e.content),
            pandoc.RawBlock("latex", "\\end{" .. env_name .. "}")
        }
    end
end

