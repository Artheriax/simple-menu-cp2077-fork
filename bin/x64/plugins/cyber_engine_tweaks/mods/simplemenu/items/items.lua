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
    local merged = CUtil.TableMerge(
        TweakDB:GetRecords('gamedataWeaponItem_Record'),
        TweakDB:GetRecords('gamedataItem_Record'),
        TweakDB:GetRecords('gamedataClothing_Record'),
        TweakDB:GetRecords('gamedataConsumableItem_Record'),
        TweakDB:GetRecords('gamedataGrenade_Record')
    )

    -- Deduplicate the merged record list. TweakDB:GetRecords on a base record
    -- type also returns records of its derived types (e.g. gamedataItem_Record
    -- yields weapons, clothing, consumables and grenades as well), so the
    -- merge above can contain the same record two or three times. Indexing
    -- duplicates multiplies the indexing workload and produces doubled
    -- entries in the Search tab (and doubled "Add All" inventory spam).
    local seen = {}
    local deduped = {}
    local duplicates = 0
    for _, rec in ipairs(merged) do
        local okId, id = pcall(function() return rec:GetID().value end)
        local key = (okId and id ~= nil) and tostring(id) or tostring(rec)
        if seen[key] == nil then
            seen[key] = true
            table.insert(deduped, rec)
        else
            duplicates = duplicates + 1
        end
    end

    Items.tweakDBRecords = deduped
    DEBUG_printl(LOG_LEVEL.Info, "Getting TweakDB items took:", CUtil.Round((os.clock() - startTime) * 1000, 2).."ms",
        "| merged:", #merged, "| unique:", #deduped, "| duplicates removed:", duplicates)
end

function Items.RefreshPlayerVehicles()
    -- Guard: this can be called from the Misc tab's draw loop (every frame
    -- until the list is populated); during load transitions the vehicle
    -- system or player-vehicle list may not be ready yet.
    local vs = Game.GetVehicleSystem()
    if vs == nil then
        DEBUG_printl(LOG_LEVEL.Info, "RefreshPlayerVehicles: VehicleSystem not available yet")
        return Items.Vehicles, Items.VehicleNames
    end

    local okList, rawVehicles = pcall(function() return vs:GetPlayerVehicles() end)
    if not okList or rawVehicles == nil then
        DEBUG_printl(LOG_LEVEL.Info, "RefreshPlayerVehicles: GetPlayerVehicles failed")
        return Items.Vehicles, Items.VehicleNames
    end

    local filtered = {}

    for _, v in ipairs(rawVehicles) do
        local id = v.recordID.value --[[@as string]]
        -- Must have the "_player" suffix (the standard convention for player-ownable vehicles)
        if id:find("_player") then
            -- Validate the record exists and has a non-empty display name.
            -- This mirrors the "hasName" check used in Items.ProcessFilters
            -- for the search tab, and filters out invalid / test / debug
            -- vehicles that would otherwise show up as blank entries.
            local okRec, record = pcall(function() return TweakDB:GetRecord(v.recordID.value) end)
            if okRec and record ~= nil then
                local okName, displayName = pcall(function() return record:DisplayName() end)
                local hasName = false
                if okName and displayName ~= nil then
                    -- DisplayName returns a CName; check it's not the empty CName
                    -- (same pattern as Items.ProcessFilters line: hasName = v:DisplayName() ~= CName.new())
                    hasName = displayName ~= CName.new()
                    -- Also resolve the localized text to make sure it's not empty
                    -- (some vehicles have a CName that resolves to an empty string)
                    if hasName then
                        local okLoc, locName = pcall(function() return Game.GetLocalizedTextByKey(displayName) end)
                        if not okLoc or locName == nil or locName == "" then
                            hasName = false
                        end
                    end
                end
                if hasName then
                    table.insert(filtered, v.recordID.value)
                else
                    DEBUG_printl(LOG_LEVEL.Info, "RefreshPlayerVehicles: skipping invalid/unnamed vehicle:", id)
                end
            else
                DEBUG_printl(LOG_LEVEL.Info, "RefreshPlayerVehicles: skipping vehicle with unresolvable record:", id)
            end
        end
    end

    Items.Vehicles = filtered
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
        -- pcall hardening: records injected by other mods (TweakXL etc.) can
        -- have malformed flats; a binding error here used to abort the whole
        -- filter pass. Malformed records are dropped instead.
        local okId, tdbidStr = pcall(function() return tostring(t[i]:GetID().value) end)
        if not okId or tdbidStr == nil then
            return false
        end
        local defaultTDBID = tdbidStr:match(matchPattern) ~= nil

        if defaultTDBID then
            return false
        end

        local okType, itemType = pcall(function() return t[i]:ItemType() end)
        return (okType and itemType ~= nil)
    end)
    DEBUG_printl(LOG_LEVEL.Trace, "Nil cleanup took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    --clean up anything without a category (this is usually broken shit anyway)
    matchPattern = "Prt_"
    startTime = os.clock()
    CUtil.ArrayRemove(records, function(t, i, _)
        local gotCat, record = pcall(function() return t[i]:ItemCategory() end)
        local gotItype, itype = pcall(function() return t[i]:ItemType():Name().value end)
        local isWPart = false
        if gotItype and itype ~= nil then
            local findS, _ = string.find(itype, matchPattern)
            isWPart = findS ~= nil
        end
        return ((gotCat and record ~= nil) or isWPart)
    end)
    DEBUG_printl(LOG_LEVEL.Trace, "Category cleanup took:", CUtil.Round(((os.clock() - startTime) * 1000), 5).."ms")

    --remove anything with the name "!OBSOLETE"
    local obsStr = "!OBSOLETE"
    startTime = os.clock()
    CUtil.ArrayRemove(records, function(t, i, _)
        local gotDn, dname = pcall(function() return t[i]:DisplayName() end)

        if gotDn and dname ~= nil then
            local gotLoc, lname = pcall(function()
                return Game.GetLocalizedTextByKey(CName.new(tonumber(dname.hash_lo)))
            end)
            if gotLoc and lname ~= nil and lname:upper() == obsStr then
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
    -- COMPACT the input array into a fresh, hole-free array first.
    -- The upstream `records` array has been through CUtil.ArrayRemove
    -- (in GetFilteredRecords above), which sets removed slots to nil
    -- but does NOT shrink the array — leaving nil holes. With nil holes:
    --   - #records returns an undefined value (stops at the first nil),
    --     so `n` (used for progress + completion) would be wrong
    --   - pairs() skips nil holes, so the last key yielded is NOT
    --     necessarily the last numeric index — the j==n completion
    --     check never fires and the loading bar hangs at 25% (then never
    --     advances to the indexing phase).
    -- Compacting fixes both problems. (Real fix for GitHub issue #1.)
    local compacted = {}
    for _, v in pairs(records) do
        table.insert(compacted, v)
    end
    records = compacted

    local k, n = 1, #records
    local startTime = os.clock()
    local loadingSpeed = CUtil.Round(1 / (Items.Util.configuration.menuConfigs.search.loadingSpeed * 3), 5)
    DEBUG_printl(LOG_LEVEL.Info, "Starting filtering process, speed:", (loadingSpeed * 1000).."ms per item",
        "| total records:", n)
    local skippedFilters = 0  -- count of records that failed during filtering
    local processedCount = 0  -- tracks how many records have been processed (completion check)
    local nextIndex = 1       -- index of the next record to process

    -- Edge case: empty records array — skip straight to PreLoad so the
    -- indexing phase can proceed (it'll find nothing to index and exit).
    if n == 0 then
        print("[SimpleMenu] Search filter: no records to filter (empty array)")
        local postFilterFunc = function()
            ModState.LoadingItemsState = LoadingState.PreLoad
            ModState.LoadedPercent = 25
            DEBUG_printl(LOG_LEVEL.Info, "Pre-Fetch complete (empty input)")
        end
        Cron.After(0.33, postFilterFunc)
        return
    end

    -- Time-sliced batch filtering. The old implementation scheduled ONE
    -- Cron.After timer per record — tens of thousands of pending timers at
    -- once. Cron.Update then walked every pending timer on every frame, and
    -- its removal sweep performed O(n*k) table.remove shifts per frame while
    -- all of those one-shot timers expired. That timer storm is the
    -- main-thread stall / memory spike behind the "crash mid building index"
    -- reports on lower-end machines and heavily modded TweakDBs. A single
    -- recurring timer that processes a batch of records per tick achieves
    -- the exact same pacing (records/second) with constant overhead.
    local TICK = 0.05
    local totalTime = n * loadingSpeed
    local batch = math.max(1, math.floor(((n * TICK) / (totalTime > 0 and totalTime or TICK)) + 0.5))
    if batch > 250 then batch = 250 end -- never process more than 250 records in one tick
    DEBUG_printl(LOG_LEVEL.Info, "Filter batching:", batch.." records / "..(TICK * 1000).."ms tick")

    local chunkTimerId
    chunkTimerId = Cron.Every(TICK, function()
        local processedThisTick = 0

        while processedThisTick < batch and nextIndex <= n do
            local j = nextIndex
            local v = records[j]
            nextIndex = nextIndex + 1

            -- Wrap the per-record filtering in pcall so a malformed TweakDB
            -- record doesn't abort the entire filter pass. (Part of issue #1 fix)
            local okFilter = pcall(function()
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
            end)
            if not okFilter then
                skippedFilters = skippedFilters + 1
                if skippedFilters <= 10 then
                    local tdbidForLog = "?"
                    local okId, idVal = pcall(function() return v:GetID() end)
                    if okId and idVal then
                        local okStr, idStr = pcall(function() return idVal.value end)
                        if okStr and type(idStr) == "string" then tdbidForLog = idStr end
                    end
                    print("[SimpleMenu] Search filter: skipping malformed TweakDB record #"..j.." ("..tdbidForLog..")")
                end
            end

            processedCount = processedCount + 1
            processedThisTick = processedThisTick + 1
        end

        ModState.LoadedPercent = CUtil.Clamp(CUtil.Round((processedCount / n) * 25, 0), 0, 25)

        if processedCount >= n then
            Cron.Halt(chunkTimerId)

            if skippedFilters > 0 then
                print("[SimpleMenu] Search filter: completed with", skippedFilters, "malformed record(s) skipped")
            end

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
    end)
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

    -- pcall: adding the skip-activity-log tags writes to TweakDB; a malformed
    -- record (usually injected by another mod) would throw here and abort the
    -- add loop halfway through.
    pcall(function() record:AddSkipActivityLogTags() end)

    local loops = 1
    local added = amount
    local gotStruct, structure = pcall(function()
        return ItemID.GetStructure(ItemID.FromTDBID(record:GetID()))
    end)
    local isStackable = gotStruct and structure ~= nil and structure ~= gamedataItemStructure.Unique

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

---Queue a list of ItemRecords to be added to the inventory over time.
---"Add All" used to add every search result synchronously in a single frame:
---hundreds or thousands of GiveItem + TweakDB SetFlat calls at once. That is
---both a crash risk (main-thread flood) and the main vector by which OTHER
---mods' items mass-contaminated the savegame. The queue drains gradually.
Items.addItemQueue = {}
Items.addItemQueueTimer = nil
local ADD_QUEUE_DRAIN = 10 -- items processed per 0.1s tick

function Items.QueueAddItems(recordList, amount, forceQual)
    local queued = 0
    for _, v in ipairs(recordList) do
        table.insert(Items.addItemQueue, { record = v, amount = amount, forceQual = forceQual })
        queued = queued + 1
    end

    print("[SimpleMenu] Queued", queued, "item(s) for adding (added gradually to avoid frame spikes)")

    if Items.addItemQueueTimer == nil and #Items.addItemQueue > 0 then
        Items.addItemQueueTimer = Cron.Every(0.1, function()
            local drained = 0
            while drained < ADD_QUEUE_DRAIN and #Items.addItemQueue > 0 do
                local entry = table.remove(Items.addItemQueue, 1)
                local okAdd, errAdd = pcall(Items.AddItem2, entry.record, entry.amount, entry.forceQual)
                if not okAdd then
                    print("[SimpleMenu] Add-all queue: failed to add an item:", errAdd)
                end
                drained = drained + 1
            end

            if #Items.addItemQueue == 0 then
                Cron.Halt(Items.addItemQueueTimer)
                Items.addItemQueueTimer = nil
                print("[SimpleMenu] Add-all queue drained")
            end
        end)
    end
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