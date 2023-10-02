do
    local data = {}
    function GetDisabledIcon(icon)
        if not type(icon) == "string" then return icon end
        --ReplaceableTextures\CommandButtons\BTNHeroPaladin.tga -> ReplaceableTextures\CommandButtonsDisabled\DISBTNHeroPaladin.tga
        if not data[icon] and string.sub(icon,35,35) ~= "\\" then return icon end --this string has not enough chars return it
        if not data[icon] then
            local old = icon
            -- make it lower to reduce the amount of cases and for warcraft 3 FilePath case does not matter
            icon = string.lower(icon)
            if string.find(icon, "commandbuttons\\btn") then data[old] = string.gsub(icon, "commandbuttons\\btn", "commandbuttonsdisabled\\disbtn" )
            -- default wacraft 3 style
            elseif string.find(icon, "passivebuttons\\pasbtn") then data[old] = string.gsub(icon, "passivebuttons\\pasbtn", "commandbuttonsdisabled\\dispasbtn" )
            --recommented by hiveworkshop
            elseif string.find(icon, "passivebuttons\\pas") then data[old] = string.gsub(icon, "passivebuttons\\pas", "commandbuttonsdisabled\\dispas" )
            elseif string.find(icon, "commandbuttons\\atc") then data[old] = string.gsub(icon, "commandbuttons\\atc", "commandbuttonsdisabled\\disbtn" ) end
            icon = old
        end
        return data[icon]
    end
end
