local UI = {}

UI.Elements = require("ui/elements")
UI.Crafting = require("ui/tabs/crafting")
UI.Items = require("ui/tabs/items")
UI.Player = require("ui/tabs/player")
UI.Misc = require("ui/tabs/misc")
UI.Search = require("ui/tabs/search")
UI.Config = require("ui/tabs/config")

function UI.Create(SimpleMenu)
    --set window position and size on first start only
    ImGui.SetNextWindowPos(0, 500, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(420, 350, ImGuiCond.FirstUseEver)

    if (ImGui.Begin("SimpleMenu")) then
        if (ImGui.BeginTabBar("SimpleMenuTabs")) then

            --CONFIG TAB
            UI.Elements.TabMenu(UILabels.config.tabname, UI.Config.TabConfig)

            --ITEMS TAB
            UI.Elements.TabMenu(UILabels.items.tabname, UI.Items.TabItems)

            --PLAYER TAB
            UI.Elements.TabMenu(UILabels.player.tabname, UI.Player.TabPlayer)

            --MISC TAB
            UI.Elements.TabMenu(UILabels.misc.tabname, UI.Misc.TabMisc)

            --SEARCH TAB
            UI.Elements.TabMenu(UILabels.search.tabname, UI.Search.TabSearch)

            --CRAFTING TAB
            UI.Elements.TabMenu(UILabels.crafting.tabname, UI.Crafting.TabCrafting)
        ImGui.EndTabBar()
        end
    end
    ImGui.End()
end

return UI