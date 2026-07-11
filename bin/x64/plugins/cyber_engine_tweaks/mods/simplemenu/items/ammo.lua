--Infinite Ammo script created by Nexus user TheBs65422

local Ammo = {
    player = nil,
    ts = nil,
    ss = nil
}

Ammo.Util = require("config/util")
Ammo.Misc = require("misc/misc")
local CUtil = require("misc/cetUtils")
local ItemRecord = require("classes/itemrecord")
local TweakDBRecords = nil
local AmmoItems = {}

---@enum EModifier
local EModifier = {
    -- Weapon Modifiers --
    InfiniteMag   = 1,
    SuperReload   = 2,
    SuperAccuracy = 3,
    SuperZoom     = 4,
    SuperRange    = 5,
    NoRecoil      = 6,
    UltraKill     = 7,
    PsychoMode    = 8,
    BeastMode     = 9,
    ScaleCycle    = 10,
    BigBrain      = 11,
    Penetrator    = 12,

    -- Player Modifiers --
    InfiniteCombo = 101
}

---@enum EWeaponEvo
local EWeaponEvo = {
    Smart   = 50,
    Power   = 51,
    Tech    = 52,
    Invalid = 0
}

---@enum EWeaponType
local EWeaponType = {
    Ranged      = 1,
    Melee       = 2,
    Invalid     = 0
}

--Add combined types
EWeaponType.Both        = EWeaponType.Ranged + EWeaponType.Melee
EWeaponType.SmartRanged = EWeaponType.Ranged + EWeaponEvo.Smart
EWeaponType.PowerRanged = EWeaponType.Ranged + EWeaponEvo.Power
EWeaponType.TechRanged  = EWeaponType.Ranged + EWeaponEvo.Tech

---@enum ETargetType
local ETargetType = {
    Player  = 101,
    Invalid = 0
}

---@enum EModifierType
local EModifierType = {
    Ranged      = EWeaponType.Ranged,
    Melee       = EWeaponType.Melee,
    Both        = EWeaponType.Both,
    SmartRanged = EWeaponType.SmartRanged,
    PowerRanged = EWeaponType.PowerRanged,
    TechRanged  = EWeaponType.TechRanged,
    Player      = ETargetType.Player,
    Invalid     = EWeaponType.Invalid
}

---@type table<EModifier, table<any>?>
local modifierGroups = {
    [EModifier.InfiniteMag]   = nil,
    [EModifier.SuperReload]   = nil,
    [EModifier.SuperAccuracy] = nil,
    [EModifier.SuperZoom]     = nil,
    [EModifier.SuperRange]    = nil,
    [EModifier.NoRecoil]      = nil,
    [EModifier.UltraKill]     = nil,
    [EModifier.PsychoMode]    = nil,
    [EModifier.BeastMode]     = nil,
    [EModifier.InfiniteCombo] = nil,
    [EModifier.ScaleCycle]    = nil,
    [EModifier.BigBrain]      = nil,
    [EModifier.Penetrator]    = nil,
}

---@type table<EModifier, table<any, function?>?>
local modifierFunctions = {
    [EModifier.InfiniteMag]   = nil,
    [EModifier.SuperReload]   = nil,
    [EModifier.SuperAccuracy] = nil,
    [EModifier.SuperZoom]     = nil,
    [EModifier.SuperRange]    = nil,
    [EModifier.NoRecoil]      = nil,
    [EModifier.UltraKill]     = nil,
    [EModifier.PsychoMode]    = nil,
    [EModifier.BeastMode]     = nil,
    [EModifier.InfiniteCombo] = nil,
    [EModifier.ScaleCycle]    = nil,
    [EModifier.BigBrain]      = nil,
    [EModifier.Penetrator]    = nil,
}

