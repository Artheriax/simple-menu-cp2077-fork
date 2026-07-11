-- PERK TAB DEVELOPED BY Corvellt - https://www.nexusmods.com/users/20850139
local Perks = {}

local CUtil = require("misc/cetUtils")

local perkCatKeys = {}

Perks.PerkList = { }

function Perks.GetPerkNames(category)
    local perkNameList = {}
    table.insert(perkNameList, "")
    for _, v in pairs(Perks.PerkList[category]) do
        table.insert(perkNameList, CUtil.GetLocalizedPerkName(v))
    end
    return perkNameList
end

function Perks.Preload()
    Perks.PerkList = {
        Body = {
            gamedataNewPerkType.Body_Central_Milestone_1,
            gamedataNewPerkType.Body_Right_Milestone_1,
            gamedataNewPerkType.Body_Left_Milestone_2,
            gamedataNewPerkType.Body_Right_Milestone_2,
            gamedataNewPerkType.Body_Central_Milestone_3,
            gamedataNewPerkType.Body_Left_Milestone_3,
            gamedataNewPerkType.Body_Right_Milestone_3,
            gamedataNewPerkType.Body_Central_Perk_1_1,
            gamedataNewPerkType.Body_Central_Perk_1_2,
            gamedataNewPerkType.Body_Central_Perk_1_3,
            gamedataNewPerkType.Body_Central_Perk_1_4,
            gamedataNewPerkType.Body_Central_Perk_3_1,
            gamedataNewPerkType.Body_Central_Perk_3_2,
            gamedataNewPerkType.Body_Central_Perk_3_4,
            gamedataNewPerkType.Body_Left_Perk_2_1,
            gamedataNewPerkType.Body_Left_Perk_2_3,
            gamedataNewPerkType.Body_Left_Perk_2_4,
            gamedataNewPerkType.Body_Left_Perk_3_1,
            gamedataNewPerkType.Body_Left_Perk_3_2,
            gamedataNewPerkType.Body_Left_Perk_3_3,
            gamedataNewPerkType.Body_Left_Perk_3_4,
            gamedataNewPerkType.Body_Right_Perk_2_1,
            gamedataNewPerkType.Body_Right_Perk_2_2,
            gamedataNewPerkType.Body_Right_Perk_2_3,
            gamedataNewPerkType.Body_Right_Perk_2_4,
            gamedataNewPerkType.Body_Right_Perk_3_1,
            gamedataNewPerkType.Body_Right_Perk_3_2,
            gamedataNewPerkType.Body_Inbetween_Left_3,
            gamedataNewPerkType.Body_Inbetween_Right_3,
            gamedataNewPerkType.Body_Master_Perk_1,
            gamedataNewPerkType.Body_Master_Perk_2,
            gamedataNewPerkType.Body_Master_Perk_3,
            gamedataNewPerkType.Body_Master_Perk_5
        },
        Cool = {
            gamedataNewPerkType.Cool_Central_Milestone_1,
            gamedataNewPerkType.Cool_Left_Milestone_1,
            gamedataNewPerkType.Cool_Right_Milestone_1,
            gamedataNewPerkType.Cool_Left_Milestone_2,
            gamedataNewPerkType.Cool_Right_Milestone_2,
            gamedataNewPerkType.Cool_Central_Milestone_3,
            gamedataNewPerkType.Cool_Left_Milestone_3,
            gamedataNewPerkType.Cool_Right_Milestone_3,
            gamedataNewPerkType.Cool_Central_Perk_1_1,
            gamedataNewPerkType.Cool_Central_Perk_1_2,
            gamedataNewPerkType.Cool_Central_Perk_1_4,
            gamedataNewPerkType.Cool_Central_Perk_3_1,
            gamedataNewPerkType.Cool_Central_Perk_3_2,
            gamedataNewPerkType.Cool_Central_Perk_3_4,
            gamedataNewPerkType.Cool_Left_Perk_2_1,
            gamedataNewPerkType.Cool_Left_Perk_2_2,
            gamedataNewPerkType.Cool_Left_Perk_2_3,
            gamedataNewPerkType.Cool_Left_Perk_2_4,
            gamedataNewPerkType.Cool_Left_Perk_3_1,
            gamedataNewPerkType.Cool_Left_Perk_3_2,
            gamedataNewPerkType.Cool_Left_Perk_3_3,
            gamedataNewPerkType.Cool_Left_Perk_3_4,
            gamedataNewPerkType.Cool_Right_Perk_1_1,
            gamedataNewPerkType.Cool_Right_Perk_1_2,
            gamedataNewPerkType.Cool_Right_Perk_2_1,
            gamedataNewPerkType.Cool_Right_Perk_2_2,
            gamedataNewPerkType.Cool_Right_Perk_2_3,
            gamedataNewPerkType.Cool_Right_Perk_2_4,
            gamedataNewPerkType.Cool_Right_Perk_3_1,
            gamedataNewPerkType.Cool_Right_Perk_3_2,
            gamedataNewPerkType.Cool_Right_Perk_3_3,
            gamedataNewPerkType.Cool_Right_Perk_3_4,
            gamedataNewPerkType.Cool_Inbetween_Left_2,
            gamedataNewPerkType.Cool_Inbetween_Left_3,
            gamedataNewPerkType.Cool_Inbetween_Right_3,
            gamedataNewPerkType.Cool_Master_Perk_1,
            gamedataNewPerkType.Cool_Master_Perk_2,
            gamedataNewPerkType.Cool_Master_Perk_4
        },
        Intelligence = {
            gamedataNewPerkType.Intelligence_Central_Milestone_1,
            gamedataNewPerkType.Intelligence_Left_Milestone_1,
            gamedataNewPerkType.Intelligence_Right_Milestone_1,
            gamedataNewPerkType.Intelligence_Central_Milestone_2,
            gamedataNewPerkType.Intelligence_Left_Milestone_2,
            gamedataNewPerkType.Intelligence_Right_Milestone_2,
            gamedataNewPerkType.Intelligence_Left_Milestone_3,
            gamedataNewPerkType.Intelligence_Central_Milestone_3,
            gamedataNewPerkType.Intelligence_Right_Milestone_3,
            gamedataNewPerkType.Intelligence_Central_Perk_1_1,
            gamedataNewPerkType.Intelligence_Central_Perk_1_2,
            gamedataNewPerkType.Intelligence_Central_Perk_1_3,
            gamedataNewPerkType.Intelligence_Central_Perk_2_1,
            gamedataNewPerkType.Intelligence_Central_Perk_2_2,
            gamedataNewPerkType.Intelligence_Central_Perk_2_3,
            gamedataNewPerkType.Intelligence_Central_Perk_2_4,
            gamedataNewPerkType.Intelligence_Central_Perk_3_1,
            gamedataNewPerkType.Intelligence_Central_Perk_3_2,
            gamedataNewPerkType.Intelligence_Central_Perk_3_3,
            gamedataNewPerkType.Intelligence_Left_Perk_1_1,
            gamedataNewPerkType.Intelligence_Left_Perk_1_2,
            gamedataNewPerkType.Intelligence_Left_Perk_2_1,
            gamedataNewPerkType.Intelligence_Left_Perk_2_2,
            gamedataNewPerkType.Intelligence_Left_Perk_2_3,
            gamedataNewPerkType.Intelligence_Left_Perk_2_4,
            gamedataNewPerkType.Intelligence_Left_Perk_3_1,
            gamedataNewPerkType.Intelligence_Left_Perk_3_2,
            gamedataNewPerkType.Intelligence_Left_Perk_3_4,
            gamedataNewPerkType.Intelligence_Right_Perk_2_1,
            gamedataNewPerkType.Intelligence_Right_Perk_2_2,
            gamedataNewPerkType.Intelligence_Right_Perk_3_1,
            gamedataNewPerkType.Intelligence_Right_Perk_3_2,
            gamedataNewPerkType.Intelligence_Inbetween_Left_2,
            gamedataNewPerkType.Intelligence_Inbetween_Left_3,
            gamedataNewPerkType.Intelligence_Inbetween_Right_2,
            gamedataNewPerkType.Intelligence_Master_Perk_1,
            gamedataNewPerkType.Intelligence_Master_Perk_3,
            gamedataNewPerkType.Intelligence_Master_Perk_4
        },
        Reflexes = {
            gamedataNewPerkType.Reflexes_Central_Milestone_1,
            gamedataNewPerkType.Reflexes_Left_Milestone_1,
            gamedataNewPerkType.Reflexes_Central_Milestone_2,
            gamedataNewPerkType.Reflexes_Left_Milestone_2,
            gamedataNewPerkType.Reflexes_Right_Milestone_2,
            gamedataNewPerkType.Reflexes_Central_Milestone_3,
            gamedataNewPerkType.Reflexes_Left_Milestone_3,
            gamedataNewPerkType.Reflexes_Right_Milestone_3,
            gamedataNewPerkType.Reflexes_Central_Perk_1_1,
            gamedataNewPerkType.Reflexes_Central_Perk_1_2,
            gamedataNewPerkType.Reflexes_Central_Perk_1_3,
            gamedataNewPerkType.Reflexes_Central_Perk_1_4,
            gamedataNewPerkType.Reflexes_Central_Perk_2_1,
            gamedataNewPerkType.Reflexes_Central_Perk_2_2,
            gamedataNewPerkType.Reflexes_Central_Perk_2_3,
            gamedataNewPerkType.Reflexes_Central_Perk_2_4,
            gamedataNewPerkType.Reflexes_Central_Perk_3_2,
            gamedataNewPerkType.Reflexes_Central_Perk_3_3,
            gamedataNewPerkType.Reflexes_Left_Perk_2_2,
            gamedataNewPerkType.Reflexes_Left_Perk_2_3,
            gamedataNewPerkType.Reflexes_Left_Perk_2_4,
            gamedataNewPerkType.Reflexes_Left_Perk_3_1,
            gamedataNewPerkType.Reflexes_Left_Perk_3_2,
            gamedataNewPerkType.Reflexes_Left_Perk_3_3,
            gamedataNewPerkType.Reflexes_Left_Perk_3_4,
            gamedataNewPerkType.Reflexes_Right_Perk_2_1,
            gamedataNewPerkType.Reflexes_Right_Perk_2_2,
            gamedataNewPerkType.Reflexes_Right_Perk_2_3,
            gamedataNewPerkType.Reflexes_Right_Perk_3_1,
            gamedataNewPerkType.Reflexes_Right_Perk_3_3,
            gamedataNewPerkType.Reflexes_Right_Perk_3_4,
            gamedataNewPerkType.Reflexes_Inbetween_Left_3,
            gamedataNewPerkType.Reflexes_Inbetween_Right_2,
            gamedataNewPerkType.Reflexes_Master_Perk_1,
            gamedataNewPerkType.Reflexes_Master_Perk_2,
            gamedataNewPerkType.Reflexes_Master_Perk_3,
            gamedataNewPerkType.Reflexes_Master_Perk_5
        },
        TechnicalAbility = {
            gamedataNewPerkType.Tech_Left_Milestone_1,
            gamedataNewPerkType.Tech_Right_Milestone_1,
            gamedataNewPerkType.Tech_Central_Milestone_2,
            gamedataNewPerkType.Tech_Left_Milestone_2,
            gamedataNewPerkType.Tech_Left_Milestone_3,
            gamedataNewPerkType.Tech_Central_Milestone_3,
            gamedataNewPerkType.Tech_Right_Milestone_3,
            gamedataNewPerkType.Tech_Central_Perk_2_1,
            gamedataNewPerkType.Tech_Central_Perk_2_2,
            gamedataNewPerkType.Tech_Central_Perk_2_3,
            gamedataNewPerkType.Tech_Central_Perk_2_4,
            gamedataNewPerkType.Tech_Central_Perk_3_1,
            gamedataNewPerkType.Tech_Central_Perk_3_2,
            gamedataNewPerkType.Tech_Central_Perk_3_3,
            gamedataNewPerkType.Tech_Central_Perk_3_4,
            gamedataNewPerkType.Tech_Left_Perk_1_1,
            gamedataNewPerkType.Tech_Left_Perk_1_2,
            gamedataNewPerkType.Tech_Left_Perk_2_1,
            gamedataNewPerkType.Tech_Left_Perk_2_2,
            gamedataNewPerkType.Tech_Left_Perk_2_3,
            gamedataNewPerkType.Tech_Left_Perk_2_4,
            gamedataNewPerkType.Tech_Left_Perk_3_01,
            gamedataNewPerkType.Tech_Left_Perk_3_2,
            gamedataNewPerkType.Tech_Left_Perk_3_3,
            gamedataNewPerkType.Tech_Left_Perk_3_4,
            gamedataNewPerkType.Tech_Right_Perk_3_1,
            gamedataNewPerkType.Tech_Right_Perk_3_2,
            gamedataNewPerkType.Tech_Right_Perk_3_3,
            gamedataNewPerkType.Tech_Right_Perk_3_4,
            gamedataNewPerkType.Tech_Inbetween_Left_3,
            gamedataNewPerkType.Tech_Inbetween_Right_2,
            gamedataNewPerkType.Tech_Master_Perk_2,
            gamedataNewPerkType.Tech_Master_Perk_3,
            gamedataNewPerkType.Tech_Master_Perk_5
        },
        Relic = {
            gamedataNewPerkType.Espionage_Central_Milestone_1,
            gamedataNewPerkType.Espionage_Left_Milestone_Perk,
            gamedataNewPerkType.Espionage_Right_Milestone_1,
            gamedataNewPerkType.Espionage_Central_Perk_1_1,
            gamedataNewPerkType.Espionage_Central_Perk_1_2,
            gamedataNewPerkType.Espionage_Central_Perk_1_3,
            gamedataNewPerkType.Espionage_Central_Perk_1_4,
            gamedataNewPerkType.Espionage_Left_Perk_1_2,
            gamedataNewPerkType.Espionage_Right_Perk_1_1
        }
    }

    perkCatKeys = {
        { key = "Body", dt = gamedataAttributeDataType.BodyAttributeData },
        { key = "Cool", dt = gamedataAttributeDataType.CoolAttributeData },
        { key = "Intelligence", dt = gamedataAttributeDataType.IntelligenceAttributeData },
        { key = "Reflexes", dt = gamedataAttributeDataType.ReflexesAttributeData },
        { key = "TechnicalAbility", dt = gamedataAttributeDataType.TechnicalAbilityAttributeData },
        { key = "Relic", dt = gamedataAttributeDataType.EspionageAttributeData }
    }
