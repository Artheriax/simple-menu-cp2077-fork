local Items = {}

Items.tweakDBRecords = {}
Items.filteredRecords = {}
Items.records = GlobalItemRecords

Items.itemrecords = {
    consumable = {},
    material   = {},
    skillbook  = {}
}

Items.itemnames = {
    consumable = {},
    material   = {},
    skillbook  = {}
}

Items.Vehicles = {}
Items.VehicleNames = {}
Items.Util = require("config/util")

local CUtil = require("misc/cetUtils")
local ItemRecord = require("classes/itemrecord")

local createFuncId
local consumableFuncId
local materialFuncId
local shardFuncId
local printFuncId

function Items.Preload()
    DEBUG_printl(LOG_LEVEL.Info, "Getting TweakDB items")
    local startTime = os.clock()
    Items.tweakDBRecords = CUtil.TableMerge(
        TweakDB:GetRecords('gamedataWeaponItem_Record'),
        TweakDB:GetRecords('gamedataItem_Record'),
        TweakDB:GetRecords('gamedataClothing_Record'),
        TweakDB:GetRecords('gamedataConsumableItem_Record'),
        TweakDB:GetRecords('gamedataGrenade_Record')
    )
    DEBUG_printl(LOG_LEVEL.Info, "Getting TweakDB items took:", CUtil.Round((os.clock() - startTime) * 1000, 2).."ms")
end

function Items.RefreshPlayerVehicles()
    Items.Vehicles = CUtil.ArrayProjectSafe(
        Game.GetVehicleSystem():GetPlayerVehicles(),
        function (v)
            local id = v.recordID.value --[[@as string]]--
            if id:find("_player") then
                return v.recordID.value
            else
                return nil
            end
        end
    )
    table.sort(Items.Vehicles)

    Items.VehicleNames = CUtil.ArrayProject(
        Items.Vehicles,
        function(v)
            return Game.GetLocalizedTextByKey(
                TweakDB:GetRecord(v):DisplayName()
            ) .. " ("..v..")"
        end
    )

    table.insert(Items.Vehicles, 1, "")
    table.insert(Items.VehicleNames, 1, UILabels.misc.vehicles.placeholder)

    return Items.Vehicles, Items.VehicleNames
end

