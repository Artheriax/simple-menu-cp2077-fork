---@class ItemRecord
local ItemRecord = {}
ItemRecord.__index = ItemRecord
setmetatable(ItemRecord, {
    __call = function(class, ...)
        return class:new(...)
    end
})

local CUtil = require("misc/cetUtils")
local Util = require("config/util")
local T = Util.T

function ItemRecord:new(TDBItemRecord)
    local vt = {}
    local gotVts, vts
    gotVts, vts = pcall(function() return TDBItemRecord:VisualTags() end)

    if gotVts and vts ~= nil then
        for _, v in pairs(vts) do
            if v ~= nil and v ~= CName.new() then
                table.insert(vt, v.value)
            end
        end
    end
    if #vt == 0 then vt[1] = "" end

    local gotType, type
    gotType, type = pcall(function()
        return Game.GetLocalizedTextByKey(
            TDBItemRecord:ItemType():LocalizedType()
        )
    end)
    if not gotType or type == nil then type = "" end

    local gotCategory, category
    gotCategory, category = pcall(function()
        return TDBItemRecord:ItemCategory():Name()
    end)

    --scopes and muzzle devices don't have one... for whatever reason
    if not gotCategory or category == nil then
        --Check if it's a "part"
        local gotItype, itype = pcall(function() return TDBItemRecord:ItemType():Name().value end)
        local isWPart = false
        if gotItype then
            local findS, _ = string.find(itype, "Prt_")
            isWPart = findS ~= nil
        end

        if isWPart then
            category = "Part"
        else
            category = ""
        end
    else
        category = category.value
    end

    local gotIconic, isIconic = pcall(function() return TDBItemRecord:StatModifiersContains(TweakDB:GetRecord('Quality.IconicItem')) end)
    if not gotIconic then isIconic = false end

    local gotLocDesc, locDesc, desc
    gotLocDesc, locDesc = pcall(function() return TDBItemRecord:LocalizedDescription() end)

    if gotLocDesc then
        desc = T(
            locDesc ~= CName.new(),
            Game.GetLocalizedTextByKey(locDesc),
            nil
        )
    end

    local evo = ""
    if category == "Weapon" then
        local gotWEvo, wEvo
        gotWEvo, wEvo = pcall(function() return TDBItemRecord:Evolution():Name() end)
        if gotWEvo then
            evo = wEvo
        end
    end

    local gotQuality, qualityRec = pcall(function() return TDBItemRecord:Quality() end)
    if not gotQuality or qualityRec == nil then
        print("[SimpleMenu] Nil quality on record:", TDBItemRecord:GetID().value)
        qualityRec = nil
    end

    local qualityName, qualityLevel
    if qualityRec ~= nil then
        local gotVal, qVal = pcall(function() return qualityRec:Value() end)
        qualityLevel = (gotVal and qVal) or -1
        if qualityLevel ~= -1 then
            local gotType, qType = pcall(function() return qualityRec:Type() end)
            if gotType and qType ~= nil then
                local gotLoc, qStr = pcall(function()
                    return GetLocalizedText(UIItemsHelper.QualityToTierPlusString(qType))
                end)
                qualityName = (gotLoc and qStr) or UILabels.universalelements.random
            else
                qualityName = UILabels.universalelements.random
            end
        else
            qualityName = UILabels.universalelements.random
        end
    else
        qualityName = UILabels.universalelements.random
        qualityLevel = -1
    end

    local o = {
        LocalizedName  = Game.GetLocalizedTextByKey(TDBItemRecord:DisplayName()),
        QualityLevel   = qualityLevel,
        QualityName    = qualityName,
        VisualTags     = vt,
        TDBTags        = TDBItemRecord:Tags(),
        TweakDBID      = TDBItemRecord:GetID().value,
        Type           = type,
        Category       = category,
        Evolution      = evo,
        IsIconic       = isIconic,
        Description    = desc,
        Record         = TDBItemRecord
    }

    return setmetatable(o, self)
