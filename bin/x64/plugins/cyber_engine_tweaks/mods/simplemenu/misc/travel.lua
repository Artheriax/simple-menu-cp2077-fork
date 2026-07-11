local Travel = {
    instantSpawn = false
}

Travel.Util = require("config/util")
local Items = require("items/items")
local CUtil = require("misc/cetUtils")

local playerApartments = {
    {
        name = "V's Megabuilding H10 Apartment",
        loc  = { -1390.0656, 1271.3367, 123.0824, 1 },
        dir  = { 0, 0, -96.20002 }
    },
    {
        name = "Corpo Plaza Apartment",
        loc  = { -1606.5579, 362.14868, 49.21, 1 },
        dir  = { 0, 0, 179.54999 }
    },
    {
        name = "Glen Apartment",
        loc  = { -1525.6123, -968.8601, 86.97, 1 },
        dir  = { 0, 0, 179.79997 }
    },
    {
        name = "Japantown Apartment",
        loc  = { -782.66895, 978.5567, 28.209541, 1 },
        dir  = { 0, -0, 97.349884 }
    },
    {
        name = "Northside Apartment",
        loc  = { -1503.0637, 2225.4202, 22.199997, 1 },
        dir  = { 0, 0, 34.15005 }
    },
    {
        name = "Dogtown Hideout",
        loc  = { -2237.372, -2556.6138, 80.30098, 1 },
        dir  = { -0, 0, -134.54433 }
    },
    {
        name = "V's Mansion (Outside)",
        loc  = { -1342.5204, 1220.2633, 115.100006, 1 },
        dir  = { 0, -0, 174.49997 }
    },
    {
        name = "V's Mansion (Inside - you will need to teleport out)",
        loc  = { -1343.1973, 1210.1692, 115.04297, 1 },
        dir  = { 0, -0, 174.49997 }
    }
}

Travel.Apartments = CUtil.ArrayProject(
    playerApartments,
    function(v)
        return v.name
    end
)
table.insert(Travel.Apartments, 1, UILabels.misc.teleport.cApartmentTel)

