local CetUtils = {
    player = nil,
    ts = nil,
    ss = nil
}

local function RefreshSystems()
    CetUtils.player = Game.GetPlayer()
    CetUtils.ts = Game.GetTransactionSystem()
    CetUtils.ss = Game.GetStatsSystem()
end

function CetUtils.EnumName(enum, value)
    for k, v in pairs(enum) do
        if v == value then return k end
    end

    return ""
end

function CetUtils.GetLocalizedPerkName(newPerkType)
    -- pcall + nil-guard: this is called EVERY FRAME while the Player tab's
    -- perk section is open (Perks.GetPerkNames -> this). The perk enum list
    -- is hardcoded per game version; if a single "NewPerks.<name>" record
    -- doesn't resolve on the user's game version (or TweakDB hiccups during
    -- a load transition), an unguarded chain here would crash the whole UI
    -- draw pass on every frame.
    local okRec, record = pcall(function() return TweakDB:GetRecord("NewPerks."..newPerkType.value) end)
    if not okRec or record == nil then return "" end

    local okKey, locKey = pcall(function()
        return record:Loc_name_key():upper():gsub("(LOCKEY#)(%d+)", "%2")
    end)
    if not okKey or locKey == nil then return "" end

    local x, nameStr = pcall(function() return Game.GetLocalizedTextByKey(CName.new(tonumber(locKey))) end)
    if x then return nameStr else return "" end
end

function CetUtils.GetPerkLvlCount(newPerkType)
    local okRec, record = pcall(function() return TweakDB:GetRecord("NewPerks."..newPerkType.value) end)
    if not okRec or record == nil then return 0 end

    local okCount, count = pcall(function() return record:GetLevelsCount() end)
    if not okCount or count == nil then return 0 end
    return count
end

function CetUtils.StringEmptyOrWhitespace(str)
    if #str == 0 then return true end

    for i = 1, #str do
        if not str:sub(i,i):find("%s") then return false end
    end

    return true
end

function CetUtils.p(i, f, ...)
    if type(i) == "table" then
        if f == nil then
            CetUtils.PrintTable(i)
        else
            CetUtils.PrintTableF(i, f)
        end
    elseif type(i) == "userdata" then
        local succ, err = pcall(function() print(Dump(i, false)) end)
        if not succ then
            print(err, i)
        else
            if f == nil then
                print(i, ...)
            else
                f(i)
            end
        end
    else
        print(i, ...)
    end
end

---Gets the pad length of a number (exponent + 1)
---@param val number
---@return integer
function CetUtils.PadLength(val)
    return (math.floor(math.log10(val)) + 1)
end