--Declare what type modifiers apply to
---@type table<EModifier, EModifierType>
local modifierType = {
    [EModifier.InfiniteMag]   = EModifierType.Ranged,
    [EModifier.SuperReload]   = EModifierType.Ranged,
    [EModifier.SuperAccuracy] = EModifierType.Ranged,
    [EModifier.SuperZoom]     = EModifierType.Ranged,
    [EModifier.SuperRange]    = EModifierType.Ranged,
    [EModifier.NoRecoil]      = EModifierType.Ranged,
    [EModifier.UltraKill]     = EModifierType.Both,
    [EModifier.PsychoMode]    = EModifierType.Ranged,
    [EModifier.BeastMode]     = EModifierType.Melee,
    [EModifier.InfiniteCombo] = EModifierType.Player,
    [EModifier.ScaleCycle]    = EModifierType.Ranged,
    [EModifier.BigBrain]      = EModifierType.SmartRanged,
    [EModifier.Penetrator]    = EModifierType.Ranged,
}

local EnumName = CUtil.EnumName

---@param modifier EModifier
---@return EModifierType
local function GetModifierType(modifier)
    return modifierType[modifier]
end

---@param mType EModifierType
---@return boolean
local function IsModifierTypeEvoSpecific(mType)
    local modtypes = { EModifierType.SmartRanged, EModifierType.PowerRanged, EModifierType.TechRanged }
    local retVal, _ = CUtil.Exists(modtypes, mType)
    return retVal
end

---@param wItemID any
---@return EWeaponEvo
local function GetEWeaponEvo(wItemID)
    local wEvo = RPGManager.GetWeaponEvolution(wItemID)
    if wEvo == gamedataWeaponEvolution.Smart then return EWeaponEvo.Smart end
    if wEvo == gamedataWeaponEvolution.Power then return EWeaponEvo.Power end
    if wEvo == gamedataWeaponEvolution.Tech  then return EWeaponEvo.Tech  end
    return EWeaponEvo.Invalid
end

local function RefreshSystems()
    Ammo.player = Game.GetPlayer()
    Ammo.ts = Game.GetTransactionSystem()
    Ammo.ss = Game.GetStatsSystem()
end

