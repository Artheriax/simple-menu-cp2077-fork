local UIconfig = {}

UIconfig.Util = require("config/util")
UIconfig.Elements = require("ui/elements")
UIconfig.Search = require("ui/tabs/search")
UIconfig.Hotkey = require("config/hotkeys")
local Colour = require("classes/colour")
local CUtil = require("misc/cetUtils")
local started = true

--main tab
function UIconfig.TabConfig()
    ImGui.Text(UILabels.config.modVersion)
    UIconfig.Elements.QuickTooltip(UILabels.config.tModVersion, Colour.Info)
    ImGui.SameLine()
    ImGui.Text(tostring(UIconfig.Util.configuration.modVersion)..UIconfig.Util.T(UIconfig.Util.configuration.isBeta, " (beta)", ""))
    UIconfig.Elements.QuickTooltip(UILabels.config.tModVersion, Colour.Info)
    ImGui.Text(UILabels.config.version)
    UIconfig.Elements.QuickTooltip(UILabels.config.tVersion, Colour.Info)
    ImGui.SameLine()
    ImGui.Text(tostring(UIconfig.Util.configuration.version)..UIconfig.Util.T(UIconfig.Util.configuration.isBeta, " (beta)", ""))
    UIconfig.Elements.QuickTooltip(UILabels.config.tVersion, Colour.Info)
    --script pause
    ImGui.Text(UILabels.config.scriptpause)
    ImGui.SameLine()
    if (GameState.isPaused) then
        ImGui.TextColored(0.33, 1, 0.33, 1, UILabels.universalelements.returnTrue)
    else
        ImGui.TextColored(1, 0.33, 0.33, 1, UILabels.universalelements.returnFalse)
    end

    UIconfig.Elements.Separator()

    --main controls
    if (ImGui.Button(UILabels.config.reset)) then
        UIconfig.Util.ResetConfig()
    end
    ImGui.SameLine()
    UIconfig.Util.configuration.autoUI, ConfigPressed = ImGui.Checkbox(UILabels.config.autoUI, UIconfig.Util.configuration.autoUI)
    if (ConfigPressed) then
        UIconfig.Util.SaveConfig()
    end

    UIconfig.Elements.Separator()

    if started then -- always open this menu on init
        ImGui.SetNextItemOpen(true)
    end
    UIconfig.Elements.HeaderMenu(UILabels.config.globalConfig, UIconfig.GlobalConfig)

    UIconfig.Elements.Separator()

    if UIconfig.Util.configuration.menus.config.weapMods then
        ImGui.SetNextItemOpen(true)
    end
    UIconfig.Elements.CustomHeaderMenu(
        UILabels.config.weaponMods.header,
        UIconfig.WeaponModConfig,
        20,
        nil,
        nil,
        nil
    )

    UIconfig.Elements.Separator()

    if UIconfig.Util.configuration.menus.config.search then
        ImGui.SetNextItemOpen(true)
    end
    UIconfig.Elements.HeaderMenu(UILabels.search.tabnameExtended, UIconfig.SearchConfig)

    UIconfig.Elements.Separator()

    --Menu Config
    if (UIconfig.Util.configuration.menus.config.menus) then
        ImGui.SetNextItemOpen(true)
    end

    UIconfig.Elements.CustomHeaderMenu(
        UILabels.config.menus.header,
        UIconfig.MenuConfig,
        20,
        UILabels.config.menus.desc,
        Colour.Info,
        { --{ label: string, func: function }[]
            {
                label = UILabels.config.menus.allOff,
                func = function ()
                    UIconfig.ToggleAll(false)
                end
            },
            {
                label = UILabels.config.menus.allOn,
                func = function ()
                    UIconfig.ToggleAll(true)
                end
            },
        }
    )

    UIconfig.Elements.Separator()

    --Other Variables
    if (UIconfig.Util.configuration.menus.config.json) then
        ImGui.SetNextItemOpen(true)
    end
    UIconfig.Elements.HeaderMenu(UILabels.config.json.header, UIconfig.MenuJSON)

    if started then started = false end
end