---Pad a string `str` to length `l`, optionally with character `c`, optionally to the `right`
---@param str string     -- [required] any non-null string
---@param l number       -- [required] length to pad to
---@param c string?      -- [optional] character to pad with (default: ' ')
---@param right boolean? -- [optional] pad to the right instead (default: false)
---@return string
function CetUtils.Pad(str, l, c, right)
    c = c or " "
    right = right or false

    local s
    if type(str) ~= string then
        s = tostring(str)
    else
        s = str
    end

    if s == nil or #c > 1 then
        return str
    end

    local total = CetUtils.Clamp(l - #s, 0, 999)

    if not right then
        return string.rep(c, total)..s
    else
        return s..string.rep(c, total)
    end
end


---Round to `places` decimal places, optionally shift the rounding `pivot`
---@param val number     -- [required] - the number to round
---@param places? number -- [optional] - the places to round to (default: 2)
---@param pivot? number  -- [optional] - the "pivot" to round around; set it to the fraction you want to round up from (default: 0.5)
---@return number
function CetUtils.Round(val, places, pivot)
    places = places or 2
    pivot = pivot or 0.5
    pivot = (1 - pivot)
    local exp = math.pow(10, places)
    return math.floor((val * exp) + pivot) / exp
end

--Round a number to the nearest whole power of 10
--E.g. RoundNearestPower(534, 10) = 530, (567, 100) = 600, etc
function CetUtils.RoundNearestPower(val, power)
    return math.floor((val / power) + 0.5) * power
end

function CetUtils.Clamp(val, lower, upper)
    if val > upper then
        return upper
    elseif val < lower then
        return lower
    else
        return val
    end
end

--Tokenise string on delimiter, return array of strings with delimiters removed
function CetUtils.StrSplit(str, del)
    local tokens = {}
    local findIndices = {}
    local startPoints = {}
    local i = 1

    while true do
        table.insert(startPoints, i)
        i, _ = str:find(del, i)
        if i ~= nil then
            table.insert(findIndices, i)
            i = i + #del
        else
            break
        end
    end

    for j = 1, #startPoints do
        if j < #startPoints then
            tokens[j] = str:sub(startPoints[j], findIndices[j] - 1)
        else
            tokens[j] = str:sub(startPoints[j])
        end
    end

    return tokens
end

function CetUtils.ArrayFirst(t, func)
    for i = 1, #t do
        if func(t[i]) then
            return t[i]
        end
    end

    return nil
end

function CetUtils.ArrayMap(t, func)
    for i = 1, #t do
        func(t[i])
    end
end

function CetUtils.ArrayProject(t, func)
    local result = {}

    for _, v in pairs(t) do
        table.insert(result, func(v))
    end

    return result
end

function CetUtils.ArrayProjectSafe(t, func, distinct, selector)
    distinct = distinct or false
    local result = {}

    for k, v in pairs(t) do
        local res = func(v, k)
        if res ~= nil then
            if distinct and selector ~= nil then
                if CetUtils.IndexOf(result, res[selector], selector) == -1 then
                    table.insert(result, res)
                end
            else
                table.insert(result, res)
            end
        end
    end

    return result
end

function CetUtils.ArrayWhere(t, func)
    local result = {}

    for _, v in pairs(t) do
        if func(v) then
            table.insert(result, v)
        end
    end

    return result
end

function CetUtils.ArrayRemove(t, fnKeep)
    local j, n = 1, #t

    for i = 1, n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1 -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil
        end
    end
end

function CetUtils.TableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function CetUtils.TableMerge(...)
    local result = {}

    for _, t in ipairs({...}) do
        for _, v in ipairs(t) do
            table.insert(result, v)
        end
    end

    return result
end

function CetUtils.PrintTable(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, function(v1, v2) return v1 < v2 end)

    for _, v in pairs(keys) do
        print("["..v.."]", t[v])
    end
end

--Print table with a custom print function
--Useful with tables of userdata
function CetUtils.PrintTableF(t, f)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, function(v1, v2) return v1 < v2 end)

    for _, v in pairs(keys) do
        f(v, t[v])
    end
end

--Recursively print all tables found in a table
--Don't look too closely at this shit, it does the job ok
function CetUtils.PrintTableR(t, tabs)
    tabs = tabs or 0

    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, function(v1, v2) return v1 < v2 end)

    for _, v in pairs(keys) do
        if type(t[v]) ~= "table" then
            local tb = ""
            for i = 2, tabs do tb = tb.."--" end
            local arrow = ""
            if tabs > 1 then arrow = ">" end
            print(tb..arrow.."["..v.."]", t[v])
        else
            tabs = tabs + 1
            print("Nested table: ["..v.."]")
            CetUtils.PrintTableR(t[v], tabs)
            tabs = tabs - 1
        end
    end
end

function CetUtils.GetTimedWarn(time)
    return UILabels.universalelements.timedBtnWarn:gsub(
        "{#}", time
    )
end

function CetUtils.GetButtonWidth(varTable)
    local textWidth, _ = ImGui.CalcTextSize(varTable.Stat)
    local buttonWidth = math.max(textWidth + ImGui.GetFontSize(), ModState.SVars.ConfTextX)
    return buttonWidth
end

function CetUtils.MatchString(s, ss)
    if #ss == 0 then return false end

    for i = 1, #ss do
        if string.find(s, ss[i]) then return true end
    end

    return false
end

function CetUtils.IndexOf(t, v, selector)
    local value
    for i = 1, #t do
        if selector ~= nil then
            value = t[i][selector]
        else
            value = t[i]
        end

        if value == v then return i end
    end

    return -1
end

function CetUtils.Exists(t, v)
    if #t == 0 then return false, -1 end

    for i = 1, #t do
        if t[i] == v then return true, i end
    end

    return false, -1
end

function CetUtils.AnyExists(t, vt)
    if #t == 0 or #vt == 0 then return false end

    for i = 1, #vt do
        local exists, j = CetUtils.Exists(t, vt[i])
        if exists then return true end
    end

    return false
end

function CetUtils.TagExists(t, v)
    if #t == 0 then return false end

    for i = 1, #t do
        if t[i].value == v then return true, i end
    end

    return false
end

function CetUtils.AnyTagExists(t, vt)
    if #t == 0 or #vt == 0 then return false end

    for i = 1, #vt do
        local exists, j = CetUtils.TagExists(t, vt[i])
        if exists then return true end
    end

    return false
