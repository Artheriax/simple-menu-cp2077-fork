local UImisc = {
    teleportcategory = 0,
    teleporttype = 0,
    vehicletype = 0,
    factscategory = 0,
    factstype = 0,
    timeH = 9,
    timeM = 0,
    slowMoHeaderText = "",
    slowMoHeaderColour = nil,
    wantedLevel = 0,
    allowUnsolvable = false,
    exceed = false,
    selectedApartment = 0,
    selectedQuick = 0,
    jumpDist = 1,
    widestBreachLabel = 0
}

local Colour = require("classes/colour")
local CUtil = require("misc/cetUtils")
local unsolvToggle = false
local Items = require("items/items")

UImisc.Util = require("config/util")
UImisc.Elements = require("ui/elements")
UImisc.Travel = require("misc/travel")
UImisc.slowMoHeaderText = UILabels.misc.time.tSlowMoLabelEnabled
UImisc.slowMoHeaderColour = Colour.Positive
UImisc.Misc = require("misc/misc")
UImisc.Ammo = require("items/ammo")
local t = UImisc.Util.T
local nextQuickTelName = ""
local modalOpened = false
local quickNames = {}
local updateQuickList = true

local function checkApplyFocus()
    if not modalOpened then
        ImGui.SetKeyboardFocusHere()
        modalOpened = true
    end
end

local function AddQuickTelModal()
    if(ImGui.BeginPopupModal("AddQuickTelPop", bit32.bor(ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoTitleBar))) then
        UImisc.Elements.Text(UILabels.misc.teleport.qTelPrompt, true)
        local width = ImGui.GetWindowContentRegionWidth()
        local submitted = false
        ImGui.SetNextItemWidth(width)
        checkApplyFocus()
        nextQuickTelName, submitted = ImGui.InputText("", nextQuickTelName, 50, ImGuiInputTextFlags.EnterReturnsTrue)
        ImGui.BeginDisabled(#nextQuickTelName < 3)
        if (submitted or ImGui.Button(UILabels.universalelements.ok, 120, 40)) and #nextQuickTelName >= 3 then
            ImGui.CloseCurrentPopup()
            modalOpened = false
            return true
        end
        ImGui.EndDisabled()
        ImGui.SameLine(140)
        if(ImGui.Button(UILabels.universalelements.cancel, 120, 40)) then
            ImGui.CloseCurrentPopup()
            modalOpened = false
            nextQuickTelName = ""
            return false
        end
        ImGui.EndPopup()
    end
    return false
end

local function resetBPOptions()
    UImisc.Misc.bpOptions.custBPTime = 5
    UImisc.Misc.bpOptions.custBPSize = 5
    UImisc.Misc.bpOptions.custBPBuff = 4
    UImisc.Misc.bpOptions.custBPPuzz = 1
end

function UImisc.TabMisc()
    if (UImisc.Util.configuration.menus.misc.police) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.police.header, UImisc.MenuPolice)

    UImisc.Elements.Separator()

    --Quests and Romances
    if (UImisc.Util.configuration.menus.misc.quest) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.quest.header, UImisc.MenuQuest)

    UImisc.Elements.Separator()

    --Teleport
    if (UImisc.Util.configuration.menus.misc.teleport) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.teleport.header, UImisc.MenuTeleport)

    UImisc.Elements.Separator()

    --Time
    if (UImisc.Util.configuration.menus.misc.time) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.time.header, UImisc.MenuTime)

    UImisc.Elements.Separator()

    --Vehicles
    if (UImisc.Util.configuration.menus.misc.vehicles) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.vehicles.header, UImisc.MenuVehicles)

    UImisc.Elements.Separator()

    if (UImisc.Util.configuration.menus.misc.breach) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.breachProto.header, UImisc.MenuBreachProtocol)

    UImisc.Elements.Separator()

    if (UImisc.Util.configuration.menus.misc.npc_other) then
        ImGui.SetNextItemOpen(true)
    end
    UImisc.Elements.HeaderMenu(UILabels.misc.npc_other.header, UImisc.MenuNPC)
end

