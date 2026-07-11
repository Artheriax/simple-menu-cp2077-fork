local UIcraft = {
    knownRecipeSel = {},
    currentKnown = 0,
    multiSelKnown = false,
    rangeSelKnown = false,
    rangeSelKnownRange = 1,
    knownSearch = "",
    knownSearchDone = false,
    knownDisplayContext = {},
    knownSelectionIds = {},
    unknownRecipeSel = {},
    currentUnknown = 0,
    multiSelUnknown = false,
    rangeSelUnknown = false,
    rangeSelUnknownRange = 1,
    unknownSearch = "",
    unknownSearchDone = false,
    unknownDisplayContext = {},
    unknownSelectionIds = {},
}

-- Aliases
---@alias KnownRecipe { id: any, name: string, num: number, q: string, i: boolean, hide: boolean }
---@alias UnknownRecipe { id: any, name: string, q: string, i: boolean, hide: any[] }

local Elem = require("ui/elements")
local CUtil = require("misc/cetUtils")
local Util = require("config/util")
local Colour = require("classes/colour")
local DeprecatedRecipes = require("misc/deprecatedRecipes")

-- Local vars
local preloadComplete = false
local pendingRequest = true

---@type KnownRecipe[]
local knownRecipes

---@type KnownRecipe[]
local knownUnhiddenRecipes

---@type UnknownRecipe[]
local availRecipes

local craftingSystem
local craftBook

local function printSelected(current, selectables)
    DEBUG_printl(LOG_LEVEL.Trace,
        "Currently selected:", current..",",
        "is in range:", selectables[current].inRange,
        "is in multi:", selectables[current].inMulti
    )
end

local function clearSelected(selectables, known, preserveIds)
    preserveIds = preserveIds or false

    for _, v in pairs(selectables) do
        v.selected = false
        v.inRange = false
        v.inMulti = false
    end

    local text = Util.T(known, "known", "unknown")
    if known then
        UIcraft.currentKnown = 0
        UIcraft.rangeSelKnownRange = 1
        if not preserveIds then UIcraft.knownSelectionIds = {} end
    else
        UIcraft.currentUnknown = 0
        UIcraft.rangeSelUnknownRange = 1
        if not preserveIds then UIcraft.unknownSelectionIds = {} end
    end

    if not preserveIds then DEBUG_printl(LOG_LEVEL.Info, "Cleared", text, "selections") end
    return 0, 1
end

local function addSelectedId(idList, context, index)
    local itemId = context[index].id
    local indexInList = CUtil.IndexOf(idList, itemId)
    if indexInList == -1 then
        table.insert(idList, itemId)
        DEBUG_printl(LOG_LEVEL.Trace, "Added to selection:", itemId.value)
    end
end

local function removeSelectedId(idList, context, index)
    local itemId = context[index].id
    local indexInList = CUtil.IndexOf(idList, itemId)
    if indexInList ~= -1 then
        table.remove(idList, indexInList)
        DEBUG_printl(LOG_LEVEL.Trace, "Removed from selection:", itemId.value)
    end
end

