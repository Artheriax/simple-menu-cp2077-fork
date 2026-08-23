local UIsearch = {
    searchText = "",
    currentType = 0,
    currentCat = 0,
    currentTier = 0,
    currentItem = 0,
    iconicFilter = false,
    prevItem = 0,
    currentItemAddDesc = "",
    itemTypes = {},
    rawItemTypes = {},
    -- visibleTypeEntries is a single array of {str, raw} pairs for the types
    -- that are valid for the currently selected category. Using one array of
    -- pairs (instead of two parallel arrays) eliminates any possibility of
    -- the display name and raw type string drifting out of alignment.
    -- When "(All)" category is selected it contains every type; when a specific
    -- category is selected it contains only types that have at least one item
    -- in that category.
    visibleTypeEntries = {},
    -- catToTypes maps a category string (e.g. "Weapon", "WeaponMod") to an array
    -- of indices into itemTypes / rawItemTypes. Built lazily after item indexing.
    catToTypes = {},
    typeMapBuilt = false,
    itemCats = {},
    typeListItems = {},
    catListItems = {},
    resultList = {},
    searchResult = {},
    threeChars = false,
    newSearch = false,
    aValue = 1,
    overridequality = 0,
    catsOpen = true,
    typesOpen = true,
    resultsOpen = false,
    infoOpen = false,
    searchWarnText = "",
    searchWarnCol  = nil
}

UIsearch.Items = require("items/items")

local ItemRecord = require("classes/itemrecord")
local Elem = require("ui/elements")
local CUtil = require("misc/cetUtils")
local Util = require("config/util")
local Colour = require("classes/colour")
local T = Util.T
local qualityList = Util.GetDLabels("item", "modupgradequality")
local qualityFilterList = CUtil.TableCopy(qualityList)
local listTextHeight = 20
qualityFilterList[1] = UILabels.dynamic.item.modupgradequalityFirstOverride
table.insert(qualityFilterList, 2, UILabels.universalelements.random)

function UIsearch.Populate()
    local types = TweakDB:GetRecords("gamedataItemType_Record")
    local x = 2
    local tempItems = {}
    tempItems[1] = { str = UILabels.search.categories[1], raw = nil }

    -- LUA string optimization garbage begins --
    -- match strings
    local fabricEnh = "FabricEnhancer"
    local AssRifle  = "Wea_AssaultRifle"
    local clothing  = "Clo_"
    local longBlade = "LongBlade"
    local muzzle    = "Prt_Muzzle"
    local moneySh   = "Gen_MoneyShard"
    local cybHeal   = "Cyb_HealingAbility"

    --result strings
    local longBladeR = "Long Blade"
    local silencerR  = "Silencer"
    local moneyShR   = "Money Shard"
    local cybHealR   = "Cyberwear Healing Ability"
    -- LUA string optimization garbage ends --

    for i = 1, #types do
        local exclude =
            types[i]:LocalizedType() ~= CName.new() and
            not string.find(types[i]:Name().value, fabricEnh) and
            not string.find(types[i]:Name().value, AssRifle)

        local str = nil
        if (string.find(types[i]:Name().value, clothing)) then
            str = "Clothing ("..Game.GetLocalizedTextByKey(types[i]:LocalizedType())..")"
        elseif (types[i]:Name() == CName.new(longBlade)) then
            str = longBladeR
        elseif (types[i]:Name() == CName.new(muzzle)) then
            str = silencerR
        elseif (types[i]:Name() == CName.new(moneySh)) then
            str = moneyShR
        elseif (types[i]:Name() == CName.new(cybHeal)) then
            str = cybHealR
        elseif (exclude) then
            str = Game.GetLocalizedTextByKey(types[i]:LocalizedType())
        end

        if str ~= nil and not CUtil.StringEmptyOrWhitespace(str) then
            tempItems[x] = { str = str, raw = types[i]:Name().value }
            x = x + 1
        end
    end

    table.sort(tempItems, function(l, r) return l.str < r.str end)

    for i = 1, #tempItems do
        UIsearch.itemTypes[i] = tempItems[i].str
        UIsearch.rawItemTypes[i] = tempItems[i].raw
    end

    -- Initialize visible type list to the full list (default category is "(All)")
    -- Each entry is a {str, raw} pair so the display name and raw type string
    -- can never drift apart.
    UIsearch.visibleTypeEntries = {}
    for i = 1, #UIsearch.itemTypes do
        UIsearch.visibleTypeEntries[i] = { str = UIsearch.itemTypes[i], raw = UIsearch.rawItemTypes[i] }
        UIsearch.typeListItems[i] = false
    end

    for i = 1, #UILabels.search.categories do
        UIsearch.itemCats[i] = UILabels.search.categories[i]
        UIsearch.catListItems[i] = false
    end

    --Select (All) type/category by default
    UIsearch.typeListItems[1] = true
    UIsearch.catListItems[1] = true
