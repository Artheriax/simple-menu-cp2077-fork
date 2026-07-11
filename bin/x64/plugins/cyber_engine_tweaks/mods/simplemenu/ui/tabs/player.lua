local UIplayer = {
    attributeamount = 1,
    attributetype = 0,
    attrpointamount = 0,
    statamount = 1,
    stattype = 0,
    perkpointamount = 0,
    perkcategory = 0,
    perktype = 0,
    levelamount = 1,
    leveltype = 0
}

UIplayer.Util = require("config/util")
UIplayer.Elements = require("ui/elements")
UIplayer.Perks = require("player/perks")
UIplayer.Player = require("player/player")
local Colour = require("classes/colour")
local CUtil = require("misc/cetUtils")

local perkCats, perkCatsN = UIplayer.Util.GetDLabels("player", "perkcategories")
local statTypes = UIplayer.Util.GetDLabels("player", "stat")

local function setModsState(enabled)
    for k, v in pairs(ModState.SVars.Mods) do
        if v ~= enabled then
            local enumVal = UIplayer.Player.EPlayerMod[k]
            ModState.SVars.Mods[k] = enabled
            UIplayer.Util.configuration.playerMods[k] = enabled
            UIplayer.Player.ChangeModifiers(enumVal, enabled)
        end
    end

    UIplayer.Util.SaveConfig()
end

function UIplayer.TabPlayer()
    if (UIplayer.Util.configuration.menus.player.mainCheats) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.HeaderMenu(UILabels.player.god.menuHeading, UIplayer.MenuMainCheats)

    UIplayer.Elements.Separator()

    if (UIplayer.Util.configuration.menus.player.modifiers) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.CustomHeaderMenu(
        UILabels.player.modifiers.menuHeading,
        UIplayer.MenuModifiers,
        nil,
        nil,
        nil,
        { --{ label: string, func: function }[]
            {
                label = UILabels.config.menus.allOff,
                func = function ()
                    setModsState(false)
                end
            },
            {
                label = UILabels.config.menus.allOn,
                func = function ()
                    setModsState(true)
                end
            },
        }
    )

    UIplayer.Elements.Separator()

    --Attributes
    if (UIplayer.Util.configuration.menus.player.attributes) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.HeaderMenu(UILabels.player.attributes.header, UIplayer.MenuAttributes)

    UIplayer.Elements.Separator()

    --Experience and Level
    if (UIplayer.Util.configuration.menus.player.level) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.HeaderMenu(UILabels.player.level.header, UIplayer.MenuLevel)

    UIplayer.Elements.Separator()

    --Other Stats
    if (UIplayer.Util.configuration.menus.player.stats) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.HeaderMenu(UILabels.player.stats.header, UIplayer.MenuStats)

    UIplayer.Elements.Separator()

    --Perks
    if (UIplayer.Util.configuration.menus.player.perks) then
        ImGui.SetNextItemOpen(true)
    end
    UIplayer.Elements.HeaderMenu(UILabels.player.perks.header, UIplayer.MenuPerks)
end

function UIplayer.MenuMainCheats()
    local _, GodmodePressed = ImGui.Checkbox(UILabels.player.god.bGod, UIplayer.Util.configuration.functions.godMode)
    UIplayer.Elements.QuickMultiTooltip({
        { text = UILabels.player.god.tGod1, colour = Colour.Info },
        { text = UILabels.player.god.tGod2, colour = Colour.Warning }
    })
    if (GodmodePressed) then
        UIplayer.Player.ToggleGodMode()
    end

    local _, InfStaminaPressed = ImGui.Checkbox(UILabels.player.god.bStam, UIplayer.Util.configuration.functions.infStamina)
    if (InfStaminaPressed) then
        UIplayer.Player.ToggleInfiniteStamina()
    end

    local _, InfOxyPressed = ImGui.Checkbox(UILabels.player.god.bOxy, UIplayer.Util.configuration.functions.infOxy)
    if (InfOxyPressed) then
        UIplayer.Player.ToggleInfiniteOxygen()
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.god.tOxy, Colour.Info)

    ModState.SVars.Invisibility, InvisiblityClicked = ImGui.Checkbox(UILabels.player.god.bInvis, ModState.SVars.Invisibility)
    if InvisiblityClicked then
        UIplayer.Player.ToggleInvisibility(ModState.SVars.Invisibility)
    end
    UIplayer.Elements.QuickMultiTooltip({
        { text = UILabels.player.god.tInvis1, colour = Colour.Info },
        { text = UILabels.player.god.tInvis2, colour = Colour.Warning }
    })