local function processListBoxSelection(selectables, current, context, rangeSelect, range, multiSelect, idList, known)
    local checkedReg, checkedRange, checkedMulti, clickedClear = false, false, false, false
    local radioValue = 0
    local rbx = 0
    local radiosWidth = 0

    if rangeSelect then radioValue = 1 end
    if multiSelect then radioValue = 2 end

    radioValue, checkedReg = ImGui.RadioButton(UILabels.crafting.stdSelect.."##known="..tostring(known), radioValue, 0)
    rbx, _ = ImGui.GetItemRectSize()
    radiosWidth = radiosWidth + rbx
    Elem.QuickMultiTooltip({
        { text = UILabels.crafting.tStdSelect, colour = Colour.Info },
        { text = UILabels.crafting.tMultiSelect2, colour = Colour.Warning },
    })
    ImGui.SameLine()
    radioValue, checkedRange = ImGui.RadioButton(UILabels.crafting.multiSelect.."##known="..tostring(known), radioValue, 1)
    rbx, _ = ImGui.GetItemRectSize()
    radiosWidth = radiosWidth + rbx
    Elem.QuickMultiTooltip({
        { text = UILabels.crafting.tMultiSelect1, colour = Colour.Info },
        { text = UILabels.crafting.tMultiSelect2, colour = Colour.Warning },
    })
    ImGui.SameLine()
    radioValue, checkedMulti = ImGui.RadioButton(UILabels.crafting.separateSelect.."##known="..tostring(known), radioValue, 2)
    rbx, _ = ImGui.GetItemRectSize()
    radiosWidth = radiosWidth + rbx
    Elem.QuickMultiTooltip({
        { text = UILabels.crafting.tSeparateSelect, colour = Colour.Info },
        { text = UILabels.crafting.tMultiSelect2, colour = Colour.Warning },
    })

    if radioValue == 0 then
        rangeSelect = false
        multiSelect = false
    elseif radioValue == 1 then
        rangeSelect = true
        multiSelect = false
    else
        rangeSelect = false
        multiSelect = true
    end

    local itemSpc = (ImGui.GetStyle().ItemSpacing.x) * 3
    local buttonWidth = ImGui.GetWindowContentRegionWidth() - (radiosWidth + itemSpc)
    ImGui.BeginDisabled(current == 0)
    ImGui.SameLine() clickedClear = ImGui.Button(UILabels.crafting.clearSelect.."##known="..tostring(known), buttonWidth, 0)
    ImGui.EndDisabled()
    if checkedRange or checkedMulti or checkedReg or clickedClear then
        current, range = clearSelected(selectables, known)
    end

    for k, v in pairs(selectables) do
        if not rangeSelect then
            if v.selected and range == 1 then
                if current == 0 then
                    current = k
                    if multiSelect then
                        v.inMulti = true
                        addSelectedId(idList, context, current)
                    end
                    printSelected(current, selectables)
                elseif current ~= k and range == 1 and not multiSelect then
                    selectables[current].selected = false
                    current = k
                    printSelected(current, selectables)
                elseif multiSelect and not v.inMulti then
                    v.inMulti = true
                    current = k
                    addSelectedId(idList, context, current)
                end
            end

            if multiSelect and not v.selected and v.inMulti then
                v.inMulti = false
                removeSelectedId(idList, context, k)
            end
        else
            if v.selected then
                if current == 0 then
                    current = k
                    v.inRange = true
                    addSelectedId(idList, context, current)
                elseif current ~= k and range == 1 then
                    local min = math.min(current, k)
                    local max = math.max(current, k)
                    range = max - (min - 1)

                    for i = min, max do
                        selectables[i].selected = true
                        selectables[i].inRange = true
                        addSelectedId(idList, context, i)
                    end

                    if min < current then current = min end
                    DEBUG_printl(LOG_LEVEL.Trace, "Selected range:", min, "-", max, "(total = "..range..")")
                end
            end
            if v.inRange and not v.selected then
                v.selected = true
                addSelectedId(idList, context, k)
            elseif not v.inRange and v.selected then
                v.selected = false
                removeSelectedId(idList, context, k)
            end
        end
    end

    return current, rangeSelect, multiSelect, range
end

function RefreshCraftBookMenu()
    clearSelected(UIcraft.knownRecipeSel, true, false)
    clearSelected(UIcraft.unknownRecipeSel, false, false)
    UIcraft.Refresh()
end

local prefixTemplate = "[{#}] "
local tierTemplate  = "[{#}]"
local parenTemplate = " ({#})"
local itemInfixTemplate = " {#} "
---Returns the string representation of a recipe
---@param recipe KnownRecipe | UnknownRecipe
local function recipeString(prefix, recipe, debug)
    debug = debug or false
    if type(prefix ~= "string") then prefix = tostring(prefix) end

    local prefStr = prefixTemplate:gsub("{#}", prefix)
    local nameStr = itemInfixTemplate:gsub("{#}", recipe.name)
    local qualStr = tierTemplate:gsub("{#}", recipe.q)

    local str = prefStr..nameStr..qualStr

    if recipe.i then
        local iconStr = parenTemplate:gsub("{#}", UILabels.universalelements.iconic)
        str = str..iconStr
    end

    if debug then
        local idStr = parenTemplate:gsub("{#}", recipe.id.value)
        str = str..idStr..","
    end

    return str
end

