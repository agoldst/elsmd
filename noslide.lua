function Div(e)
    if e.attr.classes[1] == "noslide" then
        if FORMAT == "beamer" then
            return {} -- delete Divs of form ::: noslide ...  :::
        else -- assume non-slideshow format
            return {
                pandoc.HorizontalRule(),
                e,
                pandoc.HorizontalRule()
            }
        end
    else
        return nil
    end
end