function UImisc.MenuPolice()
    _, PolicePressed = ImGui.Checkbox(UILabels.misc.police.bSystem, UImisc.Util.configuration.functions.disablePolice)
    if (PolicePressed) then
        UImisc.Misc.PoliceToggle()
    end

    ImGui.BeginDisabled(UImisc.Util.configuration.functions.disablePolice)
    UImisc.wantedLevel, WantedLevelChanged = ImGui.SliderInt("##WantedLevel", UImisc.wantedLevel, 0, 5)

    ImGui.SameLine()

    if (ImGui.Button(UILabels.misc.police.bHeat)) then
        UImisc.Misc.PoliceLevel(UImisc.wantedLevel)
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.police.tHeat)
    end
    ImGui.EndDisabled()
end

--Quest
function UImisc.MenuQuest()
    UImisc.Elements.SectionHeading(UILabels.misc.quest.shTracking, Colour.Info, false)
    if (ImGui.Button(UILabels.misc.quest.bEnd)) then
        UImisc.Misc.EndQuest()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.quest.tEnd)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.misc.quest.bUntrack)) then
        UImisc.Misc.Untrack()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.quest.tUntrack)
    end

    UImisc.Elements.SectionHeading(UILabels.misc.quest.shFlags, Colour.Info)
    UImisc.factscategory = ImGui.Combo(UILabels.universalelements.category.."##quest", UImisc.factscategory, UImisc.Util.ProcessLabels("misc", "factcategory"))
    UImisc.factstype = ImGui.Combo(UILabels.universalelements.type.."##quest", UImisc.factstype, UImisc.Util.ProcessLabels("facttype", UImisc.factscategory + 1))

    local disBtnX = CUtil.GetButtonWidth(ModState.SVars.Timers.DisableQFact)
    local disableQfClick = ImGui.Button(ModState.SVars.Timers.DisableQFact.Text, disBtnX, 0)
    local disableQfTime = ModState.SVars.Timers.DisableQFact.Time
    TimedButton(
        disableQfClick,
        ModState.SVars.Timers.DisableQFact,
        {
            { text = UILabels.misc.quest.tDisable, colour = Colour.Info },
            { text = CUtil.GetTimedWarn(disableQfTime), colour = Colour.Warning },
        },
        UImisc.Misc.ChangeFact,
        UImisc.factscategory,
        UImisc.factstype,
        0
    )

    ImGui.SameLine()

    local enaBtnX = CUtil.GetButtonWidth(ModState.SVars.Timers.EnableQFact)
    local enableQfClick = ImGui.Button(ModState.SVars.Timers.EnableQFact.Text, enaBtnX, 0)
    local enableQfTime = ModState.SVars.Timers.EnableQFact.Time
    TimedButton(
        enableQfClick,
        ModState.SVars.Timers.EnableQFact,
        {
            { text = UILabels.misc.quest.tEnable, colour = Colour.Info },
            { text = CUtil.GetTimedWarn(enableQfTime), colour = Colour.Warning },
        },
        UImisc.Misc.ChangeFact,
        UImisc.factscategory,
        UImisc.factstype,
        1
    )

    UImisc.Elements.SectionHeading(UILabels.misc.quest.shMods, Colour.Info)
    local freezeCarTimerChecked
    UImisc.Util.configuration.functions.freezeCarQuestTime, freezeCarTimerChecked = ImGui.Checkbox(
        UILabels.misc.quest.cbFreezeTimer,
        UImisc.Util.configuration.functions.freezeCarQuestTime
    )
    if freezeCarTimerChecked then
        UImisc.Util.SaveConfig()
    end
end