end

---Build a map from category string to the set of type indices that exist in that
---category, based on the actual loaded ItemRecords. Called lazily after item
---indexing completes. Idempotent — safe to call every frame.
function UIsearch.BuildTypeMap()
    if UIsearch.typeMapBuilt then return end
    if UIsearch.Items == nil or #UIsearch.Items.records == 0 then return end

    -- Reverse lookup: raw type string -> index in itemTypes.
    -- We iterate using #itemTypes (NOT #rawItemTypes) because rawItemTypes[1]
    -- is nil (the "(All)" entry has no raw type), which makes Lua's # operator
    -- on rawItemTypes return an undefined value.
    local rawTypeToIndex = {}
    for i = 2, #UIsearch.itemTypes do
        rawTypeToIndex[UIsearch.rawItemTypes[i]] = i
    end

    UIsearch.catToTypes = {}
    local seen = {}  -- catStr -> set of typeIdx (for dedup)

    for _, rec in ipairs(UIsearch.Items.records) do
        local catStr = rec.Category or ""
        if catStr ~= "" then
            local ok, rawType = pcall(function() return rec.Record:ItemType():Name().value end)
            if ok and rawType ~= nil then
                local typeIdx = rawTypeToIndex[rawType]
                if typeIdx ~= nil then
                    if seen[catStr] == nil then seen[catStr] = {} end
                    if not seen[catStr][typeIdx] then
                        seen[catStr][typeIdx] = true
                        if UIsearch.catToTypes[catStr] == nil then
                            UIsearch.catToTypes[catStr] = {}
                        end
                        table.insert(UIsearch.catToTypes[catStr], typeIdx)
                    end
                end
            end
        end
    end

    -- Sort each category's type indices numerically so the visible list stays
    -- alphabetical (the master itemTypes array is already sorted by display
    -- name, and sorting by index preserves that order).
    for _, indices in pairs(UIsearch.catToTypes) do
        table.sort(indices)
    end

    UIsearch.typeMapBuilt = true
    DEBUG_printl(LOG_LEVEL.Info, "Search: category-to-type map built for", #UIsearch.catToTypes, "categories")
end

---Rebuild the visible type list based on the currently selected category.
---When "(All)" is selected (index 1), all types are shown. When a specific
---category is selected, only types that have at least one item in that
---category are shown.
function UIsearch.UpdateVisibleTypes()
    UIsearch.visibleTypeEntries = {}
    -- Always include "(All)" at index 1
    UIsearch.visibleTypeEntries[1] = { str = UIsearch.itemTypes[1], raw = UIsearch.rawItemTypes[1] }

    if UIsearch.currentCat == 0 or UIsearch.currentCat == 1 then
        -- "(All)" category: show every type
        for i = 2, #UIsearch.itemTypes do
            UIsearch.visibleTypeEntries[#UIsearch.visibleTypeEntries + 1] = {
                str = UIsearch.itemTypes[i],
                raw = UIsearch.rawItemTypes[i]
            }
        end
    else
        -- Specific category: only types that exist in that category
        local catStr = UIsearch.itemCats[UIsearch.currentCat]:gsub(" ", "")
        local typeIndices = UIsearch.catToTypes[catStr]
        if typeIndices ~= nil then
            for _, idx in ipairs(typeIndices) do
                UIsearch.visibleTypeEntries[#UIsearch.visibleTypeEntries + 1] = {
                    str = UIsearch.itemTypes[idx],
                    raw = UIsearch.rawItemTypes[idx]
                }
            end
        end
    end
end

function UIsearch.CategoryList(_)
    _, listTextHeight = ImGui.CalcTextSize("A")
    local width = ImGui.GetWindowContentRegionWidth()
    if ImGui.BeginListBox("categories", width, 200) then
        for i = 1, #UIsearch.itemCats do
            UIsearch.catListItems[i] = ImGui.Selectable(
                UIsearch.itemCats[i],
                UIsearch.catListItems[i],
                ImGuiSelectableFlags.None,
                width, listTextHeight
            )
        end
        ImGui.EndListBox()
    end
end

function UIsearch.TypeList(_)
    local width = ImGui.GetWindowContentRegionWidth()
    if ImGui.BeginListBox("itemTypes", width, 300) then
        for i = 1, #UIsearch.visibleTypeEntries do
            UIsearch.typeListItems[i] = ImGui.Selectable(
                UIsearch.visibleTypeEntries[i].str.."##itemType"..i,
                UIsearch.typeListItems[i] or false,
                ImGuiSelectableFlags.None,
                width, listTextHeight
            )
        end
        ImGui.EndListBox()
    end
end

local tableFlags = bit32.bor(
    ImGuiTableFlags.BordersOuterH,
    ImGuiTableFlags.BordersOuterV,
    ImGuiTableFlags.SizingFixedFit,
    ImGuiTableFlags.NoHostExtendY,
    ImGuiTableFlags.ScrollY,
    ImGuiTableFlags.Resizable,
    ImGuiTableFlags.Hideable
)

local tableRowH = 27

local function resultsTableHeaderSetup(qX, iX)
    ImGui.TableSetupColumn(UILabels.universalelements.name, ImGuiTableColumnFlags.WidthStretch)
    ImGui.TableSetupColumn(UILabels.universalelements.type)
    ImGui.TableSetupColumn(UILabels.universalelements.style)
    ImGui.TableSetupColumn(UILabels.universalelements.quality, ImGuiTableColumnFlags.WidthFixed, qX)
    ImGui.TableSetupColumn(UILabels.universalelements.iconic, ImGuiTableColumnFlags.WidthFixed, iX)
    ImGui.TableSetupScrollFreeze(0, 1)
    ImGui.TableHeadersRow()
end

function UIsearch.SearchResults()
    if UIsearch.searchWarnCol == nil then UIsearch.searchWarnCol = Colour.Default end
    if UIsearch.searchWarnText ~= "" and UIsearch.searchWarnText ~= nil then
        Elem.Text(UIsearch.searchWarnText, true, true, UIsearch.searchWarnCol, 1)
    else
        Elem.Text(UILabels.search.headerHint, true, true, Colour.Disabled)
    end
    ImGui.Spacing()

    local width = ImGui.GetWindowContentRegionWidth()
    if (ImGui.BeginChild("tableWrapper-searchResults", width, 350)) then
        if ImGui.BeginTable("searchResults", 5, tableFlags, width, 350) then
            local qX, textH = ImGui.CalcTextSize(UILabels.universalelements.quality)
            local iX, _     = ImGui.CalcTextSize(UILabels.universalelements.iconic)

            --padding
            qX    = qX + 20
            iX    = iX + 20

            local rowHeight = math.max(tableRowH, textH)

            resultsTableHeaderSetup(qX, iX)
            ImGui.TableNextRow(rowHeight, ImGuiTableRowFlags.None)
            ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, 0x00000000)

            if UIsearch.threeChars then
                UIsearch.searchWarnCol = Colour.Warning
                UIsearch.searchWarnText = UILabels.search.tCharWrn
            elseif #UIsearch.searchResult == 0 and UIsearch.newSearch then
                UIsearch.searchWarnCol = Colour.Info
                UIsearch.searchWarnText = UILabels.search.tSearchNone
            else
                if UIsearch.newSearch then
                    for i = 1, #UIsearch.searchResult do
                        UIsearch.resultList[i] = false
                    end
                    UIsearch.newSearch = false
                end
                UIsearch.searchWarnText = ""
                for i = 1, #UIsearch.searchResult do
                    ImGui.TableNextColumn()
                    UIsearch.resultList[i] = ImGui.Selectable(
                        UIsearch.searchResult[i]:GetName().."##searchResult"..i,
                        UIsearch.resultList[i],
                        ImGuiSelectableFlags.SpanAllColumns,
                        width, rowHeight
                    )
                    Elem.QuickTooltip(
                        UIsearch.searchResult[i].TweakDBID,
                        Colour.Disabled,
                        1200
                    )

                    --Type
                    ImGui.TableNextColumn()
                    local tName = UIsearch.searchResult[i]:GetType()
                    ImGui.Text(tName)

                    --Style
                    ImGui.TableNextColumn()
                    local vName = UIsearch.searchResult[i]:GetVisualStyle()

                    if vName ~= nil then
                        ImGui.Text(vName)
                    else
                        ImGui.Text("--")
                    end

                    --Quality
                    ImGui.TableNextColumn()
                    local qName = UIsearch.searchResult[i]:GetQuality()
                    if qName ~= nil then
                        ImGui.Text(qName)
                    else
                        ImGui.Text("--")
                    end

                    --Iconic?
                    ImGui.TableNextColumn()
                    if UIsearch.searchResult[i]:IconicItem() then
                        ImGui.Text(UILabels.universalelements.yes)
                    else
                        ImGui.Text("--")
                    end
                end
            end
            ImGui.TableSetColumnIndex(0)
            ImGui.EndTable()
        end
        ImGui.EndChild()
    end