local function addRecipe(list, index, refresh)
    refresh = refresh or false
    local recipe = list[index]
    local knownIndex = CUtil.IndexOf(knownRecipes, recipe.id, "id")

    if knownIndex == -1 then
        craftBook:AddRecipe(recipe.id, recipe.hide, 1)
    else
        craftBook:HideRecipe(recipe.id, false)
    end

    DEBUG_printl(LOG_LEVEL.Trace, "Added:", recipeString(index, recipe, true), "refresh:", refresh)

    if refresh then
        pendingRequest = true
        Cron.After(0.33, RefreshCraftBookMenu)
    end
end

local function addRecipesFromSelections(list, selections)
    for i = 1, #selections do
        local index = CUtil.IndexOf(list, selections[i], "id")
        if index ~= -1 then
            addRecipe(list, index, i == #selections)
        end
    end
end

local function addRecipeRange(list, from, to)
    for i = from, to do
        addRecipe(list, i, i == to)
    end
end

local function removeRecipe(list, index, refresh)
    refresh = refresh or false
    local recipe = list[index]
    craftBook:HideRecipe(recipe.id, true)

    DEBUG_printl(LOG_LEVEL.Trace, "Removed:,", recipeString(index, recipe, true), "refresh:", refresh)

    if refresh then
        pendingRequest = true
        Cron.After(0.33, RefreshCraftBookMenu)
    end
end

local function removeRecipeRange(list, from, to)
    for i = from, to do
        removeRecipe(list, i, i == to)
    end
end

local function removeRecipesFromSelections(list, selections)
    for i = 1, #selections do
        local index = CUtil.IndexOf(list, selections[i], "id")
        if index ~= -1 then
            removeRecipe(list, index, i == #selections)
        end
    end
end

local function searchRecipes(text, recipes, iconic)
    if (text ~= "" or text ~= nil) then
        return CUtil.ArrayWhere(
            recipes,
            ---@param v KnownRecipe
            function(v)
                if string.find(v.name:upper(), text:upper(), nil, true) then
                    if iconic then
                        return v.i
                    else
                        return true
                    end
                end
                return false
            end
        ), true
    else
        if iconic then
            return CUtil.ArrayWhere(
                recipes,
                function(v)
                    return v.i
                end
            ), true
        end
        return recipes, true
    end
end

local function setSelectedIds(selectionList, recipeList, selRecipeIdList, rangeSelect)
    local currentIndex = Util.T(#selRecipeIdList == 0, 0, #selectionList)
    local range = Util.T(rangeSelect and #selRecipeIdList ~= 0, #selRecipeIdList, 1)
    for _, v in pairs(selRecipeIdList) do
        local index = CUtil.IndexOf(recipeList, v, "id")
        if index ~= -1 then
            currentIndex = math.min(currentIndex, index)
            selectionList[index].selected = true
            selectionList[index].inRange = true
        end
    end
    return currentIndex, range
end

local tableFlags = bit32.bor(
    ImGuiTableFlags.BordersOuterH,
    ImGuiTableFlags.BordersOuterV,
    ImGuiTableFlags.SizingFixedFit,
    ImGuiTableFlags.NoHostExtendY,
    ImGuiTableFlags.ScrollY
)

local tableRowH = 27

local function tableHeaderSetup(id, qh, ih)
    ImGui.TableSetupColumn(" #", ImGuiTableColumnFlags.WidthFixed, id)
    ImGui.TableSetupColumn(UILabels.universalelements.name, ImGuiTableColumnFlags.WidthStretch)
    ImGui.TableSetupColumn(UILabels.universalelements.quality, ImGuiTableColumnFlags.WidthFixed, qh)
    ImGui.TableSetupColumn(UILabels.universalelements.iconic, ImGuiTableColumnFlags.WidthFixed, ih)
    ImGui.TableSetupScrollFreeze(0, 1)
    ImGui.TableHeadersRow()
end

local knownIconics, knownIconicCheck = false, false
local function MenuCraftbook()
    local width = ImGui.GetWindowContentRegionWidth()
    local padL = CUtil.PadLength(#knownUnhiddenRecipes)
    local labelX, _ = ImGui.CalcTextSize(UILabels.crafting.nameSearch)

    local checkWidth, _ = ImGui.GetItemRectSize()
    knownIconics, knownIconicCheck = ImGui.Checkbox(
        UILabels.universalelements.iconicF.."##knownIconic",
        knownIconics
    )

    local sTextChanged
    ImGui.SameLine()
    UIcraft.knownSearch, sTextChanged = ImGui.InputTextMultiline(
        UILabels.crafting.nameSearch.."##searchKnownTextInput", UIcraft.knownSearch,
        32, width - (labelX + checkWidth), 40, ImGuiInputTextFlags.CtrlEnterForNewLine
    )
    Elem.QuickTooltip(UILabels.crafting.tNameSearch, Colour.Info)

    if sTextChanged or knownIconicCheck or not UIcraft.knownSearchDone then
        UIcraft.knownSearchDone = false
        UIcraft.knownDisplayContext, UIcraft.knownSearchDone = searchRecipes(
            UIcraft.knownSearch,
            knownUnhiddenRecipes,
            knownIconics
        )
        UIcraft.currentKnown, UIcraft.rangeSelKnownRange = clearSelected(UIcraft.knownRecipeSel, true, true)
        UIcraft.currentKnown, UIcraft.rangeSelKnownRange
            = setSelectedIds(
                UIcraft.knownRecipeSel,
                UIcraft.knownDisplayContext,
                UIcraft.knownSelectionIds,
                UIcraft.rangeSelKnown
            )
    end

    ImGui.Spacing()

    if (ImGui.BeginChild("tableWrapper-knownRecipeList", width, 350)) then
        if ImGui.BeginTable("knownRecipeList", 4, tableFlags, width, 350) then
            local qHeadX, textH = ImGui.CalcTextSize(UILabels.universalelements.quality)
            local iHeadX, _ = ImGui.CalcTextSize(UILabels.universalelements.iconic)
            local idHeadX, _ = ImGui.CalcTextSize(string.rep("0", padL))
            local rowHeight = math.max(tableRowH, textH)
            tableHeaderSetup(idHeadX + 20, qHeadX + 20, iHeadX + 20)
            ImGui.TableNextRow(rowHeight, ImGuiTableRowFlags.None)
            ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, 0x00000000)

            for k, v in pairs(UIcraft.knownDisplayContext) do
                local padK = CUtil.Pad(tostring(k), padL, "0")
                if UIcraft.knownRecipeSel[k] == nil then
                    UIcraft.knownRecipeSel[k] = { selected = false, inRange = false, inMulti = false }
                end
                ImGui.TableNextColumn()
                UIcraft.knownRecipeSel[k] = {
                    selected = ImGui.Selectable(
                        padK.."##knownRecipe"..k,
                        UIcraft.knownRecipeSel[k].selected,
                        ImGuiSelectableFlags.SpanAllColumns,
                        width, rowHeight
                    ),
                    inRange = UIcraft.knownRecipeSel[k].inRange,
                    inMulti = UIcraft.knownRecipeSel[k].inMulti
                }
                Elem.QuickTooltip("ID: "..v.id.value, Colour.Disabled)
                ImGui.TableNextColumn()
                ImGui.Text(v.name)
                ImGui.TableNextColumn()
                ImGui.Text(v.q)
                ImGui.TableNextColumn()
                if v.i then
                    ImGui.Text(UILabels.universalelements.yes)
                else
                    ImGui.Text("--")
                end
            end
            ImGui.TableSetColumnIndex(0)
            ImGui.EndTable()
        end
        ImGui.EndChild()
    end

    ImGui.Spacing()

    UIcraft.currentKnown,
    UIcraft.rangeSelKnown,
    UIcraft.multiSelKnown,
    UIcraft.rangeSelKnownRange = processListBoxSelection(
        UIcraft.knownRecipeSel,
        UIcraft.currentKnown,
        UIcraft.knownDisplayContext,
        UIcraft.rangeSelKnown,
        UIcraft.rangeSelKnownRange,
        UIcraft.multiSelKnown,
        UIcraft.knownSelectionIds,
        true
    )

    local buttonWidth, _ = ImGui.GetContentRegionAvail()
    local buttonText = UILabels.crafting.remRecipe
    if UIcraft.rangeSelKnown or UIcraft.multiSelKnown then buttonText = buttonText.."s" end

    ImGui.BeginDisabled(UIcraft.currentKnown == 0 or (UIcraft.rangeSelKnown and UIcraft.rangeSelKnownRange == 1))
    if ImGui.Button(buttonText, buttonWidth, 0) then
        if UIcraft.rangeSelKnownRange > 1 then
            local endIndex = (UIcraft.currentKnown + UIcraft.rangeSelKnownRange) - 1
            DEBUG_printl(LOG_LEVEL.Trace, "Removing recipes:", UIcraft.currentKnown, "to", endIndex)
            removeRecipeRange(UIcraft.knownDisplayContext, UIcraft.currentKnown, endIndex)
        else
            if UIcraft.multiSelKnown then
                removeRecipesFromSelections(UIcraft.knownDisplayContext, UIcraft.knownSelectionIds)
            else
                removeRecipe(UIcraft.knownDisplayContext, UIcraft.currentKnown, true)
            end
        end
    end
    ImGui.EndDisabled()

    Elem.Separator()
end

local unknownIconics, unknownIconicCheck = false, false
local function MenuOtherRecipes()
    local width = ImGui.GetWindowContentRegionWidth()
    local padL = CUtil.PadLength(#availRecipes)
    local labelX, _ = ImGui.CalcTextSize(UILabels.crafting.nameSearch)

    local checkWidth, _ = ImGui.GetItemRectSize()
    unknownIconics, unknownIconicCheck = ImGui.Checkbox(
        UILabels.universalelements.iconicF.."##unknownIconic",
        unknownIconics
    )

    local sTextChanged
    ImGui.SameLine()
    UIcraft.unknownSearch, sTextChanged = ImGui.InputTextMultiline(
        UILabels.crafting.nameSearch.."##searchUnknownTextInput", UIcraft.unknownSearch,
        32, width - (labelX + checkWidth), 40, ImGuiInputTextFlags.CtrlEnterForNewLine
    )
    Elem.QuickTooltip(UILabels.crafting.tNameSearch, Colour.Info)

    if sTextChanged or unknownIconicCheck or not UIcraft.unknownSearchDone then
        UIcraft.unknownSearchDone = false
        UIcraft.unknownDisplayContext, UIcraft.unknownSearchDone = searchRecipes(
            UIcraft.unknownSearch,
            availRecipes,
            unknownIconics
        )
        UIcraft.currentUnknown, UIcraft.rangeSelUnknownRange = clearSelected(UIcraft.unknownRecipeSel, false, true)
        UIcraft.currentUnknown, UIcraft.rangeSelUnknownRange
            = setSelectedIds(
                UIcraft.unknownRecipeSel,
                UIcraft.unknownDisplayContext,
                UIcraft.unknownSelectionIds,
                UIcraft.rangeSelUnknown
            )
    end

    ImGui.Spacing()

    if (ImGui.BeginChild("tableWrapper-unknownRecipeList", width, 350)) then
        if ImGui.BeginTable("unknownRecipeList", 4, tableFlags, width, 350) then
            local qHeadX, textH = ImGui.CalcTextSize(UILabels.universalelements.quality)
            local iHeadX, _ = ImGui.CalcTextSize(UILabels.universalelements.iconic)
            local idHeadX, _ = ImGui.CalcTextSize(string.rep("0", padL))
            local rowHeight = math.max(tableRowH, textH)
            tableHeaderSetup(idHeadX + 20, qHeadX + 20, iHeadX + 20)
            ImGui.TableNextRow(rowHeight)
            ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, 0x00000000)

            for k, v in pairs(UIcraft.unknownDisplayContext) do
                local padK = CUtil.Pad(tostring(k), padL, "0")
                if UIcraft.unknownRecipeSel[k] == nil then
                    UIcraft.unknownRecipeSel[k] = { selected = false, inRange = false }
                end
                ImGui.TableNextColumn()
                UIcraft.unknownRecipeSel[k] = {
                    selected = ImGui.Selectable(
                        padK.."##unknownRecipe"..k,
                        UIcraft.unknownRecipeSel[k].selected,
                        ImGuiSelectableFlags.SpanAllColumns,
                        width, rowHeight
                    ),
                    inRange = UIcraft.unknownRecipeSel[k].inRange
                }
                Elem.QuickTooltip("ID: "..v.id.value, Colour.Disabled)
                ImGui.TableNextColumn()
                ImGui.Text(v.name)
                ImGui.TableNextColumn()
                ImGui.Text(v.q)
                ImGui.TableNextColumn()
                if v.i then
                    ImGui.Text(UILabels.universalelements.yes)
                else
                    ImGui.Text("--")
                end
            end
            ImGui.TableSetColumnIndex(0)
            ImGui.EndTable()
        end
        ImGui.EndChild()
    end

    ImGui.Spacing()

    UIcraft.currentUnknown,
    UIcraft.rangeSelUnknown,
    UIcraft.multiSelUnknown,
    UIcraft.rangeSelUnknownRange = processListBoxSelection(
        UIcraft.unknownRecipeSel,
        UIcraft.currentUnknown,
        UIcraft.unknownDisplayContext,
        UIcraft.rangeSelUnknown,
        UIcraft.rangeSelUnknownRange,
        UIcraft.multiSelUnknown,
        UIcraft.unknownSelectionIds,
        false
    )

    local buttonWidth, _ = ImGui.GetContentRegionAvail()
    local buttonText = UILabels.crafting.addRecipe
    if UIcraft.rangeSelUnknown or UIcraft.multiSelUnknown then buttonText = buttonText.."s" end

    ImGui.BeginDisabled(UIcraft.currentUnknown == 0 or (UIcraft.rangeSelUnknown and UIcraft.rangeSelUnknownRange == 1))
    if ImGui.Button(buttonText, buttonWidth, 0) then
        if UIcraft.rangeSelUnknownRange > 1 then
            local endIndex = (UIcraft.currentUnknown + UIcraft.rangeSelUnknownRange) - 1
            DEBUG_printl(LOG_LEVEL.Trace, "Adding recipes:", UIcraft.currentUnknown, "to", endIndex)
            addRecipeRange(UIcraft.unknownDisplayContext, UIcraft.currentUnknown, endIndex)
        else
            if UIcraft.multiSelUnknown then
                addRecipesFromSelections(UIcraft.unknownDisplayContext, UIcraft.unknownSelectionIds)
            else
                addRecipe(UIcraft.unknownDisplayContext, UIcraft.currentUnknown, true)
            end
        end
    end
    ImGui.EndDisabled()

    Elem.Separator()
end

local knc, unc = true, true
function UIcraft.TabCrafting()
    if GameState.isLoaded and preloadComplete then
        ImGui.BeginDisabled(pendingRequest)
        local knownHeader = UILabels.crafting.tCraftBook
        local unknownHeader = UILabels.crafting.tOtherRecipes

        if UIcraft.rangeSelKnownRange > 1 then
            knownHeader = UILabels.crafting.tCraftBookSel:gsub("{#}", tostring(UIcraft.rangeSelKnownRange))
            knc = true
        elseif #UIcraft.knownSelectionIds > 0 then
            knownHeader = UILabels.crafting.tCraftBookSel:gsub("{#}", tostring(#UIcraft.knownSelectionIds))
            knc = true
        end

        if UIcraft.rangeSelUnknownRange > 1 then
            unknownHeader = UILabels.crafting.tOtherRecipesSel:gsub("{#}", tostring(UIcraft.rangeSelUnknownRange))
            unc = true
        elseif #UIcraft.unknownSelectionIds > 0 then
            unknownHeader = UILabels.crafting.tCraftBookSel:gsub("{#}", tostring(#UIcraft.unknownSelectionIds))
            unc = true
        end

        knc = Elem.ToggleHeaderMenu(knownHeader, MenuCraftbook, knc)
        unc = Elem.ToggleHeaderMenu(unknownHeader, MenuOtherRecipes, unc)
        ImGui.EndDisabled()
    else
        Elem.InGameWarning(true)
    end
end

local function GetNameFromTDBID(TDBID, default)
    local item = TweakDB:GetRecord(TDBID)
    if item == nil then return default end
    local gotLk, locKey = pcall(function() return item:DisplayName() end)
    local gotName, itemName = pcall(
        function()
            if gotLk then
                return Game.GetLocalizedTextByKey(locKey)
            else
                error("No LocKey!", 1)
            end
        end
    )

    if gotName then return itemName else return Util.T(default ~= nil, default, nil) end
end

local function GetQualityFromTDBID(TDBID, default)
    local item = TweakDB:GetRecord(TDBID)
    if item == nil then return default end
    local q = item:Quality():Type()
    if q == nil then return Util.T(default ~= nil, default, nil) end
    if q == gamedataQuality.Random then return "Random" end
    return GetLocalizedText(UIItemsHelper.QualityToTierPlusString(q))
end

local function GetIconicFromTDBID(TDBID)
    local gotIconic, iconic = pcall(
        function()
            local iconicRec = TweakDB:GetRecord('Quality.IconicItem')
            local item = TweakDB:GetRecord(TDBID)
            if item == nil then return false end
            local isIconic = item:StatModifiersContains(iconicRec)
            if isIconic then return true else return false end
        end
    )

    if gotIconic then return iconic else return false end
end

function UIcraft.Refresh()
    DEBUG_printl(LOG_LEVEL.Info, "Calling UIcraft.Refresh()")
    local startTime = os.clock()
    preloadComplete = false
    knownRecipes = {}
    knownUnhiddenRecipes = {}
    availRecipes = {}
    UIcraft.knownSearchDone = false
    UIcraft.unknownSearchDone = false

    local function sortFunc(a, b)
        if a.name < b.name then
            return true
        elseif a.name == b.name then
            if a.q < b.q then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    craftingSystem = CraftingSystem.GetInstance()
    craftBook = craftingSystem:GetPlayerCraftBook()
    knownRecipes = CUtil.ArrayProjectSafe(
        craftBook.knownRecipes,
        function(v)
            local name = GetNameFromTDBID(v.targetItem, "#ERROR#")
            local qual = GetQualityFromTDBID(v.targetItem, "#ERROR#")
            local iconic = GetIconicFromTDBID(v.targetItem)
            return {
                id = v.targetItem,
                name = name,
                num = v.amount,
                q = qual,
                i = iconic,
                hide = v.isHidden
            }
        end,
        true,
        "id"
    )

    table.sort(knownRecipes, sortFunc)

    knownUnhiddenRecipes = CUtil.ArrayProjectSafe(
        knownRecipes,
        function(v)
            if not v.hide then return v end
        end
    )

    DEBUG_printl(LOG_LEVEL.Info,
        "Got Player Craftbook:", tostring(craftBook ~= nil)..",",
        "Total recipe count:", #knownRecipes,
        "Unhidden recipes:", #knownUnhiddenRecipes
    )

    local allRecipes = TweakDB:GetRecords("gamedataItemRecipe_Record")
    local deprCName = CName.new("DeprecatedRecipe")
    DEBUG_printl(LOG_LEVEL.Trace, "Total recipe count:", #allRecipes)

    local knownIds = CUtil.ArrayProject(knownUnhiddenRecipes, function(v) return v.id.value end)
    availRecipes = CUtil.ArrayProjectSafe(
        allRecipes,
        function(v)
            local gotResult, craftResult = pcall(function() return v:CraftingResult():Item():GetID() end)

            local isDeprecated = (
                not gotResult or
                v:TagsContains(deprCName) or
                CUtil.Exists(DeprecatedRecipes, craftResult.value) or
                CUtil.Exists(knownIds, craftResult.value)
            )

            if not isDeprecated then
                local itemName = GetNameFromTDBID(craftResult, "#ERROR#")
                local quality = GetQualityFromTDBID(craftResult, "#ERROR#")
                local iconic =  GetIconicFromTDBID(craftResult)

                if itemName ~= nil and quality ~= nil then
                    local hideItems = v:HideOnItemsAdded()
                    return { id = craftResult, name = itemName, q = quality, i = iconic, hide = hideItems }
                end
            end
        end,
        true,
        "id"
    )

    table.sort(availRecipes, sortFunc)

    DEBUG_printl(LOG_LEVEL.Info,
        "Available recipe count:", tostring(#availRecipes)..",",
        "Recipe refresh took:", CUtil.Round(((os.clock() - startTime) * 1000), 3).."ms"
    )

    preloadComplete = true
    pendingRequest = false
end

return UIcraft