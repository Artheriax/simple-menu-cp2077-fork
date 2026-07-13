local Upgrade = {}

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

local Items = require("items/items")

--original script created by Expired, heavily modified by Dank Rafft
function Upgrade.ChangeQuality(newItemQuality, processSlot, mode)
    local player = Game.GetPlayer()
    local ssc = Game.GetScriptableSystemsContainer()
    local ts = Game.GetTransactionSystem()
    local ss = Game.GetStatsSystem()
    local es = ssc:Get(CName.new('EquipmentSystem'))
    local espd = es:GetPlayerData(player)
    espd['GetItemInEquipSlot2'] = espd['GetItemInEquipSlot;gamedataEquipmentAreaInt32']
    local playerPLValue = ss:GetStatValue(player:GetEntityID(), 'PowerLevel')
    local modItemLevel = 0

    local slots = {
        { "Face", 1 },
        { "Feet", 1 },
        { "Head", 1 },
        { "InnerChest", 1 },
        { "Legs", 1 },
        { "OuterChest", 1 },
        { "Outfit", 1 },
        { "Weapon", 1 },
        { "Weapon", 2 },
        { "Weapon", 3 },
    }

    --process all equipped items
    if(processSlot == 0) then
        for k, _ in pairs(slots) do
            local itemid = espd:GetItemInEquipSlot2(slots[k][1], slots[k][2] - 1)
            if (itemid.tdbid.hash ~= 0) then

                --variables
                local itemdata = ts:GetItemData(player, itemid)
                local statObj = itemdata:GetStatsObjectID()
                local itemLevel = ss:GetStatValue(statObj, 'ItemLevel')
                local powerLevel = ss:GetStatValue(statObj, 'PowerLevel')
                local itemQuality = math.floor(ss:GetStatValue(statObj, 'Quality'))

                --recalculate item level
                if(mode == 1 or mode == 0) then
                    if (itemLevel < math.floor(playerPLValue) * 10) then
                        modItemLevel = math.floor(playerPLValue - powerLevel) * 10 + 5
                        local levelMod = Game['gameRPGManager::CreateStatModifier;gamedataStatTypegameStatModifierTypeFloat']('ItemLevel', 'Additive', modItemLevel)
                        ss:AddSavedModifier(statObj, levelMod)
                        --print result
                        print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "changed from item level", itemLevel, "to", (itemLevel + modItemLevel))
                    else
                        print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "already is at max item level.")
                    end
                end

                --recalculate item quality
                if(mode == 2 or mode == 0) then
                    if(newItemQuality ~= 0) then
                        if (itemQuality < newItemQuality) then
                            RPGManager.ForceItemTier(player, itemdata, CName.new(quality[newItemQuality]))
                            --print result
                            print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "changed from item quality", quality[itemQuality], "to", quality[newItemQuality])
                        else
                            print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "already is at selected or higher quality")
                        end
                    else
                        print("[SimpleMenu] Equipment: Invalid argument, you need to select a quality.")
                    end
                end
            end
        end

    --proccess only selected slot
    elseif(processSlot ~= 0 and newItemQuality ~= 0) then
        local itemid = espd:GetItemInEquipSlot2(slots[processSlot][1], slots[processSlot][2] - 1)
        if (itemid.tdbid.hash ~= 0) then

            --variables
            local itemdata = ts:GetItemData(player, itemid)
            local statObj = itemdata:GetStatsObjectID()
            local itemLevel = ss:GetStatValue(statObj, 'ItemLevel')
            local powerLevel = ss:GetStatValue(statObj, 'PowerLevel')
            local itemQuality = math.floor(ss:GetStatValue(statObj, 'Quality'))

            --recalculate item level
            if(mode == 1 or mode == 0) then
                if (itemLevel < math.floor(playerPLValue) * 10) then
                    modItemLevel = math.floor(playerPLValue - powerLevel) * 10 + 5
                    local levelMod = Game['gameRPGManager::CreateStatModifier;gamedataStatTypegameStatModifierTypeFloat']('ItemLevel', 'Additive', modItemLevel)
                    ss:AddSavedModifier(statObj, levelMod)
                    --print result
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "changed from item level", itemLevel, "to", (itemLevel + modItemLevel))
                else
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "already is at max item level.")
                end
            end

            --recalculate item quality
            if(mode == 2 or mode == 0) then
                if(newItemQuality ~= 0) then
                    RPGManager.ForceItemTier(player, itemdata, CName.new(quality[newItemQuality]))
                    --print result
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "changed from item quality", quality[itemQuality], "to", quality[newItemQuality])
                else
                    print("[SimpleMenu] Equipment: Invalid argument, you need to select a quality.")
                end
            end
        end
    end
