local Util = {
    counter = 0,
    configPath = "config/config.json",
    quickTelePath = "config/quickTele.json",
    configuration = {},
    configurationDefault = {
        version = 51,
        modVersion = 51,
        isBeta = true,
        autoUI = true,
        initNotification = false,
        popupsEnabled = true,
        debugMode = false,
        logLevel = 0,
        menus = {
            items = {
                weaponMods = false,
                additems = false,
                shop = false,
                equipment = false
            },
            player = {
                mainCheats = false,
                modifiers = false,
                attributes = false,
                stats = false,
                perks = false,
                level = false
            },
            misc = {
                police = false,
                quest = false,
                teleport = false,
                time = false,
                vehicles = false,
                breach = false,
                npc_other = false
            },
            config = {
                weapMods = false,
                search = false,
                menus = false,
                json = false
            }
        },
        menuConfigs = {
            search = {
                loadingBar = true,
                loadingSpeed = 1000
            }
        },
        weapModConf = {
            bigBrain = {
                reticlePitch = 45,
                reticleYaw = 45,
                velocity = 100,
                range = 500,
                maxLocks = 10
            },
            psychoMode = {
                projectiles = 10,
                fireRate = 5
            },
            superZoom = {
                zoomLevel = 5
            }
        },
        playerMods = {
            GodMode             = false,
            InfiniteOxygen      = false,
            InfiniteStamina     = false,
            HealItemCooldown    = false,
            GrenadeCooldown     = false,
            ProjectileCooldown  = false,
            CloakCooldown       = false,
            SandevistanCooldown = false,
            BerserkCooldown     = false,
            KerenzikovCooldown  = false,
            OverclockCooldown   = false,
            QuickhackCooldown   = false,
            QuickhackCost       = false,
            MemoryRegeneration  = false,
            FaceplateCooldown   = false,
            InfiniteDoubleJump  = false,
            InfiniteAirDash     = false
        },
        functions = {
            ammoInfiniteInv = false,
            ammoInfiniteMag = false,
            superReload = false,
            superAccuracy = false,
            superZoom = false,
            superRange = false,
            noRecoil = false,
            ultraKill = false,
            psychoMode = false,
            beastMode = false,
            bigBrain = false,
            penetrator = false,
            infStamina = false,
            godMode = false,
            infOxy = false,
            disablePolice = false,
            freezeTime = false,
            freezeCarQuestTime = false,
            slowMoDilation = 50,
            slowMoPlayerRatio = 50,
            slowMoEffect = 0,
            slowMoScaleCycleTime = false,
            instantRepairs = false,
            lockPlayerTiDi = true,
            savedPositionX = 0,
            savedPositionY = 0,
            savedPositionZ = 0,
            savedYaw = 0,
            quickTeleports = {
                {
                    name = "",
                    loc  = { -1380.580566, 1271.436035, 123.064896, 1 },
                    dir  = { 0, 0, 0 }
                },
                {
                    name = "",
                    loc  = { -1546.726196, 1227.393066, 11.520233, 1 },
                    dir  = { 0, 0, 0 }
                }
            },
        }
    }
}

-------------
-- GENERAL --
-------------

function Util.T(expr, t, f)
    if expr then return t else return f end
end

--dynamic label processing
function Util.ProcessLabels(category, subcat)
    local subtable = UILabels.dynamic
    local fullString = table.concat(subtable[category][subcat], "\0")
    fullString = fullString .. "\0"
    return fullString
end

function Util.GetDLabels(category, subcat)
    local list = UILabels.dynamic[category][subcat]
    return list, #list
end

