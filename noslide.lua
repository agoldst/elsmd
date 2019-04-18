--[[

A filter to process Divs with class `noslide`. If the output format
is `beamer`, these will be removed. Otherwise, they will be kept but
surrounded by a "delineator" block on both sides. This delineator is
empty by default, but can be controlled with the metadata variable
`noslide`. The filter understands the following special values:

none: nothing (default)
hr: a horizontal rule
br: a blank line

Any other non-empty string is passed through as a raw LaTeX block.

--]]

local DEFAULT_DELINEATOR = pandoc.Null
local d = DEFAULT_DELINEATOR

function get_dcode (m)
    local dcode = m.noslide
    if dcode == "hr" then
        d = pandoc.HorizontalRule
    elseif dcode == "br" then
        d = function () return pandoc.Para { pandoc.Str(""), pandoc.LineBreak() } end
    elseif dcode == "none" then
        d = pandoc.Null
    elseif type(dcode) == "string" and string.len(dcode) > 0 then
        d = function () return pandoc.RawBlock("latex", dcode) end
    end
end

function process_div (e)
    if e.attr.classes[1] == "noslide" then
        if FORMAT == "beamer" then
            return {} -- delete Divs of form ::: noslide ...  :::
        else -- assume non-slideshow format, put delineator on either side
            return { d(), e, d() }
        end
    else
        return nil -- no-op
    end
end

return { { Meta = get_dcode }, { Div = process_div } }