end

function Perks.AddPerkLevel(category, type)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    print(category, type)
    local succ = pdd:BuyNewPerk(Perks.PerkList[category][type], true) --force so doesn't spend points
    if succ then
        print("[SimpleMenu] Perk Added:", CUtil.GetLocalizedPerkName(Perks.PerkList[category][type]))
    else
        print("[SimpleMenu] could not add perk:", CUtil.GetLocalizedPerkName(Perks.PerkList[category][type]))
    end
end

function Perks.RemovePerk(category, type)
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())

    --force sell gives back points even though force buy doesn't spend them, so... lol w/e
    local sold, level = pdd:ForceSellNewPerk(Perks.PerkList[category][type])
    if sold then
        print("[SimpleMenu] Perk Removed:", CUtil.GetLocalizedPerkName(Perks.PerkList[category][type]), "Level Removed:", level)
    else
        print("[SimpleMenu] could not remove perk", CUtil.GetLocalizedPerkName(Perks.PerkList[category][type]))
    end
end

function Perks.AddAllPerks()
    local pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    pdd:AddDevelopmentPoints(999, gamedataDevelopmentPointType.Espionage)
    pdd:AddDevelopmentPoints(999, gamedataDevelopmentPointType.Primary)
    for _, v in pairs(perkCatKeys) do
        for _, p in pairs(Perks.PerkList[v.key]) do
            local levels = CUtil.GetPerkLvlCount(p)
            for _ = 1, levels do
                pdd:BuyNewPerk(p, false)
                pdd = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
                pdd:UnlockFreeNewPerks(v.dt)
            end
        end
    end
    pdd:ClearAllDevPoints()
end



return Perks