end

local function DoStatDescriptionConstruction(stats, qName)
    if #stats == 0 then return "" end
    local modDesc = ">>"..qName.." Quality:\n "

    for j = 1, #stats do
        --get props
        local props = stats[j]:GetProperties()

        -- try get key
        local nameKey, _ = props.localizedName:upper():gsub("(LOCKEY#)(%d+)", "%2")
        local x, nameStr = pcall(function() return Game.GetLocalizedTextByKey(CName.new(tonumber(nameKey))) end)
        if not x then return "" end

        --get value and apply modifiers
        local value = stats[j].Value
        local shouldRound = props.roundValue
        local decimalPlaces = props.decimalPlaces
        local mult100 = props.multiplyBy100InText
        local flipNegative = props.flipNegative
        local valRnd = T(shouldRound, CUtil.Round(value, decimalPlaces), CUtil.Round(value, 1))
        local valMult = T(mult100, valRnd * 100, valRnd)
        local valueStr = ""..T(flipNegative, math.abs(valMult), valMult)

        --add symbols as necessary
        local displayPercent = props.displayPercent
        local displayPlus = props.displayPlus and value > 0
        valueStr = T(displayPlus, "+", "")..valueStr..T(displayPercent, "%", "")

        --add units
        local inMetres = props.inMeters
        local inSeconds = props.inSeconds
        local inSpeed = props.inSpeed
        if inMetres then
            valueStr = valueStr.." m"
        elseif inSeconds then
            valueStr = valueStr.." sec."
        elseif inSpeed then
            valueStr = valueStr.." mph"
        end

        valueStr = valueStr.." "..nameStr..T(j < #stats, "\n ", "")
        modDesc = modDesc..valueStr
    end

    return modDesc
end

local function DoModTokenReplacement(mods, qName)
    if #mods == 0 then return "" end
    local modDesc = ">>"..qName.." Quality:\n "
    for j = 1, #mods do
        local locKey, _ = mods[j].Description:upper():gsub("(LOCKEY#)(%d+)", "%2")
        local x, modStr = pcall(function() return Game.GetLocalizedTextByKey(CName.new(tonumber(locKey))) end)
        local intVals   = mods[j].DataPackage.intValues
        local floatVals = mods[j].DataPackage.floatValues
        local statVals  = mods[j].DataPackage.statValues
        local nameVals  = mods[j].DataPackage.nameValues

        if not x then return "" end
        modDesc = modDesc .. modStr .. "\n "

        if intVals ~= nil then
            for k = 1, #intVals do
                modDesc, _ = modDesc:gsub("{int_"..tostring(k - 1).."}", intVals[k]):gsub("%. %u-", ".\n ")
            end
        end

        if floatVals ~= nil then
            for k = 1, #floatVals do
                modDesc, _ = modDesc:gsub("{float_"..tostring(k - 1).."}", CUtil.Round(floatVals[k])):gsub("%. %u-", ".\n ")
            end
        end

        if statVals ~= nil then
            for k = 1, #statVals do
                modDesc, _ = modDesc:gsub("{stat_"..tostring(k - 1).."}", CUtil.Round(statVals[k])):gsub("%. %u-", ".\n ")
            end
        end

        if nameVals ~= nil then
            for k = 1, #nameVals do
                modDesc, _ = modDesc:gsub("{name_"..tostring(k - 1).."}", nameVals[k]):gsub("%. %u-", ".\n ")
            end
        end

        --This whole section is just... fuck.
        modDesc, _ = modDesc:gsub("</>", "|||")
        local splitModDesc = CUtil.StrSplit(modDesc, "|||")
        local rejoinedModDesc = ""
        for _, v in pairs(splitModDesc) do
            rejoinedModDesc = rejoinedModDesc..v:gsub("(<.*>)([%g ]*)", "%2")
        end
        modDesc = rejoinedModDesc
        modDesc, _ = modDesc:gsub("\\n", "\n ")
    end

    return modDesc
end

local function GetStats(statsMgr)
    local stats = {}
    statsMgr:FetchSecondayStats()
    statsMgr:FetchTooltipStats()

    if #statsMgr.Stats > 0 and #statsMgr.TooltipStats > 0 then
        local merge = CUtil.TableMerge(statsMgr.Stats, statsMgr.TooltipStats)
        for _, v in pairs(merge) do table.insert(stats, v) end
    elseif #statsMgr.Stats > 0 then
        for _, v in pairs(statsMgr.Stats) do table.insert(stats, v) end
    else
        for _, v in pairs(statsMgr.TooltipStats) do table.insert(stats, v) end
    end

    return stats
end

function ItemRecord:GetStatsDescription()
    local descStr = ""
    local intToQName = UIItemsHelper.QualityIntToName -- why type more when you can type less?
    local cs = Game.GetScriptableSystemsContainer():Get("CraftingSystem")
    local player = Game.GetPlayer()
    local itemId = ItemID.FromTDBID(self.TweakDBID)
    local invMgr = Game.GetInventoryManager()

    local itemData = invMgr:CreateBasicItemData(itemId, player)
    itemData:ReinitializePlayerStats(player:GetEntityID())

    --Check if we have any mods, so we can exit early
    local uii  = UIInventoryItem.Make(player, itemData)
    local mods = uii:GetModsManager().mods
    local stats = GetStats(uii:GetStatsManager())

    if #mods == 0 and #stats == 0 then
        return ">>" --ahh, hacks
    end

    --Set the item level appropriate to the player to calculate stats
    cs:SetItemLevel(itemData)

    --Get quality tier count
    --subtract 1 for 0-indexing, and another for the fact that the UIItemsHelper functions skip "Random" within the enum
    local qualityLevels = tonumber(EnumValueFromString('gamedataQuality', 'Count')) - 2 --total is 11 in patch 2.0

    --If it has "random" quality, calculate all possible values
    if self.QualityName == "Random" then
        for i = 0, qualityLevels do
            RPGManager.ForceItemTier(Game.GetPlayer(), itemData, intToQName(i))

            --Recreate in order to account for forced level
            uii  = UIInventoryItem.Make(player, itemData)
            mods = uii:GetModsManager().mods
            stats = GetStats(uii:GetStatsManager())

            if #mods > 0 then
                descStr = descStr .. DoModTokenReplacement(mods, intToQName(i).value)
            else
                descStr = descStr .. DoStatDescriptionConstruction(stats, intToQName(i).value)
            end
        end
    else -- Not "random" quality
        --Recreate in order to account for updating player stats
        uii  = UIInventoryItem.Make(player, itemData)
        mods = uii:GetModsManager().mods
        stats = GetStats(uii:GetStatsManager())

        if #mods > 0 then
            descStr = DoModTokenReplacement(mods, self.QualityName)
        else
            descStr = DoStatDescriptionConstruction(stats, self.QualityName)
        end
    end

    return descStr
end

function ItemRecord:AddSkipActivityLogTags()
    if not CUtil.AnyKeyExists(SearchQueuedTagUpdates, self:GetID()) then
        local tags = self.Record:Tags()
        table.insert(tags, CName.new("SkipActivityLog"))
        table.insert(tags, CName.new("SkipActivityLogOnRemove"))
        table.insert(tags, CName.new("HideInBackpackUI"))
        local flatSucc = TweakDB:SetFlat(self.TweakDBID..".tags", tags)
        local updSucc = TweakDB:Update(self.Record)
        return flatSucc and updSucc
    end

    return false
end

function ItemRecord:QueueTagUpdate()
    local k = tostring(self:GetID())

    if not CUtil.AnyKeyExists(SearchQueuedTagUpdates, k) then
        SearchQueuedTagUpdates[k] = {
            item = self,
            tags = self.TDBTags,
            attempts = 0
        }
    end
end

function ItemRecord:GetID()
    return self.TweakDBID
end

function ItemRecord:GetName()
    return self.LocalizedName
end

function ItemRecord:GetQuality()
    -- `nil or X` always returns X, and `s ~= nil` is always true for any string,
    -- so the previous `or` version was a no-op (always returned QualityName).
    -- Use `and` so we only return the name when it is non-nil AND non-empty.
    return T(self.QualityName ~= nil and self.QualityName ~= "", self.QualityName, nil)
end

function ItemRecord:GetType()
    return self.Type
end

function ItemRecord:GetVisualStyle()
    if self.VisualTags[1] ~= "" then
        return self.VisualTags[1]
    end

    return nil
end

function ItemRecord:GetQName()
    return (self:GetName().." ("..self.QualityName..")")
end

function ItemRecord.HasType(arr, type)
    for i = 1, #arr do
        if arr[i].Record:ItemType():Name() == type then return true end
    end
    return false
end

function ItemRecord:NameContains(str)
    if str:len() > self.LocalizedName:len() then
        return false
    elseif self.LocalizedName:upper():find(str:upper(), nil, true) then
        return true
    else
        return false
    end
end

function ItemRecord:IsType(type)
    return self.Record:ItemType():Name().value == type
end

function ItemRecord:IsCategory(cat)
    return self.Category == cat
end

function ItemRecord:IsQuality(q)
    return self.QualityLevel == q
end

function ItemRecord:IconicItem()
    return self.IsIconic
end

function ItemRecord.IdSearch(arr, id)
    for k, v in pairs(arr) do
        if v.TweakDBID == id then
            return v
        end
    end

    return nil
end

---Search ItemRecords
---@param arr ItemRecord[]
---@param str string
---@param type { i: number, s: string }
---@param cat { i: number, s: string }
---@param tier number
---@return table
function ItemRecord.Search(arr, str, type, cat, tier, iconic)
    ---@type ItemRecord[]
    local result = {}

    if str ~= nil then
        for i = 1, #arr do
            if arr[i]:NameContains(str) then
                table.insert(result, arr[i])
            end
        end

        --Remove anything that isn't in category
        if (cat.i ~= 1) then
            CUtil.ArrayRemove(result, function(t, i, j)
                return (t[i]:IsCategory(cat.s))
            end)
        end

        --Remove anything that isn't of type
        if (type.i ~= 1) then
            CUtil.ArrayRemove(result, function(t, i, j)
                return (t[i]:IsType(type.s))
            end)
        end
    elseif cat.i ~= 1 then
        for i = 1, #arr do
            if arr[i]:IsCategory(cat.s) then
                table.insert(result, arr[i])
            end
        end

        --Remove anything that isn't of type
        if (type.i ~= 1) then
            CUtil.ArrayRemove(result, function(t, i, j)
                return (t[i]:IsType(type.s))
            end)
        end
    else
        for i = 1, #arr do
            if arr[i]:IsType(type.s) then
                table.insert(result, arr[i])
            end
        end
    end

    if (tier ~= 0) then
        if tier == 1 then
            tier = -1
        else
            tier = tier - 2
        end

        CUtil.ArrayRemove(result, function(t, i, j)
            return (t[i]:IsQuality(tier))
        end)
    end

    if iconic then
        CUtil.ArrayRemove(result, function(t, i, j)
            return (t[i]:IconicItem())
        end)
    end

    return result
end

function ItemRecord.GetNames(itemRecords, withQuality, blankFirst)
    local names = {}
    local index = 1
    local sub = 0
    blankFirst = blankFirst or false
    withQuality = withQuality or false

    if blankFirst then
        names[index] = UILabels.items.additems.cSelItem
        index = 2
        sub = 1
    end

    for i = index, #itemRecords + sub do
        local qName = (tostring(i - sub)..". "..itemRecords[i - sub]:GetQName())
        local gName = (tostring(i - sub)..". "..itemRecords[i - sub]:GetName())
        names[i] = T(withQuality, qName, gName)
    end
    return names
end

function ItemRecord.CreateItemRecordFromTDBID(TDBIDStr)
    local record = TweakDB:GetRecord(TDBIDStr)
    if record == nil then return nil end
    return ItemRecord(record)
end

local sortFuncId, createStarted = nil, false
--This function looks scarier than it actually is... trust me ;)
function ItemRecord.CreateItemRecordArray(TDBItemRecordArray, sort, timerId)
    if ModState.LoadingItemsState == LoadingState.PreLoad and not createStarted then
        local startTime = os.clock()
        createStarted = true
        sort = sort or false
        ModState.LoadingItemsState = LoadingState.Loading

        -- COMPACT the input array into a fresh, hole-free array first.
        -- The upstream code passes an array that has been through
        -- CUtil.ArrayRemove, which sets removed slots to nil but does NOT
        -- shrink the array — leaving nil holes. With nil holes:
        --   - #TDBItemRecordArray returns an undefined value (stops at the
        --    first nil), so ModState.TotalRecords would be wrong
        --   -pairs() skips nil holes, so the last key yielded is NOT
        --    necessarily the last numeric index — the k==TotalRecords
        --    completion check never fires and the loading bar hangs at 99%
        -- Compacting into a fresh array fixes BOTH problems.
        -- (This is the real fix for GitHub issue #1 — the pcall added in
        -- v52.3 was necessary but not sufficient; the completion check
        -- itself was broken.)
        local compacted = {}
        for _, v in pairs(TDBItemRecordArray) do
            table.insert(compacted, v)
        end
        TDBItemRecordArray = compacted

        ModState.TotalRecords = #TDBItemRecordArray
        if ModState.TotalRecords == 0 then
            -- Edge case: all records were filtered out. Skip straight to Sorted.
            print("[SimpleMenu] Search index: no records to index (empty array after filtering)")
            ModState.LoadedPercent = 100
            -- Forward-only transition: never step the state machine backwards.
            if ModState.LoadingItemsState == LoadingState.Loading then
                ModState.LoadingItemsState = LoadingState.Sorted
            end
            Cron.Halt(timerId)
            return
        end

        local loadingSpeed = CUtil.Round(1 / Util.configuration.menuConfigs.search.loadingSpeed, 5)
        DEBUG_printl(LOG_LEVEL.Info, "Starting indexing process, speed:", (loadingSpeed * 1000).."ms per item",
            "| total records:", ModState.TotalRecords)
        local skippedRecords = 0  -- count of records that failed to construct
        local processedCount = 0   -- tracks how many Cron callbacks have run (completion check)

        for k, v in ipairs(TDBItemRecordArray) do
            local insertFunc = function ()
                -- Wrap ItemRecord(v) construction in pcall so a single
                -- malformed/broken TweakDB record doesn't hang the entire
                -- indexing process. (Part of GitHub issue #1 fix)
                local okRec, newRec = pcall(function() return ItemRecord(v) end)
                if okRec and newRec ~= nil then
                    table.insert(GlobalItemRecords, newRec)
                else
                    skippedRecords = skippedRecords + 1
                    -- Log the first few skips for diagnosis (don't spam the log)
                    if skippedRecords <= 10 then
                        local tdbidForLog = "?"
                        local okId, idVal = pcall(function() return v:GetID() end)
                        if okId and idVal then
                            local okStr, idStr = pcall(function() return idVal.value end)
                            if okStr and type(idStr) == "string" then tdbidForLog = idStr end
                        end
                        print("[SimpleMenu] Search index: skipping malformed TweakDB record #"..k.." ("..tdbidForLog..")")
                    end
                end

                -- Use a processedCount counter for the completion check instead
                -- of relying on k == TotalRecords. Even though we now compact
                -- the array (so ipairs goes 1..N in order and k==N will fire),
                -- the counter approach is more robust against any future
                -- changes to how the array is built.
                processedCount = processedCount + 1
                ModState.LoadedPercent = CUtil.Clamp(25 + CUtil.Round((processedCount / ModState.TotalRecords)  * 75, 0), 25, 99)

                if processedCount == ModState.TotalRecords then
                    DEBUG_printl(LOG_LEVEL.Trace, "Index complete")
                    if skippedRecords > 0 then
                        print("[SimpleMenu] Search index: completed with", skippedRecords, "malformed record(s) skipped")
                    end
                    local postIndex = function()
                        -- Guard the transition so this callback is idempotent.
                        -- Only advance FROM Loading; if a later stage (sort,
                        -- consumables, ...) already ran, never step the state
                        -- machine backwards — that would deadlock the pipeline
                        -- and leave the loading bar stuck at 99% forever.
                        if sort then
                            if ModState.LoadingItemsState == LoadingState.Loading then
                                ModState.LoadingItemsState = LoadingState.MainIndex
                            end
                        else
                            DEBUG_printl(LOG_LEVEL.Trace, "Skipping sort")
                            if ModState.LoadingItemsState == LoadingState.Loading then
                                ModState.LoadingItemsState = LoadingState.Sorted
                            end
                        end
                        local finalTime = CUtil.Round(((os.clock() - startTime) * 1000), 5)
                        local avgTime = CUtil.Round(finalTime / ModState.TotalRecords, 5)
                        DEBUG_printl(LOG_LEVEL.Info,
                            "Record create took:", finalTime.."ms,",
                            "average time per item:", avgTime.."ms"
                        )
                        Cron.Halt(timerId)
                    end
                    Cron.After(0.33, postIndex)
                end
            end
            Cron.After((k * loadingSpeed), insertFunc)
        end

        if sort then
            local sortFunc = function()
                if ModState.LoadingItemsState == LoadingState.MainIndex then
                    DEBUG_printl(LOG_LEVEL.Trace, "Starting sort")
                    table.sort(GlobalItemRecords)
                    ModState.LoadingItemsState = LoadingState.Sorted
                    DEBUG_printl(LOG_LEVEL.Trace, "Sort complete")
                    Cron.Halt(sortFuncId)
                end
            end
            sortFuncId = Cron.Every(0.1, sortFunc)
        end
    end
end

function ItemRecord:ShortName(boxX)
    boxX = boxX or -1
    local iconic = ""

    if self.IsIconic then iconic = " (Iconic)" end

    local name = self.LocalizedName

    local tail = (
        T(self.VisualTags[1] ~= "", " ["..self.VisualTags[1].."]", "").." / "..
        self.QualityName.." / "..
        self.Type..iconic
    )

    --Take a rough approximation of 3 characters width
    --Using capital letters here in order to overshoot somewhat
    --Basically, we want to know how many "blocks" of 3 chars we can chop in order for the string to fit
    local threeCharWidthApprox = ImGui.CalcTextSize("AAA")
    local textX, _ = ImGui.CalcTextSize(name..tail)
    local deltaX = textX - boxX

    if(deltaX > 0) then
        --Logic: the width delta divided by the approx width of 3 characters
        --round it up and add one to be on the safe side, add another for the elipses,
        --multiply by 3 to get char count
        local charsToRemove = (math.ceil(deltaX / threeCharWidthApprox) + 2) * 3
        local substrN = (name:sub(1, #name - charsToRemove).."...")

        return (substrN..tail)
    else
        return (name..tail)
    end
end

function ItemRecord:__tostring()
    return "Name = "..self:GetQName()..", Quality = "..self.QualityName.." ("..self.QualityLevel.."), TweakDBID = "..self.TweakDBID
end

--Sort by name first, then quality
function ItemRecord:__lt(comp)
    if self.LocalizedName < comp.LocalizedName then
        return true
    elseif self.LocalizedName == comp.LocalizedName then
        if self.QualityLevel < comp.QualityLevel then
            return true
        else
            return false
        end
    else
        return false
    end
end

return ItemRecord