function Ammo.Preload()
    TweakDBRecords = require("items/items").tweakDBRecords

    for _, v in pairs(TweakDBRecords) do
        if string.find(v:GetID().value, "Ammo.") and not string.find(v:GetID().value, "Items.") then
            table.insert(AmmoItems, ItemRecord(v))
        end
    end

    --Infinite mag
    modifierGroups[EModifier.InfiniteMag] = {
        RPGManager.CreateStatModifier(gamedataStatType.NumShotsToFire, gameStatModifierType.Multiplier, 0)
    }

    --Super Reload
    modifierGroups[EModifier.SuperReload] = {
        RPGManager.CreateStatModifier(gamedataStatType.ReloadTimeBase, gameStatModifierType.Multiplier, 0.2),
        RPGManager.CreateStatModifier(gamedataStatType.ReloadEndTime, gameStatModifierType.Multiplier, 0.1),
        RPGManager.CreateStatModifier(gamedataStatType.EmptyReloadTime, gameStatModifierType.Multiplier, 0.2),
        RPGManager.CreateStatModifier(gamedataStatType.EmptyReloadEndTime, gameStatModifierType.Multiplier, 0.1)
    }

    --Super Accuracy
    modifierGroups[EModifier.SuperAccuracy] = {
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMinX, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMinY, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMaxX, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMaxY, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMinX, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMinY, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMaxX, gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMaxY, gameStatModifierType.Multiplier, 0.05)
    }

    --Super Zoom
    modifierGroups[EModifier.SuperZoom] = {
        RPGManager.CreateStatModifier(gamedataStatType.ZoomLevel, gameStatModifierType.Multiplier, 5),
        RPGManager.CreateStatModifier(gamedataStatType.SwaySideMinimumAngleDistance, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SwaySideMaximumAngleDistance, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SwaySideTopAngleLimit, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SwayCenterMaximumAngleOffset, gameStatModifierType.Multiplier, 0)
    }

    --Super Zoom customisers
    modifierFunctions[EModifier.SuperZoom] = {
        [gamedataStatType.ZoomLevel.value] = function(_, ...)
            local configValue = Ammo.Util.configuration.weapModConf.superZoom.zoomLevel
            return gamedataStatType.ZoomLevel.value, configValue
        end
    }

    --Super Range
    modifierGroups[EModifier.SuperRange] = {
        RPGManager.CreateStatModifier(gamedataStatType.EffectiveRange, gameStatModifierType.Multiplier, 100),
        RPGManager.CreateStatModifier(gamedataStatType.MaximumRange, gameStatModifierType.Multiplier, 100)
    }

    --No Recoil
    modifierGroups[EModifier.NoRecoil] = {
        RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMin, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMax, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.RecoilUseDifferentStatsInADS, gameStatModifierType.Multiplier, 0)
    }

    --Ultra Kill Mode
    modifierGroups[EModifier.UltraKill] = {
        RPGManager.CreateStatModifier(gamedataStatType.CritChance, gameStatModifierType.Additive, 100),
        RPGManager.CreateStatModifier(gamedataStatType.CritDamage, gameStatModifierType.Additive, 10000)
    }

    --Psycho Mode
    modifierGroups[EModifier.PsychoMode] = {
        RPGManager.CreateStatModifier(gamedataStatType.CycleTime, gameStatModifierType.Multiplier, 0.2),
        RPGManager.CreateStatModifier(gamedataStatType.ProjectilesPerShot, gameStatModifierType.Additive, 10),
        RPGManager.CreateStatModifier(gamedataStatType.DamagePerHit, gameStatModifierType.Multiplier, 1)
    }

    --Psycho Mode customisers
    modifierFunctions[EModifier.PsychoMode] = {
        [gamedataStatType.CycleTime.value] = function(_, ...)
            local configValue = 1 / Ammo.Util.configuration.weapModConf.psychoMode.fireRate
            return gamedataStatType.CycleTime.value, configValue
        end,
        [gamedataStatType.ProjectilesPerShot.value] = function(statsObj, ...)
            local value = Ammo.ss:GetStatValue(statsObj, gamedataStatType.DamagePerHit)
            local configValue = Ammo.Util.configuration.weapModConf.psychoMode.projectiles
            return
                gamedataStatType.DamagePerHit.value, value,
                gamedataStatType.ProjectilesPerShot.value, configValue
        end,
        [gamedataStatType.DamagePerHit.value] = function(statsObj, ...)
            local initial = ({...})[1]
            local current = Ammo.ss:GetStatValue(statsObj, gamedataStatType.DamagePerHit)
            local mult = initial / current
            return gamedataStatType.DamagePerHit.value, mult
        end
    }

    --Beast Mode: HitDismembermentFactor only works for blades, for the most part. Blunt weapons can occasionally explode heads.
    modifierGroups[EModifier.BeastMode] = {
        RPGManager.CreateStatModifier(gamedataStatType.HitDismembermentFactor, gameStatModifierType.Additive, 10000),
        RPGManager.CreateStatModifier(gamedataStatType.BlockFactor, gameStatModifierType.Multiplier, 100),
        RPGManager.CreateStatModifier(gamedataStatType.StaminaCostReduction, gameStatModifierType.Additive, -2),
        RPGManager.CreateStatModifier(gamedataStatType.CanWeaponInfinitlyCombo, gameStatModifierType.Additive, 1)
    }

    --InfiniteCombo: Used together with BeastMode, applies to player not weapon
    modifierGroups[EModifier.InfiniteCombo] = {
        RPGManager.CreateStatModifier(gamedataStatType.CanMeleeInfinitelyCombo, gameStatModifierType.Additive, 1)
    }

    modifierGroups[EModifier.ScaleCycle] = {
        RPGManager.CreateStatModifier(gamedataStatType.CycleTime, gameStatModifierType.Multiplier, 1)
    }

    modifierFunctions[EModifier.ScaleCycle] = {
        [gamedataStatType.CycleTime.value] = function(_, ...)
            if not Ammo.Util.configuration.functions.psychoMode then
                local gTiDi = Ammo.Util.configuration.functions.slowMoDilation / 100
                local scale = CUtil.Clamp((gTiDi / (1 + (1 - gTiDi))), 0.01, 1)
                DEBUG_printl(LOG_LEVEL.Trace, "gTiDi:", gTiDi, "scale:", scale)
                return gamedataStatType.CycleTime.value, scale
            else
                return gamedataStatType.CycleTime.value, 1
            end
        end
    }

    modifierGroups[EModifier.BigBrain] = {
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunMaxLockedPointsPerTarget,   gameStatModifierType.Additive,   2),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsTimeToLock,              gameStatModifierType.Multiplier, 0.1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsMaxLockedTargets,        gameStatModifierType.Additive,   10),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipTimeToLock,              gameStatModifierType.Multiplier, 0.05),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipMaxLockedTargets,        gameStatModifierType.Additive,   10),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHitProbability,             gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunMissDelay,                  gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunMissRadius,                 gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunPlayerProjectileVelocity,   gameStatModifierType.Additive,   100),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunStartingAccuracy,           gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunTargetAcquisitionRange,     gameStatModifierType.Additive,   500),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunTrackMultipleEntitiesInADS, gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.DamagePerHit,                       gameStatModifierType.Multiplier, 1),

        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsLockingAnglePitch,       gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsLockingAngleYaw,         gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsTargetableAnglePitch,    gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunAdsTargetableAngleYaw,      gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipLockingAnglePitch,       gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipLockingAngleYaw,         gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipTargetableAnglePitch,    gameStatModifierType.Additive,   1),
        RPGManager.CreateStatModifier(gamedataStatType.SmartGunHipTargetableAngleYaw,      gameStatModifierType.Additive,   1),
    }

    local function getSmartReticleStatModifiers(stat, type)
        local additives = 0
        local additiveMults = 0

        if stat ~= nil then
            for _, v in pairs(stat.modifiers) do
                DEBUG_printl(LOG_LEVEL.Trace, "Stat:", type.value, "mod:", v.modifierType.value, "value:", v.value)
                if v.modifierType == gameStatModifierType.Additive then
                    additives = additives + v.value
                elseif v.modifierType == gameStatModifierType.AdditiveMultiplier then
                    additiveMults = additiveMults + v.value
                end
            end
            additiveMults = additiveMults + 1
        end

        return additives, additiveMults
    end

    local function calcSmartReticlePitch(statsObjID, ...)
        local type = ({...})[2]
        local stat = CUtil.GetObjectStatFromStatsID(statsObjID, type)
        local configValue = Ammo.Util.configuration.weapModConf.bigBrain.reticlePitch
        local additives, additiveMults = getSmartReticleStatModifiers(stat, type)
        local result = ((configValue / additiveMults) - additives)
        DEBUG_printl(LOG_LEVEL.Trace, "Additive total:", additives, "AddMult total:", additiveMults, "result:", result, "\n ")
        return type.value, result
    end

    local function calcSmartReticleYaw(statsObjID, ...)
        local type = ({...})[2]
        local stat = CUtil.GetObjectStatFromStatsID(statsObjID, type)
        local configValue = Ammo.Util.configuration.weapModConf.bigBrain.reticleYaw
        local additives, additiveMults = getSmartReticleStatModifiers(stat, type)
        local result = ((configValue / additiveMults) - additives)
        DEBUG_printl(LOG_LEVEL.Trace, "Additive total:", additives, "AddMult total:", additiveMults, "result:", result, "\n ")
        return type.value, result
    end

    modifierFunctions[EModifier.BigBrain] = {
        [gamedataStatType.SmartGunAdsLockingAnglePitch.value]     = calcSmartReticlePitch,
        [gamedataStatType.SmartGunAdsLockingAngleYaw.value]       = calcSmartReticleYaw,
        [gamedataStatType.SmartGunAdsTargetableAnglePitch.value]  = calcSmartReticlePitch,
        [gamedataStatType.SmartGunAdsTargetableAngleYaw.value]    = calcSmartReticleYaw,
        [gamedataStatType.SmartGunHipLockingAnglePitch.value]     = calcSmartReticlePitch,
        [gamedataStatType.SmartGunHipLockingAngleYaw.value]       = calcSmartReticleYaw,
        [gamedataStatType.SmartGunHipTargetableAnglePitch.value]  = calcSmartReticlePitch,
        [gamedataStatType.SmartGunHipTargetableAngleYaw.value]    = calcSmartReticleYaw,
        [gamedataStatType.SmartGunAdsMaxLockedTargets.value]      = function(_, ...)
            local configValue = Ammo.Util.configuration.weapModConf.bigBrain.maxLocks
            return gamedataStatType.SmartGunAdsMaxLockedTargets.value, configValue
        end,
        [gamedataStatType.SmartGunHipMaxLockedTargets.value]      = function(_, ...)
            local configValue = Ammo.Util.configuration.weapModConf.bigBrain.maxLocks
            return gamedataStatType.SmartGunHipMaxLockedTargets.value, configValue
        end,
        [gamedataStatType.SmartGunPlayerProjectileVelocity.value] = function(_, ...)
            local configValue = Ammo.Util.configuration.weapModConf.bigBrain.velocity
            return gamedataStatType.SmartGunPlayerProjectileVelocity.value, configValue
        end,
        [gamedataStatType.SmartGunTargetAcquisitionRange.value]   = function(_, ...)
            local configValue = Ammo.Util.configuration.weapModConf.bigBrain.range
            return gamedataStatType.SmartGunTargetAcquisitionRange.value, configValue
        end
    }

    modifierGroups[EModifier.Penetrator] = {
        RPGManager.CreateStatModifier(gamedataStatType.TechPierceEnabled, gameStatModifierType.Additive, 1),
        RPGManager.CreateStatModifier(gamedataStatType.CanWeaponIgnoreArmor, gameStatModifierType.Additive, 1)
    }

    modifierFunctions[EModifier.Penetrator] = {
        [gamedataStatType.TechPierceEnabled.value] = function(statsObjID, ...)
            local ss = Game.GetStatsSystem()
            local pierceVal = ss:GetStatValue(statsObjID, gamedataStatType.TechPierceEnabled)
            local returnVal = 1
            if pierceVal > 0 then returnVal = 0 end
            return gamedataStatType.TechPierceEnabled.value, returnVal
        end
    }