end

function UIsearch.ItemInfo(selItemData)
    local width = ImGui.GetWindowContentRegionWidth()
    ImGui.BeginChild("ItemInfoPanel", width, 250, true)
    if(selItemData ~= nil) then
        ImGui.TextWrapped(selItemData.LocalizedName.." - "
            ..selItemData.QualityName
            ..T(selItemData.IsIconic, " / "..UILabels.universalelements.iconic.." ", " ")
        )
        ImGui.TextWrapped(selItemData.Category.." / "
            ..selItemData.Type
            ..T(selItemData.Evolution ~= "", " / "..selItemData.Evolution, "")
        )
        if selItemData.VisualTags[1] ~= "" then
            ImGui.TextWrapped(UILabels.search.iStyleVariant..": "..selItemData.VisualTags[1])
        end

        ImGui.TextWrapped(selItemData.Description)

        if UIsearch.currentItemAddDesc == "" then
            UIsearch.currentItemAddDesc = selItemData:GetStatsDescription()
        end

        if UIsearch.currentItemAddDesc ~= "" then
            for _, v in pairs(CUtil.StrSplit(UIsearch.currentItemAddDesc, ">>")) do
                ImGui.TextWrapped(v)
            end
        end        
    end
    ImGui.EndChild()
end

function UIsearch.TabSearch()
    if GameState.isLoaded and UIVisible and ModState.LoadingItemsState == LoadingState.Finished then
        local width = ImGui.GetWindowContentRegionWidth()
        local tFlags = bit32.bor(ImGuiInputTextFlags.CtrlEnterForNewLine)
        local listItemClicked = false

        -- Build the category-to-type map (idempotent; runs once after items are loaded).
        -- If this is the first time the map was built and a specific category is
        -- already selected, rebuild the visible type list to apply the filter.
        local mapWasBuilt = not UIsearch.typeMapBuilt
        UIsearch.BuildTypeMap()
        if mapWasBuilt and UIsearch.typeMapBuilt and UIsearch.currentCat > 1 then
            UIsearch.UpdateVisibleTypes()
            UIsearch.currentType = 1
            UIsearch.typeListItems = {}
            for i = 1, #UIsearch.visibleTypeEntries do
                UIsearch.typeListItems[i] = (i == 1)
            end
        end

        Elem.SectionHeading(UILabels.search.sNHeading, Colour.Info, false)
        local sTextChanged
        UIsearch.searchText, sTextChanged = ImGui.InputTextMultiline("searchTextInput", UIsearch.searchText, 32, width, 40, tFlags)
        Elem.QuickTooltip(UILabels.search.tSearchB, Colour.Info)

        Elem.Separator()

        UIsearch.catsOpen = Elem.ToggleHeaderMenu(
            UILabels.search.sCHeading,
            UIsearch.CategoryList,
            UIsearch.catsOpen
        )

        local prevCat = UIsearch.currentCat

        for i = 1, #UIsearch.catListItems do
            if UIsearch.catListItems[i] then
                if UIsearch.currentCat == 0 then
                    UIsearch.currentCat = i
                    listItemClicked = true
                elseif UIsearch.currentCat ~= i then
                    UIsearch.catListItems[UIsearch.currentCat] = false
                    UIsearch.currentCat = i
                    listItemClicked = true
                end
            end
        end

        -- If the category changed, rebuild the visible type list so only types
        -- that actually exist in the selected category are shown, and reset the
        -- type selection to "(All)". This fixes the issue where selecting
        -- "Weapon" would still show irrelevant types like "Tarot Card".
        if prevCat ~= UIsearch.currentCat and UIsearch.currentCat ~= 0 then
            UIsearch.UpdateVisibleTypes()
            UIsearch.currentType = 1
            UIsearch.typeListItems = {}
            for i = 1, #UIsearch.visibleTypeEntries do
                UIsearch.typeListItems[i] = (i == 1)
            end
            -- Force a re-search with the new category and "(All)" type
            listItemClicked = true
        end

        Elem.Separator()

        UIsearch.typesOpen = Elem.ToggleHeaderMenu(
            UILabels.search.sTHeading,
            UIsearch.TypeList,
            UIsearch.typesOpen
        )

        for i = 1, #UIsearch.typeListItems do
            if UIsearch.typeListItems[i] then
                if UIsearch.currentType == 0 then
                    UIsearch.currentType = i
                    listItemClicked = true
                elseif UIsearch.currentType ~= i then
                    UIsearch.typeListItems[UIsearch.currentType] = false
                    UIsearch.currentType = i
                    listItemClicked = true
                end
            end
        end

        Elem.Separator()
        local tierFilterChanged, iconicFilterChanged, availX
        Elem.SectionHeading(UILabels.search.sTierFilter, Colour.Info, false)
        UIsearch.iconicFilter, iconicFilterChanged = ImGui.Checkbox(UILabels.universalelements.iconicF, UIsearch.iconicFilter)
        Elem.QuickTooltip(UILabels.search.tIconicFilter, Colour.Info)

        ImGui.SameLine()

        availX, _ = ImGui.GetContentRegionAvail()
        ImGui.PushItemWidth(availX)
        UIsearch.currentTier, tierFilterChanged = ImGui.Combo(
            "##qualityFilter",
            UIsearch.currentTier,
            qualityFilterList,
            #qualityFilterList
        )
        Elem.QuickTooltip(UILabels.search.tTierFilter, Colour.Info)

        if sTextChanged or listItemClicked or tierFilterChanged or iconicFilterChanged then
            if #UIsearch.searchText < 3 and (UIsearch.currentCat == 1 and UIsearch.currentType == 1) then
                UIsearch.threeChars = true
                UIsearch.searchResult = {}
            else
                UIsearch.threeChars = false
                -- Look up the raw type string from the SINGLE visibleTypeEntries
                -- array (a list of {str, raw} pairs). This guarantees the display
                -- name the user clicked and the raw type string passed to the
                -- search filter come from the exact same entry — they can never
                -- drift apart.
                local selEntry = UIsearch.visibleTypeEntries[UIsearch.currentType]
                local selRawType = selEntry and selEntry.raw or nil
                UIsearch.searchResult = ItemRecord.Search(
                    UIsearch.Items.records --[=[@as ItemRecord[]]=],
                    UIsearch.searchText,
                    { i = UIsearch.currentType, s = selRawType },
                    { i = UIsearch.currentCat, s = UIsearch.itemCats[UIsearch.currentCat]:gsub(" ", "") },
                    UIsearch.currentTier,
                    UIsearch.iconicFilter
                )
                UIsearch.newSearch = true
                UIsearch.currentItem = 0
                UIsearch.resultsOpen = true
            end
        end

        Elem.Separator()

        UIsearch.resultsOpen = Elem.ToggleHeaderMenu(
            UILabels.search.sResults:gsub("{#}", "("..tostring(#UIsearch.searchResult)..")"),
            UIsearch.SearchResults,
            UIsearch.resultsOpen
        )

        for i = 1, #UIsearch.resultList do
            if UIsearch.resultList[i] then
                if UIsearch.currentItem == 0 then
                    UIsearch.currentItemAddDesc = ""
                    UIsearch.currentItem = i
                    UIsearch.infoOpen = true
                elseif UIsearch.currentItem ~= i then
                    UIsearch.resultList[UIsearch.currentItem] = false
                    UIsearch.currentItemAddDesc = ""
                    UIsearch.currentItem = i
                    UIsearch.infoOpen = true
                end
            end
        end

        if #UIsearch.searchResult == 0 then UIsearch.infoOpen = false end

        Elem.Separator()

        local selItemData = UIsearch.searchResult[UIsearch.currentItem]
        ImGui.BeginDisabled(#UIsearch.searchResult == 0 or UIsearch.currentItem == 0)
        UIsearch.infoOpen = Elem.ToggleHeaderMenu(
            UILabels.search.iHeading,
            UIsearch.ItemInfo,
            UIsearch.infoOpen,
            selItemData
        )
        ImGui.EndDisabled()

        Elem.Separator()
        Elem.SectionHeading(UILabels.search.tAddItemsControl, Colour.Info, false)
        if #UIsearch.searchResult == 0 then UIsearch.currentItem = 0 end
        ImGui.BeginDisabled(#UIsearch.searchResult == 0)
        ImGui.AlignTextToFramePadding()
        local tx, _ = ImGui.CalcTextSize(UILabels.search.itemAmountLabel)
        ImGui.Text(UILabels.search.itemAmountLabel)
        ImGui.SameLine()
        ImGui.PushItemWidth(((width - (tx + 10)) / 2) - tx)
        local amountChanged
        UIsearch.aValue, amountChanged = ImGui.InputInt("##amount", UIsearch.aValue, 1, 10)
        if amountChanged and UIsearch.aValue < 1 then UIsearch.aValue = 1 end
        ImGui.PopItemWidth()

        ImGui.SameLine()

        availX, _ = ImGui.GetContentRegionAvail()
        ImGui.PushItemWidth(availX)
        UIsearch.overridequality = ImGui.Combo(
            UILabels.universalelements.forcequality.."##item",
            UIsearch.overridequality,
            qualityList,
            #qualityList
        )
        ImGui.PopItemWidth()
        Elem.QuickMultiTooltip({
            { text = UILabels.items.additems.tForceQual , colour = Colour.Warning },
            { text = UILabels.items.additems.tForceQual2, colour = Colour.Info },
            { text = UILabels.items.additems.tForceQual3, colour = Colour.Info }
        })

        local addItemLabel = UILabels.search.bSearchAdd:gsub("{#}", tostring(UIsearch.aValue))
        local addAllLabel  = UILabels.search.bSearchAddAll:gsub("{#}", tostring(UIsearch.aValue))
        if UIsearch.overridequality > 0 then
            addItemLabel = addItemLabel..UILabels.search.bSearchQual:gsub("{#}", qualityList[UIsearch.overridequality + 1])
            addAllLabel  = addAllLabel..UILabels.search.bSearchQual:gsub("{#}", qualityList[UIsearch.overridequality + 1])
        else
            addItemLabel = addItemLabel..UILabels.search.bSearchScale
            addAllLabel  = addAllLabel..UILabels.search.bSearchScale
        end

        if #UIsearch.searchResult > 0 then
            addAllLabel = addAllLabel..UILabels.search.bSearchAllCount:gsub("{#}", tostring(#UIsearch.searchResult * UIsearch.aValue))
        end

        if UIsearch.currentItem == 0 then
            addItemLabel = UILabels.search.bSearchNoItem
        end
        if #UIsearch.searchResult == 0 then
            addAllLabel = UILabels.search.bSearchNoSearch
        end

        ImGui.BeginDisabled(UIsearch.currentItem == 0)
        local addItemClicked = ImGui.Button(addItemLabel, width, 36)
        if(addItemClicked and selItemData ~= nil) then
            local okAdd, errAdd = pcall(
                UIsearch.Items.AddItem2, selItemData, UIsearch.aValue, UIsearch.overridequality
            )
            if not okAdd then
                print("[SimpleMenu] Failed to add item:", errAdd)
            end
        end
        ImGui.EndDisabled()

        local addAllClicked = ImGui.Button(addAllLabel, width, 36)
        Elem.QuickTooltip(UILabels.search.tSearchAddAll, Colour.Warning)
        if addAllClicked then
            -- Adds are queued and drained gradually (10 items per 0.1s) instead
            -- of dumping every search result into the inventory in a single
            -- frame. The synchronous flood was a crash risk and the main
            -- vector by which OTHER mods' items mass-contaminated savegames
            -- (see the "Savegame bricks after removing mods" section in the
            -- README). See Items.QueueAddItems in items/items.lua.
            UIsearch.Items.QueueAddItems(UIsearch.searchResult, UIsearch.aValue, UIsearch.overridequality)
        end
        ImGui.EndDisabled()
    elseif GameState.isLoaded and UIVisible and ModState.LoadingItemsState < LoadingState.Finished then
        local text
        if ModState.LoadedPercent == 0 then
            text = UILabels.search.preload
        else
            text = UILabels.search.loadingText:gsub("{#}", tostring(ModState.LoadedPercent))
        end
        local wx, _ = ImGui.GetWindowSize()
        local tx, _ = ImGui.CalcTextSize(text)
        ImGui.SetCursorPosX((wx - tx) * 0.5);
        ImGui.AlignTextToFramePadding()
        ImGui.TextDisabled(text)
        Elem.Separator()
    elseif UIVisible then
        Elem.InGameWarning(true)
    end
end

return UIsearch