end

function CetUtils.AnyKeyExists(t, key)
    for k, v in pairs(t) do
        if k == key then return true end
    end

    return false
end

function CetUtils.TableString(t, c, z)
    if(#t == 0) then return "[]" end
    z = z or 1
    local str = "["
    c = c or ", "
    for i = z, #t do
        if i < #t then
            str = str..t[i]..c
        else
            str = str..t[i].."]"
        end
    end
    return str
end


--The below are most useful in game
--import the mod with "<var> = GetMod("simplemenu")
--invoke like "<var>.CetUtils.<method>(<args>)"
function CetUtils.PrintItemRecord(k, record, printTags)
    printTags = printTags or false

    local id = record:GetID().value
    local name = Game.GetLocalizedTextByKey(record:DisplayName())
    local type = record:ItemType():Name().value
    print(k..": ID = \'"..id.."\', Name = ("..name.."), Type = ("..type..")")

    if printTags then
        local tags = record:Tags()
        local strL = {}
        for i = 1, #tags do
            strL[i] = tags[i].value
        end
        print("\tTags: "..CetUtils.TableString(strL, " | "))
    end
end

function CetUtils.PrintItemRecords(records, printTags)
    for k, record in pairs(records) do
        CetUtils.PrintItemRecord(k, record, printTags)
        print("\n ")
    end
end

function CetUtils.PrintStats(stats)
    for k, v in pairs(stats) do
        print (k, v.statType.value, " = ", v.value, "(Min: ", v.limitMin, "| Max: ", v.limitMax,")")
        for k1, v1 in pairs(v.modifiers) do
            print("\t",v1.modifierType.value, " = ", v1.value)
        end
    end
end

function CetUtils.GetHeldWeaponStats(print)
    RefreshSystems()
    local wStat = CetUtils.ts:GetItemInSlot(CetUtils.player, TweakDBID.new('AttachmentSlots.WeaponRight'))
    if wStat == nil then return nil end
    local itemID = wStat:GetItemID()
    local wStatsObjId = wStat:GetItemData():GetStatsObjectID()
    local stats = CetUtils.ss:GetStatDetails(wStatsObjId)
    if print then CetUtils.PrintStats(stats) end
    return { st = stats, so = wStatsObjId, id = itemID }
end

function CetUtils.GetHeldWeaponStat(statType)
    local wStats = CetUtils.GetHeldWeaponStats(false)
    if wStats == nil then return end
    local stats = wStats.st
    local statRec = nil

    for _, v in pairs(stats) do
        if v.statType.value == statType.value then
            statRec = v
            break
        end
    end

    CetUtils.PrintStats({ statRec })
end

function CetUtils.GetObjectStats(obj, print)
    print = print or false

    local ss = Game.GetStatsSystem()
    local eId = obj:GetEntityID()
    local stats = ss:GetStatDetails(eId)
    if print then
        CetUtils.PrintStats(stats)
    end
    return stats
end

function CetUtils.GetObjectStat(obj, statType)
    local stats = CetUtils.GetObjectStats(obj)
    if stats == nil then return end
    local statRec = nil

    for _, v in pairs(stats) do
        if v.statType.value == statType.value then
            statRec = v
            break
        end
    end

    CetUtils.PrintStats({ statRec })
end

function CetUtils.GetObjectStatFromStatsID(statsObjID, statType)
    local stats = Game.GetStatsSystem():GetStatDetails(statsObjID)
    if stats == nil then return end
    local statRec = nil

    for _, v in pairs(stats) do
        if v.statType.value == statType.value then
            statRec = v
            break
        end
    end

    return statRec
end

function CetUtils.AddModifierToHeldWeapon(modifier)
    RefreshSystems()
    local wStat = CetUtils.ts:GetItemInSlot(CetUtils.player, TweakDBID.new('AttachmentSlots.WeaponRight'))
    if wStat == nil then return nil end
    local wStatsObjId = wStat:GetItemData():GetStatsObjectID()
    CetUtils.ss:AddModifier(wStatsObjId, modifier)
end

--As above
function CetUtils.RemoveModifierFromHeldWeapon(modifier)
    RefreshSystems()
    local wStat = CetUtils.ts:GetItemInSlot(CetUtils.player, TweakDBID.new('AttachmentSlots.WeaponRight'))
    if wStat == nil then return nil end
    local wStatsObjId = wStat:GetItemData():GetStatsObjectID()
    CetUtils.ss:RemoveModifier(wStatsObjId, modifier)
end

return CetUtils