end

---@param modifier EModifier
---@param mType EModifierType
---@param enable boolean
---@param wType EWeaponType
---@param wStatsObjId any
local function ApplyWeaponModifiers(modifier, mType, enable, wType, wStatsObjId, wItemID)
    local intermediates = {}
    if mType == wType or mType == EModifierType.Both then
        DEBUG_printl(LOG_LEVEL.Trace,
            "\nmodifier:", modifier, EnumName(EModifier, modifier),
            "\nmType:", mType, EnumName(EModifierType, mType),
            "\nenable:", enable,
            "\nwType:", wType, EnumName(EWeaponType, wType),
            "\nID:", wItemID.id.value, "\n "
        )
        for _, v in pairs(modifierGroups[modifier]) do
            if enable then
                if modifierFunctions[modifier] ~= nil then
                    local func = modifierFunctions[modifier][v.statType.value]
                    if func ~= nil then
                        local ival = intermediates[v.statType.value]
                        local statType1, value1, statType2, value2 = func(wStatsObjId, ival, v.statType)
                        intermediates[statType1] = value1
                        if statType2 ~= nil and value2 ~= nil then
                            intermediates[statType2] = value2
                        end
                    end

                    local modVal = intermediates[v.statType.value]
                    if modVal ~= nil then
                        v.value = modVal
                    end
                end

                Ammo.ss:AddModifier(wStatsObjId, v)
            else
                Ammo.ss:RemoveModifier(wStatsObjId, v)
            end
        end
    end
