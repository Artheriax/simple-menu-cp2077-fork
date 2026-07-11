local Upgrade = {}

local quality = {
    "Common",
    "CommonPlus",
    "Uncommon",
    "UncommonPlus",
    "Rare",
    "RarePlus",
    "Epic",
    "EpicPlus",
    "Legendary",
    "LegendaryPlus",
    "LegendaryPlusPlus"
}

local Items = require("items/items")

--original script created by Expired, heavily modified by Dank Rafft
function Upgrade.ChangeQuality(newItemQuality, processSlot, mode)
    local player = Game.GetPlayer()
    local ssc = Game.GetScriptableSystemsContainer()
    local ts = Game.GetTransactionSystem()
    local ss = Game.GetStatsSystem()
    local es = ssc:Get(CName.new('EquipmentSystem'))
    local espd = es:GetPlayerData(player)
    espd['GetItemInEquipSlot2'] = espd['GetItemInEquipSlot;gamedataEquipmentAreaInt32']
    local playerPLValue = ss:GetStatValue(player:GetEntityID(), 'PowerLevel')
    local modItemLevel = 0

    local slots = {
        { "Face", 1 },
        { "Feet", 1 },
        { "Head", 1 },
        { "InnerChest", 1 },
        { "Legs", 1 },
        { "OuterChest", 1 },
        { "Outfit", 1 },
        { "Weapon", 1 },
        { "Weapon", 2 },
        { "Weapon", 3 },
    }

    --process all equipped items
    if(processSlot == 0) then
        for k, _ in pairs(slots) do
            local itemid = espd:GetItemInEquipSlot2(slots[k][1], slots[k][2] - 1)
            if (itemid.tdbid.hash ~= 0) then

                --variables
                local itemdata = ts:GetItemData(player, itemid)
                local statObj = itemdata:GetStatsObjectID()
                local itemLevel = ss:GetStatValue(statObj, 'ItemLevel')
                local powerLevel = ss:GetStatValue(statObj, 'PowerLevel')
                local itemQuality = math.floor(ss:GetStatValue(statObj, 'Quality'))

                --recalculate item level
                if(mode == 1 or mode == 0) then
                    if (itemLevel < math.floor(playerPLValue) * 10) then
                        modItemLevel = math.floor(playerPLValue - powerLevel) * 10 + 5
                        local levelMod = Game['gameRPGManager::CreateStatModifier;gamedataStatTypegameStatModifierTypeFloat']('ItemLevel', 'Additive', modItemLevel)
                        ss:AddSavedModifier(statObj, levelMod)
                        --print result
                        print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "changed from item level", itemLevel, "to", (itemLevel + modItemLevel))
                    else
                        print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "already is at max item level.")
                    end
                end

                --recalculate item quality
                if(mode == 2 or mode == 0) then
                    if(newItemQuality ~= 0) then
                        if (itemQuality < newItemQuality) then
                            RPGManager.ForceItemTier(player, itemdata, CName.new(quality[newItemQuality]))
                            --print result
                            print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "changed from item quality", quality[itemQuality], "to", quality[newItemQuality])
                        else
                            print("[SimpleMenu] Equipment: Item in", slots[k][1], "slot", slots[k][2], "already is at selected or higher quality")
                        end
                    else
                        print("[SimpleMenu] Equipment: Invalid argument, you need to select a quality.")
                    end
                end
            end
        end

    --proccess only selected slot
    elseif(processSlot ~= 0 and newItemQuality ~= 0) then
        local itemid = espd:GetItemInEquipSlot2(slots[processSlot][1], slots[processSlot][2] - 1)
        if (itemid.tdbid.hash ~= 0) then

            --variables
            local itemdata = ts:GetItemData(player, itemid)
            local statObj = itemdata:GetStatsObjectID()
            local itemLevel = ss:GetStatValue(statObj, 'ItemLevel')
            local powerLevel = ss:GetStatValue(statObj, 'PowerLevel')
            local itemQuality = math.floor(ss:GetStatValue(statObj, 'Quality'))

            --recalculate item level
            if(mode == 1 or mode == 0) then
                if (itemLevel < math.floor(playerPLValue) * 10) then
                    modItemLevel = math.floor(playerPLValue - powerLevel) * 10 + 5
                    local levelMod = Game['gameRPGManager::CreateStatModifier;gamedataStatTypegameStatModifierTypeFloat']('ItemLevel', 'Additive', modItemLevel)
                    ss:AddSavedModifier(statObj, levelMod)
                    --print result
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "changed from item level", itemLevel, "to", (itemLevel + modItemLevel))
                else
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "already is at max item level.")
                end
            end

            --recalculate item quality
            if(mode == 2 or mode == 0) then
                if(newItemQuality ~= 0) then
                    RPGManager.ForceItemTier(player, itemdata, CName.new(quality[newItemQuality]))
                    --print result
                    print("[SimpleMenu] Equipment: Item in", slots[processSlot][1], "slot", slots[processSlot][2], "changed from item quality", quality[itemQuality], "to", quality[newItemQuality])
                else
                    print("[SimpleMenu] Equipment: Invalid argument, you need to select a quality.")
                end
            end
        end
    end
end

function Upgrade.UpgradeAll(forceQual)
    local player = Game.GetPlayer()
    local ts = Game.GetTransactionSystem()
    local gotItems, items = ts:GetItemListExcludingTags(player, { CName.new("CraftingPart"), CName.new("Currency"), CName.new("Ammo") })
    if gotItems then
        for _, v in pairs(items) do
            DEBUG_printl(LOG_LEVEL.Trace, "UPGRADE:", v, v:GetID().id.value)
            Items.UpgradeItemWithForcedQuality(v, forceQual)
        end
    end
end

--created by Expired
--removes quest tag from items
function Upgrade.RemoveQuest()
    local player = Game.GetPlayer()
    local ssc = Game.GetScriptableSystemsContainer()
    local ts = Game.GetTransactionSystem()
    local es = ssc:Get(CName.new('EquipmentSystem'))
    local espd = es:GetPlayerData(player)
    espd['GetItemInEquipSlot2'] = espd['GetItemInEquipSlot;gamedataEquipmentAreaInt32']
    
    local slots = {
        Face = 1,
        Feet = 1,
        Head = 1,
        InnerChest = 1,
        Legs = 1,
        OuterChest = 1,
        Weapon = 3
    }

    local procItems = 0
    
    for k,v in pairs(slots) do
        for i=1,v do
            --get equipped items
            local itemid = espd:GetItemInEquipSlot2(k, i - 1)
            if itemid.tdbid.hash ~= 0 then
                --get data of equipped items
                local itemdata = ts:GetItemData(player, itemid)
                if itemdata:HasTag("Quest") then
                    --if item has quest tag, remove it
                    itemdata:RemoveDynamicTag("Quest")
                    print("[SimpleMenu] Quest Tag: Item in", k, "slot", i, "got its quest tag removed")
                    --if tag was removed increase counter
                    procItems = procItems + 1
                else
                    print("[SimpleMenu] Quest Tag: Item in", k, "slot", i, "doesn't have the quest tag")
                end
            end
        end
    end
    --rint result
    print("[SimpleMenu] Quest Tag: A total of", procItems, "item(s) were modified")
end

return Upgrade