end

local function GetMinColWidth(headerText, columnWidth)
    local eHeaderW, _ = ImGui.CalcTextSize(headerText)
    if columnWidth < eHeaderW then columnWidth = (eHeaderW + 20) end
    return columnWidth
end

local function NextRow(minHeight)
    ImGui.TableNextRow(ImGuiTableRowFlags.None, minHeight)
    ImGui.TableNextColumn()
end

local function HeaderRow(minHeight)
    if minHeight < ImGui.GetFontSize() then minHeight = ImGui.GetFontSize() end
    ImGui.TableNextRow(ImGuiTableRowFlags.Headers, minHeight)
    ImGui.TableNextColumn()
end

local function CreateModifierCheckRow(modifierText, toolText, checkVar, checkedFunc, modifier, configVar, checkSideLen, checkColWidth, rowHeight)
    local checkedChanged = false
    NextRow(rowHeight)
    UIplayer.Elements.VCentredCellText(modifierText, rowHeight)
    ImGui.TableNextColumn()
    checkVar, checkedChanged = UIplayer.Elements.HVCentredCheckbox("##check"..modifierText, checkVar, checkSideLen, checkColWidth, rowHeight)
    if checkedChanged and checkedFunc ~= nil then
        checkedFunc(modifier, checkVar)
        configVar = checkVar
    end
    if ImGui.IsItemHovered() and toolText ~= nil then
        local toolTexts = {
            { text = toolText, colour = Colour.Info }
        }
        UIplayer.Elements.Tooltip(toolTexts, 600, true)
    end
    checkSideLen, _ = ImGui.GetItemRectSize()
    return checkVar, configVar, checkedChanged, checkSideLen
end

local checkSideLen = 0
local headerHeight = 30
local rowHeight = 50
local checkColWidth = 100
local tableHeight = 0
local tableBorders = bit32.bor(
    ImGuiTableFlags.BordersInnerH,
    ImGuiTableFlags.BordersInnerV,
    ImGuiTableFlags.BordersOuterH,
    ImGuiTableFlags.BordersOuterV
)

local function notifyModToggle(modifier, enable)
    print(
        "[SimpleMenu] Modifier",
        UIplayer.Util.T(enable, "enabled:", "disabled:"),
        CUtil.EnumName(UIplayer.Player.EPlayerMod, modifier)
    )
end

local function checkSave(checkChange)
    if checkChange then UIplayer.Util.SaveConfig() end
end

