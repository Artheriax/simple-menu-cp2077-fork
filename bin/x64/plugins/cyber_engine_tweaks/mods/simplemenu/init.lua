----------------------------------------------------------------------------------
--                Simple Menu created by Dank Rafft                             --
--                Currently maintained by: capncoolio2                          --
--                https://www.nexusmods.com/cyberpunk2077/mods/818              --
--                                                                              --
--                Fork for Cyberpunk 2.31 compatibility                         --
--                Maintained by: Artheriax                                      --
--                https://github.com/Artheriax/simple-menu-cp2077-fork          --
----------------------------------------------------------------------------------

----------------
---- GLOBAL ----
----------------

---@return table, table
function GetLocalizationMetadata()
    local langNames = {}
    local langCodes = {}
    local i = 1

    --get default first
    local defaultFile = io.open("./translation/meta/default-en-meta.json", "r")
    if defaultFile ~= nil then
        local defaultMeta = json.decode(defaultFile:read("*a"))
        langNames[i] = (defaultMeta.name.." ("..defaultMeta.info..")")
        langCodes[i] = (defaultMeta.code)
        print("[SimpleMenu] Language found:", langCodes[i], langNames[i])
        i = i + 1
        defaultFile:close()
    end

    --Get the rest
    for _, v in pairs(dir("./translation/meta")) do
        if string.find(v.name, ".json") and string.find(v.name, "language-") and not string.find(v.name, "default-") then
            local file = io.open("./translation/meta/"..v.name, "r")
            if file == nil then return {}, {} end
            local meta = json.decode(file:read("*a"))
            langNames[i] = (meta.name.." ("..meta.info..")")
            langCodes[i] = (meta.code)
            print("[SimpleMenu] Language found:", langCodes[i], langNames[i])
            i = i + 1
            file:close()
        end
    end

    return langNames, langCodes
end

function GetSelectedLanguage(codes)
    local file = io.open("./translation/lang.json", "r")
    if file == nil then return 0 end
    local langConf = json.decode(file:read("*a"))
    for k, v in pairs(codes) do
        if v == langConf.selectedLang then
            file:close()
            return k - 1
        end
    end
    file:close()
    return 0
end

---@param language string
---@return table
function LoadLabels(language)
    local path = "./translation/labels/"..language..".json"
    local file = io.open(path, "r")
    local translation = {}
    if file ~= nil then
        translation = json.decode(file:read("*a"))
        file:close()
    end

    return translation
end

local function EN(enum, value)
    for k, v in pairs(enum) do
        if v == value then return k end
    end

    return ""
end

---@enum LOG_LEVEL
LOG_LEVEL = {
    None    = -1,
    Info    =  0,
    Trace   =  1
}

---Get a LOG_LEVEL from an int
---@param level number
---@return LOG_LEVEL?
function GetLogLevelValue(level)
    if level == 0 then return LOG_LEVEL.Info end
    if level == 1 then return LOG_LEVEL.Trace end
    return nil
end

DEBUG_MODE = false
LOGLEVEL = LOG_LEVEL.Info

---Set the global Logging level
---@param logLevel LOG_LEVEL?
function SET_LOG_LEVEL(logLevel)
    if logLevel == nil then return end
    LOGLEVEL = logLevel
end