--Teleport
function UImisc.MenuTeleport()
    UImisc.Elements.SectionHeading(UILabels.misc.teleport.pAparts, Colour.Info, false)
    UImisc.selectedApartment = ImGui.Combo(
        "Apartment",
        UImisc.selectedApartment,
        UImisc.Travel.Apartments,
        #UImisc.Travel.Apartments
    )
    if (ImGui.Button("Teleport to Apartment")) then
        UImisc.Travel.TeleportToApartment(UImisc.selectedApartment)
    end

    if updateQuickList then
        quickNames = CUtil.ArrayProject(
            UImisc.Util.configuration.functions.quickTeleports,
            function(v)
                return v.name
            end
        )
        table.insert(quickNames, 1, UILabels.misc.teleport.cQuickTel)
        updateQuickList = false
    end

    UImisc.Elements.SectionHeading(UILabels.misc.teleport.tQTel, Colour.Info)
    UImisc.selectedQuick = ImGui.Combo(
        UILabels.misc.teleport.cbQTel,
        UImisc.selectedQuick,
        quickNames,
        #quickNames
    )
    if ImGui.Button(UILabels.misc.teleport.bQTelGo) and UImisc.selectedQuick ~= 0 then
        DEBUG_printl(LOG_LEVEL.Info, "TELEPORT TO LOCATION:", UImisc.Util.configuration.functions.quickTeleports[UImisc.selectedQuick].name)
        UImisc.Travel.QuickTeleport(UImisc.Util.configuration.functions.quickTeleports[UImisc.selectedQuick])
        UImisc.selectedQuick = 0
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tQTelGo, Colour.Info)

    ImGui.SameLine()

    if(ImGui.Button(UILabels.misc.teleport.bAddQTel)) then
        ImGui.SetNextWindowSize(400, 0)
        local x, y = ImGui.GetMousePos()
        ImGui.SetNextWindowPos(x - 200, y)
        ImGui.OpenPopup("AddQuickTelPop")
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tAddQTel, Colour.Info)

    if(AddQuickTelModal()) then
        local player = Game.GetPlayer()
        local locn   = player:GetWorldPosition()
        local dirn   = Quaternion.ToEulerAngles(player:GetWorldOrientation())
        table.insert(UImisc.Util.configuration.functions.quickTeleports, {
            name = nextQuickTelName,
            loc  = { locn.x, locn.y, locn.z, locn.w },
            dir  = { 0, 0, dirn.yaw }
        })
        UImisc.Util.SaveConfig()
        UImisc.selectedQuick = 0
        updateQuickList = true
        nextQuickTelName = ""
    end
    ImGui.SameLine()
    if(ImGui.Button(UILabels.misc.teleport.bRemQTel) and UImisc.selectedQuick ~= 0) then
        local name = UImisc.Util.configuration.functions.quickTeleports[UImisc.selectedQuick].name
        table.remove(UImisc.Util.configuration.functions.quickTeleports, UImisc.selectedQuick)
        UImisc.Util.SaveConfig()
        print("[SimpleMenu]: Quick Teleport ["..name.."] deleted successfully")
        UImisc.selectedQuick = 0
        updateQuickList = true
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tRemQTel, Colour.Info)

    UImisc.Elements.SectionHeading(UILabels.misc.teleport.tSavedTel, Colour.Info)
    if (ImGui.Button(UILabels.misc.teleport.bSaveQt)) then
        UImisc.Travel.SaveCurrentQTele(
            UImisc.Util.configuration.functions.quickTeleports[UImisc.selectedQuick]
        )
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tSaveQt, Colour.Info)

    if (ImGui.Button(UILabels.misc.teleport.bSave)) then
        UImisc.Travel.SaveCurrentPos()
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tSave, Colour.Info)

    if (ImGui.Button(UILabels.misc.teleport.bMove)) then
        UImisc.Travel.MoveSavedPos()
    end

    UImisc.Elements.SectionHeading(UILabels.misc.teleport.tOtherTeles, Colour.Info)

    UImisc.teleportcategory = ImGui.Combo(
        UILabels.universalelements.category.."##location",
        UImisc.teleportcategory,
        UImisc.Util.ProcessLabels("misc", "locationcategory")
    )

    UImisc.teleporttype = ImGui.Combo(
        UILabels.universalelements.type.."##location",
        UImisc.teleporttype,
        UImisc.Util.ProcessLabels("locationtype", UImisc.teleportcategory + 1)
    )

    if (ImGui.Button(UILabels.misc.teleport.bCustom)) then
        UImisc.Travel.Teleport("custom", UImisc.teleportcategory, UImisc.teleporttype)
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tCustom, Colour.Warning)

    UImisc.Elements.SectionHeading(UILabels.misc.teleport.tLocalTele, Colour.Info)

    ModState.SVars.JumpDist, _ = ImGui.SliderInt(UILabels.misc.teleport.cbJmpForw, ModState.SVars.JumpDist, -10, 10)
    if(ImGui.Button(UILabels.misc.teleport.bJmpForw)) then
        UImisc.Travel.JumpForward(ModState.SVars.JumpDist)
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.teleport.tJmpForw, Colour.Info)
end

