local Player = {}

Player.Util = require("config/util")
local T = Player.Util.T
local level = {}
local attribute = {}
local stat = {}

---@enum EPlayerMod
local EPlayerMod = {
    GodMode             = 1,
    InfiniteOxygen      = 2,
    InfiniteStamina     = 3,
    HealItemCooldown    = 4,
    GrenadeCooldown     = 5,
    ProjectileCooldown  = 6,
    CloakCooldown       = 7,
    SandevistanCooldown = 8,
    BerserkCooldown     = 9,
    KerenzikovCooldown  = 10,
    OverclockCooldown   = 11,
    QuickhackCooldown   = 12,
    QuickhackCost       = 13,
    MemoryRegeneration  = 14,
    FaceplateCooldown   = 15,
    InfiniteDoubleJump  = 16,
    InfiniteAirDash     = 17
}

Player.EPlayerMod = EPlayerMod

---@type table<EPlayerMod, table<any>?>
local modGroups = {}

---@type table<EPlayerMod, { enable: function<boolean>?, disable: function<boolean>? }>
local modConditions = {}

---@type table<EPlayerMod, table<any, function<string, number?>>?>
local modFunctions = {}

function Player.Preload()
    level = {
        gamedataProficiencyType.Level,
        gamedataProficiencyType.CoolSkill,
        gamedataProficiencyType.IntelligenceSkill,
        gamedataProficiencyType.ReflexesSkill,
        gamedataProficiencyType.StrengthSkill,
        gamedataProficiencyType.TechnicalAbilitySkill,
        gamedataProficiencyType.StreetCred
    }

    attribute = {
        gamedataStatType.Strength,
        gamedataStatType.Reflexes,
        gamedataStatType.TechnicalAbility,
        gamedataStatType.Intelligence,
        gamedataStatType.Cool
    }

    stat = {
        gamedataStatType.Armor,
        gamedataStatType.CarryCapacity,
        gamedataStatType.CritChance,
        gamedataStatType.CritDamage,
        gamedataStatType.Humanity,
        gamedataStatType.Health,
        gamedataStatType.HealthGeneralRegenRateMult,
        gamedataStatType.MaxSpeed,
        gamedataStatType.Oxygen,
        gamedataStatType.Memory,
        gamedataStatType.Stamina
    }

    --GOD MODE: MODS
    modGroups[EPlayerMod.GodMode] = {
        RPGManager.CreateStatModifier(gamedataStatType.HealthGeneralRegenRateMult, gameStatModifierType.Additive, 9999.996),
        RPGManager.CreateStatModifier(gamedataStatType.Armor, gameStatModifierType.Additive, 99999999.997),
        RPGManager.CreateStatModifier(gamedataStatType.Health, gameStatModifierType.Additive, 99999.998),
        RPGManager.CreateStatModifier(gamedataStatType.FallDamageReduction, gameStatModifierType.Additive, 99.999),
        RPGManager.CreateStatModifier(gamedataStatType.ExplosionResistance, gameStatModifierType.Additive, 99.801),
        RPGManager.CreateStatModifier(gamedataStatType.MeleeResistance, gameStatModifierType.Additive, 99.802),
        RPGManager.CreateStatModifier(gamedataStatType.ThermalResistance, gameStatModifierType.Additive, 99.803),
        RPGManager.CreateStatModifier(gamedataStatType.ChemicalResistance, gameStatModifierType.Additive, 99.804),
        RPGManager.CreateStatModifier(gamedataStatType.ElectricResistance, gameStatModifierType.Additive, 99.805),
        RPGManager.CreateStatModifier(gamedataStatType.PhysicalResistance, gameStatModifierType.Additive, 99.806),
        RPGManager.CreateStatModifier(gamedataStatType.HealthInCombatRegenEnabled, gameStatModifierType.Additive, 1)
    }

    --GOD MODE: CONDITIONS
    modConditions[EPlayerMod.GodMode] = {
        enable = function(entity)
            local ss = Game.GetStatsSystem()
            local hp = ss:GetStatValue(entity, gamedataStatType.Health)
            return hp <= 99999
        end,
        disable = function(entity)
            local ss = Game.GetStatsSystem()
            local hp = ss:GetStatValue(entity, gamedataStatType.Health)
            return hp > 99999
        end
    }

    --GOD MODE: STAT FUNCTIONS
    modFunctions[EPlayerMod.GodMode] = {
        [gamedataStatType.HealthInCombatRegenEnabled.value] = function(entity, ...)
            local ss = Game.GetStatsSystem()
            local statVal = ss:GetStatValue(entity, gamedataStatType.HealthInCombatRegenEnabled)
            local retVal = T(statVal >= 0.99, nil, 1) --[[@as number?]]
            DEBUG_printl(LOG_LEVEL.Trace, "Called:", gamedataStatType.HealthInCombatRegenEnabled.value, "Stat Value:", statVal, "Ret Value:", retVal)
            return gamedataStatType.HealthInCombatRegenEnabled.value, retVal
        end
    }

    --INFINITE OXYGEN: MODS
    modGroups[EPlayerMod.InfiniteOxygen] = {
        RPGManager.CreateStatModifier(gamedataStatType.CanBreatheUnderwater, gameStatModifierType.Additive, 1)
    }

    --INFINITE OXYGEN: CONDITIONS
    modConditions[EPlayerMod.InfiniteOxygen] = {
        enable = function(entity)
            local ss = Game.GetStatsSystem()
            local currentVal = math.floor(ss:GetStatValue(entity, gamedataStatType.CanBreatheUnderwater))
            return currentVal == 0
        end,
        disable = function(entity)
            local ss = Game.GetStatsSystem()
            local currentVal = math.floor(ss:GetStatValue(entity, gamedataStatType.CanBreatheUnderwater))
            return currentVal == 1
        end
    }

    --INFINITE STAMINA: MODS
    modGroups[EPlayerMod.InfiniteStamina] = {
        RPGManager.CreateStatModifier(gamedataStatType.CanIgnoreStamina, gameStatModifierType.Additive, 1)
    }

    --INFINITE STAMINA: CONDITIONS
    modConditions[EPlayerMod.InfiniteStamina] = {
        enable = function(entity)
            local ss = Game.GetStatsSystem()
            local currentVal = math.floor(ss:GetStatValue(entity, gamedataStatType.CanIgnoreStamina))
            return currentVal == 0
        end,
        disable = function(entity)
            local ss = Game.GetStatsSystem()
            local currentVal = math.floor(ss:GetStatValue(entity, gamedataStatType.CanIgnoreStamina))
            return currentVal == 1
        end
    }

    modGroups[EPlayerMod.HealItemCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.HealingItemsChargesRegenMult, gameStatModifierType.Additive, 10000)
    }

    modGroups[EPlayerMod.GrenadeCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.GrenadesChargesRegenMult, gameStatModifierType.Additive, 10000)
    }

    modGroups[EPlayerMod.ProjectileCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.ProjectileLauncherChargesRegenMult, gameStatModifierType.Additive, 10000)
    }

    modGroups[EPlayerMod.CloakCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.OpticalCamoRechargeDuration, gameStatModifierType.Multiplier, 0.01),
        RPGManager.CreateStatModifier(gamedataStatType.OpticalCamoChargesRegenRate, gameStatModifierType.Additive, 100)
    }

    modGroups[EPlayerMod.SandevistanCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.TimeDilationSandevistanRechargeDuration, gameStatModifierType.Multiplier, 0.01)
    }

    modGroups[EPlayerMod.BerserkCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.BerserkChargesRegenRate, gameStatModifierType.Additive, 100)
    }

    modGroups[EPlayerMod.KerenzikovCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.KerenzikovCooldownDuration, gameStatModifierType.Multiplier, 0.01)
    }

    modGroups[EPlayerMod.OverclockCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.CyberdeckOverclockRegenRate, gameStatModifierType.Additive, 100),
        RPGManager.CreateStatModifier(gamedataStatType.CyberdeckOverclockCooldown, gameStatModifierType.Multiplier, 0.01)
    }

    modGroups[EPlayerMod.QuickhackCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.QuickhacksCooldownReduction, gameStatModifierType.Additive, 1),
    }

    modGroups[EPlayerMod.QuickhackCost] = {
        RPGManager.CreateStatModifier(gamedataStatType.MemoryCostReduction, gameStatModifierType.Additive, 10000)
    }

    modGroups[EPlayerMod.MemoryRegeneration] = {
        RPGManager.CreateStatModifier(gamedataStatType.MemoryRegenRateMult, gameStatModifierType.Additive, 100)
    }

    modGroups[EPlayerMod.FaceplateCooldown] = {
        RPGManager.CreateStatModifier(gamedataStatType.CWMaskRechargeDuration, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.CWMaskChargesRegenRate, gameStatModifierType.Additive, 100)
    }