---Print Debug output, with respect to LOGLEVEL
---@param logLevel LOG_LEVEL
---@param ... any
function DEBUG_printl(logLevel, ...)
    if DEBUG_MODE and logLevel <= LOGLEVEL then
        local clks = tostring(os.clock())
        local mill = clks:sub(clks:find('%.') or 1)
        local time = os.date("%H:%I:%S", os.time())..mill..string.rep('0', 4 - #mill)
        print("["..time.."] [SimpleMenu]", EN(LOG_LEVEL, logLevel):upper()..":", ...)
    end
end

---@enum LoadingState
LoadingState = {
    NotLoaded   = -1,
    Init        =  0,
    PreFetch    =  1,
    PreLoad     =  2,
    Loading     =  3,
    MainIndex   =  4,
    Sorted      =  5,
    Consumables =  6,
    Materials   =  7,
    Shards      =  8,
    Finished    =  9
}

GameState = {}
SearchQueuedTagUpdates = {}
GlobalItemRecords = {}
UIVisible = false
UILangNames, UILangCodes = GetLocalizationMetadata()
UISelectedLang = GetSelectedLanguage(UILangCodes)
UILabels = LoadLabels(UILangCodes[UISelectedLang + 1]) --seriously go to hell ImGui for being 0-indexed in a 1-indexed language
Cron = require("libs/cp2077-cet-kit/Cron")

CustomGameState = {
    InHackingMinigame = false
}

ModState = {
    LoadingItemsState = LoadingState.NotLoaded,
    TotalRecords = 0,
    LoadedPercent = 0,
    FinishTime = 0,
    KeyModifiers = {
        Shift = false
    },
    SVars = {
        ConfTextX = -1,
        Invisibility = false,
        CurrentFrames = {},
        JumpDist = 1,
        Timers = {
            DisableQFact = {
                Time = 3,
                Elap = 0,
                Text = "",
                Cron = nil,
                Stat = UILabels.misc.quest.bDisable
            },
            EnableQFact = {
                Time = 3,
                Elap = 0,
                Text = "",
                Cron = nil,
                Stat = UILabels.misc.quest.bEnable
            },
            ForceInv = {
                Time = 5,
                Elap = 0,
                Text = "",
                Cron = nil,
                Stat = UILabels.items.equipment.bUpgradeAll
            },
            PermStat = {
                Time = 5,
                Elap = 0,
                Text = "",
                Cron = nil,
                Stat = UILabels.player.stats.pButton
            }
        },
        Mods = {
            HealItemCooldown = false,
            GrenadeCooldown = false,
            ProjectileCooldown = false,
            CloakCooldown = false,
            SandevistanCooldown = false,
            BerserkCooldown = false,
            KerenzikovCooldown = false,
            OverclockCooldown = false,
            QuickhackCooldown = false,
            QuickhackCost = false,
            MemoryRegeneration = false,
            FaceplateCooldown = false,
            InfiniteDoubleJump = false,
            InfiniteAirDash = false
        }
    }
}

---Modify timed button state
---@param varTable { Cron: any?, Time: number, Elap: number, Text: string, Stat: string }
local function ButtonTimerHelper(varTable)
    if varTable.Cron == nil then
        varTable.Elap = varTable.Time
        varTable.Text = varTable.Stat
    else
        varTable.Elap = varTable.Elap - 1
    end

    if varTable.Elap <= 0 then
        DEBUG_printl(LOG_LEVEL.Trace, "Time = 0, halting... caller:", varTable.Stat)
        Cron.Halt(varTable.Cron)
        varTable.Cron = nil
        varTable.Text = varTable.Stat
    else
        varTable.Text = UILabels.universalelements.buttonConfirm:gsub(
            "{#}", tostring(varTable.Elap)
        )
        DEBUG_printl(LOG_LEVEL.Trace, "Time = "..varTable.Elap..", returning:", varTable.Text)
    end
end

local Elem = require("ui/elements")
local Colour = require("classes/colour")
---Create/Maintain timed button state
---@param predicate boolean
---@param varTable { Cron: any?, Time: number, Elap: number, Text: string, Stat: string }
---@param toolTips { text: string, colour: Colour? }[]?
---@param confirmFunc function
function TimedButton(predicate, varTable, toolTips, confirmFunc, ...)
    if varTable.Text == "" then varTable.Text = varTable.Stat end
    if predicate and varTable.Elap <= 0 then
        ButtonTimerHelper(varTable)
        varTable.Cron = Cron.Every(1, ButtonTimerHelper, varTable)
    elseif predicate and varTable.Elap > 0 then
        varTable.Elap = 0
        ButtonTimerHelper(varTable)
        confirmFunc(...)
    end

    if toolTips ~= nil then
        if varTable.Elap <= 0 then
            Elem.QuickMultiTooltip(toolTips)
        else
            Elem.QuickTooltip(UILabels.universalelements.timedBtnConf, Colour.Positive)
        end
    end
end

local SimpleMenu = {
    description = "",
    showUI = false,
    previousWState = 0
}

SimpleMenu.Notifications = require("ui/notifications")
SimpleMenu.Hotkey = require("config/hotkeys")
SimpleMenu.Util = require("config/util")
SimpleMenu.UI = require("ui/main")
SimpleMenu.Ammo = require("items/ammo")
SimpleMenu.Items = require("items/items")
SimpleMenu.Misc = require("misc/misc")
SimpleMenu.CetUtils = require("misc/cetUtils")
SimpleMenu.Player = require("player/player")
SimpleMenu.Perks = require("player/perks")
SimpleMenu.ItemRecord = require("classes/itemrecord")
SimpleMenu.p = SimpleMenu.CetUtils.p --print function redefined here for ease of access from CET Console (I'm lazy)

function LanguageReloadActions()
    ModState.SVars.Timers.DisableQFact.Stat = UILabels.misc.quest.bDisable
    ModState.SVars.Timers.EnableQFact.Stat  = UILabels.misc.quest.bEnable
    ModState.SVars.Timers.ForceInv.Stat     = UILabels.items.equipment.bUpgradeAll
    ModState.SVars.Timers.PermStat.Stat     = UILabels.player.stats.pButton

    for _, v in pairs (ModState.SVars.Timers) do
        v.Text = ""
    end

    ModState.SVars.ConfTextX = -1
    SimpleMenu.UI.Misc.widestBreachLabel = 0
end

----------------
---- LOCAL  ----
----------------

local Session = require("libs/cp2077-cet-kit/GameSession")
local GameHUD = require("libs/cp2077-cet-kit/GameHUD")
local Elements = require("ui/elements")
local Delegates = require("misc/delegates")
local postInit = false
local t1 = nil
local t2 = nil

local function DrawLoadingPopup(progress)
    local flags = bit32.bor(ImGuiWindowFlags.NoCollapse, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoScrollbar, ImGuiWindowFlags.NoTitleBar)
    local resx, resy = GetDisplayResolution()
    local scalex, scaley = resx / 3840, resy / 2160
    local sizex, sizey = 600 * scalex, 150 * scaley
    ImGui.SetNextWindowPos((resx / 2) - (sizex / 2), resy / 12, ImGuiCond.Always)
    ImGui.SetNextWindowSize(sizex, sizey, ImGuiCond.Always)

    if (ImGui.Begin("SimpleMenuLoading", flags)) then
        local text
        if ModState.LoadingItemsState == LoadingState.Init then
            text = UILabels.universalelements.preloadingMsg
        elseif ModState.LoadingItemsState == LoadingState.PreFetch then
            text = UILabels.universalelements.preFetchingMsg
        elseif ModState.LoadingItemsState < LoadingState.Finished then
            text = UILabels.universalelements.loadingMsg
        else
            text = UILabels.universalelements.postloadingMsg
        end
        local wx, _ = ImGui.GetWindowSize()
        local tx, _ = ImGui.CalcTextSize(text)
        ImGui.SetCursorPosX((wx - tx) * 0.5);
        Elements.Text(text, false, true, Colour.Warning, 1)
        Elements.Separator()
        local availX, availY = ImGui.GetContentRegionAvail()
        ImGui.ProgressBar(progress / 100, availX, availY)
    end
    ImGui.End()
end

local function ProcessTagUpdate(k)
    SearchQueuedTagUpdates[k].attempts = SearchQueuedTagUpdates[k].attempts + 1
    local flatSet  = TweakDB:SetFlat(SearchQueuedTagUpdates[k].item.TweakDBID..".tags", SearchQueuedTagUpdates[k].tags)
    local tweakUpd = TweakDB:Update(SearchQueuedTagUpdates[k].item.Record)
    if flatSet and tweakUpd then
        SearchQueuedTagUpdates[k] = nil
    elseif SearchQueuedTagUpdates[k].attempts < 5 then
        SearchQueuedTagUpdates[k].attempts = SearchQueuedTagUpdates[k].attempts + 1
    else
        error(
            "[SimpleMenu] Failed to update TweakDB record: "..
            SearchQueuedTagUpdates[k].item:GetID().." after "..
            SearchQueuedTagUpdates[k].attempts.." attempts."
        )
    end
end

local function ProcessTagUpdateQueue()
    for k, _ in pairs(SearchQueuedTagUpdates) do
        ProcessTagUpdate(k)
    end
end

local function SetPlayerInvisibilityState()
    ModState.SVars.Invisibility = Game.GetPlayer():IsInvisible()
end

local function GetStash()
    local stashID = EntityID.new()
    stashID.hash = 16570246047455160070ULL
    return Game.FindEntityByID(stashID);
end

local function AddItemToStash(tdbid)
    local ts = Game.GetTransactionSystem()
    local item = ItemID.FromTDBID(tdbid)
    local stash = GetStash()

    if stash ~= nil then
        ts:GiveItem(GetStash(), item, 1)
    end
end

local function PostLoadActions()
    -- Defensive guard: ensure the player exists before re-applying modifiers.
    -- On hot-reloads or some edge case loads, Game.GetPlayer() can briefly be nil,
    -- and ChangeModifiers would silently no-op in the best case or error in others.
    if Game.GetPlayer() == nil then
        DEBUG_printl(LOG_LEVEL.Info, "PostLoadActions: player not ready yet, skipping")
        return
    end

    --Infinite Stamina
    SimpleMenu.Player.ChangeModifiers(
        SimpleMenu.Player.EPlayerMod.InfiniteStamina,
        SimpleMenu.Player.Util.configuration.functions.infStamina
    )

    --God Mode
    SimpleMenu.Player.ChangeModifiers(
        SimpleMenu.Player.EPlayerMod.GodMode,
        SimpleMenu.Player.Util.configuration.functions.godMode
    )

    --Infinite Oxygen
    SimpleMenu.Player.ChangeModifiers(
        SimpleMenu.Player.EPlayerMod.InfiniteOxygen,
        SimpleMenu.Player.Util.configuration.functions.infOxy
    )

    for k, v in pairs(ModState.SVars.Mods) do
        if v then
            local enumVal = SimpleMenu.Player.EPlayerMod[k]
            if enumVal ~= nil then
                SimpleMenu.Player.ChangeModifiers(enumVal, true)
                DEBUG_printl(LOG_LEVEL.Trace, "Enabled modifier after load:", k)
            else
                print("[SimpleMenu] PostLoadActions: unknown modifier key in config:", k, "-- ignored")
            end
        end
    end

    --Set up craftbook
    local okCraft, errCraft = pcall(RefreshCraftBookMenu)
    if not okCraft then
        print("[SimpleMenu] PostLoadActions: RefreshCraftBookMenu failed:", errCraft)
    end

    --Set Police System state
    local okPolice, errPolice = pcall(function()
        SimpleMenu.Misc.DisablePolice(SimpleMenu.Util.configuration.functions.disablePolice)
    end)
    if not okPolice then
        print("[SimpleMenu] PostLoadActions: DisablePolice failed:", errPolice)
    end

    SetPlayerInvisibilityState()
end

local function PostFirstLoadActions()
    if GameState.isLoaded and not postInit then
        local delay = 5 -- normal load
        if GameState.wasLoaded then delay = 10 end --hot reload in game
        DEBUG_printl(LOG_LEVEL.Trace, "Item load delay is:", delay)
        ModState.LoadingItemsState = LoadingState.Init

        --Item search setup
        Cron.After(delay, SimpleMenu.Items.Populate)
        SimpleMenu.UI.Search.Populate()

        PostLoadActions()

        Cron.Halt(t1)
    end
end

local function CheckActions()
    --check if user isn't in main or another menu
    if not GameState.isPaused and GameState.isLoaded then
        --Freeze Game Time
        if (SimpleMenu.Util.configuration.functions.freezeTime) then
            Game.GetTimeSystem():SetPausedState(true, CName.new())
        end
    end
end

local function ReloadListener()
    if GameState.isLoaded then
        local weaponBbDef = GetAllBlackboardDefs().PlayerStateMachine.Weapon
        local psmbb = Game.GetPlayer():GetPlayerStateMachineBlackboard()
        local currentWState = psmbb:GetInt(weaponBbDef)
        if currentWState ~= SimpleMenu.previousWState then
            SimpleMenu.Ammo.WeaponStateListener(currentWState)
            SimpleMenu.previousWState = currentWState
        end
    end
end

local function PostInitCheck()
    --If everything's been loaded, and we've just initialized the mod,
    --display the initialization banner to notify that init is complete,
    --and stop the timer that runs this function periodically.
    if  ModState.LoadingItemsState == LoadingState.Finished and not postInit
    then
        postInit = true

        if SimpleMenu.Util.configuration.initNotification then
            GameHUD.ShowWarning(UILabels.config.initNotification, 3.0)
        end

        Cron.Halt(t2)
    end
end

local function GetStartingState()
    GameState = Session.GetState()
end

local function UpdateStateTick()
    GameState.isLoaded = Session.IsLoaded()
    GameState.isPaused = Session.IsPaused()
end

local function UpdateState(state)
    GameState = state
    if GameState.event == "Start" and not GameState.wasLoaded then
        PostLoadActions()
    end
end

local function updatePlayerModsFromConfig()
    for k, v in pairs(SimpleMenu.Util.configuration.playerMods) do
        ModState.SVars.Mods[k] = v
    end
end

----------------
--- INSTANCE ---
----------------

function SimpleMenu:new()
    --Populate metatable for use in game with GetMod("simplemenu")
    local o = {}
    setmetatable(o, self)
    self.__index = self

    ----------------
    -- INITIALISE --
    ----------------

    registerForEvent('onInit', function()
        SimpleMenu.Util.LoadConfig()
        DEBUG_MODE = SimpleMenu.Util.configuration.debugMode
        LOGLEVEL = SimpleMenu.Util.configuration.logLevel
        updatePlayerModsFromConfig()
        GameHUD.Initialize()

        Cron.After(0.1, GetStartingState)          --Initial state update (for hot reloads)
        Session.Listen(UpdateState)                --Subsequent state updates on state listener

        --Bunch of loading/indexing stuff
        SimpleMenu.Items.Preload()                 --Load TweakDB Items and create ItemRecords
        SimpleMenu.Ammo.Preload()                  --Create Weapon cheat stat modifiers
        SimpleMenu.Player.Preload()                --Create cheat modifiers and gamedataStatType lists
        SimpleMenu.Perks.Preload()                 --Create gamedataNewPerkType lists and Perk Categories

        --Repeating jobs (lifetime)
        Cron.Every(0.3, ReloadListener)            --Weapon state "listener"
        Cron.Every(1.0, UpdateStateTick)           --Keep loaded/paused state up to date
        Cron.Every(2.0, CheckActions)              --General Gameplay effect updates
        Cron.Every(5.0, ProcessTagUpdateQueue)     --Processes TweakDB tag update queue (search adds tags to prevent activity log entries)

        --Repeating jobs (once per mod load)
        t1 = Cron.Every(1.0, PostFirstLoadActions) --Checks periodically for when to index TweakDB and notify UI of loaded state
        t2 = Cron.Every(1.0, PostInitCheck)        --Are we there yet?

        --Track notification time and store timer ID globally (disable after 3 seconds)
        Notifications.nt = Cron.Every(1.0, UpdateNotification, { s = 1 })

        --This listens for the Equip event, to apply modifiers
        Observe(
            "PlayerPuppet",
            "OnItemEquipped",
            Delegates.PlayerPuppetOnItemEquipped
        )

        --This listens for the Unequip event, to remove modifiers
        Observe(
            "PlayerPuppet",
            "OnItemUnequipped",
            Delegates.PlayerPuppetOnItemUnequipped
        )

        --Stop fall damage
        ObserveAfter(
            "LocomotionAirEvents",
            "OnEnter",
            Delegates.LocomotionAirEventsOnEnterDelegate
        )

        --Infinite Breach Protocol Time
        Observe(
            "HackingMinigameGameController",
            "OnPositionSelected",
            Delegates.HackingMinigameGameControllerOnPositionSelected
        )

        --Breach Protocol parameter overrides
        Override(
            "HackingMinigameGameController",
            "OnInitialize",
            Delegates.HackingMinigameGameControllerOnInitialize
        )

        --To know when out of hacking minigame
        ObserveAfter(
            "HackingMinigameGameController",
            "OnUninitialize",
            Delegates.HackingMinigameGameControllerOnUninitialize
        )

        --Force Breach Protocol puzzle length
        Override(
            "MinigameGenerationRuleScalingPrograms",
            "DefineLength",
            Delegates.MinigameGenerationRuleScalingProgramsDefineLength
        )

        Override(
            "VehicleSystem",
            "GetPlayerUnlockedVehicles",
            Delegates.VehicleSystemGetPlayerUnlockedVehicles
        )

        Override(
            "DoubleJumpDecisions",
            "EnterCondition",
            Delegates.DoubleJumpDecisionsEnterCondition
        )

        Override(
            "LocomotionTransition",
            "WantsToDodge",
            Delegates.LocomotionTransitionWantsToDodge
        )

        ObserveAfter(
            "MinimapContainerController",
            "OnCountdownTimerActiveUpdated",
            Delegates.MinimapContainerControllerOnCountdownTimerActiveUpdated
        )
    end)


    -------------
    -- CLEANUP --
    -------------
    registerForEvent('onShutdown', function()
        DEBUG_printl(LOG_LEVEL.Trace, "SHUTTING DOWN: Performing clean up...")

        --Disable any modifiers that were enabled
        for k, v in pairs(ModState.SVars.Mods) do
            if v then
                local enumVal = SimpleMenu.Player.EPlayerMod[k]
                SimpleMenu.Player.ChangeModifiers(enumVal, false)
                DEBUG_printl(LOG_LEVEL.Trace, "Disabled modifier:", k)
            end
        end

        --Disable invisibility
        if ModState.SVars.Invisibility then
            SimpleMenu.Player.ToggleInvisibility(false)
        end
    end)

    -------------
    -- HOTKEYS --
    -------------

    registerHotkey("ToggleUI", UILabels.hotkeys.ToggleUI, function()
        SimpleMenu.showUI = not SimpleMenu.showUI
        UIVisible = SimpleMenu.showUI
    end)

    SimpleMenu.Hotkey.RegisterCustom()

    --------------------
    -- UPDATE SCRIPTS --
    --------------------

    registerForEvent("onUpdate", function(deltaTime)
        Cron.Update(deltaTime)
    end)

    --------
    -- UI --
    --------

    --make SM's UI appear simultaneously with CET's console
    registerForEvent("onOverlayOpen", function()
        if (SimpleMenu.Util.configuration.autoUI) then
            SimpleMenu.showUI = true
            UIVisible = true
        end
    end)

    --make SM's UI disappear simultaneously with CET's console
    registerForEvent("onOverlayClose", function()
        if (SimpleMenu.Util.configuration.autoUI) then
            SimpleMenu.showUI = false
            UIVisible = false
        end
    end)

    --draw UI
    registerForEvent("onDraw", function()
        if ModState.SVars.ConfTextX == -1 then
            ModState.SVars.ConfTextX, _ = ImGui.CalcTextSize(UILabels.universalelements.buttonConfirm)
        end

        if (Notifications.showNote) then
            CreateNotification()
        end
        if (SimpleMenu.showUI) then
            SimpleMenu.UI.Create(SimpleMenu)
        end

        local finished = false
        if ModState.LoadingItemsState == LoadingState.Finished and os.time() - ModState.FinishTime > 3 then
            finished = true
        end
        if (
            ModState.LoadingItemsState > LoadingState.NotLoaded and
            not UIVisible and not finished and not GameState.isPaused and
            SimpleMenu.Util.configuration.menuConfigs.search.loadingBar
        ) then
            DrawLoadingPopup(ModState.LoadedPercent)
        end
    end)

    return o
end

return SimpleMenu:new()