local coordinates = {
    quick = {
        apartment = {
            { "-1380.580566", "1271.436035", "123.064896" }, --V's apartment
        },
        mansion = {
            { "-1341.383545", "1242.970337", "111.100006" }, --V's mansion
        },
        viktor = {
            { "-1546.726196", "1227.393066", "11.520233" } --Viktor's clinic
        }
    },
    custom = {
        {
            { "-1218.135986", "1409.635010", "113.524445" }, --generic
            { "4743.650879", "-1091.755127", "1310.439575" },
            { "-1449.256470", "118.300171", "321.639038" },
            { "-1383.655518", "118.832474", "542.696289" },
            { "185.345749", "2365.449707", "67.081177" },
            { "-1663.618774", "-1867.443726", "54.990150" },
            { "-652.481812", "790.145996", "128.252228" },
            { "-1389.446533", "141.266556", "-139.361572" },
            { "-2202.186035", "1783.184204", "163.000000" },
            { "-1371.780029", "1340.888550", "311.471313" },
            { "-701.484680", "849.270264", "322.252228" },
            { "-1761.547729", "-1010.821655", "94.300003" },
            { "-1456.893433", "1038.277222", "16.825035" },
            { "-665.472961", "810.591492", "128.273163" },
            { "-940.837341", "-77.526871", "7.509773" },
            { "-1260.774536", "-981.771790", "11.589195" },
            { "-2265.841309", "-2112.402588", "13.296661" },
            { "-640.769165", "886.267151", "19.888809" },
            { "-1207.988525", "1563.142090", "22.920128" },
            { "3444.628174", "-365.633270", "133.852707" },
            { "1816.382324", "2256.925781", "180.260223" },
            { "-1158.889404", "1342.452271", "19.943626" },
            { "-1751.548462", "-1933.493042", "61.524582" },
            { "-1782.537598", "-390.172638", "-4.015121" },
            { "2599.074707", "-33.218079", "80.714417" },
            { "1628.261475", "-775.431030", "49.980309" },
            { "3602.863037", "-879.516479", "119.546600" }
        },
        {
            { "-645.418945", "-1260.975586", "9.376778" }, --npc
            { "2419.131836", "-795.221985", "66.996750" },
            { "-1967.008423", "369.847382", "8.040825" },
            { "-906.306396", "1868.635620", "42.360016" },
            { "-1546.295776", "1194.164063", "16.260002" },
            { "405.594482", "-2352.642578", "182.027740" },
            { "-1149.433105", "1581.234619", "71.712402" },
            { "1235.896606", "-504.580139", "36.427094" },
            { "-1427.401245", "1014.764099", "16.901749" },
            { "-1803.299805", "-1279.714111", "21.837990" },
            { "-668.265747", "823.310669", "19.566063" }
        },
        {
            { "-964.2407", "2778.072", "30.049217" }, --perk shards
            { "-399.95956", "254.22954", "22.14943" },
            { "-874.67896", "-1008.6402", "11.369972" },
            { "-253.68695", "-1462.9231", "7.5999146" },
            { "-254.02971", "-1508.8351", "12.610001" },
            { "-1984.3334", "-1027.2446", "7.6319275" },
            { "-1354.8429", "444.22794", "13.151001" },
            { "645.40015", "-2159.7837", "39.349243" },
            { "2287.9966", "-1051.378", "55.498795" }
        },
        {
            { "-1575.944580", "-282.437988", "-4.425003" }, --vendor clothing
            { "-682.614563", "1239.223755", "37.966957" },
            { "-1884.361938", "82.698013", "7.519997" },
            { "-1119.808105", "1752.149658", "33.722076" },
            { "-230.233231", "-36.969742", "0.883064" },
            { "-1522.441040", "1701.879639", "18.317543" },
            { "253.300400", "-1475.245850", "9.500000" },
            { "-1017.764709", "-1557.709351", "25.700897" },
            { "-1895.527832", "2504.133301", "18.263504" },
            { "1202.813965", "-570.510498", "32.692131" },
            { "-2437.346680", "-666.163452", "6.922104" },
            { "-2477.911377", "-2536.459229", "16.969376" }
        },
        {
            { "-1430.860107", "1335.109497", "119.206131" }, --vendor melee
            { "-337.444519", "563.404053", "38.349251" },
            { "-476.260040", "-1942.191772", "7.003807" },
            { "133.805145", "-4670.488281", "54.607399" },
            { "-2529.142578", "-2468.510010", "17.196762" }
        },
        {
            { "-492.061035", "583.292725", "26.802223" }, --vendor netrunner
            { "-1906.515015", "-1925.094238", "48.903023" },
            { "-351.593842", "1368.778564", "42.124115" },
            { "-1180.311279", "2041.457520", "20.087074" }
        },
        {
            { "-1090.759155", "2147.218262", "13.330742" }, --vendor ripperdoc
            { "-1686.586182", "2386.400879", "18.344055" },
            { "-712.370605", "871.832458", "11.982414" },
            { "-1245.325439", "1945.930908", "8.030479" },
            { "-573.507813", "795.048279", "24.906097" },
            { "-1040.245972", "1440.913696", "0.500221" },
            { "-40.347633", "-52.439484", "7.179688" },
            { "3438.949463", "-380.475800", "133.569855" },
            { "1814.132202", "2274.446289", "182.176987" },
            { "588.132568", "-2179.594482", "42.437347" },
            { "-2361.011475", "-929.024597", "12.266129" },
            { "-2411.207764", "393.523010", "11.837067" },
            { "-1546.726196", "1227.393066", "11.520233" },
            { "-705.582397", "-395.248322", "8.199997" },
            { "-2607.956787", "-2498.076660", "17.334549" },
            { "-1072.172729", "-1274.062866", "11.456871" }
        },
        {
            { "-2402.214355", "-630.521790", "6.906044" }, --vendor weapon
            { "-906.048767", "-703.476807", "8.237724" },
            { "-1846.321899", "-4295.308105", "74.014191" },
            { "-1770.706543", "222.652618", "43.727768" },
            { "-1895.143433", "2729.943359", "7.449997" },
            { "-783.261963", "2183.184570", "52.801941" },
            { "-992.885986", "-1589.419189", "25.700897" },
            { "3429.046387", "-375.550720", "133.535477" },
            { "1796.789307", "2253.482178", "180.262894" },
            { "-2438.164063", "-2405.232422", "16.722504" },
            { "569.700745", "-2201.206787", "35.345894" },
            { "-453.489319", "1450.199219", "37.388107" },
            { "-1207.415771", "2043.946289", "7.844711" },
            { "1678.147217", "-771.591980", "49.839981" },
            { "-1899.170654", "-1019.690430", "7.676468" },
            { "-1450.176147", "1311.742676", "119.082397" }
        }
    }
}

function Travel.Teleport(verboseType, category, type)
    local player = Game.GetPlayer()
    local tele = Game.GetTeleportationFacility()
    local pos = Vector4.new()
    pos.w = 1
    pos.x = tonumber(coordinates[verboseType][category][type][1])
    pos.y = tonumber(coordinates[verboseType][category][type][2])
    pos.z = tonumber(coordinates[verboseType][category][type][3])

    tele:Teleport(player, pos, EulerAngles.new())
    print("[SimpleMenu] Teleported to location", pos.x, pos.y, pos.z)
