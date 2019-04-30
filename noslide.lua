--[[

A filter to process Divs with class `noslide`. If the metadata variable
hide_noslide is true, these Divs will be removed. In all other cases,
the Divs will be kept and surrounded by horizontal rules. A final
processing step removes duplicate horizontal rules introduced by this
transformation, because of my obsessive compulsion.

If hide_noslide is not set, then the default behavior is to remove
noslide Divs if the output format is beamer and to retain them
otherwise.

This leads to a special behavior if Divs are retained AND the output
format is a slideshow format (including beamer). In that case, the
horizontal rules are reinterpreted by pandoc as slide delimiters. For
the purposes of this setup, this is actually desirable behavior.

--]]

local hide_noslide = (FORMAT == "beamer") -- default: hide in beamer output

function process_meta (m)
    if type(m.hide_noslide) == "boolean" then
        hide_noslide = m.hide_noslide
    end
end

function process_div (e)
    if e.attr.classes[1] == "noslide" and hide_noslide then
        return {} -- delete Divs of form ::: noslide ...  :::
    else
        return { pandoc.HorizontalRule(), e, pandoc.HorizontalRule() }
    end
end

local was_hr = false

function cleanup_hrs (e)
    local result -- nil, i.e. no-op by default
    local is_hr = pandoc.utils.equals(e, pandoc.HorizontalRule())
    if was_hr and is_hr then
        result = {} -- delete
    end

    was_hr = is_hr
    return result
end

return {
    { Meta = process_meta },
    { Div = process_div },
    { Block = cleanup_hrs }
}