function Items.Populate()
    DEBUG_printl(LOG_LEVEL.Info, "Items.Populate() called")
    ModState.LoadingItemsState = LoadingState.PreFetch
    Items.GetFilteredRecords(
        Items.tweakDBRecords,
        nil, nil,
        { "FabricEnhancer" },
        {
            "Testera",
            "GenericMod1"
        },
        {   --ID filters
            "Left_Hand",
            "FunctionalTests",
            "TEST.",
            "CPO",
            "KERS",
            "Tutorial",
            "Items.Inhaler",
            "Items.Injector",
            "Items.LongLasting",
            "_Arasaka",
            "_Oda_S",
            "BaseDeck",
            "NPC",
            "Test",
            "Silenced",
            "SemiAuto",
            "_V_",
            "Generic",
            "Items.Silverhand_Malorian",
            "Items.SimpleWeaponMod10",
            "IntrinsicFabricEnhancer",
            "Items.Dummy",
            "Items.PowerWeaponMod",
            "Items.TechWeaponMod",
            "Items.SmartWeaponMod",
            "knuckledusters",
            "Items.Preset_Knuckles",
            "Smasher_HMG",
            "HMG_Sasquatch",
            "HMG_turret",
            "Minotaur_HMG",
            "HMG_Invisible",
            "Items.Panzer_",
            "Items.Panam_Vehicle",
            "Items.Vehicle_",
            "Items.RareMaterial2",
            "Items.EpicMaterial2",
            "Items.LegendaryMaterial2"
        },
        Items.filteredRecords
    )

    local createFunc = function()
        ItemRecord.CreateItemRecordArray(Items.filteredRecords, true, createFuncId)
    end
    createFuncId = Cron.Every(0.1, createFunc)

    --All consumables
    local consumableFunc = function ()
        if ModState.LoadingItemsState == LoadingState.Sorted then
            DEBUG_printl(LOG_LEVEL.Trace, "Starting consumable indexing process")
            Items.itemrecords.consumable = CUtil.ArrayWhere(
                Items.records,
                function(v)
                    return
                        v:IsType("Con_Injector") or
                        v:IsType("Con_Inhaler") or
                        v:IsType("Con_LongLasting")
                end
            )
            Items.itemnames.consumable = ItemRecord.GetNames(Items.itemrecords.consumable, true, true)
            ModState.LoadingItemsState = LoadingState.Consumables
            DEBUG_printl(LOG_LEVEL.Trace, "Finished consumable indexing process")
            Cron.Halt(consumableFuncId)
        end
    end
    consumableFuncId = Cron.Every(0.1, consumableFunc)

    --All crafting materials
    local materialFunc = function()
        if ModState.LoadingItemsState == LoadingState.Consumables then
            DEBUG_printl(LOG_LEVEL.Trace, "Starting material indexing process")
            Items.itemrecords.material = CUtil.ArrayWhere(
                Items.records,
                function(v)
                    return v:IsType("Gen_CraftingMaterial")
                end
            )
            Items.itemnames.material = ItemRecord.GetNames(Items.itemrecords.material, false, true)
            ModState.LoadingItemsState = LoadingState.Materials
            DEBUG_printl(LOG_LEVEL.Trace, "Finished material indexing process")
            Cron.Halt(materialFuncId)
        end
    end
    materialFuncId = Cron.Every(0.1, materialFunc)

    --All skill shards
    local shardFunc = function()
        if ModState.LoadingItemsState == LoadingState.Materials then
            DEBUG_printl(LOG_LEVEL.Trace, "Starting shard indexing process")
            Items.itemrecords.skillbook = CUtil.ArrayWhere(
                Items.records,
                function(v)
                    return v:IsType("Con_Skillbook")
                end
            )
            Items.itemnames.skillbook = ItemRecord.GetNames(Items.itemrecords.skillbook, true, true)
            ModState.LoadingItemsState = LoadingState.Shards
            ModState.LoadedPercent = 100
            DEBUG_printl(LOG_LEVEL.Trace, "Finished shard indexing process")
            Cron.Halt(shardFuncId)
        end
    end
    shardFuncId = Cron.Every(0.1, shardFunc)

    local printFunc = function()
        if ModState.LoadingItemsState == LoadingState.Shards then
            print("[SimpleMenu] Indexed", #Items.records, "items for Search, out of", #Items.tweakDBRecords, "TweakDB item records.")
            ModState.FinishTime = os.time()
            ModState.LoadingItemsState = LoadingState.Finished
            Cron.Halt(printFuncId)
        end
    end
    printFuncId = Cron.Every(0.1, printFunc)
end

function Items.GetFilteredRecords(records, types, tagsMatchList, tagsExcludeList, idMatchList, idExcludeList, outRecordList)
    --optional lists
    types = types or {}
    tagsMatchList = tagsMatchList or {}
    tagsExcludeList = tagsExcludeList or {}
    idMatchList = idMatchList or {}
    idExcludeList = idExcludeList or {}

    --Check if there's any overlap between include/exclude filters
    for _, v in pairs(tagsMatchList) do
        local found, i = CUtil.Exists(tagsExcludeList, v)
        if found then
            table.remove(tagsExcludeList, i)
        end
    end

    for _, v in pairs(idMatchList) do
        local found, i = CUtil.Exists(idExcludeList, v)
        if found then
            table.remove(idExcludeList, i)
        end
    end

    --clean up nil types
    local matchPattern = "(<.+>)"
    local startTime = os.clock()
    CUtil.ArrayRemove(records, function(t, i, _)
        local tdbidStr = tostring(t[i]:GetID().value)
        local defaultTDBID = tdbidStr:match(matchPattern) ~= nil

        if defaultTDBID then
            return false
        end

        return (t[i]:ItemType() ~= nil)
    end)
    DEBUG_printl(LOG_LEVEL.Trace, "Nil cleanup took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    --clean up anything without a category (this is usually broken shit anyway)
    matchPattern = "Prt_"
    startTime = os.clock()
    CUtil.ArrayRemove(records, function(t, i, _)
        local record = t[i]:ItemCategory()
        local gotItype, itype = pcall(function() return t[i]:ItemType():Name().value end)
        local isWPart = false
        if gotItype then
            local findS, _ = string.find(itype, matchPattern)
            isWPart = findS ~= nil
        end
        return (record ~= nil or isWPart)
    end)
    DEBUG_printl(LOG_LEVEL.Trace, "Category cleanup took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    --remove anything with the name "!OBSOLETE"
    local obsStr = "!OBSOLETE"
    startTime = os.clock()
    CUtil.ArrayRemove(records, function(t, i, _)
        local dname = t[i]:DisplayName()

        if dname ~= nil then
            local lname = Game.GetLocalizedTextByKey(CName.new(tonumber(dname.hash_lo)))
            if lname:upper() == obsStr then
                return false
            end
        end

        return true
    end)
    DEBUG_printl(LOG_LEVEL.Trace, "Obsolete cleanup took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    --do type check first so we don't have to process
    --the everloving shit out of a potentially huge list
    local intermediate = {}
    startTime = os.clock()
    if #types > 0 then
        for i = 1, #records do
            local exists, _ = CUtil.Exists(types, records[i]:ItemType():Name().value)
            if exists then
                intermediate[i] = records[i]
            end
        end
    end
    DEBUG_printl(LOG_LEVEL.Trace, "Type check took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    if #types == 0 then
        Items.ProcessFilters(records, tagsMatchList, tagsExcludeList, idMatchList, idExcludeList, outRecordList)
    else
        Items.ProcessFilters(intermediate, tagsMatchList, tagsExcludeList, idMatchList, idExcludeList, outRecordList)
    end
    -- results are written into outRecordList (passed by reference); no return value.
end

function Items.ProcessFilters(records, tagsMatchList, tagsExcludeList, idMatchList, idExcludeList, outRecordList)
    local k, n = 1, #records
    local startTime = os.clock()
    local loadingSpeed = CUtil.Round(1 / (Items.Util.configuration.menuConfigs.search.loadingSpeed * 3), 5)
    DEBUG_printl(LOG_LEVEL.Info, "Starting filtering process, speed:", (loadingSpeed * 1000).."ms per item")
    for j, v in pairs(records) do
        local filterFunc = function()
            ModState.LoadedPercent = CUtil.Clamp(CUtil.Round((j / n)  * 25, 0), 0, 25)
            local hasName = v:DisplayName() ~= CName.new()
            local tags = v:Tags()
            local id = v:GetID().value
            local tagMatch = false
            local tagExcl = false
            local idMatch = false
            local idExcl = false
            local isBase = false
            local hasTags = tags ~= nil and #tags > 0

            if string.find(id, "Base") then
                isBase = true
            end

            if not isBase then
                if hasTags then
                    --true if no tags passed
                    if #tagsMatchList > 0 then
                        tagMatch = CUtil.AnyTagExists(tags, tagsMatchList)
                    else
                        tagMatch = true
                    end
                end

                tagExcl = not CUtil.AnyTagExists(tags, tagsExcludeList)

                --true if no id filters passed
                if #idMatchList > 0 then
                    idMatch = CUtil.MatchString(id, idMatchList)
                end

                idExcl = CUtil.MatchString(id, idExcludeList)

                if hasTags and hasName and tagMatch and tagExcl and (not idExcl or idMatch) then
                    outRecordList[k] = v
                    k = k + 1
                end
            end

            if j == n then
                local postFilterFunc = function()
                    local finalTime = CUtil.Round(((os.clock() - startTime) * 1000), 5)
                    local avgTime = CUtil.Round(finalTime / n, 5)
                    ModState.LoadingItemsState = LoadingState.PreLoad
                    ModState.LoadedPercent = 25
                    DEBUG_printl(LOG_LEVEL.Info, "Filtering took:", finalTime.."ms,", "average time per item:", avgTime.."ms")
                    DEBUG_printl(LOG_LEVEL.Info, "Pre-Fetch complete")
                end
                Cron.After(0.33, postFilterFunc)
            end
        end
        Cron.After(j * loadingSpeed, filterFunc)
    end
end

local quality = {
    "Common",
    "CommonPlus",
    "Uncommon",
    "UncommonPlus",
    "Rare",
    "RarePlus",
    "Epic",
    "EpicPlus",
    "Legendary",
    "LegendaryPlus",
    "LegendaryPlusPlus"
}

--add schmoney
function Items.AddMoney(amount)
    Game.AddToInventory("Items.money", amount)
    print("[SimpleMenu] added", amount, "Eurodollars")
end

local function GetOldQualityValue(quality)
    if quality == gamedataQuality.Common then
        return 0
    elseif quality == gamedataQuality.Uncommon then
        return 1
    elseif quality == gamedataQuality.Rare then
        return 2
    elseif quality == gamedataQuality.Epic then
        return 3
    elseif quality == gamedataQuality.Legendary then
        return 4
    else
        return 0
    end
end

local function UpgradeIconicItem(itemData, tier, checkPlus)
    checkPlus = checkPlus or false

    local qValu = RPGManager.GetItemTierFromName(tier)              --Get value from quality name
    local tEnum = RPGManager.ConvertCombinedValueToQuality(qValu)   --Get gamedataQuality from value
    local qEnum = RPGManager.ConvertQualityToNonPlusQuality(tEnum)  --Discard plus information
    local finalVal = GetOldQualityValue(qEnum)                      --Convert back to quality value
    local ss = Game.GetStatsSystem()
    local statsObj = itemData:GetStatsObjectID()

    local modQ = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, finalVal)

    local f = function()
        ss:RemoveAllModifiers(statsObj, gamedataStatType.Quality, true)
        ss:AddSavedModifier(statsObj, modQ)
    end

    Cron.After(0.25, f)

    if checkPlus then
        local plusVal = RPGManager.ConvertQualityToItemPlusValue(tEnum)
        local modP = RPGManager.CreateStatModifier(gamedataStatType.IsItemPlus, gameStatModifierType.Additive, plusVal)
        ss:RemoveAllModifiers(statsObj, gamedataStatType.IsItemPlus, true)
        ss:AddSavedModifier(statsObj, modP)
    end
end

function Items.UpgradeItemBasedOnPlayerSkill(itemData)
    local cs = CraftingSystem.GetInstance()

    if itemData:HasTag('IconicWeapon') then
        local forceQual = RPGManager.SetQualityBasedOnLevel(Game.GetPlayer())
        UpgradeIconicItem(itemData, forceQual, false)
    else
        cs:SetItemQualityBasedOnPlayerSkill(itemData)
    end

    cs:SetItemLevel(itemData)
end

function Items.UpgradeItemWithForcedQuality(itemData, forceQual)
    local cs = CraftingSystem.GetInstance()
    local qCname = CName.new(quality[forceQual])

    if itemData:HasTag('IconicWeapon') then
        UpgradeIconicItem(itemData, qCname, true)
    else
        RPGManager.ForceItemTier(Game.GetPlayer(), itemData, qCname)
    end

    cs:SetItemLevel(itemData)
end

function Items.AddItem(category, type, amount)
    --Add the item to the inventory
    local record = Items.itemrecords[category] and Items.itemrecords[category][type]
    if record == nil then
        print("[SimpleMenu] AddItem: invalid category/type")
        return
    end
    Game.AddToInventory(record:GetID(), amount)

    print("[SimpleMenu]", amount, "item(s) of type", record:GetQName(), "added")
end

function Items.AddItem2(record, amount, forceQual)
    --optional force quality
    forceQual = forceQual or 0

    record:AddSkipActivityLogTags()

    local loops = 1
    local added = amount
    local isStackable = ItemID.GetStructure(
        ItemID.FromTDBID(record:GetID())
    ) ~= gamedataItemStructure.Unique

    if not isStackable then
        loops = amount
        amount = 1
    end

    local ts = Game.GetTransactionSystem()
    local player = Game.GetPlayer()
    for _ = 1, loops do
        --Add the item to the inventory
        local addItemId = ItemID.FromTDBID(record:GetID())
        ts:GiveItem(player, addItemId, amount)
        local newItem = ts:GetItemData(player, addItemId)

        --If not forcing Quality, Set the item's power and quality appropriate to the player
        if forceQual ~= 0 then
            Items.UpgradeItemWithForcedQuality(newItem, forceQual)
        else
            Items.UpgradeItemBasedOnPlayerSkill(newItem)
        end
    end

    record:QueueTagUpdate()
    print("[SimpleMenu]", added, "item(s) of type", record:GetID(), "added")
end

--add whole category of items
function Items.AddCategory(category, amount)
    --select table and cycle through all item ids
    for position, _ in pairs(Items.itemrecords[category]) do
        Items.AddItem(category, position, amount)
    end
end

--unequip all items, including weapon, armor and cyberware
--when using an arm cyberware you'll have invisible arms until you equip arm cyberware again
function Items.UnequipItems()
    Game.ClearEquipment()
    print("[SimpleMenu] Unequipped armour, weapons and cyberware")
end

return Items