function UIplayer.MenuModifiers()
    local checkChange = false
    checkColWidth = GetMinColWidth("Enabled", checkColWidth)
    local width = ImGui.GetWindowContentRegionWidth()
    if (ImGui.BeginChild("tableWrapper-ModifierTable", width, tableHeight, false, ImGuiWindowFlags.AlwaysAutoResize)) then
        if ImGui.BeginTable("ModifierTable", 2, tableBorders) then
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags.WidthStretch)
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags.WidthFixed, checkColWidth)

            HeaderRow(headerHeight)
            ImGui.Text("Modifier")
            ImGui.TableNextColumn()
            UIplayer.Elements.HCentredCellText("Enabled", checkColWidth)

            ModState.SVars.Mods.HealItemCooldown,
            UIplayer.Util.configuration.playerMods.HealItemCooldown,
            checkChange,
            checkSideLen = CreateModifierCheckRow(
                UILabels.player.modifiers.dHealItemCooldown,
                UILabels.player.modifiers.tHealItemCooldown,
                ModState.SVars.Mods.HealItemCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.HealItemCooldown,
                UIplayer.Util.configuration.playerMods.HealItemCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.GrenadeCooldown,
            UIplayer.Util.configuration.playerMods.GrenadeCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dGrenadeCooldown,
                UILabels.player.modifiers.tGrenadeCooldown,
                ModState.SVars.Mods.GrenadeCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.GrenadeCooldown,
                UIplayer.Util.configuration.playerMods.GrenadeCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.ProjectileCooldown,
            UIplayer.Util.configuration.playerMods.ProjectileCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dProjectileCooldown,
                UILabels.player.modifiers.tProjectileCooldown,
                ModState.SVars.Mods.ProjectileCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.ProjectileCooldown,
                UIplayer.Util.configuration.playerMods.ProjectileCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.CloakCooldown,
            UIplayer.Util.configuration.playerMods.CloakCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dCloakCooldown,
                UILabels.player.modifiers.tCloakCooldown,
                ModState.SVars.Mods.CloakCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.CloakCooldown,
                UIplayer.Util.configuration.playerMods.CloakCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.SandevistanCooldown,
            UIplayer.Util.configuration.playerMods.SandevistanCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dSandevistanCooldown,
                UILabels.player.modifiers.tSandevistanCooldown,
                ModState.SVars.Mods.SandevistanCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.SandevistanCooldown,
                UIplayer.Util.configuration.playerMods.SandevistanCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.BerserkCooldown,
            UIplayer.Util.configuration.playerMods.BerserkCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dBerserkCooldown,
                UILabels.player.modifiers.tBerserkCooldown,
                ModState.SVars.Mods.BerserkCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.BerserkCooldown,
                UIplayer.Util.configuration.playerMods.BerserkCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.KerenzikovCooldown,
            UIplayer.Util.configuration.playerMods.KerenzikovCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dKerenzikovCooldown,
                UILabels.player.modifiers.tKerenzikovCooldown,
                ModState.SVars.Mods.KerenzikovCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.KerenzikovCooldown,
                UIplayer.Util.configuration.playerMods.KerenzikovCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.OverclockCooldown,
            UIplayer.Util.configuration.playerMods.OverclockCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dOverclockCooldown,
                UILabels.player.modifiers.tOverclockCooldown,
                ModState.SVars.Mods.OverclockCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.OverclockCooldown,
                UIplayer.Util.configuration.playerMods.OverclockCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.QuickhackCooldown,
            UIplayer.Util.configuration.playerMods.QuickhackCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dQuickhackCooldown,
                UILabels.player.modifiers.tQuickhackCooldown,
                ModState.SVars.Mods.QuickhackCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.QuickhackCooldown,
                UIplayer.Util.configuration.playerMods.QuickhackCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.QuickhackCost,
            UIplayer.Util.configuration.playerMods.QuickhackCost,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dQuickhackCost,
                UILabels.player.modifiers.tQuickhackCost,
                ModState.SVars.Mods.QuickhackCost,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.QuickhackCost,
                UIplayer.Util.configuration.playerMods.QuickhackCost,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.MemoryRegeneration,
            UIplayer.Util.configuration.playerMods.MemoryRegeneration,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dMemoryRegeneration,
                UILabels.player.modifiers.tMemoryRegeneration,
                ModState.SVars.Mods.MemoryRegeneration,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.MemoryRegeneration,
                UIplayer.Util.configuration.playerMods.MemoryRegeneration,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.FaceplateCooldown,
            UIplayer.Util.configuration.playerMods.FaceplateCooldown,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dFaceplateCooldown,
                UILabels.player.modifiers.tFaceplateCooldown,
                ModState.SVars.Mods.FaceplateCooldown,
                UIplayer.Player.ChangeModifiers,
                UIplayer.Player.EPlayerMod.FaceplateCooldown,
                UIplayer.Util.configuration.playerMods.FaceplateCooldown,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.InfiniteDoubleJump,
            UIplayer.Util.configuration.playerMods.InfiniteDoubleJump,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dInfJump,
                UILabels.player.modifiers.tInfJump,
                ModState.SVars.Mods.InfiniteDoubleJump,
                notifyModToggle,
                UIplayer.Player.EPlayerMod.InfiniteDoubleJump,
                UIplayer.Util.configuration.playerMods.InfiniteDoubleJump,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ModState.SVars.Mods.InfiniteAirDash,
            UIplayer.Util.configuration.playerMods.InfiniteAirDash,
            checkChange,
            _ = CreateModifierCheckRow(
                UILabels.player.modifiers.dInfAirDash,
                UILabels.player.modifiers.tInfAirDash,
                ModState.SVars.Mods.InfiniteAirDash,
                notifyModToggle,
                UIplayer.Player.EPlayerMod.InfiniteAirDash,
                UIplayer.Util.configuration.playerMods.InfiniteAirDash,
                checkSideLen, checkColWidth, rowHeight
            )
            checkSave(checkChange)

            ImGui.EndTable()
        end
         _, tableHeight = ImGui.GetItemRectSize()
        ImGui.EndChild()
    end
end

--Attributes
function UIplayer.MenuAttributes()
    UIplayer.Elements.SectionHeading(UILabels.player.attributes.tSetAttrib, Colour.Info, false)
    UIplayer.attributeamount = ImGui.InputInt(UILabels.universalelements.amount.."##attribute", UIplayer.attributeamount, 1, 10)
    UIplayer.attributetype = ImGui.Combo(UILabels.universalelements.type.."##attribute", UIplayer.attributetype, UIplayer.Util.ProcessLabels("player", "attribute"))
    if (ImGui.Button(UILabels.player.attributes.setbutton)) then
        UIplayer.Player.SetAttribute(UIplayer.attributetype, UIplayer.attributeamount)
    end

    UIplayer.Elements.SectionHeading(UILabels.player.attributes.tAddAttrib, Colour.Info)
    UIplayer.attrpointamount = ImGui.InputInt(UILabels.universalelements.amount.."##attrpoints", UIplayer.attrpointamount, 1, 10)
    if (ImGui.Button(UILabels.player.attributes.addbutton)) then
        UIplayer.Player.AddAttributePoints(UIplayer.attrpointamount)
    end
end

local function statTooltip(baseText, baseTextColour, warningText)
    local toolTexts = {
        { text = baseText, colour = baseTextColour }
    }

    if warningText ~= nil then
        table.insert(toolTexts,
            { text = warningText, colour = baseTextColour }
        )
    end

    local selectedStat = statTypes[UIplayer.stattype + 1]
    if selectedStat == "Cyberware Capacity" then
        table.insert(toolTexts,
            { text = UILabels.player.stats.cybCapWarn, colour = Colour.Warning }
        )
    end

    UIplayer.Elements.Tooltip(toolTexts, 600, true)
end

--Other Stats
function UIplayer.MenuStats()
    UIplayer.Elements.SectionHeading(UILabels.player.stats.tModStats, Colour.Info, false)
    UIplayer.statamount = ImGui.InputInt(UILabels.universalelements.amount.."##stat", UIplayer.statamount, 1, 10)
    UIplayer.stattype = ImGui.Combo(UILabels.universalelements.type.."##stat", UIplayer.stattype, statTypes, #statTypes)

    ImGui.BeginDisabled(UIplayer.stattype == 0)
    if (ImGui.Button(UILabels.player.stats.button)) then
        UIplayer.Player.ModStats(UIplayer.stattype, UIplayer.statamount)
    end
    if (ImGui.IsItemHovered()) then
        statTooltip(UILabels.player.stats.tooltip, Colour.Info)
    end

    ImGui.SameLine()

    local permBtnX = CUtil.GetButtonWidth(ModState.SVars.Timers.PermStat)
    local permButtonClick = ImGui.Button(ModState.SVars.Timers.PermStat.Text, permBtnX, 0)
    TimedButton(
        permButtonClick,
        ModState.SVars.Timers.PermStat,
        nil,
        UIplayer.Player.ModStats,
        UIplayer.stattype,
        UIplayer.statamount,
        true
    )
    if (ImGui.IsItemHovered()) then
        if ModState.SVars.Timers.PermStat.Elap <= 0 then
            statTooltip(
                UILabels.player.stats.pTooltip,
                Colour.Critical,
                UILabels.universalelements.timedBtnWarn:gsub(
                    "{#}",
                    ModState.SVars.Timers.PermStat.Time
                )
            )
        else
            statTooltip(UILabels.universalelements.timedBtnConf, Colour.Positive)
        end
    end
    ImGui.EndDisabled()
end

--Perks
function UIplayer.MenuPerks()
    UIplayer.Elements.SectionHeading(UILabels.player.perks.tAddPoints, Colour.Info, false)
    UIplayer.perkpointamount = ImGui.InputInt(UILabels.universalelements.amount.."##perkpoints", UIplayer.perkpointamount, 1, 10)
    ImGui.Spacing()
    if (ImGui.Button(UILabels.player.perks.bAddPoint)) then
        UIplayer.Player.AddPerkPoints(UIplayer.perkpointamount)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.player.perks.bAddRelicPoint)) then
        UIplayer.Player.AddRelicPoints(UIplayer.perkpointamount)
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.perks.tAddRelicPoint, Colour.Warning)

    UIplayer.Elements.SectionHeading(UILabels.player.perks.tAddPerks, Colour.Info)
    local perkCatChanged
    UIplayer.perkcategory, perkCatChanged = ImGui.Combo(UILabels.universalelements.category.."##perk", UIplayer.perkcategory, perkCats, perkCatsN)
    if perkCatChanged then
        UIplayer.perktype = 0
    end

    local selectedPerkCat = perkCats[UIplayer.perkcategory + 1]:gsub(" ", "")
    local perkNames = UIplayer.Perks.GetPerkNames(selectedPerkCat)
    UIplayer.perktype = ImGui.Combo(UILabels.universalelements.type.."##perk", UIplayer.perktype, perkNames, #perkNames)
    if (ImGui.Button(UILabels.player.perks.bAdd)) then
        UIplayer.Perks.AddPerkLevel(selectedPerkCat, UIplayer.perktype)
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.perks.tAdd, Colour.Info)

    ImGui.SameLine()

    if (ImGui.Button(UILabels.player.perks.bRem)) then
        UIplayer.Perks.RemovePerk(selectedPerkCat, UIplayer.perktype)
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.perks.tRem, Colour.Info)

    ImGui.SameLine()

    if (ImGui.Button(UILabels.player.perks.bRes)) then
        UIplayer.Player.ResetPerks()
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.perks.tRes, Colour.Info)

    ImGui.SameLine()

    if (ImGui.Button(UILabels.player.perks.bAddAll)) then
        UIplayer.Perks.AddAllPerks()
        UIplayer.Perks.AddAllPerks()
        --gotta do it twice, probably bad ordering, will fix at some point
        print("[SimpleMenu] ALL Perks Added!")
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.perks.tAddAll, Colour.Info)
end