function UIconfig.GlobalConfig()
    local UILangChanged
    UISelectedLang, UILangChanged = ImGui.Combo(UILabels.universalelements.language, UISelectedLang, UILangNames, #UILangNames)
    if UILangChanged then
        UIconfig.Util.SaveLanguageConfig({ selectedLang = UILangCodes[UISelectedLang + 1] })
        UILabels = LoadLabels(UILangCodes[UISelectedLang + 1])
        UIconfig.Search.Populate()
        LanguageReloadActions()
    end

    local EnablePopupPressed
    UIconfig.Util.configuration.popupsEnabled, EnablePopupPressed = ImGui.Checkbox(
        UILabels.config.cbEnablePopup,
        UIconfig.Util.configuration.popupsEnabled
    )
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.config.tEnablePopup)
    end
    if (EnablePopupPressed) then
        UIconfig.Util.SaveConfig()
    end

    local NotificationPressed
    UIconfig.Util.configuration.initNotification, NotificationPressed = ImGui.Checkbox(
        UILabels.config.cInitNotification,
        UIconfig.Util.configuration.initNotification
    )
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.config.tInitNotification)
    end
    if (NotificationPressed) then
        UIconfig.Util.SaveConfig()
    end

    local DebugPressed
    UIconfig.Util.configuration.debugMode, DebugPressed = ImGui.Checkbox(
        UILabels.config.cDebugMode,
        UIconfig.Util.configuration.debugMode
    )
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.config.tDebugMode)
    end
    if (DebugPressed) then
        DEBUG_MODE = UIconfig.Util.configuration.debugMode
        UIconfig.Util.SaveConfig()
    end

    ImGui.BeginDisabled(not UIconfig.Util.configuration.debugMode)
    local logLevelChanged
    UIconfig.Util.configuration.logLevel, logLevelChanged = ImGui.Combo(
        UILabels.config.cbLogLevel,
        UIconfig.Util.configuration.logLevel,
        UILabels.config.aLogLevels,
        #UILabels.config.aLogLevels
    )
    if (logLevelChanged) then
        SET_LOG_LEVEL(GetLogLevelValue(UIconfig.Util.configuration.logLevel))
        UIconfig.Util.SaveConfig()
    end
    UIconfig.Elements.QuickMultiTooltip({
        { text = UILabels.config.tLogLevel, colour = Colour.Info},
        { text = UILabels.config.tLogLevelInfo, colour = Colour.Positive},
        { text = UILabels.config.tLogLevelTrace, colour = Colour.Warning}
    })
    ImGui.EndDisabled()
end