--Time
function UImisc.MenuTime()
    UImisc.Elements.SectionHeading(UILabels.misc.time.tInGameTime, Colour.Info, false)
    UImisc.timeH, ChangedTime = ImGui.SliderInt(UILabels.misc.time.timeH, UImisc.timeH, 0, 23)
    UImisc.timeM, ChangedTime = ImGui.SliderInt(UILabels.misc.time.timeM, UImisc.timeM, 0, 59)
    if (ImGui.Button(UILabels.misc.time.timeSet)) then
        UImisc.Misc.SetTime(UImisc.timeH, UImisc.timeM)
    end
    ImGui.SameLine()
    _, FreezePressed = ImGui.Checkbox(UILabels.misc.time.freeze, UImisc.Util.configuration.functions.freezeTime)
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.time.freezeTT)
    end
    if (FreezePressed) then
        UImisc.Misc.FreezeTime()
    end

    UImisc.slowMoHeaderColour = t(UImisc.Misc.slowMo, Colour.Critical, Colour.Positive)
    UImisc.Elements.SectionHeading(UImisc.slowMoHeaderText, UImisc.slowMoHeaderColour)

    ImGui.BeginDisabled(UImisc.Misc.slowMo)
    local lockChecked
    UImisc.Util.configuration.functions.lockPlayerTiDi, lockChecked = ImGui.Checkbox(
        UILabels.misc.time.bLockPlayerTiDi,
        UImisc.Util.configuration.functions.lockPlayerTiDi
    )
    if lockChecked then
        if UImisc.Util.configuration.functions.lockPlayerTiDi then
            UImisc.Util.configuration.functions.slowMoPlayerRatio = UImisc.Util.configuration.functions.slowMoDilation
        end

        UImisc.Util.SaveConfig()
    end

    UImisc.Elements.DoubleSpace()

    local changedDilation
    UImisc.Util.configuration.functions.slowMoDilation, changedDilation = ImGui.SliderInt(
        UILabels.misc.time.slowmodilation,
        UImisc.Util.configuration.functions.slowMoDilation,
        1, 100,
        "%d%% speed"
    )
    UImisc.Elements.QuickTooltip(UILabels.misc.time.tDilationSlider, Colour.Info)

    if (changedDilation) then
        if UImisc.Util.configuration.functions.slowMoDilation > 100 then
            UImisc.Util.configuration.functions.slowMoDilation = 100
        elseif UImisc.Util.configuration.functions.slowMoDilation < 1 then
            UImisc.Util.configuration.functions.slowMoDilation = 1
        end

        if UImisc.Util.configuration.functions.lockPlayerTiDi then
            UImisc.Util.configuration.functions.slowMoPlayerRatio = UImisc.Util.configuration.functions.slowMoDilation
        end

        UImisc.Util.SaveConfig()
    end

    UImisc.Elements.DoubleSpace()
    local changedPlayerRatio, ratio, overRatio, ratioSliderText
    ratio = CUtil.Round(UImisc.Util.configuration.functions.slowMoPlayerRatio / UImisc.Util.configuration.functions.slowMoDilation, 2)
    local actual = 10 * (UImisc.Util.configuration.functions.slowMoDilation)
    ratioSliderText = (("%d%% speed (ratio: {#}, max: {$}%%)"):gsub("{#}", string.format("%.2f", ratio))):gsub("{$}", tostring(actual))

    if ratio <= 10 then
        overRatio = false
    else
        overRatio = true
        ImGui.PushStyleColor(ImGuiCol.Text, Colour.Critical:Params())
    end

    ImGui.BeginDisabled(UImisc.Util.configuration.functions.lockPlayerTiDi)
    UImisc.Util.configuration.functions.slowMoPlayerRatio, changedPlayerRatio = ImGui.SliderInt(
        UILabels.misc.time.slowmoPlayerRatio,
        UImisc.Util.configuration.functions.slowMoPlayerRatio,
        1, 100,
        ratioSliderText
    )
    ImGui.EndDisabled()

    if overRatio then ImGui.PopStyleColor() end
    UImisc.Elements.QuickMultiTooltip({
        { text = UILabels.misc.time.tDilationRatioSlider1, colour = Colour.Info },
        { text = UILabels.misc.time.tDilationRatioSlider2, colour = Colour.Warning },
        { text = UILabels.misc.time.tDilationRatioSlider3, colour = Colour.Critical }
    })

    if (changedPlayerRatio) then
        if UImisc.Util.configuration.functions.slowMoPlayerRatio > 1000 then
            UImisc.Util.configuration.functions.slowMoPlayerRatio = 1000
        elseif UImisc.Util.configuration.functions.slowMoPlayerRatio < 1 then
            UImisc.Util.configuration.functions.slowMoPlayerRatio = 1
        end

        UImisc.Util.SaveConfig()
    end
    UImisc.Elements.Text(UILabels.misc.time.tDilationRatioNote, true, true, Colour.Disabled, 0.9)

    UImisc.Elements.DoubleSpace()
    local effectClicked
    UImisc.Util.configuration.functions.slowMoEffect, effectClicked = ImGui.Combo(
        UILabels.misc.time.lSlowMoEffects,
        UImisc.Util.configuration.functions.slowMoEffect,
        UILabels.misc.time.cSlowMoEffects, 3
    )
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.time.tSlowMoEffects)
    end

    UImisc.Elements.Text(UILabels.misc.time.tSlowMoEffectsNote, true, true, Colour.Disabled, 0.9)

    if (effectClicked) then
        UImisc.Util.SaveConfig()
    end

    UImisc.Elements.DoubleSpace()
    ImGui.EndDisabled()

    local slowmoPressed
    _, slowmoPressed = ImGui.Checkbox(UILabels.misc.time.slowmoenable, UImisc.Misc.slowMo)
    if (slowmoPressed) then
        local effectIndex = UImisc.Util.configuration.functions.slowMoEffect + 1
        local effect = string.lower(UILabels.misc.time.cSlowMoEffects[effectIndex]:gsub("nz", "zn"))
        DEBUG_printl(LOG_LEVEL.Trace, "Effect:", effect)
        UImisc.Misc.SlowMotion(effect)
        UImisc.slowMoHeaderText = t(UImisc.Misc.slowMo, UILabels.misc.time.tSlowMoLabelDisabled, UILabels.misc.time.tSlowMoLabelEnabled)
        if (UImisc.Util.configuration.functions.slowMoScaleCycleTime) then
            UImisc.Ammo.ToggleScaledCycleTime(UImisc.Misc.slowMo)
        end
    end

    ImGui.SameLine()

    local slowmoSelfPressed
    _, slowmoSelfPressed = ImGui.Checkbox(UILabels.misc.time.bSlowmoself, UImisc.Misc.applyToSelf)
    if (slowmoSelfPressed) then
        UImisc.Misc.SlowMotionSelf()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.time.tSlowmoself)
    end

    ImGui.SameLine()

    local scaleCyclePressed
    UImisc.Util.configuration.functions.slowMoScaleCycleTime, scaleCyclePressed = ImGui.Checkbox(
        UILabels.misc.time.bScaleCycle, UImisc.Util.configuration.functions.slowMoScaleCycleTime
    )
    if scaleCyclePressed then
        if UImisc.Misc.slowMo and UImisc.Util.configuration.functions.slowMoScaleCycleTime then
            DEBUG_printl(LOG_LEVEL.Trace, "Toggling cycle time cheat to: true")
            UImisc.Ammo.ToggleScaledCycleTime(true)
        elseif UImisc.Misc.slowMo and not UImisc.Util.configuration.functions.slowMoScaleCycleTime then
            DEBUG_printl(LOG_LEVEL.Trace, "Toggling cycle time cheat to: false")
            UImisc.Ammo.ToggleScaledCycleTime(false)
        end
    end
    UImisc.Elements.QuickMultiTooltip({
        { text = UILabels.misc.time.tScaleCycle1, colour = Colour.Info },
        { text = UILabels.misc.time.tScaleCycle1b, colour = Colour.Info },
        { text = UILabels.misc.time.tScaleCycle2, colour = Colour.Warning }
    })