--EXP and Level
function UIplayer.MenuLevel()
    UIplayer.Elements.SectionHeading(UILabels.player.level.tModLevels, Colour.Info, false)
    UIplayer.levelamount = ImGui.InputInt(UILabels.universalelements.amount.."##level", UIplayer.levelamount, 1, 10)
    UIplayer.leveltype = ImGui.Combo(UILabels.universalelements.type.."##level", UIplayer.leveltype, UIplayer.Util.ProcessLabels("player", "level"))
    if (ImGui.Button(UILabels.player.level.levelbutton)) then
        UIplayer.Player.SetLevel(UIplayer.leveltype, UIplayer.levelamount)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.player.level.expbutton)) then
        UIplayer.Player.AddXP(UIplayer.leveltype, UIplayer.levelamount)
    end

    UIplayer.Elements.SectionHeading(UILabels.player.level.tLevelQuickAct, Colour.Info)
    if (ImGui.Button(UILabels.player.maxall.button)) then
        UIplayer.Player.MaxAll()
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.maxall.tooltip, Colour.Positive)

    ImGui.SameLine()

    if (ImGui.Button(UILabels.player.resetall.button)) then
        UIplayer.Player.ResetAll()
    end
    UIplayer.Elements.QuickTooltip(UILabels.player.resetall.tooltip, Colour.Positive)
end

return UIplayer