local Elements = {}
local Colour = require("classes/colour")
local CUtil = require("misc/cetUtils")
local Util = require("config/util")

function Elements.Separator()
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
end

function Elements.DoubleSpace()
    ImGui.Spacing()
    ImGui.Spacing()
end

function Elements.TripleSpace()
    ImGui.Spacing()
    ImGui.Spacing()
    ImGui.Spacing()
end

function Elements.HeaderMenu(label, execute)
    if ImGui.CollapsingHeader(label) then
        ImGui.Spacing()
        execute()
    end
end

local function VCentreCellText(textHeight, contentRegionHeight)
    local padding = (contentRegionHeight - textHeight) / 2
    return padding - ImGui.GetStyle().CellPadding.y
end

local function HCentreCellText(textWidth, contentRegionWidth)
    local padding = (contentRegionWidth - textWidth) / 2
    return padding
end

function Elements.HCentredCellText(text, contentRegionWidth)
    local textW, _ = ImGui.CalcTextSize(text)
    ImGui.SetCursorPosX(ImGui.GetCursorPosX{} + HCentreCellText(textW, contentRegionWidth))
    ImGui.Text(text)
end

function Elements.VCentredCellText(text, contentRegionHeight)
    local _, textH = ImGui.CalcTextSize(text)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY{} + VCentreCellText(textH, contentRegionHeight))
    ImGui.Text(text)
end

function Elements.HVCentredCellText(text, contentRegionWidth, contentRegionHeight)
    local textW, textH = ImGui.CalcTextSize(text)
    ImGui.SetCursorPosX(ImGui.GetCursorPosX{} + HCentreCellText(textW, contentRegionWidth))
    ImGui.SetCursorPosY(ImGui.GetCursorPosY{} + VCentreCellText(textH, contentRegionHeight))
    ImGui.Text(text)
end

local function HCentreCellItem(itemWidth, contentRegionWidth)
    local padding = (contentRegionWidth - itemWidth) / 2
    return padding
end

local function VCentreCellItem(itemHeight, contentRegionHeight)
    local padding = (contentRegionHeight - itemHeight) / 2
    return padding - ImGui.GetStyle().CellPadding.y
end

function Elements.HVCentredCheckbox(label, var, checkSideLen, contentRegionWidth, contentRegionHeight)
    local checkedChanged = false
    ImGui.SetCursorPosX(ImGui.GetCursorPosX() + HCentreCellItem(checkSideLen, contentRegionWidth))
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + VCentreCellItem(checkSideLen, contentRegionHeight))
    var, checkedChanged = ImGui.Checkbox(label, var)
    return var, checkedChanged
end

---Header menu with optional indent and optional buttons on the right hand side
---@param label string
---@param execute function
---@param indent? number
---@param tooltip? string
---@param colour? Colour
---@param buttons? { label: string, func: function, tooltip?: string, offset?: number }[]
---@return boolean
function Elements.CustomHeaderMenu(label, execute, indent, tooltip, colour, buttons)
    indent = indent or -0.01
    local open = ImGui.CollapsingHeader(label, ImGuiTreeNodeFlags.AllowItemOverlap) --[[@as boolean]]
    if (ImGui.IsItemHovered() and not open and tooltip ~= nil) then
        colour = colour or Colour.Default
        local toolTexts = {
            { text = tooltip, colour = colour }
        }

        Elements.Tooltip(toolTexts, 600, true)
    end
    local headerW, headerH = ImGui.GetItemRectSize()

    if (buttons ~= nil and open) then
        local padX = ImGui.GetStyle().FramePadding.x
        local padY = ImGui.GetStyle().FramePadding.y
        local spaceX = ImGui.GetStyle().ItemSpacing.x
        local spaceY = ImGui.GetStyle().ItemSpacing.y
        local prevButtonW;
        local prevCurY;

        for k, v in pairs(buttons) do
            local labelSx, labelSy = ImGui.CalcTextSize(v.label, true)
            local curPosX = 0
            labelSx = labelSx + (2 * padX)
            v.offset = v.offset or 0

            if prevButtonW == nil then
                curPosX = (headerW - labelSx) + v.offset
                ImGui.SetCursorPosY(ImGui.GetCursorPosY() - (headerH + (padY / 2.5)))
                prevCurY = ImGui.GetCursorPosY()
            else
                curPosX = ((headerW - labelSx) - (prevButtonW + (spaceX / 2))) + v.offset
                ImGui.SetCursorPosY(prevCurY)
            end

            ImGui.SetCursorPosX(curPosX)
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, padX, 0)
            ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, spaceX / 2, spaceY)
            if ImGui.Button(v.label, labelSx, labelSy) then
                v.func()
            end
            ImGui.PopStyleVar(2)
            prevButtonW = labelSx

            if k == #buttons then
                ImGui.SetCursorPosY(ImGui.GetCursorPosY() + (padY))
            end
        end
    end

    if open then
        ImGui.BeginGroup()
        ImGui.Indent(indent)
        ImGui.Spacing()
        execute()
        ImGui.Unindent(indent)
        ImGui.EndGroup()
    end

    return open
end

function Elements.ToggleHeaderMenu(label, execute, open, arg)
    ImGui.SetNextItemOpen(open)
    open = ImGui.CollapsingHeader(label)
    if open then
        ImGui.Spacing()
        execute(arg)
    end
    return open
end

function Elements.TabMenu(label, execute)
    if (ImGui.BeginTabItem(label)) then
        ImGui.Spacing()
        execute()
    ImGui.EndTabItem()
    end