--sort table by key value
function Util.spairs(t)
    --collect the keys
    local keys = {}
    for k in pairs(t) do
        keys[#keys+1] = k
    end
    --sort keys
    table.sort(keys)
    --return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-------------------
-- CONFIGURATION --
-------------------

function Util.fileExists(filename)
    local f=io.open(filename,"r")
    if (f~=nil) then
        io.close(f)
        return true
    else
        return false
    end
end

function Util.ResetConfig()
    Util.configuration = Util.configurationDefault

    --Set some defaults that need to be loaded
    Util.configuration.functions.quickTeleports[1].name = UILabels.misc.teleport.bApartment
    Util.configuration.functions.quickTeleports[2].name = UILabels.misc.teleport.bViktor

    print("[SimpleMenu] User configuration reset")
    Util.SaveConfig(true)
end

function Util.LoadConfig()
    if not Util.fileExists(Util.configPath) then
        local file = io.open(Util.configPath, "w")
        local jconfig = json.encode(Util.configurationDefault)
        if file ~= nil then
            file:write(jconfig)
            file:close()
        end
    end

    local file = io.open(Util.configPath, "r")
    if file ~= nil then
        local config = json.decode(file:read("*a"))
        file:close()
        Util.configuration = config

        local sameVersion =
            (Util.configuration.version == Util.configurationDefault.version) and
            (Util.configuration.isBeta ~= nil) and
            (Util.configuration.isBeta == Util.configurationDefault.isBeta)

        if (sameVersion) then
            print("[SimpleMenu] Version", Util.configuration.version, "- User configuration loaded")
            Util.configuration.functions.quickTeleports = Util.LoadQuickTeleports()
            Util.CreateQuickTeleports(Util.configuration.functions.quickTeleports)
        else
            print("[SimpleMenu] Version", Util.configuration.version, "- User configuration is outdated and will be replaced with a new one")
            Util.ResetConfig()
            Util.configuration.functions.quickTeleports = Util.LoadQuickTeleports()
            Util.CreateQuickTeleports(Util.configuration.functions.quickTeleports)
        end
    else
        print("[SimpleMenu] Failed to load user configuration")
    end
end

function Util.CreateQuickTeleports(tele)
    if not Util.fileExists(Util.quickTelePath) then
        local teleFile = io.open(Util.quickTelePath, "w")
        local teleConfig = json.encode(tele)
        if teleFile ~= nil then
            teleFile:write(teleConfig)
            teleFile:close()
            print("[SimpleMenu] Created quick teleports file")
        else
            print("[SimpleMenu] Failed to create quick teleports file")
        end
    end
end

function Util.LoadQuickTeleports()
    local teleFile = io.open(Util.quickTelePath, "r")
    if teleFile ~= nil then
        local teleConfig = json.decode(teleFile:read("*a"))
        teleFile:close()

        if teleConfig ~= nil then return teleConfig
        else return Util.configurationDefault.functions.quickTeleports
        end
    else
        DEBUG_printl(LOG_LEVEL.Info, "FAILED TO LOAD QUICK TELEPORTS")
        Util.configurationDefault.functions.quickTeleports[1].name = UILabels.misc.teleport.bApartment
        Util.configurationDefault.functions.quickTeleports[2].name = UILabels.misc.teleport.bViktor
        return Util.configurationDefault.functions.quickTeleports
    end
end

function Util.SaveConfig(skipTele)
    skipTele = skipTele or false

    local file = io.open(Util.configPath, "w")
    local jconfig = json.encode(Util.configuration)

    if file ~= nil then
        file:write(jconfig)
        file:close()
    else
        print("[SimpleMenu] Failed to save user configuration")
    end

    if not skipTele then
        local teleFile = io.open(Util.quickTelePath, "w")
        local teleConfig = json.encode(Util.configuration.functions.quickTeleports)
        if teleFile ~= nil then
            teleFile:write(teleConfig)
            teleFile:close()
        else
            print("[SimpleMenu] Failed to save quick teleports")
        end
    end
end

function Util.SaveLanguageConfig(val)
    local file = io.open("./translation/lang.json", "w")
    local jconfig = json.encode(val)
    if file ~= nil then
        file:write(jconfig)
        file:close()
    else
        print("[SimpleMenu] Failed to save language configuration")
    end
end

return Util