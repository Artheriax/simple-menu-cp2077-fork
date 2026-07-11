local Hotkey = {}

Hotkey.Util = require("config/util")
Hotkey.UI = require("ui/main")
Hotkey.Ammo = require("items/ammo")
Hotkey.Shop = require("items/shop")
Hotkey.Player = require("player/player")
Hotkey.Misc = require("misc/misc")
Hotkey.Travel = require("misc/travel")

local t = Hotkey.Util.T

function Hotkey.RegisterCustom()

    registerHotkey("InfiniteAmmo", UILabels.hotkeys.AutoAmmoInv.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleInfiniteAmmo()
            SetNotification(UILabels.hotkeys.AutoAmmoInv.notification, Hotkey.Util.configuration.functions.ammoInfiniteInv)
        end
    end)

    registerHotkey("InfiniteAmmoNoReload", UILabels.hotkeys.AutoAmmoMag.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleInfiniteAmmoNoReload()
            SetNotification(UILabels.hotkeys.AutoAmmoMag.notification, Hotkey.Util.configuration.functions.ammoInfiniteMag)
        end
    end)

    registerHotkey("SuperReload", UILabels.hotkeys.SuperReload.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleSuperReload()
            SetNotification(UILabels.hotkeys.SuperReload.notification, Hotkey.Util.configuration.functions.superReload)
        end
    end)

    registerHotkey("SuperAccuracy", UILabels.hotkeys.SuperAccuracy.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleSuperAccuracy()
            SetNotification(UILabels.hotkeys.SuperAccuracy.notification, Hotkey.Util.configuration.functions.superAccuracy)
        end
    end)

    registerHotkey("SuperZoom", UILabels.hotkeys.SuperZoom.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleSuperZoom()
            SetNotification(UILabels.hotkeys.SuperZoom.notification, Hotkey.Util.configuration.functions.superZoom)
        end
    end)

    registerHotkey("SuperRange", UILabels.hotkeys.SuperRange.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleSuperRange()
            SetNotification(UILabels.hotkeys.SuperRange.notification, Hotkey.Util.configuration.functions.superRange)
        end
    end)

    registerHotkey("NoRecoil", UILabels.hotkeys.NoRecoil.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleNoRecoil()
            SetNotification(UILabels.hotkeys.NoRecoil.notification, Hotkey.Util.configuration.functions.noRecoil)
        end
    end)

    registerHotkey("UltraKill", UILabels.hotkeys.UltraKill.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleUltraKill()
            SetNotification(UILabels.hotkeys.UltraKill.notification, Hotkey.Util.configuration.functions.ultraKill)
        end
    end)

    registerHotkey("PsychoMode", UILabels.hotkeys.PsychoMode.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.TogglePsychoMode()
            SetNotification(UILabels.hotkeys.PsychoMode.notification, Hotkey.Util.configuration.functions.psychoMode)
        end
    end)

    registerHotkey("BeastMode", UILabels.hotkeys.BeastMode.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleBeastMode()
            SetNotification(UILabels.hotkeys.BeastMode.notification, Hotkey.Util.configuration.functions.beastMode)
        end
    end)

    registerHotkey("BigBrain", UILabels.hotkeys.BigBrain.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.ToggleBigBrain()
            SetNotification(UILabels.hotkeys.BigBrain.notification, Hotkey.Util.configuration.functions.bigBrain)
        end
    end)

    registerHotkey("ThePenetrator", UILabels.hotkeys.Penetrator.description, function()
        if (not GameState.isPaused) then
            Hotkey.Ammo.TogglePenetrator()
            SetNotification(UILabels.hotkeys.Penetrator.notification, Hotkey.Util.configuration.functions.penetrator)
        end
    end)

    registerHotkey("RefillAmmo", UILabels.hotkeys.RefillAmmo.description, function()
        Hotkey.Ammo.ManualRefill(true)
        SetNotification(UILabels.hotkeys.RefillAmmo.notification, UILabels.hotkeys.noteDone)
    end)

    --registerHotkey("ConvDrinkFood", UILabels.hotkeys.ConvDrinkFood.description, function()
    --    Hotkey.Shop.ConvertItem(0, 0)
    --    SetNotification(UILabels.hotkeys.ConvDrinkFood.notification, UILabels.hotkeys.noteDone)
    --end)
    --
    --registerHotkey("SellConsume", UILabels.hotkeys.SellConsume.description, function()
    --    Hotkey.Shop.ProcessItems(1, "sell")
    --    Hotkey.Shop.ProcessItems(2, "sell")
    --    Hotkey.Shop.ProcessItems(3, "sell")
    --    SetNotification(UILabels.hotkeys.SellConsume.notification, UILabels.hotkeys.noteDone)
    --end)
    --
    --registerHotkey("SellGrenades", UILabels.hotkeys.SellGrenades.description, function()
    --    Hotkey.Shop.ProcessItems(4, "sell")
    --    Hotkey.Shop.ProcessItems(5, "sell")
    --    Hotkey.Shop.ProcessItems(6, "sell")
    --    Hotkey.Shop.ProcessItems(7, "sell")
    --    SetNotification(UILabels.hotkeys.SellGrenades.notification, UILabels.hotkeys.noteDone)
    --end)
    --
    --registerHotkey("SellJunk", UILabels.hotkeys.SellJunk.description, function()
    --    Hotkey.Shop.ProcessItems(8, "sell")
    --    Hotkey.Shop.ProcessItems(9, "sell")
    --    SetNotification(UILabels.hotkeys.SellJunk.notification, UILabels.hotkeys.noteDone)
    --end)
    --
    --registerHotkey("SellAll", UILabels.hotkeys.SellAll.description, function()
    --    Hotkey.Shop.SellAll()
    --    SetNotification(UILabels.hotkeys.SellAll.notification, UILabels.hotkeys.noteDone)
    --end)

    registerHotkey("GodMode", UILabels.hotkeys.GodMode.description, function()
        if (not GameState.isPaused) then
            Hotkey.Player.ToggleGodMode()
            SetNotification(UILabels.hotkeys.GodMode.notification, Hotkey.Util.configuration.functions.godMode)
        end
    end)

    registerHotkey("InfStamina", UILabels.hotkeys.InfStamina.description, function()
        if (not GameState.isPaused) then
            Hotkey.Player.ToggleInfiniteStamina()
            SetNotification(UILabels.hotkeys.InfStamina.notification, Hotkey.Util.configuration.functions.infStamina)
        end
    end)

    registerHotkey("InfOxy", UILabels.hotkeys.InfOxy.description, function()
        if (not GameState.isPaused) then
            Hotkey.Player.ToggleInfiniteOxygen()
            SetNotification(UILabels.hotkeys.InfOxy.notification, Hotkey.Util.configuration.functions.infOxy)
        end
    end)

    registerHotkey("Invisibility", UILabels.hotkeys.Invisibility.description, function()
        if (not GameState.isPaused) then
            ModState.SVars.Invisibility = not ModState.SVars.Invisibility
            SetNotification(UILabels.hotkeys.Invisibility.notification, Hotkey.Player.ToggleInvisibility(ModState.SVars.Invisibility))
        end
    end)

    registerHotkey("KillNPC", UILabels.hotkeys.KillNPC.description, function()
        if (not GameState.isPaused) then
            Hotkey.Misc.Kill()
            SetNotification(UILabels.hotkeys.KillNPC.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("PoliceToggle", UILabels.hotkeys.PoliceToggle.description, function()
        if (not GameState.isPaused) then
            Hotkey.Misc.PoliceToggle()
            SetNotification(UILabels.hotkeys.PoliceToggle.notification, Hotkey.Util.configuration.functions.disablePolice)
        end
    end)

    registerHotkey("PoliceHeatPlus", UILabels.hotkeys.PoliceHeatPlus.description, function()
        if (not GameState.isPaused) then
            local succ = Hotkey.Misc.PoliceLevelStep(1)
            if succ then
                SetNotification(UILabels.hotkeys.PoliceHeatPlus.notification, true)
            else
                SetNotification(UILabels.hotkeys.policeDisabled, false)
            end
        end
    end)

    registerHotkey("PoliceHeatMinus", UILabels.hotkeys.PoliceHeatMinus.description, function()
        if (not GameState.isPaused) then
            local succ = Hotkey.Misc.PoliceLevelStep(-1)
            if succ then
                SetNotification(UILabels.hotkeys.PoliceHeatMinus.notification, true)
            else
                SetNotification(UILabels.hotkeys.policeDisabled, false)
            end
        end
    end)

    registerHotkey("BreachProtocolTimer", UILabels.hotkeys.BreachProtocol.description, function()
        Hotkey.Misc.bpOptions.infBPTime = not Hotkey.Misc.bpOptions.infBPTime
        Hotkey.Misc.CheckBPTimerState()
        SetNotification(UILabels.hotkeys.BreachProtocol.notification, Hotkey.Misc.bpOptions.infBPTime)
    end)

    registerHotkey("Untrack", UILabels.hotkeys.Untrack.description, function()
        if (not GameState.isPaused) then
            Hotkey.Misc.Untrack()
            SetNotification(UILabels.hotkeys.Untrack.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("QuickTelSave", UILabels.hotkeys.QuickTelSave.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.SaveCurrentPos()
            SetNotification(UILabels.hotkeys.QuickTelSave.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("QuickTelMove", UILabels.hotkeys.QuickTelMove.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.MoveSavedPos()
            SetNotification(UILabels.hotkeys.QuickTelMove.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("QuickTel1", UILabels.hotkeys.QuickTel1.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.Teleport("quick", "apartment", 1)
            SetNotification(UILabels.hotkeys.QuickTel1.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("QuickTel2", UILabels.hotkeys.QuickTel2.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.Teleport("quick", "viktor", 1)
            SetNotification(UILabels.hotkeys.QuickTel2.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("DoorBuster", UILabels.hotkeys.DoorBuster.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.JumpForward(ModState.SVars.JumpDist)
            SetNotification(UILabels.hotkeys.DoorBuster.notification, UILabels.hotkeys.noteDone)
        end
    end)

    registerHotkey("FreezeTime", UILabels.hotkeys.FreezeTime.description, function()
        if (not GameState.isPaused) then
            Hotkey.Misc.FreezeTime()
            SetNotification(UILabels.hotkeys.FreezeTime.notification, Hotkey.Util.configuration.functions.freezeTime)
        end
    end)

    registerHotkey("SlowMo", UILabels.hotkeys.SlowMo.description, function()
        if (not GameState.isPaused) then
            local effectIndex = Hotkey.Util.configuration.functions.slowMoEffect + 1
            local effect = string.lower(UILabels.misc.time.cSlowMoEffects[effectIndex]:gsub("nz", "zn"))
            DEBUG_printl(LOG_LEVEL.Trace, "Effect:", effect)
            Hotkey.Misc.SlowMotion(effect)
            SetNotification(UILabels.hotkeys.SlowMo.notification, Hotkey.Misc.slowMo)
            Hotkey.UI.Misc.slowMoHeaderText = t(Hotkey.Misc.slowMo, UILabels.misc.time.tSlowMoLabelDisabled, UILabels.misc.time.tSlowMoLabelEnabled)
            if (Hotkey.Util.configuration.functions.slowMoScaleCycleTime) then
                DEBUG_printl(LOG_LEVEL.Info, "Toggling cycle time cheat to:", Hotkey.Misc.slowMo)
                Hotkey.Ammo.ToggleScaledCycleTime(Hotkey.Misc.slowMo)
            end
        end
    end)

    registerHotkey("SlowMoSelf", UILabels.hotkeys.SlowMoSelf.description, function()
        if (not GameState.isPaused) then
            Hotkey.Misc.SlowMotionSelf()
            SetNotification(UILabels.hotkeys.SlowMoSelf.notification, Hotkey.Misc.applyToSelf)
        end
    end)

    registerHotkey("SlowMoDilationPlus", UILabels.hotkeys.SlowMoDilationPlus.description, function()
        if (not GameState.isPaused) then
            if (not Hotkey.Misc.slowMo) then
                Hotkey.Misc.SlowMoDilPlus()
                SetNotification(UILabels.hotkeys.SlowMoDilationPlus.notification, tostring(Hotkey.Util.configuration.functions.slowMoDilation).."%")
            else
                SetNotification(UILabels.hotkeys.SlowMoDilationDisabled.notification, "")
            end
        end
    end)

    registerHotkey("SlowMoDilationMinus", UILabels.hotkeys.SlowMoDilationMinus.description, function()
        if (not GameState.isPaused) then
            if (not Hotkey.Misc.slowMo) then
                Hotkey.Misc.SlowMoDilMinus()
                SetNotification(UILabels.hotkeys.SlowMoDilationMinus.notification, tostring(Hotkey.Util.configuration.functions.slowMoDilation).."%")
            else
                SetNotification(UILabels.hotkeys.SlowMoDilationDisabled.notification, "")
            end
        end
    end)

    registerHotkey("VehicSpawn", UILabels.hotkeys.VehicSpawn.description, function()
        if (not GameState.isPaused) then
            Hotkey.Travel.ToggleVehicleSpawn()
            SetNotification(UILabels.hotkeys.VehicSpawn.notification, UILabels.hotkeys.noteDone)
        end
    end)
end

return Hotkey