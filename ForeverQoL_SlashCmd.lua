local ForeverQoL = select(2, ...)

SLASH_ForeverQoL1 = "/fql"

SlashCmdList["ForeverQoL"] = function(msg)
    if msg == "h" or msg == "help" then
        ForeverQoL.Print("Command usage:")
        print("|cff00ff00/fql|r - Toggle options menu")
        print("|cff00ff00/fql help|r - Show this help message")
    else
        ForeverQoL.ForeverQoLOptions:ToggleOptions()
    end
end

SLASH_RELOADUI1 = "/rel"
SlashCmdList.RELOADUI = ReloadUI