function UIconfig.WeaponModConfig()
    local labels = UILabels.config.weaponMods
    local config = UIconfig.Util.configuration.weapModConf

    local bbHeading = labels.bigBrain.subheading
    if UIconfig.Util.configuration.functions.bigBrain then
        bbHeading = bbHeading..labels.deactivate
    end
    UIconfig.Elements.HeaderMenu(
        bbHeading,
        function()
            ImGui.BeginDisabled(UIconfig.Util.configuration.functions.bigBrain)
            local valueChange
            ImGui.Text(labels.bigBrain.reticlePitch)
            config.bigBrain.reticlePitch, valueChange = ImGui.SliderInt(
                "##slider"..labels.bigBrain.reticlePitch,
                config.bigBrain.reticlePitch,
                1,
                45,
                "%d°"
            )
            UIconfig.Elements.QuickMultiTooltip({
                { text = labels.bigBrain.tReticlePitch, colour = Colour.Info },
                { text = labels.bigBrain.tReticlePitchYaw1, colour = Colour.Warning },
                { text = labels.bigBrain.tReticlePitchYaw2, colour = Colour.Warning },
                { text = labels.bigBrain.tReticlePitchYaw3, colour = Colour.Warning },
            })
            ImGui.Spacing()

            ImGui.Text(labels.bigBrain.reticleYaw)
            config.bigBrain.reticleYaw, valueChange = ImGui.SliderInt(
                "##slider"..labels.bigBrain.reticleYaw,
                config.bigBrain.reticleYaw,
                1,
                45,
                "%d°"
            )
            UIconfig.Elements.QuickMultiTooltip({
                { text = labels.bigBrain.tReticleYaw, colour = Colour.Info },
                { text = labels.bigBrain.tReticlePitchYaw1, colour = Colour.Warning },
                { text = labels.bigBrain.tReticlePitchYaw2, colour = Colour.Warning },
                { text = labels.bigBrain.tReticlePitchYaw3, colour = Colour.Warning },
            })
            ImGui.Spacing()

            ImGui.Text(labels.bigBrain.velocity)
            config.bigBrain.velocity, valueChange = ImGui.SliderInt(
                "##slider"..labels.bigBrain.velocity,
                config.bigBrain.velocity,
                1,
                100
            )
            ImGui.Spacing()

            ImGui.Text(labels.bigBrain.range)
            config.bigBrain.range, valueChange = ImGui.SliderInt(
                "##slider"..labels.bigBrain.range,
                config.bigBrain.range,
                1,
                500
            )
            ImGui.Spacing()

            ImGui.Text(labels.bigBrain.maxLocks)
            config.bigBrain.maxLocks, valueChange = ImGui.SliderInt(
                "##slider"..labels.bigBrain.maxLocks,
                config.bigBrain.maxLocks,
                1,
                10
            )

            if valueChange then
                UIconfig.Util.SaveConfig()
            end
            ImGui.EndDisabled()
        end
    )

    ImGui.Spacing()

    local pmHeading = labels.psychoMode.subheading
    if UIconfig.Util.configuration.functions.psychoMode then
        pmHeading = pmHeading..labels.deactivate
    end
    UIconfig.Elements.HeaderMenu(
        pmHeading,
        function()
            ImGui.BeginDisabled(UIconfig.Util.configuration.functions.psychoMode)
            local valueChange
            ImGui.Text(labels.psychoMode.projectiles)
            config.psychoMode.projectiles, valueChange = ImGui.SliderInt(
                "##slider"..labels.psychoMode.projectiles,
                config.psychoMode.projectiles,
                1,
                10
            )
            ImGui.Spacing()

            ImGui.Text(labels.psychoMode.fireRate)
            config.psychoMode.fireRate, valueChange = ImGui.SliderInt(
                "##slider"..labels.psychoMode.fireRate,
                config.psychoMode.fireRate,
                1,
                10
            )
            UIconfig.Elements.QuickMultiTooltip({
                { text = labels.psychoMode.tFireRate1, colour = Colour.Info },
                { text = labels.psychoMode.tFireRate2, colour = Colour.Warning },
                { text = labels.psychoMode.tFireRate3, colour = Colour.Warning },
            })

            if valueChange then
                UIconfig.Util.SaveConfig()
            end
            ImGui.EndDisabled()
        end
    )

    ImGui.Spacing()

    local szheading = labels.superZoom.subheading
    if UIconfig.Util.configuration.functions.superZoom then
        szheading = szheading..labels.deactivate
    end
    UIconfig.Elements.HeaderMenu(
        szheading,
        function()
            ImGui.BeginDisabled(UIconfig.Util.configuration.functions.superZoom)
            local valueChange

            ImGui.Text(labels.superZoom.zoomLevel)
            config.superZoom.zoomLevel, valueChange = ImGui.SliderInt(
                "##slider"..labels.superZoom.zoomLevel,
                config.superZoom.zoomLevel,
                1,
                10
            )
            UIconfig.Elements.QuickTooltip(labels.superZoom.tZoomLevel, Colour.Info)

            if valueChange then
                UIconfig.Util.SaveConfig()
            end
            ImGui.EndDisabled()
        end
    )
end

function UIconfig.SearchConfig()
    --search tab
    UIconfig.Util.configuration.menuConfigs.search.loadingBar, LoadingBarPressed = ImGui.Checkbox(
        UILabels.config.cLoadingBar,
        UIconfig.Util.configuration.menuConfigs.search.loadingBar
    )
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.config.tLoadingBar)
    end
    if (LoadingBarPressed) then
        UIconfig.Util.SaveConfig()
    end

    ImGui.BeginDisabled(not (ModState.LoadingItemsState == LoadingState.NotLoaded or ModState.LoadingItemsState == LoadingState.Finished))
    UIconfig.Util.configuration.menuConfigs.search.loadingSpeed, LoadingSpeedChanged = ImGui.SliderInt(
        UILabels.config.sLoadingSpeed,
        UIconfig.Util.configuration.menuConfigs.search.loadingSpeed,
        100, 2000,
        "%d "..UILabels.config.sLoadingSpeedLabel
    )
    ImGui.EndDisabled()
    UIconfig.Elements.QuickMultiTooltip({
        { text = UILabels.config.tLoadingSpeed1, colour = Colour.Info },
        { text = UILabels.config.tLoadingSpeed2, colour = Colour.Warning }
    })
    if (LoadingSpeedChanged) then
        UIconfig.Util.configuration.menuConfigs.search.loadingSpeed = CUtil.Clamp(UIconfig.Util.configuration.menuConfigs.search.loadingSpeed, 100, 2000)
        UIconfig.Util.SaveConfig()
    end
