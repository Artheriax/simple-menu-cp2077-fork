local UIitems = {
    moneyamount = 1000,
    itemamount = 1,
    itemcategory = 0,
    itemtypelist = {},
    itemtype = 0,
    drinktype = 0,
    foodtype = 0,
    selltype = 0,
    upgradequality = 0,
    upgradetype = 0,
    upgrademode = 0,
    modupgradetype = 0,
    modupgradequality = 0,
    -- "Remove Duplicates" feature: per-category checkbox state.
    -- Initialized lazily on first render of the equipment section.
    dupeCats = {},
    dupeCatsInitialized = false,
    dupeResultText = "",
    dupeResultColour = nil,
    -- Match options — control which properties must match for two items to be
    -- considered duplicates. All default to true (strict matching). Unchecking
    -- one loosens the matching for that property.
    dupeMatchQuality = true,
    dupeMatchLevel = true,
    dupeMatchMods = true,
    -- Which duplicate to keep: 0 = first found, 1 = highest quality, 2 = lowest quality
    dupeKeepMode = 1
}

local itemcategorykeylist = {
    "consumable",
    "material",
    "skillbook"
}

UIitems.Util = require("config/util")
UIitems.Elements = require("ui/elements")
UIitems.Ammo = require("items/ammo")
UIitems.Items = require("items/items")
UIitems.Shop = require("items/shop")
UIitems.Upgrade = require("items/upgrade")
UIitems.CUtil = require("misc/cetUtils")
local Colour = require("classes/colour")

--main tab
function UIitems.TabItems()
    _, InfAmmo1Pressed = ImGui.Checkbox(UILabels.items.ammo.bAutoInv, UIitems.Util.configuration.functions.ammoInfiniteInv)
    if (InfAmmo1Pressed) then
        UIitems.Ammo.ToggleInfiniteAmmo()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.ammo.tAutoInv)
    end

    _, InfAmmo2Pressed = ImGui.Checkbox(UILabels.items.ammo.bAutoMag, UIitems.Util.configuration.functions.ammoInfiniteMag)
    if (InfAmmo2Pressed) then
        UIitems.Ammo.ToggleInfiniteAmmoNoReload()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.ammo.tAutoMag)
    end

    UIitems.Elements.Separator()

    if (ImGui.Button(UILabels.items.ammo.bManual)) then
        UIitems.Ammo.ManualRefill(true)
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.ammo.tManual)
    end

    UIitems.Elements.Separator()

    --Weapon Mods
    if (UIitems.Util.configuration.menus.items.weaponMods) then
        ImGui.SetNextItemOpen(true)
    end
    UIitems.Elements.HeaderMenu(UILabels.items.weaponMods.header, UIitems.MenuWeaponMods)

    UIitems.Elements.Separator()

    --Add Items
    if (UIitems.Util.configuration.menus.items.additems) then
        ImGui.SetNextItemOpen(true)
    end
    UIitems.Elements.HeaderMenu(UILabels.items.additems.header, UIitems.MenuAddItems)

    UIitems.Elements.Separator()

    --Shop - Convert, Dismantle and Sell
    --if (UIitems.Util.configuration.menus.items.shop) then
    --    ImGui.SetNextItemOpen(true)
    --end
    --UIitems.Elements.HeaderMenu(UILabels.items.shop.header, UIitems.MenuShop)

    --UIitems.Elements.Separator()

    --Equipment Modification
    if (UIitems.Util.configuration.menus.items.equipment) then
        ImGui.SetNextItemOpen(true)
    end
    UIitems.Elements.HeaderMenu(UILabels.items.equipment.header, UIitems.MenuEquipment)
end