end

function Upgrade.UpgradeAll(forceQual)
    local player = Game.GetPlayer()
    local ts = Game.GetTransactionSystem()
    local gotItems, items = ts:GetItemListExcludingTags(player, { CName.new("CraftingPart"), CName.new("Currency"), CName.new("Ammo") })
    if gotItems then
        for _, v in pairs(items) do
            DEBUG_printl(LOG_LEVEL.Trace, "UPGRADE:", v, v:GetID().id.value)
            Items.UpgradeItemWithForcedQuality(v, forceQual)
        end
    end
end

--created by Expired
--removes quest tag from items
function Upgrade.RemoveQuest()
    local player = Game.GetPlayer()
    local ssc = Game.GetScriptableSystemsContainer()
    local ts = Game.GetTransactionSystem()
    local es = ssc:Get(CName.new('EquipmentSystem'))
    local espd = es:GetPlayerData(player)
    espd['GetItemInEquipSlot2'] = espd['GetItemInEquipSlot;gamedataEquipmentAreaInt32']

    local slots = {
        Face = 1,
        Feet = 1,
        Head = 1,
        InnerChest = 1,
        Legs = 1,
        OuterChest = 1,
        Weapon = 3
    }

    local procItems = 0

    for k,v in pairs(slots) do
        for i=1,v do
            --get equipped items
            local itemid = espd:GetItemInEquipSlot2(k, i - 1)
            if itemid.tdbid.hash ~= 0 then
                --get data of equipped items
                local itemdata = ts:GetItemData(player, itemid)
                if itemdata:HasTag("Quest") then
                    --if item has quest tag, remove it
                    itemdata:RemoveDynamicTag("Quest")
                    print("[SimpleMenu] Quest Tag: Item in", k, "slot", i, "got its quest tag removed")
                    --if tag was removed increase counter
                    procItems = procItems + 1
                else
                    print("[SimpleMenu] Quest Tag: Item in", k, "slot", i, "doesn't have the quest tag")
                end
            end
        end
    end
    --rint result
    print("[SimpleMenu] Quest Tag: A total of", procItems, "item(s) were modified")
end

-- Category definitions for RemoveDuplicates.
-- Each entry maps a UI category name (used by the checkboxes) to a function
-- that returns true if an inventory item's record belongs to that category.
-- We check via the record's ItemType() / ItemCategory() names, which is the
-- same approach used elsewhere in the mod. All accessors are pcall-wrapped
-- because some records (modded items, quest items, etc.) may not implement
-- every accessor and would otherwise abort the entire scan.
local function safeGetItemCategoryName(record)
    if record == nil then return nil end
    local ok, cat = pcall(function() return record:ItemCategory() end)
    if not ok or cat == nil then return nil end
    local okName, name = pcall(function() return cat:Name() end)
    if not okName or name == nil then return nil end
    -- name is a CName; .value gives the Lua string
    local okVal, val = pcall(function() return name.value end)
    if not okVal then return nil end
    return val
end

local function safeGetItemTypeName(record)
    if record == nil then return nil end
    local ok, itype = pcall(function() return record:ItemType() end)
    if not ok or itype == nil then return nil end
    local okName, name = pcall(function() return itype:Name() end)
    if not okName or name == nil then return nil end
    local okVal, val = pcall(function() return name.value end)
    if not okVal then return nil end
    return val
end