end

function Elements.InGameWarning(disabled)
    disabled = disabled or false
    ImGui.BeginDisabled(disabled)
    if (not GameState.isLoaded) then
        local text = UILabels.search.inGameWarn
        local wx, _ = ImGui.GetWindowSize()
        local tx, _ = ImGui.CalcTextSize(text)
        ImGui.SetCursorPosX((wx - tx) * 0.5);
        ImGui.AlignTextToFramePadding()
        ImGui.Text(UILabels.search.inGameWarn)
        Elements.Separator()
    end
    ImGui.EndDisabled()
end

function Elements.CustomCenteredText(text, colour, scale, sep)
    scale = scale or 1
    if sep == nil then sep = true end
    local wx, _ = ImGui.GetWindowSize()
    local tx, _ = ImGui.CalcTextSize(text)
    tx = tx * scale
    ImGui.SetCursorPosX((wx - tx) * 0.5)
    Elements.Text(text, false, true, colour, scale)
    if sep then Elements.Separator() end
end

local uScore = "_"
function Elements.SectionHeading(text, colour, topSep)
    if topSep == nil then topSep = true end

    local tx, ty = ImGui.CalcTextSize(text)
    local ux, _ = ImGui.CalcTextSize(uScore)
    local scores = CUtil.Round(tx / ux, 0, 0.2)
    local underLn = string.rep(uScore, scores)
    local padY = (ImGui.GetStyle().FramePadding.y)
    local winX = (ImGui.GetStyle().WindowPadding.x)

    if topSep then
        Elements.Separator()
    end

    ImGui.SetCursorPosY(ImGui.GetCursorPosY() - padY)
    Elements.Text(text, false, true, colour)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() - (ty + (padY / 2)))
    ImGui.BeginDisabled()
    Elements.Text(underLn, false, true, colour)
    ImGui.SameLine(winX) ImGui.Dummy(50, 10)
    ImGui.EndDisabled()
    ImGui.Spacing()
end

---Create a text element, with customisations
---@param text string       --[required] The text to render
---@param wrapped boolean?  --[optional] Whether the text should wrap
---@param coloured boolean? --[optional] Whether the text should be rendered in colour
---@param colour Colour?    --[optional] The colour to render the text in (does nothing without `coloured`)
---@param scale number?     --[optional] Scaling factor for text - 1.0 is the default, 0.5 is half, 2.0 is double, etc
function Elements.Text(text, wrapped, coloured, colour, scale)
    wrapped = wrapped or false
    coloured = coloured or false
    scale = scale or 1.0

    if coloured and colour ~= nil then
        ImGui.PushStyleColor(ImGuiCol.Text, colour:Params())
    end

    if scale ~= 1.0 then ImGui.SetWindowFontScale(scale) end
    if wrapped then
        ImGui.TextWrapped(text)
    else
        ImGui.Text(text)
    end
    if scale ~= 1.0 then ImGui.SetWindowFontScale(1.0) end

    if coloured and colour ~= nil then
        ImGui.PopStyleColor()
    end
end

---Customisable Tooltip
---@param textList { text: string, colour: Colour? }[] -- [required] An array of { text: `string`, colour: `Colour?` } tuples (`colour` defaults to white)
---@param maxWidth number?                             -- [optional] The maximum width of the tooltip (default: 400)
---@param doubleSpaced boolean?                        -- [optional] Whether to create a bigger vertical space between text items (default: false)
function Elements.Tooltip(textList, maxWidth, doubleSpaced)
    if textList == nil or #textList == 0 then return end
    maxWidth = maxWidth or 400
    doubleSpaced = doubleSpaced or false

    ---@type number[]
    local textWidths = {}
    local winX = (ImGui.GetStyle().WindowPadding.x) * 2
    for _, tv in pairs(textList) do

        local x, _ = ImGui.CalcTextSize(tv.text, true, maxWidth) --[[@as number]]
        table.insert(textWidths, x)
    end

    local width = math.max(unpack(textWidths))
    ImGui.SetNextWindowSizeConstraints(width + winX, 0, width + winX, 1000)
    ImGui.BeginTooltip()
    for i, tv in pairs(textList) do
        local colour = tv.colour or Colour.Default
        Elements.Text(tv.text, true, true, colour)
        if doubleSpaced and i < #textList then ImGui.Spacing() end
    end
    ImGui.EndTooltip()
end

---Shows a default 600px wide Tooltip for one text item, colour optional.
---Call this directly after the element you want a tooltip on.
---@param text string     -- [required] the text to put in the tooltip
---@param colour Colour?  -- [optional] the colour to render it as (default: white)
---@param width number?   -- [optional] width in pixels (default: 600px)
function Elements.QuickTooltip(text, colour, width)
    colour = colour or Colour.Default
    width = width or 600
    Elements.QuickMultiTooltip({
        { text = text, colour = colour}
    }, false, width)
end

---Shows a default 600px wide tooltip with multiple texts and optional colours.
---Call this directly after the element you want a tooltip on.
---@param toolTips { text: string, colour: Colour? }[] -- [required] an array of text/colour tuples that represent the tooltip
---@param dbSpc boolean?                               -- [optional] whether to double-space multi-line tooltip (default: true)
---@param width number?                                -- [optional] width in pixels (default: 600px)
function Elements.QuickMultiTooltip(toolTips, dbSpc, width)
    if dbSpc == nil then dbSpc = true end
    width = width or 600

    if ImGui.IsItemHovered() then
        Elements.Tooltip(toolTips, width, dbSpc)
    end
end

return Elements