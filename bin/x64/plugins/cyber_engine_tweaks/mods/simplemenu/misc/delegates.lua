local Delegates = {}

local Util = require("config/util")
local Misc = require("misc/misc")
local Ammo = require("items/ammo")
local CetUtils = require("misc/cetUtils")
local bpOptions = Misc.bpOptions
local T = Util.T

--region LOCAL DEFINITIONS

---@enum Direction
local Direction = {
    Back    = -180.0,
    Right   = -90.0,
    Forward =  0.0,
    Left    =  90.0
}

local verticalLine =
    "-------------------------------------------"..
    "----------------------------------------\n\n "

--endregion

--region LOCAL FUNCTIONS

local function setDodgeDirection(stateContext, scriptInterface, direction)
    stateContext:SetConditionFloatParameter("DodgeDirection", direction, true);
    scriptInterface.localBlackboard:SetFloat(
        GetAllBlackboardDefs().PlayerStateMachine.DodgeTimeStamp,
        EngineTime.ToFloat(
            GameInstance.GetSimTime()
        )
    )
end

local function hasDodgedDirectionally(stateContext, scriptInterface)
    if scriptInterface:IsActionJustPressed("DodgeForward") then
        setDodgeDirection(stateContext, scriptInterface, Direction.Forward)
        return true, Direction.Forward
    elseif scriptInterface:IsActionJustPressed("DodgeRight") then
        setDodgeDirection(stateContext, scriptInterface, Direction.Right)
        return true, Direction.Right
    elseif scriptInterface:IsActionJustPressed("DodgeLeft") then
        setDodgeDirection(stateContext, scriptInterface, Direction.Left)
        return true, Direction.Left
    elseif scriptInterface:IsActionJustPressed("DodgeBack") then
        setDodgeDirection(stateContext, scriptInterface, Direction.Back)
        return true, Direction.Back
    end

    return false, nil
end

local function hasTappedDodge(transition, stateContext, scriptInterface)
    local dodgePress =
        scriptInterface:IsActionJustTapped("Dodge") or
        scriptInterface:IsActionJustReleased("Dodge")

    local dir = 0
    if dodgePress then
        if transition:GetStaticBoolParameterDefault("dodgeWithNoMovementInput", false) then
            dir = Direction.Back
            setDodgeDirection(stateContext, scriptInterface, dir)
            return true, dir
        else
            dir = scriptInterface:GetInputHeading()
            setDodgeDirection(stateContext, scriptInterface, dir)
            return true, nil
        end
    end

    return false, nil
end

--endregion

--region DELEGATES

function Delegates.PlayerPuppetOnItemEquipped(_, _, item)
    Ammo.EquipListener(item)
end

function Delegates.PlayerPuppetOnItemUnequipped(_, _, item)
    Ammo.UnequipListener(item)
end

function Delegates.LocomotionAirEventsOnEnterDelegate(_, ctx, _)
    if Util.configuration.functions.godMode then
        ctx:SetPermanentFloatParameter('RegularLandingFallingSpeed', -6000, true )
        ctx:SetPermanentFloatParameter('SafeLandingFallingSpeed', -7000, true )
        ctx:SetPermanentFloatParameter('HardLandingFallingSpeed', -8000, true )
        ctx:SetPermanentFloatParameter('VeryHardLandingFallingSpeed', -9000, true )
        ctx:SetPermanentFloatParameter('DeathLandingFallingSpeed', -10000, true )
    end
end

function Delegates.HackingMinigameGameControllerOnPositionSelected(gc, _)
    if bpOptions.infBPTime then
        gc:PauseTheTimer()
    end
end

function Delegates.HackingMinigameGameControllerOnInitialize(gc, wrapped)
    Misc.bpController = gc
    wrapped()

    local anyCustom =
        bpOptions.custBPTimeEnabled or
        bpOptions.custBPSizeEnabled or
        bpOptions.custBPBuffEnabled

    if anyCustom then
        local mgData = FromVariant(gc.bbMinigame:GetVariant(GetAllBlackboardDefs().HackingMinigame.MinigameDefaults))
        local custTime = T(bpOptions.custBPTimeEnabled, bpOptions.custBPTime, mgData.timeLimit)
        local custSize = T(bpOptions.custBPSizeEnabled, bpOptions.custBPSize, mgData.gridSize)
        local custBuff = T(bpOptions.custBPBuffEnabled, bpOptions.custBPBuff, mgData.bufferSize)
        local newMgData = MinigameData.new()

        newMgData.timeLimit = custTime
        newMgData.gridSize = custSize
        newMgData.bufferSize = custBuff
        newMgData.timerWaitsForInteraction = true
        newMgData.rules = mgData.rules
        newMgData.acceptableTraps = mgData.acceptableTraps
        newMgData.symbolsToUse = mgData.symbolsToUse

        gc.bbMinigame:SetVariant(GetAllBlackboardDefs().HackingMinigame.MinigameDefaults, ToVariant(newMgData))
    end
    CustomGameState.InHackingMinigame = true
end

function Delegates.HackingMinigameGameControllerOnUninitialize(_)
    CustomGameState.InHackingMinigame = false
    Misc.bpController = nil
end

function Delegates.MinigameGenerationRuleScalingProgramsDefineLength(_, cpl, bufsz, numprogs, wrapped)
    if bpOptions.custBPPuzzEnabled then
        return bpOptions.custBPPuzz
    else
        return wrapped(cpl, bufsz, numprogs)
    end
end