function UIitems.MenuWeaponMods()
    _, SuperReloadPressed = ImGui.Checkbox(UILabels.items.weaponMods.bSuperReload, UIitems.Util.configuration.functions.superReload)
    if (SuperReloadPressed) then
        UIitems.Ammo.ToggleSuperReload()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tSuperReload)
    end

    _, SuperAccuracyPressed = ImGui.Checkbox(UILabels.items.weaponMods.bSuperAcc, UIitems.Util.configuration.functions.superAccuracy)
    if (SuperAccuracyPressed) then
        UIitems.Ammo.ToggleSuperAccuracy()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tSuperAcc)
    end

    _, SuperZoomPressed = ImGui.Checkbox(UILabels.items.weaponMods.bSuperZoom, UIitems.Util.configuration.functions.superZoom)
    if (SuperZoomPressed) then
        UIitems.Ammo.ToggleSuperZoom()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tSuperZoom)
    end

    _, SuperRangePressed = ImGui.Checkbox(UILabels.items.weaponMods.bSuperRange, UIitems.Util.configuration.functions.superRange)
    if (SuperRangePressed) then
        UIitems.Ammo.ToggleSuperRange()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tSuperRange)
    end

    _, NoRecoilPressed = ImGui.Checkbox(UILabels.items.weaponMods.bNoRecoil, UIitems.Util.configuration.functions.noRecoil)
    if (NoRecoilPressed) then
        UIitems.Ammo.ToggleNoRecoil()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tNoRecoil)
    end

    _, UltraKillPressed = ImGui.Checkbox(UILabels.items.weaponMods.bUltraKill, UIitems.Util.configuration.functions.ultraKill)
    if (UltraKillPressed) then
        UIitems.Ammo.ToggleUltraKill()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tUltraKill)
    end

    _, PsychoModePressed = ImGui.Checkbox(UILabels.items.weaponMods.bPsychoMode, UIitems.Util.configuration.functions.psychoMode)
    if (PsychoModePressed) then
        UIitems.Ammo.TogglePsychoMode()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tPsychoMode)
    end

    _, BeastModePressed = ImGui.Checkbox(UILabels.items.weaponMods.bBeastMode, UIitems.Util.configuration.functions.beastMode)
    if (BeastModePressed) then
        UIitems.Ammo.ToggleBeastMode()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.weaponMods.tBeastMode)
    end

    _, BigBrainPressed = ImGui.Checkbox(UILabels.items.weaponMods.bBigBrain, UIitems.Util.configuration.functions.bigBrain)
    if (BigBrainPressed) then
        UIitems.Ammo.ToggleBigBrain()
    end
    UIitems.Elements.QuickMultiTooltip({
        { text = UILabels.items.weaponMods.tBigBrain, colour = Colour.Positive },
        { text = UILabels.items.weaponMods.tBigBrain2, colour = Colour.Warning }
    })

    _, PenetratorPressed = ImGui.Checkbox(UILabels.items.weaponMods.bPenetrator, UIitems.Util.configuration.functions.penetrator)
    UIitems.Elements.QuickTooltip(
        UILabels.items.weaponMods.tPenetrator,
        Colour.Positive
    )
    if (PenetratorPressed) then
        UIitems.Ammo.TogglePenetrator()
    end
end