end

--Vehicles
function UImisc.MenuVehicles()
    UImisc.Elements.SectionHeading(UILabels.misc.vehicles.tManageVehicles, Colour.Info, false)
    ImGui.BeginDisabled(not GameState.isLoaded)
    UImisc.Elements.InGameWarning()
    if (Items.VehicleNames == nil or #Items.VehicleNames == 0) and GameState.isLoaded then
        Items.RefreshPlayerVehicles()
    end

    UImisc.vehicletype = ImGui.Combo(UILabels.universalelements.type.."##vehicle", UImisc.vehicletype, Items.VehicleNames, #Items.VehicleNames)
    if (ImGui.Button(UILabels.misc.vehicles.bSelected)) then
        UImisc.Travel.UnlockVehicle(UImisc.vehicletype, true)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.misc.vehicles.bLkSelected)) then
        UImisc.Travel.UnlockVehicle(UImisc.vehicletype, false)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.misc.vehicles.bAll)) then
        UImisc.Travel.UnlockVehicleAll()
    end

    UImisc.Elements.SectionHeading(UILabels.misc.vehicles.tMiscCommands, Colour.Info)
    if (ImGui.Button(UILabels.misc.vehicles.bInstant)) then
        UImisc.Travel.ToggleVehicleSpawn()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.misc.vehicles.tInstant)
    end
    ImGui.SameLine()
    if(ImGui.Button(UILabels.misc.vehicles.bFixCar)) then
        UImisc.Misc.FixCar()
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.vehicles.tFixCar, Colour.Info)

    ImGui.SameLine()

    local repairTimersPressed
    UImisc.Util.configuration.functions.instantRepairs, repairTimersPressed = ImGui.Checkbox(
        UILabels.misc.vehicles.bInstantRepair, UImisc.Util.configuration.functions.instantRepairs
    )
    UImisc.Elements.QuickTooltip(UILabels.misc.vehicles.tInstantRepair, Colour.Info)
    if (repairTimersPressed) then
        UImisc.Util.SaveConfig()
    end
    ImGui.EndDisabled()