end

---@param modifier EModifier
---@param mType EModifierType
---@param enable boolean
---@param tType ETargetType
local function ApplyOtherModifiers(modifier, mType, enable, tType)
    if mType == tType then
        local playerEnt = Game.GetPlayer():GetEntityID()
        for _, v in pairs(modifierGroups[modifier]) do
            if enable then
                Ammo.ss:AddModifier(playerEnt, v)
            else
                Ammo.ss:RemoveModifier(playerEnt, v)
            end
        end
    end
end

--wItemID is optional, if you pass nil, it'll get the currently equipped weapon
--If nothing is equipped, it does nothing
---@param modifier EModifier
---@param enable boolean
---@param wItemID? any
function Ammo.ChangeModifiers(modifier, enable, wItemID)
    RefreshSystems()
    local mType = GetModifierType(modifier)

    local filter = {
        EModifierType.Ranged,
        EModifierType.Melee,
        EModifierType.Both,
        EModifierType.SmartRanged,
        EModifierType.PowerRanged,
        EModifierType.TechRanged
    }

    if CUtil.Exists(filter, mType) then
        local wStatsObjId = nil
        local wItemData = nil
        local wType = nil

        if wItemID == nil then
            wItemData = Ammo.ts:GetItemInSlot(Ammo.player, TweakDBID.new('AttachmentSlots.WeaponRight'))
            if wItemData == nil then return end -- drop out if not holding a weapon
            wItemID = wItemData:GetItemID()
            wStatsObjId = wItemData:GetItemData():GetStatsObjectID()
        else
            wItemData = Ammo.ts:GetItemData(Ammo.player, wItemID)
            if wItemData == nil then return end
            wStatsObjId = wItemData:GetStatsObjectID()
        end

        local baseType, evoType
        if WeaponObject.IsRanged(wItemID) then
            baseType = EWeaponType.Ranged
            wType = baseType
            if IsModifierTypeEvoSpecific(mType) then
                evoType = GetEWeaponEvo(wItemID)
                wType = wType + evoType
            end
        elseif WeaponObject.IsMelee(wItemID) then
            wType = EWeaponType.Melee
        else
            wType = EWeaponType.Invalid
        end

        if wType ~= EWeaponType.Invalid then
            ApplyWeaponModifiers(modifier, mType, enable, wType, wStatsObjId, wItemID)
        end
    elseif mType ~= EModifierType.Invalid then
        local tType = nil
        if mType == EModifierType.Player then
            tType = ETargetType.Player
        else
            tType = ETargetType.Invalid
        end

        if tType ~= ETargetType.Invalid then
            ApplyOtherModifiers(modifier, mType, enable, tType)
        end
    end