--Add Items
function UIitems.MenuAddItems()
    ImGui.BeginDisabled(not GameState.isLoaded)
    UIitems.Elements.InGameWarning()

    UIitems.Elements.SectionHeading(UILabels.items.additems.tMoneySection, Colour.Info, false)
    --Money
    UIitems.moneyamount = ImGui.InputInt(UILabels.universalelements.amount.."##money", UIitems.moneyamount, 100, 1000)
    if (ImGui.Button(UILabels.items.additems.bMoney)) then
        UIitems.Items.AddMoney(UIitems.moneyamount)
    end

    -- ADD ITEMS FROM TweakDB LISTS
    UIitems.Elements.SectionHeading(UILabels.items.additems.tItemsSection, Colour.Info)
    UIitems.itemamount = ImGui.InputInt(
        UILabels.universalelements.amount.."##item",
        UIitems.itemamount,
        1,
        10
    )

    local categoryChanged
    UIitems.itemcategory, categoryChanged = ImGui.Combo(
        UILabels.universalelements.category.."##item",
        UIitems.itemcategory,
        UILabels.items.additems.categories,
        #UILabels.items.additems.categories
    )

    if(categoryChanged) then
        local listKey = itemcategorykeylist[UIitems.itemcategory]
        UIitems.itemtype = 0
        if listKey ~= nil then
            UIitems.itemtypelist = UIitems.Items.itemnames[listKey]
        else
            UIitems.itemtypelist = {}
        end
    end

    ImGui.BeginDisabled(#UIitems.itemtypelist == 0)
    UIitems.itemtype, _ = ImGui.Combo(
        UILabels.universalelements.type.."##item",
        UIitems.itemtype,
        UIitems.itemtypelist,
        #UIitems.itemtypelist
    )
    ImGui.EndDisabled()

    ImGui.BeginDisabled(UIitems.itemcategory == 0 or UIitems.itemtype == 0)
    if (ImGui.Button(UILabels.items.additems.bItemSelected)) then
        local listKey = itemcategorykeylist[UIitems.itemcategory]
        UIitems.Items.AddItem(
            listKey,
            UIitems.itemtype,
            UIitems.itemamount
        )
    end
    ImGui.EndDisabled()

    ImGui.SameLine()

    ImGui.BeginDisabled(UIitems.itemcategory == 0)
    if (ImGui.Button(UILabels.items.additems.bItemAll)) then
        local listKey = itemcategorykeylist[UIitems.itemcategory]
        UIitems.Items.AddCategory(
            listKey,
            UIitems.itemamount
        )
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.additems.tItemAll)
    end
    ImGui.EndDisabled()
    ImGui.EndDisabled()
end

--Shop
function UIitems.MenuShop()
    UIitems.drinktype = ImGui.Combo(UILabels.items.shop.drinktype, UIitems.drinktype, UIitems.Util.ProcessLabels("item", "drink"))
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.converttooltip)
    end
    UIitems.foodtype = ImGui.Combo(UILabels.items.shop.foodtype, UIitems.foodtype, UIitems.Util.ProcessLabels("item", "food"))
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.converttooltip)
    end
    if (ImGui.Button(UILabels.items.shop.convertbutton)) then
        UIitems.Shop.ConvertItem(UIitems.drinktype, UIitems.foodtype)
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.converttooltip)
    end

    UIitems.Elements.Separator()

    UIitems.selltype = ImGui.Combo(UILabels.universalelements.type.."##sell", UIitems.selltype, UIitems.Util.ProcessLabels("item", "sell"))
    if (ImGui.Button(UILabels.items.shop.bDisaSelected)) then
        UIitems.Shop.ProcessItems(UIitems.selltype, "disassemble")
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bDisaSelectedTooltip)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.shop.bSellSelected)) then
        UIitems.Shop.ProcessItems(UIitems.selltype, "sell")
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bSellSelectedTooltip)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.shop.bSellAll)) then
        UIitems.Shop.SellAll()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bSellAllTooltip)
    end
    if (ImGui.Button(UILabels.items.shop.bSellConsume)) then
        UIitems.Shop.ProcessItems(1, "sell")
        UIitems.Shop.ProcessItems(2, "sell")
        UIitems.Shop.ProcessItems(3, "sell")
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bSellConsumeTooltip)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.shop.bSellGrenade)) then
        UIitems.Shop.ProcessItems(4, "sell")
        UIitems.Shop.ProcessItems(5, "sell")
        UIitems.Shop.ProcessItems(6, "sell")
        UIitems.Shop.ProcessItems(7, "sell")
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bSellGrenadeTooltip)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.shop.bSellJunk)) then
        UIitems.Shop.ProcessItems(8, "sell")
        UIitems.Shop.ProcessItems(9, "sell")
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.shop.bSellJunkTooltip)
    end
end

