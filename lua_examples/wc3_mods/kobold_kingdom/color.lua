do
    color = {}


    color.rarity    = {
        common      = "5bff45",
        rare        = "4568ff",
        epic        = "c445ff",
        ancient     = "ff9c00",
    }

    color.tooltip   = {
        alert       = "47c9ff",
        good        = "00f066",
        bad         = "ff3e3e",
    }

    color.txt       = {
        txtwhite    = "ffffff",
        txtgrey     = "777777",
        txtdisable  = "aaaaaa",
    }

    color.dmg       = {
        arcane      = "0b39ff",
        frost       = "00eaff",
        nature      = "00ff12",
        fire        = "ff9c00",
        shadow      = "7214ff",
        physical    = "ff2020",
    }

    color.dmgid     = {
        [1]         = "0b39ff",
        [2]         = "00eaff",
        [3]         = "00ff12",
        [4]         = "ff9c00",
        [5]         = "7214ff",
        [6]         = "ff2020",
    }

    color.ui        = {
        hotkey      = "47c9ff",
        wax         = "fdff6f",
        candlelight = "fdff6f",
        gold        = "fff000",
        xp          = "d45bfb",
    }

end


function color:test()
    -- loop thru color table
    for i,t in pairs(color) do
        -- grab each child table's stored color and prepend WC3 hex code (always |cff, does nothing in-game but is needed)
        if type(t) == "table" then
            for colorname,colorvalue in pairs(t) do
                print(colorvalue.."test|r")
            end
        end
    end
end


function color:wrap(hex, str)
    -- build an RGBA hex code.
    return "|cff"..hex..str.."|r"
end
