local Util = {
    counter = 0,
    configPath = "config/config.json",
    quickTelePath = "config/quickTele.json",
    configuration = {},
    configurationDefault = {
        version = 52.4,
        modVersion = 52.4,
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
    -- Use a deep copy of the defaults so mutating the user's config never
    -- corrupts the shared `configurationDefault` table (which would also
    -- affect future fresh installs).
    Util.configuration = Util.DeepCopy(Util.configurationDefault)

    --Set some defaults that need to be loaded
    Util.configuration.functions.quickTeleports[1].name = UILabels.misc.teleport.bApartment
    Util.configuration.functions.quickTeleports[2].name = UILabels.misc.teleport.bViktor

    print("[SimpleMenu] User configuration reset")
    Util.SaveConfig(true)
end

--Recursively merge `src` into `dst`, preserving existing values in `dst`
--and adding any missing keys from `src`. Tables are merged key-by-key;
--scalars in `dst` are kept. Used for non-destructive config migration.
local function mergeDefaults(dst, src)
    if type(dst) ~= "table" or type(src) ~= "table" then
        return dst
    end
    for k, v in pairs(src) do
        if type(v) == "table" then
            if dst[k] == nil or type(dst[k]) ~= "table" then
                dst[k] = {}
            end
            mergeDefaults(dst[k], v)
        else
            if dst[k] == nil then
                dst[k] = v
            end
        end
    end
    return dst
end

Util.mergeDefaults = mergeDefaults

--Deep (recursive) copy of a table. Unlike CetUtils.TableCopy (which is shallow),
--this fully clones nested tables so mutating the copy never affects the original.
--Important for cloning `configurationDefault` so user mutations can't corrupt
--the defaults that future fresh installs would inherit.
local function deepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

Util.DeepCopy = deepCopy

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

        if config == nil then
            print("[SimpleMenu] Failed to decode user configuration; using defaults")
            Util.configuration = Util.DeepCopy(Util.configurationDefault)
        else
            -- Non-destructive migration: pull in any new default keys the user's
            -- old config doesn't have, while preserving their existing values.
            -- This replaces the old behavior of wiping the entire config whenever
            -- the version number changed.
            local oldVersion = config.version
            mergeDefaults(config, Util.configurationDefault)
            config.version = Util.configurationDefault.version
            config.modVersion = Util.configurationDefault.modVersion
            config.isBeta = Util.configurationDefault.isBeta
            Util.configuration = config
            print("[SimpleMenu] Configuration loaded (was v"..tostring(oldVersion)..", now v"..config.version..")")
        end

        Util.configuration.functions.quickTeleports = Util.LoadQuickTeleports()
        Util.CreateQuickTeleports(Util.configuration.functions.quickTeleports)
    else
        print("[SimpleMenu] Failed to load user configuration")
        Util.configuration = Util.DeepCopy(Util.configurationDefault)
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