end

function Travel.JumpForward(dist)
    local player = Game.GetPlayer()
    local orientation = player:GetWorldOrientation()
    local eulerOrient = Quaternion.ToEulerAngles(orientation)
    local foreVector  = EulerAngles.GetForward(eulerOrient)
    local currentPos  = player:GetWorldPosition()
    local jumpToPos   = Vector4.new(0, 0, 0, 1)
    local tf = Game.GetTeleportationFacility()

    jumpToPos.x = currentPos.x + (dist * foreVector.x)
    jumpToPos.y = currentPos.y + (dist * foreVector.y)
    jumpToPos.z = currentPos.z + (dist * foreVector.z)

    tf:Teleport(player, jumpToPos, eulerOrient)
end

function Travel.TeleportToApartment(apartment)
    if apartment == 0 then return end
    local player = Game.GetPlayer()
    local tele = Game.GetTeleportationFacility()
    local loc = Vector4.new(unpack(playerApartments[apartment].loc))
    local dir = EulerAngles.new(unpack(playerApartments[apartment].dir))
    tele:Teleport(player, loc, dir)
    print("[SimpleMenu] Teleported to", playerApartments[apartment].name)
end

function Travel.QuickTeleport(qtRec)
    local player = Game.GetPlayer()
    local tele = Game.GetTeleportationFacility()
    local loc = Vector4.new(unpack(qtRec.loc))
    local dir = EulerAngles.new(unpack(qtRec.dir))
    tele:Teleport(player, loc, dir)
end

function Travel.UnlockVehicle(type, unlock)
    if type == 0 then return end
    local despawn = false
    local msgText = "Unlocked"
    if not unlock then
        despawn = true
        msgText = "Locked"
    end
    type = type + 1 --I'VE HAD IT WITH THESE 1-INDEXED LISTS
    local vs = Game.GetVehicleSystem()
    vs:EnablePlayerVehicle(Items.Vehicles[type], unlock, despawn)
    print("[SimpleMenu] Vehicle "..msgText..":", Items.VehicleNames[type])
end

function Travel.UnlockVehicleAll()
    local vs = Game.GetVehicleSystem()
    vs:EnableAllPlayerVehicles()
    print("[SimpleMenu] All vehicles unlocked")
end

function Travel.ToggleVehicleSpawn()
    local vs = Game.GetVehicleSystem()
    vs:ToggleSummonMode()
    Travel.instantSpawn = not Travel.instantSpawn
    print("[SimpleMenu] Toggled Instant Vehicle Spawn")
end

function Travel.SaveCurrentQTele(qRec)
    Travel.Util.configuration.functions.savedPositionX = qRec.loc[1]
    Travel.Util.configuration.functions.savedPositionY = qRec.loc[2]
    Travel.Util.configuration.functions.savedPositionZ = qRec.loc[3]
    Travel.Util.configuration.functions.savedYaw       = qRec.dir[3]
    Travel.Util.SaveConfig()
    print("[SimpleMenu] Saved QT position: X =", qRec.loc[1], "Y =", qRec.loc[2], "Z =", qRec.loc[3], "Yaw =", qRec.dir[3])
end

function Travel.SaveCurrentPos()
    local player = Game.GetPlayer()
    local pos    = player:GetWorldPosition()
    local dirn   = Quaternion.ToEulerAngles(player:GetWorldOrientation())
    Travel.Util.configuration.functions.savedPositionX = pos.x
    Travel.Util.configuration.functions.savedPositionY = pos.y
    Travel.Util.configuration.functions.savedPositionZ = pos.z
    Travel.Util.configuration.functions.savedYaw       = dirn.yaw
    Travel.Util.SaveConfig()
    print("[SimpleMenu] Saved current position: X =", pos.x, "Y =", pos.y, "Z =", pos.z, "Yaw =", dirn.yaw)
end

function Travel.MoveSavedPos()
    if(Travel.Util.configuration.functions.savedPositionX ~= 0 and Travel.Util.configuration.functions.savedPositionY ~= 0 and Travel.Util.configuration.functions.savedPositionZ ~= 0) then
        local player = Game.GetPlayer()
        local tele = Game.GetTeleportationFacility()
        local pos = Vector4.new();
        local dir = EulerAngles.new()
        pos.w = 1
        pos.x = Travel.Util.configuration.functions.savedPositionX
        pos.y = Travel.Util.configuration.functions.savedPositionY
        pos.z = Travel.Util.configuration.functions.savedPositionZ
        dir.yaw = Travel.Util.configuration.functions.savedYaw

        tele:Teleport(player, pos, dir)
        print("[SimpleMenu] Teleport to saved location")
    else
        print("[SimpleMenu] No saved teleport location found")
    end
end

return Travel