end

function Player.MaxAll()
    for i = 1, #attribute do
        Player.SetAttribute(i, 20)
    end

    for i = 1, #level do
        Player.AddXP(i, 99999999)
    end

    PlayerDevelopmentSystem.GetData(Game.GetPlayer()):ClearAllDevPoints()
    print("[SimpleMenu] Player level, street cred, attributes and skills set to maximum")
end

function Player.ResetAll()
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:ResetNewPerks()
    pdd:ResetAttributes()
    pdd:ResetAllProficienciesLevel()
    print("[SimpleMenu] Attributes, Perks and Skills were reset and all points were returned to you")
end

function Player.SetLevel(selected, amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:SetLevel(level[selected], amount, 0, false)
    print("[SimpleMenu]", level[selected].value, "set to", amount)
end

function Player.AddXP(selected, amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:AddExperience(amount, level[selected], 0, false)
    print("[SimpleMenu]", amount, "experience added to", level[selected].value)
end

function Player.SetAttribute(selected, amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:SetAttribute(attribute[selected], amount)
    print("[SimpleMenu]", attribute[selected].value, "attribute set to", amount)
end

function Player.AddAttributePoints(amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:AddDevelopmentPoints(amount, gamedataDevelopmentPointType.Attribute)
    print("[SimpleMenu]", amount, "Attribute point(s) added")
end

function Player.AddPerkPoints(amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:AddDevelopmentPoints(amount, gamedataDevelopmentPointType.Primary)
    print("[SimpleMenu]", amount, "Perk point(s) added")
end

function Player.AddRelicPoints(amount)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:AddDevelopmentPoints(amount, gamedataDevelopmentPointType.Espionage)
    print("[SimpleMenu]", amount, "Relic point(s) added")
end

function Player.ModStats(selected, amount, permanent)
    permanent = permanent or false
    local logText = "temporarily"
    local playerEnt = Game.GetPlayer():GetEntityID()
    local ss = Game.GetStatsSystem()
    local mod = RPGManager.CreateStatModifier(stat[selected], gameStatModifierType.Additive, amount)

    if permanent then
        logText = "permanently"
        ss:AddSavedModifier(playerEnt, mod)
    else
        ss:AddModifier(playerEnt, mod)
    end

    print("[SimpleMenu]", stat[selected].value, "stat "..logText.." modified by", amount)
end

function Player.ResetPerks()
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:ResetNewPerks()
    print("[SimpleMenu] Perk allocation reset")
end

local function DisableHostiles()
    local player = Game.GetPlayer()
    local ses = Game.GetStatusEffectSystem()
    ses:ApplyStatusEffect(
        player:GetEntityID(),
        "BaseStatusEffect.OpticalCamoPlayerBuffLegendary"
    )
    player:SetInvisible(true)
    player:UpdateVisibility()
    local ttc = player:GetTargetTrackerComponent()
    local hostiles = ttc:GetHostileThreats(false)
    for _, v in pairs(hostiles) do
        local hostile = v.entity
        if hostile:IsA("NPCPuppet") then
            DEBUG_printl(LOG_LEVEL.Trace, "Disabling hostile: #"..EntityID.ToDebugStringDecimal(hostile:GetEntityID()))
            hostile:UnregisterAggressiveNPC()
            local vanishEvt = ExitCombatOnOpticalCamoActivatedEvent.new()
            vanishEvt.npc = hostile
            player:QueueEvent(vanishEvt)
        end
    end
end

local hostileFuncTimer = nil
local function MakePlayerInvisible()
    DisableHostiles()
    if hostileFuncTimer == nil then
        hostileFuncTimer = Cron.Every(5, DisableHostiles)
    end
    print("[SimpleMenu] Invisiblity: true")
end

local function MakePlayerVisible()
    local player = Game.GetPlayer()
    local ses = Game.GetStatusEffectSystem()
    ses:RemoveStatusEffect(
        player:GetEntityID(),
        "BaseStatusEffect.OpticalCamoPlayerBuffLegendary"
    )
    player:SetInvisible(false)
    player:UpdateVisibility()
    if hostileFuncTimer ~= nil then
        Cron.Halt(hostileFuncTimer)
        hostileFuncTimer = nil
    end
    print("[SimpleMenu] Invisiblity: false")
end

function Player.ToggleInvisibility(enable)
    if enable then
        MakePlayerInvisible()
    else
        MakePlayerVisible()
    end
end

local EnumName = require("misc/cetUtils").EnumName

---Change modifier state
---@param modifier EPlayerMod
---@param enable boolean
function Player.ChangeModifiers(modifier, enable)
    if Game.GetPlayer() == nil then return end
    print("[SimpleMenu] Modifier", T(enable, "enabled:", "disabled:"), EnumName(EPlayerMod, modifier))
    if modGroups[modifier] == nil then return end
    local entity = Game.GetPlayer():GetEntityID()
    local ss = Game.GetStatsSystem()
    if enable then
        DEBUG_printl(LOG_LEVEL.Trace, "Enable Modifier:", EnumName(EPlayerMod, modifier))
        if modConditions[modifier] ~= nil then
            local condition =  modConditions[modifier].enable
            if condition ~= nil then
                DEBUG_printl(LOG_LEVEL.Trace, "Condition:", tostring(condition(entity)))
                if not condition(entity) then
                    return
                end
            end
        end

        local intermediates = {}
        for _, v in pairs(modGroups[modifier]) do
            intermediates[v.statType.value] = nil
            local skip = false
            local modVal = nil
            local func = nil
            if modFunctions[modifier] ~= nil and modFunctions[modifier][v.statType.value] ~= nil then
                func = modFunctions[modifier][v.statType.value]
            end

            if func ~= nil then
                DEBUG_printl(LOG_LEVEL.Trace, EnumName(EPlayerMod, modifier), "Has Func for:", v.statType.value)
                local statType, value = func(entity)
                intermediates[statType] = value
                DEBUG_printl(LOG_LEVEL.Trace, "Func Val:", value, "Func Stat Type:", statType)
                modVal = intermediates[v.statType.value]
                if modVal ~= nil then
                    DEBUG_printl(LOG_LEVEL.Trace, "Is modifying value after func")
                    v.value = modVal
                else
                    skip = true
                end
            else
                modVal = T(
                    intermediates[v.statType.value] ~= nil,
                    intermediates[v.statType.value],
                    nil
                )

                if modVal ~= nil then
                    DEBUG_printl(LOG_LEVEL.Trace, "Is modifying value as it was given one")
                    v.value = modVal
                end
            end

            if not skip then
                DEBUG_printl(LOG_LEVEL.Trace, EnumName(EPlayerMod, modifier), "- Add Stat Mod:", v.statType.value)
                ss:AddModifier(entity, v)
            end
        end
    else
        if modConditions[modifier] ~= nil then
            local condition =  modConditions[modifier].disable
            DEBUG_printl(LOG_LEVEL.Trace, "Disable Modifier:", EnumName(EPlayerMod, modifier))
            if condition ~= nil then
                DEBUG_printl(LOG_LEVEL.Trace, "Condition:", tostring(condition(entity)))
                if not condition(entity) then
                    return
                end
            end
        end

        for _, v in pairs(modGroups[modifier]) do
            DEBUG_printl(LOG_LEVEL.Trace, EnumName(EPlayerMod, modifier), "- Remove Stat Mod:", v.statType.value)
            ss:RemoveModifier(entity, v)
        end
    end
end

function Player.ToggleInfiniteStamina()
    Player.Util.configuration.functions.infStamina = not Player.Util.configuration.functions.infStamina
    Player.ChangeModifiers(EPlayerMod.InfiniteStamina, Player.Util.configuration.functions.infStamina)
    Player.Util.SaveConfig()
    print("[SimpleMenu] Infinite stamina:", Player.Util.configuration.functions.infStamina)
end

function Player.ToggleGodMode()
    Player.Util.configuration.functions.godMode = not Player.Util.configuration.functions.godMode
    Player.ChangeModifiers(EPlayerMod.GodMode, Player.Util.configuration.functions.godMode)
    Player.Util.SaveConfig()
    print("[SimpleMenu] God Mode:", Player.Util.configuration.functions.godMode)
end

function Player.ToggleInfiniteOxygen()
    Player.Util.configuration.functions.infOxy = not Player.Util.configuration.functions.infOxy
    Player.Util.SaveConfig()
    Player.ChangeModifiers(EPlayerMod.InfiniteOxygen, Player.Util.configuration.functions.infOxy)
    print("[SimpleMenu] Infinite Oxygen:", Player.Util.configuration.functions.infOxy)
end

return Player