end

function Ammo.EquipListener(wItemID)
    if Ammo.Util.configuration.functions.ammoInfiniteMag then
        Ammo.ChangeModifiers(EModifier.InfiniteMag, true, wItemID)
    end

    if Ammo.Util.configuration.functions.superReload then
        Ammo.ChangeModifiers(EModifier.SuperReload, true, wItemID)
    end

    if Ammo.Util.configuration.functions.superAccuracy then
        Ammo.ChangeModifiers(EModifier.SuperAccuracy, true, wItemID)
    end

    if Ammo.Util.configuration.functions.superZoom then
        Ammo.ChangeModifiers(EModifier.SuperZoom, true, wItemID)
    end

    if Ammo.Util.configuration.functions.superRange then
        Ammo.ChangeModifiers(EModifier.SuperRange, true, wItemID)
    end

    if Ammo.Util.configuration.functions.noRecoil then
        Ammo.ChangeModifiers(EModifier.NoRecoil, true, wItemID)
    end

    if Ammo.Util.configuration.functions.ultraKill then
        Ammo.ChangeModifiers(EModifier.UltraKill, true, wItemID)
    end

    if Ammo.Util.configuration.functions.psychoMode then
        Ammo.ChangeModifiers(EModifier.PsychoMode, true, wItemID)
    end

    if Ammo.Util.configuration.functions.beastMode then
        Ammo.ChangeModifiers(EModifier.BeastMode, true, wItemID)
        Ammo.ChangeModifiers(EModifier.InfiniteCombo, true, nil)
    end

    if Ammo.Util.configuration.functions.bigBrain then
        Ammo.ChangeModifiers(EModifier.BigBrain, true, wItemID)
    end

    if Ammo.Misc.slowMo and Ammo.Util.configuration.functions.slowMoScaleCycleTime then
        Ammo.ChangeModifiers(EModifier.ScaleCycle, true, wItemID)
    end

    if Ammo.Util.configuration.functions.penetrator then
        Ammo.ChangeModifiers(EModifier.Penetrator, true, wItemID)
    end
end