local dupeCategoryFilters = {
    Weapons       = function(record)
        local catName = safeGetItemCategoryName(record)
        return catName == "Weapon"
    end,
    Clothing      = function(record)
        local catName = safeGetItemCategoryName(record)
        return catName == "Clothing"
    end,
    Cyberware     = function(record)
        local catName = safeGetItemCategoryName(record)
        -- Cyberware is split across multiple categories in TweakDB
        return catName == "Cyberware" or catName == "CyberwareSmall" or catName == "CyberwareLarge"
    end,
    Consumables   = function(record)
        local itype = safeGetItemTypeName(record)
        if itype == nil then return false end
        return itype == "Con_Inhaler" or itype == "Con_Injector" or itype == "Con_LongLasting" or itype == "Con_Skillbook"
    end,
    Materials     = function(record)
        local itype = safeGetItemTypeName(record)
        return itype == "Gen_CraftingMaterial"
    end,
    Grenades      = function(record)
        -- Grenades can be typed as either "Grenade" or "Gad_Grenade" and
        -- categorised as "Gadget" in TweakDB. Match all of these.
        local itype = safeGetItemTypeName(record)
        if itype ~= nil and (itype == "Grenade" or itype == "Gad_Grenade") then return true end
        local catName = safeGetItemCategoryName(record)
        if catName == "Gadget" then
            -- Only match Gadget category if the type name contains "Grenade"
            if itype ~= nil and string.find(itype:lower(), "grenade") then return true end
        end
        return false
    end,
    Junk          = function(record)
        local itype = safeGetItemTypeName(record)
        if itype == nil then return false end
        return itype == "Gen_Junk" or itype == "Gen_Miscellaneous"
    end,
    Mods          = function(record)
        local itype = safeGetItemTypeName(record)
        if itype == nil then return false end
        -- Prt_ prefix covers weapon mods and clothing fabric enhancers
        return string.find(itype, "Prt_") ~= nil or itype == "Mod_WeaponMod" or itype == "Mod_FabricEnhancer"
    end,
}

---Build a composite dedup key for an item based on its functional properties
---rather than its TweakDBID. Two items with the same key are considered
---duplicates even if they have different TweakDBIDs (e.g. a crafted Nova
---and a preset Nova with the same name, quality, level, and mods).
---
---The key is composed of (depending on match options):
---  1. Localized display name (e.g. "DR5 Nova", "Death and Taxes") — always included
---  2. Quality level (numeric stat value) — included if matchOptions.quality is true
---  3. Item level (numeric stat value) — included if matchOptions.level is true
---  4. Installed mods fingerprint (sorted mod TweakDBID strings) — included if
---     matchOptions.mods is true
---
---When a match option is false, that property is excluded from the key, so
---two items that differ only in that property will be considered duplicates.
---For example, with matchOptions.level = false, a level-10 DR5 Nova and a
---level-50 DR5 Nova (same quality, same mods) will be treated as duplicates.
---
---@param record table  The TweakDB record for the item
---@param itemData table  The gameItemData from the transaction system
---@param matchOptions { quality: boolean, level: boolean, mods: boolean }
---@return string  The composite dedup key
local function buildDupeKey(record, itemData, matchOptions)
    local parts = {}

    -- 1. Display name — always included. This is the primary dedup criterion.
    local displayName = ""
    local okName, nameVal = pcall(function()
        return Game.GetLocalizedTextByKey(record:DisplayName())
    end)
    if okName and nameVal ~= nil then displayName = nameVal end
    table.insert(parts, "n="..displayName)

    -- We fetch the stats object once and reuse it for both quality and level.
    local statObj = nil
    local okStats = pcall(function() statObj = itemData:GetStatsObjectID() end)
    if not okStats then statObj = nil end

    -- 2. Quality level — included only if matchOptions.quality is true
    if matchOptions and matchOptions.quality then
        if statObj ~= nil then
            local ss = Game.GetStatsSystem()
            local okQ, qVal = pcall(function() return ss:GetStatValue(statObj, 'Quality') end)
            if okQ and qVal ~= nil then
                table.insert(parts, "q="..tostring(math.floor(qVal + 0.5)))
            else
                table.insert(parts, "q=?")
            end
        else
            table.insert(parts, "q=?")
        end
    end

    -- 3. Item level — included only if matchOptions.level is true
    if matchOptions and matchOptions.level then
        if statObj ~= nil then
            local ss = Game.GetStatsSystem()
            local okL, lVal = pcall(function() return ss:GetStatValue(statObj, 'ItemLevel') end)
            if okL and lVal ~= nil then
                table.insert(parts, "l="..tostring(math.floor(lVal + 0.5)))
            else
                table.insert(parts, "l=?")
            end
        else
            table.insert(parts, "l=?")
        end
    end

    -- 4. Installed mods fingerprint — included only if matchOptions.mods is true
    if matchOptions and matchOptions.mods then
        local modParts = {}
        -- itemData:GetItemParts() returns an array of gameItemData for each
        -- installed mod/part. We pcall everything because modded items or
        -- items with empty slots may not behave consistently.
        local okParts, partsArr = pcall(function() return itemData:GetItemParts() end)
        if okParts and partsArr ~= nil then
            for _, part in ipairs(partsArr) do
                local okPID, partID = pcall(function() return part:GetID() end)
                if okPID and partID and partID.tdbid then
                    local okPStr, pStr = pcall(function()
                        local v = partID.tdbid.value
                        if v ~= nil and type(v) == "string" and not string.find(v, "<TDBID:") then
                            return v
                        end
                        return "h"..tostring(partID.tdbid.hash)
                    end)
                    if okPStr and pStr ~= nil then
                        table.insert(modParts, pStr)
                    end
                end
            end
        end
        -- Sort the mod parts so the fingerprint is order-independent (two items
        -- with the same mods in different slot order are still duplicates).
        table.sort(modParts)
        table.insert(parts, "m="..table.concat(modParts, ","))
    end

    return table.concat(parts, "|")
