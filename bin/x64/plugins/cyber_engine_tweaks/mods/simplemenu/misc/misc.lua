local Misc = {
    slowMo = false,
    applyToSelf = true,
    init = true,
    bpOptions = {
        infBPTime = false,
        custBPTimeEnabled = false,
        custBPTime = 5,
        custBPSizeEnabled = false,
        custBPSize = 5,
        custBPBuffEnabled = false,
        custBPBuff = 4,
        custBPPuzzEnabled = false,
        custBPPuzz = 1
    },
    bpController = nil
}

Misc.Util = require("config/util")
local CUtil = require("misc/cetUtils")
local Travel = require("misc/travel")

local facts = {
    --NPCs
    {
        "q105_fingers_beaten", --fingers
        "q105_fingers_dead",
        "q005_jackie_stay_notell", --jackie
        "q005_jackie_to_hospital",
        "q005_jackie_to_mama",
        "sq032_johnny_friend", --johnny
        "q112_takemura_dead" --takemura
    },
    --Other
    {
        "holo_delamain_deep_vehicle_talk",
        "q101_enable_side_content"
    },
    --Romances
    {
        "judy_romanceable",
        "kerry_romanceable"
    },
    --Skippy
    {
        "mq007_skippy_aim_at_head",
        "mq007_skippy_goes_emo"
    }
}

function Misc.ChangeFact(category, type, value)
    if (category == 3) then
        Game.GetQuestsSystem():SetFactStr(facts[category][type], value)
        print("[SimpleMenu] Romance quest fact", facts[category][type], "set to", value)
    end
    Game.GetQuestsSystem():SetFactStr(facts[category][type], value)
    print("[SimpleMenu] Quest fact", facts[category][type], "set to", value)
end

function Misc.EndQuest()
    local jm = Game.GetJournalManager()
    local te = jm:GetTrackedEntry()
    local qe = jm:GetParentEntry(jm:GetParentEntry(te))
    local qeh = jm:GetEntryHash(qe)
    jm:ChangeEntryStateByHash(qeh, "Succeeded", "Notify")
    print("[SimpleMenu] Current active quest ended")
end

function Misc.Untrack()
    Game.GetJournalManager():UntrackEntry()
    print("[SimpleMenu] Current active quest untracked")
end

function Misc.UnlockAchieve()
    Game.UnlockAllAchievements()
    print("[SimpleMenu] All achievements unlocked")
end

function Misc.Kill()
    local tgt = Game.GetTargetingSystem()
    local lookAtObj = tgt:GetLookAtObject(Game.GetPlayer())
    if lookAtObj ~= nil then
        if lookAtObj:IsExactlyA("NPCPuppet") then
            lookAtObj:Kill()
        end
    end
    print("[SimpleMenu] Killed NPC")
end

function Misc.SlowMotion(effect)
    local ts = Game.GetTimeSystem()
    local ratio = CUtil.Round(Misc.Util.configuration.functions.slowMoPlayerRatio / Misc.Util.configuration.functions.slowMoDilation, 2)
    Misc.slowMo = not Misc.slowMo

    if ratio > 10 then ratio = 10 end

    if (Misc.slowMo) then
        --set ignore status again here in case the game has changed it
        ts:SetIgnoreTimeDilationOnLocalPlayerZero(not Misc.applyToSelf)
        ts:SetTimeDilation(effect, Misc.Util.configuration.functions.slowMoDilation / 100)
        ts:SetTimeDilationOnLocalPlayerZero(effect, ratio)
    else
        ts:UnsetTimeDilation(effect)
        ts:UnsetTimeDilationOnLocalPlayerZero(effect)
    end

    print(
        "[SimpleMenu] Slow Motion:",
        Misc.slowMo,
        "/ Dilation:",
        Misc.Util.configuration.functions.slowMoDilation / 100,
        "/ Ratio:",
        ratio
    )
end

function Misc.SlowMotionSelf()
    Misc.applyToSelf = not Misc.applyToSelf
    local ts = Game.GetTimeSystem()
    ts:SetIgnoreTimeDilationOnLocalPlayerZero(not Misc.applyToSelf)
end

function Misc.SlowMoDilMinus()
    if (Misc.Util.configuration.functions.slowMoDilation >= 10) then
        Misc.Util.configuration.functions.slowMoDilation = CUtil.RoundNearestPower(
            Misc.Util.configuration.functions.slowMoDilation - 10, 10
        )
        Misc.Util.SaveConfig()
    end
end

function Misc.SlowMoDilPlus()
    if (Misc.Util.configuration.functions.slowMoDilation <= 90) then
        Misc.Util.configuration.functions.slowMoDilation = CUtil.RoundNearestPower(
            Misc.Util.configuration.functions.slowMoDilation + 10, 10
        )
        Misc.Util.SaveConfig()
    end
end

