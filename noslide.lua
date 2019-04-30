--[[

A filter to process Divs with class `noslide`. If the output format
is `beamer`, these will be removed, except if there is a metadata variable "hide_noslide" set to false. In all other cases, the Divs will be kept.

When Dvis are retained, they may be surrounded by a "delineator"
block on both sides. This delineator is empty by default, but can be
controlled with the metadata variable `noslide`, which should be an
inline string. The filter understands the following special values:

none: nothing (default)
hr: a horizontal rule
br: a blank line

Any other non-empty inline string is passed through as a raw LaTeX block; any other type of value is ignored.

--]]

local hide_noslide = (FORMAT == "beamer")

local DEFAULT_DCODE = "hr"
local d

function process_meta (m)
    local dcode = DEFAULT_DCODE
    if m.noslide then
        io.stderr:write(pairs(m.noslide))
        -- and m.noslide.t == "MetaInlines" then
        -- dcode = m.noslide[1].text
    end

    io.stderr:write(dcode)

    if dcode == "hr" then
        d = pandoc.HorizontalRule
    elseif dcode == "br" then
        d = function ()
            return pandoc.Para { pandoc.Str(""), pandoc.LineBreak() }
        end
    elseif dcode == "none" then
        d = pandoc.Null
    elseif type(dcode) == "string" and string.len(dcode) > 0 then
        d = function () return pandoc.RawBlock("latex", dcode) end
    else -- fallback
        d = pandoc.Null
    end

    if type(m.hide_noslide) == "boolean" then
        hide_noslide = m.hide_noslide
    end
end

function process_div (e)
    if e.attr.classes[1] == "noslide" and hide_noslide then
        return {} -- delete Divs of form ::: noslide ...  :::
    else -- put delineator on either side
        return { d(), e }
    end
end

return { { Meta = process_meta }, { Div = process_div } }