end

-- Returns the list of category names (in order) used by RemoveDuplicates.
-- Used by the UI to render the checkboxes.
function Upgrade.GetDupeCategories()
    return {
        "Weapons", "Clothing", "Cyberware", "Consumables",
        "Materials", "Grenades", "Junk", "Mods"
    }
end

---Remove duplicate items from the player's inventory in the selected categories.
---A "duplicate" is any item whose composite dedup key (name + optionally
---quality + optionally level + optionally mods) matches another item.
---
---Two-pass algorithm:
---  Pass 1: Group all items by (category, dedupKey), collecting each item's
---          quality and equipped status.
---  Pass 2: For each group with more than one item, decide which to keep
---          based on keepMode, then remove the rest.
---
---Equipped items and quest-tagged items are ALWAYS kept (never removed) to
---avoid breaking quest state or the player's loadout. This is a HARD RULE
---that overrides the keepMode — even if "keep lowest quality" is selected
---and an equipped item is the lowest quality, it will NOT be removed.
---
---@param selectedCats table<string, boolean>  Map of category name -> true to process
---@param matchOptions { quality: boolean, level: boolean, mods: boolean }?  Which properties to include in the dedup key (all default to true)
---@param keepMode number?  0 = keep first found, 1 = keep highest quality (default), 2 = keep lowest quality
---@return number  Total number of items removed
function Upgrade.RemoveDuplicates(selectedCats, matchOptions, keepMode)
    -- Default match options: all true (strict matching)
    if matchOptions == nil then
        matchOptions = { quality = true, level = true, mods = true }
    else
        if matchOptions.quality == nil then matchOptions.quality = true end
        if matchOptions.level == nil then matchOptions.level = true end
        if matchOptions.mods == nil then matchOptions.mods = true end
    end
    -- Default keep mode: 1 (keep highest quality)
    if keepMode == nil then keepMode = 1 end

    local player = Game.GetPlayer()
    if player == nil then
        print("[SimpleMenu] RemoveDuplicates: player not available")
        return 0
    end

    local ts = Game.GetTransactionSystem()
    if ts == nil then
        print("[SimpleMenu] RemoveDuplicates: TransactionSystem not available")
        return 0
    end

    -- Build the set of category filter functions we'll actually run
    local activeFilters = {}
    for catName, enabled in pairs(selectedCats) do
        if enabled and dupeCategoryFilters[catName] ~= nil then
            table.insert(activeFilters, { name = catName, fn = dupeCategoryFilters[catName] })
        end
    end

    if #activeFilters == 0 then
        print("[SimpleMenu] RemoveDuplicates: no categories selected, nothing to do")
        return 0
    end

    -- Resolve the EquipmentSystem so we can check IsItemEquipped per item.
    -- This is the AUTHORITATIVE equipped check — we do NOT rely on the
    -- tdbid-hash-based equippedIDs set from pass 1 for the keep decision,
    -- because two different item instances can share a tdbid hash.
    local ssc = Game.GetScriptableSystemsContainer()
    local okES, es = pcall(function() return ssc:Get(CName.new('EquipmentSystem')) end)
    if not okES or es == nil then
        print("[SimpleMenu] RemoveDuplicates: EquipmentSystem not available")
        return 0
    end

    -- Helper: check if a specific ItemID is currently equipped.
    -- This is the authoritative check — always used before removing any item.
    local function isItemEquipped(itemID)
        if es == nil then return false end
        local okEq, eqVal = pcall(function()
            return es:GetPlayerData(player):IsItemEquipped(itemID)
        end)
        return okEq and eqVal == true
    end

    -- Get all inventory items, excluding the "system" tags that represent
    -- non-item inventory entries (crafting parts, currency, ammo).
    local gotItems, items = ts:GetItemListExcludingTags(player, {
        CName.new("CraftingPart"), CName.new("Currency"), CName.new("Ammo")
    })

    if not gotItems or items == nil then
        print("[SimpleMenu] RemoveDuplicates: could not retrieve inventory item list")
        return 0
    end

    -- Diagnostic counters
    local checked = 0
    local diag_keptQuest = 0
    local diag_keptNoTdbid = 0
    local diag_keptNoRecord = 0
    local diag_keptNoCatMatch = 0
    local diag_keptCatNotSelected = 0
    local diag_skippedEquipped = 0   -- equipped items, never considered for removal
    local diag_uniqueKept = 0        -- items that are the only one in their group
    local diag_dupeKept = 0          -- duplicates that were chosen to be kept
    local diag_dupeMarked = 0        -- duplicates marked for removal

    ----------------------------------------------------------------------
    -- PASS 1: Group all items by (category, dedupKey).
    -- Each group is an array of item entries with all the info we need
    -- for the keep/remove decision in pass 2.
    ----------------------------------------------------------------------
    -- groups[catName][dupeKey] = array of {
    --   itemID = ItemID,
    --   itemData = gameItemData,
    --   quality = number,        -- numeric quality stat value (for keepMode sorting)
    --   isEquipped = boolean,    -- authoritative equipped check
    --   name = string,           -- localized display name (for logging)
    --   tdbid = string,          -- readable tdbid string (for logging)
    --   order = number,          -- encounter order (for "keep first" mode)
    -- }
    local groups = {}
    local encounterOrder = 0

    for _, itemData in ipairs(items) do
        checked = checked + 1
        local itemID = itemData:GetID()
        local tdbidObj = nil
        if itemID then
            if itemID.tdbid and itemID.tdbid.hash ~= 0 then
                tdbidObj = itemID.tdbid
            elseif itemID.id and itemID.id.hash ~= 0 then
                tdbidObj = itemID.id
            end
        end

        if tdbidObj == nil then
            diag_keptNoTdbid = diag_keptNoTdbid + 1
        else
            -- Skip quest-tagged items entirely
            local isQuest = false
            local okQuest, questVal = pcall(function() return itemData:HasTag("Quest") end)
            if okQuest and questVal then isQuest = true end
            if isQuest then
                diag_keptQuest = diag_keptQuest + 1
            else
                -- Resolve the record
                local record = nil
                local okRec, recVal = pcall(function() return TweakDB:GetRecord(tdbidObj) end)
                if okRec then record = recVal end

                local tdbidStr = nil
                if tdbidObj.value ~= nil and type(tdbidObj.value) == "string"
                    and not string.find(tdbidObj.value, "<TDBID:") then
                    tdbidStr = tdbidObj.value
                else
                    tdbidStr = "TDBID_"..tostring(tdbidObj.hash)
                end

                if record == nil then
                    diag_keptNoRecord = diag_keptNoRecord + 1
                    if diag_keptNoRecord <= 5 then
                        print("[SimpleMenu] RemoveDuplicates: could not resolve record for tdbid:", tdbidStr)
                    end
                else
                    -- Determine which of the ACTIVE (selected) categories
                    local matchedCat = nil
                    for _, af in ipairs(activeFilters) do
                        local okMatch, matchRes = pcall(function() return af.fn(record) end)
                        if okMatch and matchRes then
                            matchedCat = af.name
                            break
                        end
                    end

                    if matchedCat == nil then
                        -- Distinguish "matches unselected category" (expected) from
                        -- "matches no category at all" (potential filter bug)
                        local matchesAnyFilter = false
                        for _, filterFn in pairs(dupeCategoryFilters) do
                            local okAny, anyRes = pcall(function() return filterFn(record) end)
                            if okAny and anyRes then
                                matchesAnyFilter = true
                                break
                            end
                        end
                        if matchesAnyFilter then
                            diag_keptCatNotSelected = diag_keptCatNotSelected + 1
                        else
                            diag_keptNoCatMatch = diag_keptNoCatMatch + 1
                            if diag_keptNoCatMatch <= 5 then
                                local catName = safeGetItemCategoryName(record)
                                local itype = safeGetItemTypeName(record)
                                print("[SimpleMenu] RemoveDuplicates: no cat match. tdbid:", tdbidStr, "catName:", tostring(catName), "itype:", tostring(itype))
                            end
                        end
                    else
                        -- This item is in a selected category — add it to the group.
                        -- Check equipped status NOW (authoritative) so we have it
                        -- for the keep decision in pass 2.
                        local equipped = isItemEquipped(itemID)
                        if equipped then
                            diag_skippedEquipped = diag_skippedEquipped + 1
                        end

                        -- Get quality value for keepMode sorting
                        local qualityVal = 0
                        local okStats, statObj = pcall(function() return itemData:GetStatsObjectID() end)
                        if okStats and statObj ~= nil then
                            local ss = Game.GetStatsSystem()
                            local okQ, qVal = pcall(function() return ss:GetStatValue(statObj, 'Quality') end)
                            if okQ and qVal ~= nil then qualityVal = qVal end
                        end

                        -- Get display name for logging
                        local displayName = ""
                        local okName, nameVal = pcall(function()
                            return Game.GetLocalizedTextByKey(record:DisplayName())
                        end)
                        if okName and nameVal ~= nil then displayName = nameVal end

                        -- Build the dedup key
                        local dupeKey = buildDupeKey(record, itemData, matchOptions)

                        -- Add to group
                        if groups[matchedCat] == nil then groups[matchedCat] = {} end
                        if groups[matchedCat][dupeKey] == nil then groups[matchedCat][dupeKey] = {} end
                        encounterOrder = encounterOrder + 1
                        table.insert(groups[matchedCat][dupeKey], {
                            itemID = itemID,
                            itemData = itemData,
                            quality = qualityVal,
                            isEquipped = equipped,
                            name = displayName,
                            tdbid = tdbidStr,
                            order = encounterOrder
                        })
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- PASS 2: For each group, decide which items to keep and which to remove.
    --
    -- Rules:
    --   1. Equipped items are ALWAYS kept (hard rule, overrides keepMode)
    --   2. Quest items were already skipped in pass 1
    --   3. Among non-equipped items in a group:
    --      - If group has only 1 non-equipped item → keep it
    --      - If group has multiple non-equipped items:
    --          keepMode 0 (first): keep the one with lowest encounter order
    --          keepMode 1 (highest): keep the one with highest quality
    --          keepMode 2 (lowest): keep the one with lowest quality
    --      - All other non-equipped items are marked for removal
    ----------------------------------------------------------------------
    local toRemove = {}

    for catName, catGroups in pairs(groups) do
        for dupeKey, itemEntries in pairs(catGroups) do
            if #itemEntries <= 1 then
                -- Only one item in this group — it's unique, keep it
                diag_uniqueKept = diag_uniqueKept + 1
            else
                -- Separate equipped from non-equipped
                local equippedItems = {}
                local nonEquippedItems = {}
                for _, entry in ipairs(itemEntries) do
                    if entry.isEquipped then
                        table.insert(equippedItems, entry)
                    else
                        table.insert(nonEquippedItems, entry)
                    end
                end

                -- All equipped items are kept (hard rule)
                -- Now decide which non-equipped item to keep (if any)
                local keepIndex = nil  -- index into nonEquippedItems
                if #nonEquippedItems == 0 then
                    -- All items in this group are equipped — keep all, remove none
                    keepIndex = nil
                elseif keepMode == 0 then
                    -- Keep first found (lowest encounter order)
                    -- nonEquippedItems is already in encounter order since we
                    -- built it by iterating itemEntries in order
                    keepIndex = 1
                elseif keepMode == 1 then
                    -- Keep highest quality
                    local bestQ = -1
                    for i, entry in ipairs(nonEquippedItems) do
                        if entry.quality > bestQ then
                            bestQ = entry.quality
                            keepIndex = i
                        end
                    end
                elseif keepMode == 2 then
                    -- Keep lowest quality
                    local bestQ = math.huge
                    for i, entry in ipairs(nonEquippedItems) do
                        if entry.quality < bestQ then
                            bestQ = entry.quality
                            keepIndex = i
                        end
                    end
                end

                -- Mark the kept non-equipped item
                if keepIndex ~= nil then
                    diag_dupeKept = diag_dupeKept + 1
                    -- Mark all OTHER non-equipped items for removal
                    for i, entry in ipairs(nonEquippedItems) do
                        if i ~= keepIndex then
                            table.insert(toRemove, {
                                itemID = entry.itemID,
                                name = entry.name,
                                cat = catName,
                                tdbid = entry.tdbid
                            })
                            diag_dupeMarked = diag_dupeMarked + 1
                        end
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- PASS 3: Actually remove the marked items.
    ----------------------------------------------------------------------
    local removed = 0
    local removedByCat = {}
    for _, af in ipairs(activeFilters) do removedByCat[af.name] = 0 end

    for _, entry in ipairs(toRemove) do
        local okRemove = pcall(function()
            local qty = ts:GetItemQuantity(player, entry.itemID)
            local toRemoveQty = qty
            if toRemoveQty < 1 then toRemoveQty = 1 end
            ts:RemoveItem(player, entry.itemID, toRemoveQty)
            removed = removed + toRemoveQty
            removedByCat[entry.cat] = (removedByCat[entry.cat] or 0) + toRemoveQty
            local namePart = entry.name
            if namePart == nil or namePart == "" then namePart = "(unnamed)" end
            if toRemoveQty > 1 then
                print(("[SimpleMenu] RemoveDuplicates: removed %d x %s [%s] (%s)"):format(
                    toRemoveQty, namePart, entry.cat, entry.tdbid))
            else
                print(("[SimpleMenu] RemoveDuplicates: removed %s [%s] (%s)"):format(
                    namePart, entry.cat, entry.tdbid))
            end
        end)
        if not okRemove then
            print("[SimpleMenu] RemoveDuplicates: FAILED to remove item:", entry.tdbid, "("..entry.name..")")
        end
    end

    -- Build the per-category summary string
    local catSummaryParts = {}
    for _, af in ipairs(activeFilters) do
        local n = removedByCat[af.name] or 0
        if n > 0 then
            table.insert(catSummaryParts, af.name..": "..n)
        end
    end
    local catSummary = #catSummaryParts > 0 and table.concat(catSummaryParts, ", ") or "none"

    local keepModeName = ({ [0] = "first", [1] = "highest", [2] = "lowest" })[keepMode] or tostring(keepMode)
    print("[SimpleMenu] RemoveDuplicates: checked", checked, "items, removed", removed, "duplicates. Per-category:", catSummary,
        "| Match: quality="..tostring(matchOptions.quality).." level="..tostring(matchOptions.level).." mods="..tostring(matchOptions.mods),
        "| Keep: "..keepModeName)
    print("[SimpleMenu] RemoveDuplicates diagnostics:",
        "quest="..diag_keptQuest,
        "noTdbid="..diag_keptNoTdbid,
        "noRecord="..diag_keptNoRecord,
        "noCatMatch="..diag_keptNoCatMatch,
        "catNotSelected="..diag_keptCatNotSelected,
        "equipped="..diag_skippedEquipped,
        "uniqueKept="..diag_uniqueKept,
        "dupeKept="..diag_dupeKept,
        "dupeMarked="..diag_dupeMarked)
    return removed
end

return Upgrade