end

local function createCheckSliderPair(id, checkVar, sliderVar, checkText, toolText, sliderVals)
    local checkChanged, sliderChanged
    checkVar, checkChanged = ImGui.Checkbox(checkText, checkVar)
    if (ImGui.IsItemHovered()) then
        local toolTexts = {
            { text = toolText, colour = Colour.Info }
        }

        UImisc.Elements.Tooltip(toolTexts, 400, true)
    end

    ImGui.SameLine(UImisc.widestBreachLabel)

    ImGui.BeginDisabled(not checkVar)
    local availX, _ = ImGui.GetContentRegionAvail()
    ImGui.SetNextItemWidth(availX)
    sliderVar, sliderChanged = ImGui.SliderInt(id, sliderVar, sliderVals.min, sliderVals.max)
    ImGui.EndDisabled()

    return checkVar, sliderVar, checkChanged, sliderChanged
end

local function checkTextAndSetMax(text)
    local labelX, _ = ImGui.CalcTextSize(text)
    labelX = labelX + 75
    if labelX > UImisc.widestBreachLabel then
        UImisc.widestBreachLabel = labelX
    end
end

function UImisc.MenuBreachProtocol()
    local titleText = t(CustomGameState.InHackingMinigame, UILabels.misc.breachProto.inMinigame, UILabels.misc.breachProto.options)
    local titleColour = t(CustomGameState.InHackingMinigame, Colour.Critical, Colour.Positive)
    UImisc.Elements.SectionHeading(titleText, titleColour, false)

    ImGui.BeginDisabled(CustomGameState.InHackingMinigame)
    checkTextAndSetMax(UILabels.misc.breachProto.cbCustTime)
    UImisc.Misc.bpOptions.custBPTimeEnabled, UImisc.Misc.bpOptions.custBPTime, _, _ =
    createCheckSliderPair(
        "##custBPTime",
        UImisc.Misc.bpOptions.custBPTimeEnabled,
        UImisc.Misc.bpOptions.custBPTime,
        UILabels.misc.breachProto.cbCustTime,
        UILabels.misc.breachProto.tCustTime,
        t(not UImisc.exceed, {min = 5, max = 120}, {min = 1, max = 999})
    )

    ImGui.Spacing()
    local sizeValChanged
    checkTextAndSetMax(UILabels.misc.breachProto.cbCustGrid)
    UImisc.Misc.bpOptions.custBPSizeEnabled, UImisc.Misc.bpOptions.custBPSize, _, sizeValChanged =
    createCheckSliderPair(
        "##custBPSize",
        UImisc.Misc.bpOptions.custBPSizeEnabled,
        UImisc.Misc.bpOptions.custBPSize,
        UILabels.misc.breachProto.cbCustGrid,
        UILabels.misc.breachProto.tCustGrid,
        t(not UImisc.exceed, {min = 5, max = 7}, {min = 4, max = 9})
    )

    ImGui.Spacing()
    local buffValChanged
    checkTextAndSetMax(UILabels.misc.breachProto.cbCustBuff)
    UImisc.Misc.bpOptions.custBPBuffEnabled, UImisc.Misc.bpOptions.custBPBuff, _, buffValChanged = 
    createCheckSliderPair(
        "##custBPBuff",
        UImisc.Misc.bpOptions.custBPBuffEnabled,
        UImisc.Misc.bpOptions.custBPBuff,
        UILabels.misc.breachProto.cbCustBuff,
        UILabels.misc.breachProto.tCustBuff,
        t(not UImisc.exceed, {min = 4, max = 8}, {min = 1, max = 10})
    )

    ImGui.Spacing()
    local puzzValChanged
    checkTextAndSetMax(UILabels.misc.breachProto.cbCustPuzzLen)
    UImisc.Misc.bpOptions.custBPPuzzEnabled, UImisc.Misc.bpOptions.custBPPuzz, _, puzzValChanged = 
    createCheckSliderPair(
        "##custBPPuzzLen",
        UImisc.Misc.bpOptions.custBPPuzzEnabled,
        UImisc.Misc.bpOptions.custBPPuzz,
        UILabels.misc.breachProto.cbCustPuzzLen,
        UILabels.misc.breachProto.tCustPuzzLen,
        t(not UImisc.exceed, {min = 1, max = 6}, {min = 1, max = 10})
    )
    ImGui.EndDisabled()

    UImisc.Elements.SectionHeading(UILabels.misc.breachProto.tAdditionalOpt, Colour.Info)
    local infTimeCheckChanged
    UImisc.Misc.bpOptions.infBPTime, infTimeCheckChanged = ImGui.Checkbox(UILabels.misc.breachProto.cbInfTime, UImisc.Misc.bpOptions.infBPTime)
    UImisc.Elements.QuickTooltip(UILabels.misc.breachProto.tInfTime, Colour.Positive)
    if infTimeCheckChanged then
        UImisc.Misc.CheckBPTimerState()
    end

    ImGui.BeginDisabled(CustomGameState.InHackingMinigame)
    local unsolvClicked
    ImGui.SameLine()
    UImisc.allowUnsolvable, unsolvClicked = ImGui.Checkbox(UILabels.misc.breachProto.cbUnsolv, UImisc.allowUnsolvable)
    UImisc.Elements.QuickMultiTooltip({
        { text = UILabels.misc.breachProto.tUnsolv1, colour = Colour.Info },
        { text = UILabels.misc.breachProto.tUnsolv2, colour = Colour.Warning }
    })
    if unsolvClicked then unsolvToggle = true end

    local exceedClicked
    ImGui.SameLine()
    UImisc.exceed, exceedClicked = ImGui.Checkbox(UILabels.misc.breachProto.cbExceed, UImisc.exceed)
    UImisc.Elements.QuickMultiTooltip({
        { text = UILabels.misc.breachProto.tExceed1, colour = Colour.Info },
        { text = UILabels.misc.breachProto.tExceed2, colour = Colour.Warning }
    })
    if exceedClicked then resetBPOptions() end
    ImGui.EndDisabled()

    if not UImisc.allowUnsolvable then
        if (puzzValChanged or unsolvToggle) and UImisc.Misc.bpOptions.custBPBuff < UImisc.Misc.bpOptions.custBPPuzz then
            UImisc.Misc.bpOptions.custBPBuff = UImisc.Misc.bpOptions.custBPPuzz
        end

        if (buffValChanged or unsolvToggle) and UImisc.Misc.bpOptions.custBPPuzz > UImisc.Misc.bpOptions.custBPBuff then
            UImisc.Misc.bpOptions.custBPPuzz = UImisc.Misc.bpOptions.custBPBuff
        end

        if (puzzValChanged or unsolvToggle) and UImisc.Misc.bpOptions.custBPSize <= math.ceil(UImisc.Misc.bpOptions.custBPPuzz / 1.25) then
            UImisc.Misc.bpOptions.custBPSize = math.ceil(UImisc.Misc.bpOptions.custBPPuzz / 1.25)
        end

        if (sizeValChanged or unsolvToggle) and UImisc.Misc.bpOptions.custBPPuzz >= math.floor(UImisc.Misc.bpOptions.custBPSize * 1.25)  then
            UImisc.Misc.bpOptions.custBPPuzz = math.floor(UImisc.Misc.bpOptions.custBPSize * 1.25)
        end

        unsolvToggle = false
    end
end

function UImisc.MenuNPC()
    if (ImGui.Button(UILabels.misc.npc_other.bKill)) then
        UImisc.Misc.Kill()
    end
    UImisc.Elements.QuickTooltip(UILabels.misc.npc_other.tKill, Colour.Info)

    UImisc.Elements.Separator()
end

return UImisc