end

--menu config menu
function UIconfig.MenuConfig()
    --config tab
    UIconfig.Elements.HeaderMenu(
        UILabels.config.tabname,
        function()
            UIconfig.Util.configuration.menus.config.weapMods, ConfigPressed = ImGui.Checkbox(UILabels.config.weaponMods.header.."##toggle", UIconfig.Util.configuration.menus.config.weapMods)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.config.search, ConfigPressed = ImGui.Checkbox(UILabels.search.tabnameExtended.."##toggle", UIconfig.Util.configuration.menus.config.search)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.config.menus, ConfigPressed = ImGui.Checkbox(UILabels.config.menus.header.."##toggle", UIconfig.Util.configuration.menus.config.menus)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.config.json, ConfigPressed = ImGui.Checkbox(UILabels.config.json.header.."##toggle", UIconfig.Util.configuration.menus.config.json)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
        end
    )

    ImGui.Spacing()

    --items tab
    UIconfig.Elements.HeaderMenu(
        UILabels.items.tabname,
        function()
            UIconfig.Util.configuration.menus.items.weaponMods, ConfigPressed = ImGui.Checkbox(UILabels.items.weaponMods.header, UIconfig.Util.configuration.menus.items.weaponMods)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.items.additems, ConfigPressed = ImGui.Checkbox(UILabels.items.additems.header, UIconfig.Util.configuration.menus.items.additems)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            --UIconfig.Util.configuration.menus.items.shop, ConfigPressed = ImGui.Checkbox(UILabels.items.shop.header, UIconfig.Util.configuration.menus.items.shop)
            --if (ConfigPressed) then
            --    UIconfig.Util.SaveConfig()
            --end
            UIconfig.Util.configuration.menus.items.equipment, ConfigPressed = ImGui.Checkbox(UILabels.items.equipment.header, UIconfig.Util.configuration.menus.items.equipment)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
        end
    )

    ImGui.Spacing()

    --player tab
    UIconfig.Elements.HeaderMenu(
        UILabels.player.tabname,
        function()
            UIconfig.Util.configuration.menus.player.mainCheats, ConfigPressed = ImGui.Checkbox(UILabels.player.god.menuHeading, UIconfig.Util.configuration.menus.player.mainCheats)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.player.modifiers, ConfigPressed = ImGui.Checkbox(UILabels.player.modifiers.menuHeading, UIconfig.Util.configuration.menus.player.modifiers)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.player.attributes, ConfigPressed = ImGui.Checkbox(UILabels.player.attributes.header, UIconfig.Util.configuration.menus.player.attributes)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.player.level, ConfigPressed = ImGui.Checkbox(UILabels.player.level.header, UIconfig.Util.configuration.menus.player.level)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.player.stats, ConfigPressed = ImGui.Checkbox(UILabels.player.stats.header, UIconfig.Util.configuration.menus.player.stats)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.player.perks, ConfigPressed = ImGui.Checkbox(UILabels.player.perks.header, UIconfig.Util.configuration.menus.player.perks)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
        end
    )

    ImGui.Spacing()

    --misc tab
    UIconfig.Elements.HeaderMenu(
        UILabels.misc.tabname,
        function()
            UIconfig.Util.configuration.menus.misc.police, ConfigPressed = ImGui.Checkbox(UILabels.misc.police.header, UIconfig.Util.configuration.menus.misc.police)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.quest, ConfigPressed = ImGui.Checkbox(UILabels.misc.quest.header, UIconfig.Util.configuration.menus.misc.quest)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.teleport, ConfigPressed = ImGui.Checkbox(UILabels.misc.teleport.header, UIconfig.Util.configuration.menus.misc.teleport)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.time, ConfigPressed = ImGui.Checkbox(UILabels.misc.time.header, UIconfig.Util.configuration.menus.misc.time)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.vehicles, ConfigPressed = ImGui.Checkbox(UILabels.misc.vehicles.header, UIconfig.Util.configuration.menus.misc.vehicles)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.breach, ConfigPressed = ImGui.Checkbox(UILabels.misc.breachProto.header, UIconfig.Util.configuration.menus.misc.breach)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
            UIconfig.Util.configuration.menus.misc.npc_other, ConfigPressed = ImGui.Checkbox(UILabels.misc.npc_other.header, UIconfig.Util.configuration.menus.misc.npc_other)
            if (ConfigPressed) then
                UIconfig.Util.SaveConfig()
            end
        end
    )