function Ammo.UnequipListener(wItemID)
    if Ammo.Util.configuration.functions.ammoInfiniteMag then
        Ammo.ChangeModifiers(EModifier.InfiniteMag, false, wItemID)
    end

    if Ammo.Util.configuration.functions.superReload then
        Ammo.ChangeModifiers(EModifier.SuperReload, false, wItemID)
    end

    if Ammo.Util.configuration.functions.superAccuracy then
        Ammo.ChangeModifiers(EModifier.SuperAccuracy, false, wItemID)
    end

    if Ammo.Util.configuration.functions.superZoom then
        Ammo.ChangeModifiers(EModifier.SuperZoom, false, wItemID)
    end

    if Ammo.Util.configuration.functions.superRange then
        Ammo.ChangeModifiers(EModifier.SuperRange, false, wItemID)
    end

    if Ammo.Util.configuration.functions.noRecoil then
        Ammo.ChangeModifiers(EModifier.NoRecoil, false, wItemID)
    end

    if Ammo.Util.configuration.functions.ultraKill then
        Ammo.ChangeModifiers(EModifier.UltraKill, false, wItemID)
    end

    if Ammo.Util.configuration.functions.psychoMode then
        Ammo.ChangeModifiers(EModifier.PsychoMode, false, wItemID)
    end

    if Ammo.Util.configuration.functions.beastMode then
        Ammo.ChangeModifiers(EModifier.BeastMode, false, wItemID)
        Ammo.ChangeModifiers(EModifier.InfiniteCombo, false, nil)
    end

    if Ammo.Util.configuration.functions.bigBrain then
        Ammo.ChangeModifiers(EModifier.BigBrain, false, wItemID)
    end

    if Ammo.Misc.slowMo and Ammo.Util.configuration.functions.slowMoScaleCycleTime then
        Ammo.ChangeModifiers(EModifier.ScaleCycle, false, wItemID)
    end

    if Ammo.Util.configuration.functions.penetrator then
        Ammo.ChangeModifiers(EModifier.Penetrator, false, wItemID)
    end
end

function Ammo.WeaponStateListener(state)
    RefreshSystems()
    local weapon = Ammo.ts:GetItemInSlot(Ammo.player, TweakDBID.new('AttachmentSlots.WeaponRight'))
    if weapon == nil then return end
    local gotAmmoType, ammoType = pcall(function() return WeaponObject.GetAmmoType(weapon) end)
    -- If the weapon is reloading, and the setting is on
    if state == 2 and Ammo.Util.configuration.functions.ammoInfiniteInv and gotAmmoType then
        local ammoItem = ItemRecord.IdSearch(AmmoItems, ammoType.id.value)
        if ammoItem ~= nil then
            ammoItem:AddSkipActivityLogTags()
            Ammo.ts:GiveItem(Ammo.player, ammoType, 1000)
            ammoItem:QueueTagUpdate()
        end
    elseif state == 2 and Ammo.Util.configuration.functions.ammoInfiniteInv and #AmmoItems > 0 then
        --we didn't find the ammo type, but can still add ammo discreetly (no activity log entries)
        CUtil.ArrayMap(AmmoItems, ItemRecord.AddSkipActivityLogTags)
        Ammo.ManualRefill()
        CUtil.ArrayMap(AmmoItems, ItemRecord.QueueTagUpdate)
    elseif state == 2 and Ammo.Util.configuration.functions.ammoInfiniteInv then
        --fuck it just give them max of everything, loudly (will show activity log entries)
        Ammo.ManualRefill()
    end
end

function Ammo.ManualRefill(msg)
    msg = msg or false
    Game.AddToInventory("Ammo.HandgunAmmo", 500)
    Game.AddToInventory("Ammo.RifleAmmo", 700)
    Game.AddToInventory("Ammo.ShotgunAmmo", 100)
    Game.AddToInventory("Ammo.SniperRifleAmmo", 100)
    if msg then print("[SimpleMenu] All ammo refilled") end
end

function Ammo.ToggleInfiniteAmmo()
    Ammo.Util.configuration.functions.ammoInfiniteInv = not Ammo.Util.configuration.functions.ammoInfiniteInv
    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Auto-Refill Ammo - Inventory:", Ammo.Util.configuration.functions.ammoInfiniteInv)
end