--Equipment
function UIitems.MenuEquipment()
    UIitems.Elements.SectionHeading(UILabels.items.equipment.tItemActions, Colour.Info, false)
    if (ImGui.Button(UILabels.items.unequip.button)) then
        UIitems.Items.UnequipItems()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.unequip.tooltip)
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.questtag.button)) then
        UIitems.Upgrade.RemoveQuest()
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.questtag.tooltip)
    end

    UIitems.Elements.SectionHeading(UILabels.items.equipment.tItemUpgrades, Colour.Info)
    --equipment upgrade
    UIitems.upgrademode = ImGui.Combo(UILabels.universalelements.mode.."##equipment", UIitems.upgrademode, UIitems.Util.ProcessLabels("item", "upgrademode"))
    UIitems.upgradetype = ImGui.Combo(UILabels.universalelements.type.."##equipment", UIitems.upgradetype, UIitems.Util.ProcessLabels("item", "upgradetype"))
    UIitems.upgradequality = ImGui.Combo(UILabels.universalelements.quality.."##equipment", UIitems.upgradequality, UIitems.Util.ProcessLabels("item", "modupgradequality"))
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.equipment.tEquipQual)
    end
    ImGui.Spacing()
    if (ImGui.Button(UILabels.items.equipment.bEquipUpgr)) then
        UIitems.Upgrade.ChangeQuality(UIitems.upgradequality, UIitems.upgradetype, UIitems.upgrademode)
    end

    UIitems.Elements.SectionHeading(UILabels.items.equipment.tInventoryActions, Colour.Critical)
    UIitems.modupgradequality = ImGui.Combo(UILabels.universalelements.quality.."##mod", UIitems.modupgradequality, UIitems.Util.ProcessLabels("item", "modupgradequality"))

    local forceBtnX = UIitems.CUtil.GetButtonWidth(ModState.SVars.Timers.ForceInv)
    local forceAllClicked = (ImGui.Button(ModState.SVars.Timers.ForceInv.Text, forceBtnX, 0) and UIitems.modupgradequality ~= 0)
    local forceAllTime = ModState.SVars.Timers.ForceInv.Time
    TimedButton(
        forceAllClicked,
        ModState.SVars.Timers.ForceInv,
        {
            { text = UILabels.items.equipment.tUpgradeAll1, colour = Colour.Warning },
            { text = UILabels.items.equipment.tUpgradeAll2, colour = Colour.Critical },
            { text = UIitems.CUtil.GetTimedWarn(forceAllTime), colour = Colour.Critical },
            { text = UILabels.items.equipment.tUpgradeAll3, colour = Colour.Info }
        },
        UIitems.Upgrade.UpgradeAll,
        UIitems.modupgradequality
    )

    -- Remove Duplicates section
    UIitems.Elements.SectionHeading(UILabels.items.equipment.tRemoveDupes, Colour.Warning)
    UIitems.Elements.QuickTooltip(UILabels.items.equipment.tRemoveDupesDesc, Colour.Info)

    -- Lazily initialise the per-category checkbox state on first render
    if not UIitems.dupeCatsInitialized then
        local cats = UIitems.Upgrade.GetDupeCategories and UIitems.Upgrade.GetDupeCategories() or {}
        for _, cat in ipairs(cats) do
            UIitems.dupeCats[cat] = false
        end
        UIitems.dupeCatsInitialized = true
    end

    -- "Select All" / "Deselect All" convenience buttons
    local catOrder = UIitems.Upgrade.GetDupeCategories and UIitems.Upgrade.GetDupeCategories() or {}
    if (ImGui.Button(UILabels.items.equipment.bSelectAllDupes.."##dupeSelAll")) then
        for _, cat in ipairs(catOrder) do
            UIitems.dupeCats[cat] = true
        end
    end
    ImGui.SameLine()
    if (ImGui.Button(UILabels.items.equipment.bDeselectAllDupes.."##dupeDeselAll")) then
        for _, cat in ipairs(catOrder) do
            UIitems.dupeCats[cat] = false
        end
    end
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.equipment.tRemoveDupesDesc)
    end

    -- Render a compact grid of category checkboxes (2 per row to fit the narrow menu)
    local catLabels = {
        Weapons     = UILabels.items.equipment.catWeapons,
        Clothing    = UILabels.items.equipment.catClothing,
        Cyberware   = UILabels.items.equipment.catCyberware,
        Consumables = UILabels.items.equipment.catConsumables,
        Materials   = UILabels.items.equipment.catMaterials,
        Grenades    = UILabels.items.equipment.catGrenades,
        Junk        = UILabels.items.equipment.catJunk,
        Mods        = UILabels.items.equipment.catMods
    }
    for i, cat in ipairs(catOrder) do
        local changed, newVal
        UIitems.dupeCats[cat], changed = ImGui.Checkbox(catLabels[cat].."##dupeCat"..cat, UIitems.dupeCats[cat] or false)
        -- Two checkboxes per row
        if i % 2 == 1 and i < #catOrder then
            ImGui.SameLine()
        end
    end

    ImGui.Spacing()

    -- Match options: control which properties must match for two items to be
    -- considered duplicates. All default to true (strict matching). Unchecking
    -- one loosens the matching — e.g. uncheck "Match item level" to treat a
    -- level-10 DR5 Nova and a level-50 DR5 Nova as duplicates.
    UIitems.Elements.Text(UILabels.items.equipment.tMatchOptions, true, true, Colour.Disabled, 1)

    UIitems.dupeMatchQuality, _ = ImGui.Checkbox(UILabels.items.equipment.bMatchQuality.."##dupeMatchQ", UIitems.dupeMatchQuality)
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.equipment.tMatchQuality)
    end
    ImGui.SameLine()
    UIitems.dupeMatchLevel, _ = ImGui.Checkbox(UILabels.items.equipment.bMatchLevel.."##dupeMatchL", UIitems.dupeMatchLevel)
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.equipment.tMatchLevel)
    end
    ImGui.SameLine()
    UIitems.dupeMatchMods, _ = ImGui.Checkbox(UILabels.items.equipment.bMatchMods.."##dupeMatchM", UIitems.dupeMatchMods)
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(UILabels.items.equipment.tMatchMods)
    end

    ImGui.Spacing()

    -- "Keep which" dropdown — lets the user choose which duplicate to keep
    -- when multiple matches are found. Equipped items are ALWAYS kept
    -- regardless of this setting.
    local keepOptions = {
        [0] = UILabels.items.equipment.bKeepFirst,
        [1] = UILabels.items.equipment.bKeepHighest,
        [2] = UILabels.items.equipment.bKeepLowest
    }
    local keepOptionsArr = { keepOptions[0], keepOptions[1], keepOptions[2] }
    ImGui.AlignTextToFramePadding()
    ImGui.Text(UILabels.items.equipment.tKeepWhich)
    ImGui.SameLine()
    UIitems.dupeKeepMode, _ = ImGui.Combo("##dupeKeepMode", UIitems.dupeKeepMode, keepOptionsArr, #keepOptionsArr)
    -- Tooltip shows the description for the currently-selected option
    local keepTooltips = {
        [0] = UILabels.items.equipment.tKeepFirst,
        [1] = UILabels.items.equipment.tKeepHighest,
        [2] = UILabels.items.equipment.tKeepLowest
    }
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip(keepTooltips[UIitems.dupeKeepMode] or "")
    end

    ImGui.Spacing()

    -- "Remove Duplicates" button — disabled while in a menu or not in-game
    ImGui.BeginDisabled(not GameState.isLoaded)
    if (ImGui.Button(UILabels.items.equipment.bRemoveDupes)) then
        local matchOptions = {
            quality = UIitems.dupeMatchQuality,
            level   = UIitems.dupeMatchLevel,
            mods    = UIitems.dupeMatchMods
        }
        local removed = UIitems.Upgrade.RemoveDuplicates(UIitems.dupeCats, matchOptions, UIitems.dupeKeepMode)
        UIitems.dupeResultText = UILabels.items.equipment.tRemoveDupesResult:gsub("{#}", tostring(removed))
        UIitems.dupeResultColour = (removed > 0) and Colour.Positive or Colour.Info
    end
    ImGui.EndDisabled()

    -- Show the result of the last run (persists until the user runs it again)
    if UIitems.dupeResultText ~= "" and UIitems.dupeResultColour ~= nil then
        UIitems.Elements.Text(UIitems.dupeResultText, true, true, UIitems.dupeResultColour, 1)
    end
end

return UIitems