end

function UIconfig.MenuJSON()
    ImGui.Text(UILabels.config.json.desc1)
    ImGui.Text(UILabels.config.json.desc2)
    ImGui.Text(UILabels.config.json.desc3)

    UIconfig.Elements.Separator()

    UIconfig.CheckVariables()
end

function UIconfig.ToggleAllForTab(tab, enable)
    local table = UIconfig.Util.configuration.menus[tab]
    for k, _ in pairs(table) do
        table[k] = enable
    end
end

function UIconfig.ToggleAll(enable)
    local table = UIconfig.Util.configuration.menus
    for k, _ in pairs(table) do
        UIconfig.ToggleAllForTab(k, enable)
    end
    UIconfig.Util.SaveConfig()
end

function UIconfig.CheckVariables()
    ImGui.Text(UILabels.config.mainConfig..":")
    local baseTableUser = UIconfig.Util.configuration
    local baseTableDefault = UIconfig.Util.configurationDefault
    for k, v in UIconfig.Util.spairs(baseTableUser) do
        if (type(v) == "number" or type(v) == "boolean") and (k ~= "version" and k ~= "modVersion") then
            ImGui.Text("\t" .. k .. ":")
            ImGui.SameLine()
            if (baseTableUser[k] == baseTableDefault[k]) then
                ImGui.TextColored(0.33, 1, 0.33, 1, tostring(v))
            else
                ImGui.TextColored(1, 0.33, 0.33, 1, tostring(v))
            end
        end
    end

    ImGui.Text("\n"..UILabels.config.funcConfig..":")
    local tableUser = UIconfig.Util.configuration.functions
    local tableDefault = UIconfig.Util.configurationDefault.functions
    for k, v in UIconfig.Util.spairs(tableUser) do
        ImGui.Text("\t" .. k .. ":")
        if k ~= "quickTeleports" then
            ImGui.SameLine()
            if (tableUser[k] == tableDefault[k]) then
                ImGui.TextColored(0.33, 1, 0.33, 1, tostring(v))
            else
                ImGui.TextColored(1, 0.33, 0.33, 1, tostring(v))
            end
        else
            for _, q in pairs(v) do
                ImGui.Text("\t\t" .. q.name .. ":")
                ImGui.SameLine()
                local xx, yy, zz = CUtil.Round(q.loc[1], 2), CUtil.Round(q.loc[2], 2), CUtil.Round(q.loc[3], 2)
                ImGui.TextColored(0.33, 1, 0.33, 1, "(X = "..xx..", Y = "..yy..", Z = "..zz..")")
            end
        end
    end

    ImGui.Text("\n"..UILabels.config.tabConfig..":")
    for k, v in UIconfig.Util.spairs(UIconfig.Util.configuration.menuConfigs) do
        ImGui.Text("\t" .. k .. ":")
        for k1, v1 in UIconfig.Util.spairs(v) do
            local mTableDefault = UIconfig.Util.configurationDefault.menuConfigs[k]
            ImGui.Text("\t\t" .. k1 .. ":")
            ImGui.SameLine()
            if type(v1) == "number" then
                v1 = CUtil.Round(v1, 1)
            end
            if (v1 == mTableDefault[k1]) then
                ImGui.TextColored(0.33, 1, 0.33, 1, tostring(v1))
            else
                ImGui.TextColored(1, 0.33, 0.33, 1, tostring(v1))
            end
        end
    end
end

return UIconfig