function Misc.PoliceLevel(wantedLevel)
    local ps = Game.GetPlayer():GetPreventionSystem()
    if not ps:IsSystemEnabled() then
        print("[SimpleMenu] Police system disabled")
        return
    end
    local wLevel = SetWantedLevel.new()
    wLevel.wantedLevel = wantedLevel
    ps:QueueRequest(wLevel)
    print("[SimpleMenu] Set Wanted Level to", wantedLevel)
end

function Misc.PoliceLevelStep(step)
    local ps = Game.GetPlayer():GetPreventionSystem()
    if not ps:IsSystemEnabled() then
        print("[SimpleMenu] Police system disabled")
        return false
    end
    local currentWL = ps:GetWantedLevelFact()
    local newWL = currentWL + step
    if newWL > 5 then newWL = 5 end
    if newWL < 0 then newWL = 0 end
    local wLevel = SetWantedLevel.new()
    wLevel.wantedLevel = newWL
    ps:QueueRequest(wLevel)
    print("[SimpleMenu] Set Wanted Level to", newWL)
    return true
end

function Misc.DisablePolice(disabled)
    local ps = Game.GetPlayer():GetPreventionSystem()
    local toggle = TogglePreventionSystem.new()
    toggle.sourceName = CName.new('SMDisablePolice')
    toggle.isActive = not disabled
    ps:QueueRequest(toggle)
    ps:TogglePreventionSystem(not disabled)
end

function Misc.PoliceToggle()
    Misc.Util.configuration.functions.disablePolice = not Misc.Util.configuration.functions.disablePolice
    Misc.DisablePolice(Misc.Util.configuration.functions.disablePolice)
    Misc.Util.SaveConfig()
    print("[SimpleMenu] Disable Police System:", Misc.Util.configuration.functions.disablePolice)
end

function Misc.CheckBPTimerState()
    if Misc.bpController ~= nil then
        if Misc.bpOptions.infBPTime then
            Misc.bpController:PauseTheTimer()
        else
            Misc.bpController:ResumeTheTimer()
        end
    end
end

function Misc.SetTime(timeH, timeM)
    local timeSystem = Game.GetTimeSystem()
    timeSystem:SetGameTimeByHMS(timeH, timeM, 0)
    print("[SimpleMenu] Game time set to:", timeH..":"..timeM)
end

function Misc.FreezeTime()
    Misc.Util.configuration.functions.freezeTime = not Misc.Util.configuration.functions.freezeTime
    local timeSystem = Game.GetTimeSystem()
    timeSystem:SetPausedState(Misc.Util.configuration.functions.freezeTime, CName.new())
    Misc.Util.SaveConfig()
    print("[SimpleMenu] Freeze Game Time:", Misc.Util.configuration.functions.freezeTime)
end

local function QSM_SetActiveVehicle(qsm, pv)
    DEBUG_printl(LOG_LEVEL.Trace, "Creating QSM command")
    local itemRecord = TweakDB:GetRecord(pv.recordID)
    local iconPath = qsm:FindTempVehicleIcon(pv)
    local title = itemRecord:Model():EnumName()
    local type = itemRecord:Type():EnumName()
    local qsc = qsm:CreateQuickSlotItemCommand(
        ItemID.new(),
        QuickSlotActionType.SetActiveVehicle,
        iconPath,
        title,
        type,
        ""
    )
    qsc.playerVehicleData = pv
    qsc.itemType = QuickSlotItemType.Vehicle

    DEBUG_printl(LOG_LEVEL.Trace, "Executing QSM command")
    qsm:ExecuteCommand(qsc)
end

function Misc.FixCar()
    local player = Game.GetPlayer()
    local tgt = Game.GetTargetingSystem()
    local veh = tgt:GetLookAtObject(player)
    if (veh:IsExactlyA("vehicleCarBaseObject") or veh:IsExactlyA("vehicleBikeBaseObject")) and veh:IsPlayerVehicle() then
        local vcc = veh:GetVehicleComponent()
        local qsm = player:GetQuickSlotsManager()
        local vss = Game.GetVehicleSystem()
        local vps = veh:GetVehiclePS()
        local vcs = vps:GetVehicleControllerPS()
        local cpv = CUtil.ArrayFirst(
            vss:GetPlayerUnlockedVehicles(),
            function(v)
                return v.recordID == veh:GetRecordID()
            end
        )

        if cpv ~= nil then
            DEBUG_printl(LOG_LEVEL.Info, "Repairing player car:", cpv.recordID.value)
            QSM_SetActiveVehicle(qsm, cpv)
            veh:DestructionResetGlass()
            veh:DestructionResetGrid()
            vcc:RepairVehicle()
            if not Travel.instantSpawn then vss:ToggleSummonMode() end
            vss:DespawnPlayerVehicle(GarageVehicleID.Resolve(cpv.recordID.value))
            qsm:SummonVehicle(true)
            if not Travel.instantSpawn then vss:ToggleSummonMode() end
            vps:ForcePersistentStateChanged()
            vcs:SetState(vehicleEState.Default)
        end
    end
end

return Misc