function Delegates.VehicleSystemGetPlayerUnlockedVehicles(_, _, wrapped)
    local vehicles = wrapped()

    if Util.configuration.functions.instantRepairs then
        CetUtils.ArrayMap(
            vehicles,
            function (v)
                local currentST = Game.GetSimTime():ToFloat()
                local explodeST = v.destructionTimeStamp:ToFloat()
                if (currentST - explodeST) < 301 then
                    local newExplodeST = explodeST - (301 - (currentST - explodeST))
                    v.destructionTimeStamp = EngineTime.FromFloat(newExplodeST)
                end
            end
        )
    end

    return vehicles
end

function Delegates.DoubleJumpDecisionsEnterCondition(decisions, context, interface, wrappedFunc)
    local retVal = wrappedFunc(context, interface)
    if ModState.SVars.Mods.InfiniteDoubleJump then
        local currentNumberOfJumps = context:GetIntParameter("currentNumberOfJumps", true)
        if ((currentNumberOfJumps >= decisions:GetStaticIntParameterDefault("numberOfMultiJumps", 1)
            or decisions:IsCurrentFallSpeedTooFastToEnter(context, interface))
            and interface:IsActionJustPressed("Jump")
        ) then
            retVal = true
        end
    end
    return retVal
end

function Delegates.LocomotionTransitionWantsToDodge(transition, stateContext, scriptInterface, wrappedFunc)
    -- Get inputs/conditions before running original function so they don't get cancelled out
    local dodgePress, dodgeDirectionPress, dodgePDirection, dodgeDDirection = false, false, nil, nil
    dodgePress, dodgePDirection = hasTappedDodge(transition, stateContext, scriptInterface)
    dodgeDirectionPress, dodgeDDirection = hasDodgedDirectionally(stateContext, scriptInterface)

    local directionalDodge = (dodgeDirectionPress and dodgeDDirection ~= nil)
    local stationaryDodge = (dodgePress and dodgePDirection ~= nil)
    local tooFast = transition:IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface)

    -- Evaluate as normal
    local retVal = wrappedFunc(stateContext, scriptInterface)

    local preconditionMet = false
    if ModState.SVars.Mods.InfiniteAirDash then
        DEBUG_printl(1, "AirDash PRECONDITIONS:\n",
            "dodge press:", dodgePress, "|", Util.T(dodgePDirection ~= nil, dodgePDirection, "None"), "\n",
            "stationary dodge:", stationaryDodge, "\n",
            "direction double tap:", dodgeDirectionPress, "|", Util.T(dodgeDDirection ~= nil, dodgeDDirection, "None"), "\n",
            "directional dodge:", directionalDodge, "\n",
            "game calculation:", retVal, "\n",
            "too fast:", tooFast, "\n\n "
        )

        preconditionMet = not retVal and (dodgePress or dodgeDirectionPress)
        DEBUG_printl(1, "AirDash PRECONDITION EVALUATION:\n",
            "CONDITION:\n",
            "    NOT \"game calculation\" AND (\"dodge press\" OR \"direction double tap\")\n",
            "EVALUATION:", preconditionMet, "\n"..
            T(preconditionMet, "\n ", verticalLine)
        )
    end

    -- If the game thinks it's false, and the option is on, and our conditions are met, re-evaluate
    if ModState.SVars.Mods.InfiniteAirDash and preconditionMet then
        local airDashDisableParam = stateContext:GetPermanentBoolParameter("disableAirDash")
        local airDashDisable = airDashDisableParam.valid and airDashDisableParam.value
        local touchingGround = transition:IsTouchingGround(scriptInterface)
        local dodgeEnabled = GameplaySettingsSystem.GetMovementDodgeEnabled(scriptInterface.executionOwner)

        local isAirDashPerkBought = PlayerDevelopmentSystem.GetInstance(
            scriptInterface.executionOwner
        ):IsNewPerkBought(
            scriptInterface.executionOwner,
            gamedataNewPerkType.Reflexes_Central_Milestone_3
        ) == 3

        local isStaminaPositive = GameInstance.GetStatPoolsSystem():GetStatPoolValue(
            scriptInterface.executionOwner:GetEntityID(),
            gamedataStatPoolType.Stamina,
            true
        ) > 0.0

        local finalEval =
            (not touchingGround and
            (airDashDisable or not dodgeEnabled or tooFast)) and
            (isAirDashPerkBought and isStaminaPositive)

        DEBUG_printl(1, "AirDash CONDITIONS:\n",
            "touching ground:", touchingGround, "\n",
            "dodge enabled:", dodgeEnabled, "\n",
            "air dash enabled:", not airDashDisable, "\n",
            "has air dash perk:", isAirDashPerkBought, "\n",
            "has stamina:", isStaminaPositive, "\n\n "
        )

        DEBUG_printl(1, "AirDash CONDITIONS EVALUATION:\n",
            "CONDITION 1:\n",
            "    NOT \"touching ground\" AND\n",
            "    (NOT \"air dash enabled\" OR NOT \"dodge enabled\" OR \"falling too fast\")\n",
            "CONDITION 2:\n",
            "    (\"has air dash perk\" AND \"has stamina\")\n",
            "EVALUATION (CONDITION 1 AND CONDITION 2):", finalEval, "\n",
            verticalLine
        )

        retVal = finalEval
    end

    return retVal
end

function Delegates.MinimapContainerControllerOnCountdownTimerActiveUpdated(_, _)
    if Util.configuration.functions.freezeCarQuestTime then
        local timerDef = GetAllBlackboardDefs().UI_HUDCountdownTimer
        local timerBB = Game.GetBlackboardSystem():Get(timerDef)
        local missionTimer = FromVariant(timerBB:GetVariant(timerDef.TimerID))
        Game.GetDelaySystem():CancelTick(missionTimer)
        timerBB:SetFloat(timerDef.Progress, 599.0, true)
    end
end

--endregion

return Delegates