function Ammo.ToggleInfiniteAmmoNoReload()
    Ammo.Util.configuration.functions.ammoInfiniteMag = not Ammo.Util.configuration.functions.ammoInfiniteMag
    Ammo.ChangeModifiers(EModifier.InfiniteMag, Ammo.Util.configuration.functions.ammoInfiniteMag, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Infinite Magazine:", Ammo.Util.configuration.functions.ammoInfiniteMag)
end

function Ammo.ToggleSuperReload()
    Ammo.Util.configuration.functions.superReload = not Ammo.Util.configuration.functions.superReload
    Ammo.ChangeModifiers(EModifier.SuperReload, Ammo.Util.configuration.functions.superReload, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Super Reload:", Ammo.Util.configuration.functions.superReload)
end

function Ammo.ToggleSuperAccuracy()
    Ammo.Util.configuration.functions.superAccuracy = not Ammo.Util.configuration.functions.superAccuracy
    Ammo.ChangeModifiers(EModifier.SuperAccuracy, Ammo.Util.configuration.functions.superAccuracy, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Super Accuracy:", Ammo.Util.configuration.functions.superAccuracy)
end

function Ammo.ToggleSuperZoom()
    Ammo.Util.configuration.functions.superZoom = not Ammo.Util.configuration.functions.superZoom
    Ammo.ChangeModifiers(EModifier.SuperZoom, Ammo.Util.configuration.functions.superZoom, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Super Zoom:", Ammo.Util.configuration.functions.superZoom)
end

function Ammo.ToggleSuperRange()
    Ammo.Util.configuration.functions.superRange = not Ammo.Util.configuration.functions.superRange
    Ammo.ChangeModifiers(EModifier.SuperRange, Ammo.Util.configuration.functions.superRange, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Super Range:", Ammo.Util.configuration.functions.superRange)
end

function Ammo.ToggleNoRecoil()
    Ammo.Util.configuration.functions.noRecoil = not Ammo.Util.configuration.functions.noRecoil
    Ammo.ChangeModifiers(EModifier.NoRecoil, Ammo.Util.configuration.functions.noRecoil, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] No Recoil:", Ammo.Util.configuration.functions.noRecoil)
end

function Ammo.ToggleUltraKill()
    Ammo.Util.configuration.functions.ultraKill = not Ammo.Util.configuration.functions.ultraKill
    Ammo.ChangeModifiers(EModifier.UltraKill, Ammo.Util.configuration.functions.ultraKill, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Ultra Kill:", Ammo.Util.configuration.functions.ultraKill)
end

function Ammo.TogglePsychoMode()
    Ammo.Util.configuration.functions.psychoMode = not Ammo.Util.configuration.functions.psychoMode
    Ammo.ChangeModifiers(EModifier.PsychoMode, Ammo.Util.configuration.functions.psychoMode, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Psycho Mode:", Ammo.Util.configuration.functions.psychoMode)
end

function Ammo.ToggleBeastMode()
    Ammo.Util.configuration.functions.beastMode = not Ammo.Util.configuration.functions.beastMode
    Ammo.ChangeModifiers(EModifier.BeastMode, Ammo.Util.configuration.functions.beastMode, nil)
    Ammo.ChangeModifiers(EModifier.InfiniteCombo, Ammo.Util.configuration.functions.beastMode, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] Beast Mode:", Ammo.Util.configuration.functions.beastMode)
end

function Ammo.ToggleScaledCycleTime(enabled)
    Ammo.ChangeModifiers(EModifier.ScaleCycle, enabled, nil)
end

function Ammo.ToggleBigBrain()
    Ammo.Util.configuration.functions.bigBrain = not Ammo.Util.configuration.functions.bigBrain
    Ammo.ChangeModifiers(EModifier.BigBrain, Ammo.Util.configuration.functions.bigBrain, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] \"BigBrain\" Mode:", Ammo.Util.configuration.functions.bigBrain)
end

function Ammo.TogglePenetrator()
    Ammo.Util.configuration.functions.penetrator = not Ammo.Util.configuration.functions.penetrator
    Ammo.ChangeModifiers(EModifier.Penetrator, Ammo.Util.configuration.functions.penetrator, nil)

    Ammo.Util.SaveConfig()
    print("[SimpleMenu] The Penetrator:", Ammo.Util.configuration.functions.penetrator)
end

return Ammo