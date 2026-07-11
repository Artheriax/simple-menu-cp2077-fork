local Shop = {}

local items = {
    {
        "Items.Alcohol", --alcohol
        "Items.GoodQualityAlcohol",
        "Items.GoodQualityAlcohol1",
        "Items.GoodQualityAlcohol2",
        "Items.GoodQualityAlcohol3",
        "Items.GoodQualityAlcohol4",
        "Items.GoodQualityAlcohol5",
        "Items.GoodQualityAlcohol6",
        "Items.LowQualityAlcohol",
        "Items.LowQualityAlcohol1",
        "Items.LowQualityAlcohol2",
        "Items.LowQualityAlcohol3",
        "Items.LowQualityAlcohol4",
        "Items.LowQualityAlcohol5",
        "Items.LowQualityAlcohol6",
        "Items.LowQualityAlcohol7",
        "Items.LowQualityAlcohol8",
        "Items.LowQualityAlcohol9",
        "Items.MediumQualityAlcohol",
        "Items.MediumQualityAlcohol1",
        "Items.MediumQualityAlcohol2",
        "Items.MediumQualityAlcohol3",
        "Items.MediumQualityAlcohol4",
        "Items.MediumQualityAlcohol5",
        "Items.MediumQualityAlcohol6",
        "Items.MediumQualityAlcohol7",
        "Items.NomadsAlcohol1",
        "Items.NomadsAlcohol2",
        "Items.TopQualityAlcohol",
        "Items.TopQualityAlcohol1",
        "Items.TopQualityAlcohol2",
        "Items.TopQualityAlcohol3",
        "Items.TopQualityAlcohol4",
        "Items.TopQualityAlcohol5",
        "Items.TopQualityAlcohol6",
        "Items.TopQualityAlcohol7"
    },
    {
        "Items.NomadsDrink2", --drink
        "Items.MediumQualityDrink7",
        "Items.GoodQualityDrink4",
        "Items.GoodQualityDrink2",
        "Items.LowQualityDrink6",
        "Items.LowQualityDrink7",
        "Items.LowQualityDrink8",
        "Items.LowQualityDrink11",
        "Items.LowQualityDrink12",
        "Items.LowQualityDrink3",
        "Items.NomadsDrink1",
        "Items.LowQualityDrink13",
        "Items.LowQualityDrink1",
        "Items.LowQualityDrink2",
        "Items.MediumQualityDrink5",
        "Items.MediumQualityDrink6",
        "Items.LowQualityDrink10",
        "Items.LowQualityDrink9",
        "Items.MediumQualityDrink1",
        "Items.MediumQualityDrink2",
        "Items.MediumQualityDrink11",
        "Items.MediumQualityDrink3",
        "Items.MediumQualityDrink4",
        "Items.GoodQualityDrink1",
        "Items.MediumQualityDrink14",
        "Items.MediumQualityDrink10",
        "Items.LowQualityDrink4",
        "Items.LowQualityDrink5",
        "Items.GoodQualityDrink5",
        "Items.GoodQualityDrink7",
        "Items.GoodQualityDrink6",
        "Items.MediumQualityDrink12",
        "Items.MediumQualityDrink13",
        "Items.MediumQualityDrink8",
        "Items.MediumQualityDrink9",
        "Items.GoodQualityDrink11",
        "Items.GoodQualityDrink8",
        "Items.GoodQualityDrink9",
        "Items.GoodQualityDrink3",
        "Items.GoodQualityDrink10"
    },
    {
        "Items.GoodQualityFood4", --food
        "Items.MediumQualityFood5",
        "Items.MediumQualityFood6",
        "Items.GoodQualityFood11",
        "Items.MediumQualityFood9",
        "Items.MediumQualityFood4",
        "Items.MediumQualityFood12",
        "Items.MediumQualityFood13",
        "Items.GoodQualityFood3",
        "Items.NomadsFood2",
        "Items.LowQualityFood1",
        "Items.GoodQualityFood9",
        "Items.GoodQualityFood8",
        "Items.LowQualityFood3",
        "Items.LowQualityFood12",
        "Items.LowQualityFood13",
        "Items.LowQualityFood14",
        "Items.MediumQualityFood10",
        "Items.LowQualityFood20",
        "Items.LowQualityFood21",
        "Items.LowQualityFood22",
        "Items.LowQualityFood23",
        "Items.GoodQualityFood13",
        "Items.GoodQualityFood10",
        "Items.LowQualityFood5",
        "Items.LowQualityFood17",
        "Items.LowQualityFood18",
        "Items.LowQualityFood19",
        "Items.LowQualityFood6",
        "Items.MediumQualityFood14",
        "Items.MediumQualityFood11",
        "Items.MediumQualityFood15",
        "Items.GoodQualityFood6",
        "Items.GoodQualityFood5",
        "Items.LowQualityFood7",
        "Items.LowQualityFood15",
        "Items.LowQualityFood16",
        "Items.GoodQualityFood7",
        "Items.LowQualityFood8",
        "Items.MediumQualityFood2",
        "Items.GoodQualityFood1",
        "Items.MediumQualityFood19",
        "Items.MediumQualityFood17",
        "Items.MediumQualityFood18",
        "Items.MediumQualityFood3",
        "Items.MediumQualityFood7",
        "Items.MediumQualityFood20",
        "Items.LowQualityFood9",
        "Items.LowQualityFood24",
        "Items.LowQualityFood25",
        "Items.LowQualityFood26",
        "Items.LowQualityFood27",
        "Items.LowQualityFood28",
        "Items.NomadsFood1",
        "Items.MediumQualityFood1",
        "Items.MediumQualityFood16",
        "Items.GoodQualityFood2",
        "Items.GoodQualityFood12",
        "Items.LowQualityFood10",
        "Items.MediumQualityFood8",
        "Items.LowQualityFood11"
    },
    {
        "Items.GrenadeFragRegular", --grenade common
        "Items.GrenadeFlashRegular"
    },
    {
        "Items.GrenadeIncendiaryRegular", --grenade uncommon
        "Items.GrenadeEMPRegular",
        "Items.GrenadeFragSticky",
        "Items.GrenadeBiohazardRegular",
        "Items.GrenadeReconRegular",
        "Items.GrenadeReconSticky"
    },
    {
        "Items.GrenadeIncendiarySticky", --grenade rare
        "Items.GrenadeEMPSticky",
        "Items.GrenadeFragHoming",
        "Items.GrenadeBiohazardHoming",
        "Items.GrenadeFlashHoming"
    },
    {
        "Items.GrenadeIncendiaryHoming", --grenade epic
        "Items.GrenadeEMPHoming",
        "Items.GrenadeCuttingRegular"
    },
    {
        "Items.AnimalsJunkItem1", --junk cheap
        "Items.AnimalsJunkItem2",
        "Items.AnimalsJunkItem3",
        "Items.CasinoJunkItem1",
        "Items.CasinoJunkItem2",
        "Items.CasinoJunkItem3",
        "Items.CasinoPoorJunkItem1",
        "Items.CasinoPoorJunkItem2",
        "Items.CasinoPoorJunkItem3",
        "Items.CasinoRichJunkItem1",
        "Items.CasinoRichJunkItem2",
        "Items.CasinoRichJunkItem3",
        "Items.GenericCorporationJunkItem1",
        "Items.GenericCorporationJunkItem2",
        "Items.GenericCorporationJunkItem3",
        "Items.GenericCorporationJunkItem4",
        "Items.GenericCorporationJunkItem5",
        "Items.GenericGangJunkItem1",
        "Items.GenericGangJunkItem2",
        "Items.GenericGangJunkItem3",
        "Items.GenericGangJunkItem4",
        "Items.GenericGangJunkItem5",
        "Items.GenericJunkItem1",
        "Items.GenericJunkItem10",
        "Items.GenericJunkItem11",
        "Items.GenericJunkItem12",
        "Items.GenericJunkItem13",
        "Items.GenericJunkItem14",
        "Items.GenericJunkItem15",
        "Items.GenericJunkItem16",
        "Items.GenericJunkItem17",
        "Items.GenericJunkItem18",
        "Items.GenericJunkItem19",
        "Items.GenericJunkItem2",
        "Items.GenericJunkItem20",
        "Items.GenericJunkItem21",
        "Items.GenericJunkItem22",
        "Items.GenericJunkItem23",
        "Items.GenericJunkItem24",
        "Items.GenericJunkItem25",
        "Items.GenericJunkItem26",
        "Items.GenericJunkItem27",
        "Items.GenericJunkItem28",
        "Items.GenericJunkItem29",
        "Items.GenericJunkItem3",
        "Items.GenericJunkItem30",
        "Items.GenericJunkItem4",
        "Items.GenericJunkItem5",
        "Items.GenericJunkItem6",
        "Items.GenericJunkItem7",
        "Items.GenericJunkItem8",
        "Items.GenericJunkItem9",
        "Items.GenericPoorJunkItem1",
        "Items.GenericPoorJunkItem2",
        "Items.GenericPoorJunkItem3",
        "Items.GenericPoorJunkItem4",
        "Items.GenericPoorJunkItem5",
        "Items.GenericRichJunkItem1",
        "Items.GenericRichJunkItem2",
        "Items.GenericRichJunkItem3",
        "Items.GenericRichJunkItem4",
        "Items.GenericRichJunkItem5",
        "Items.Junk",
        "Items.JunkLargeSize",
        "Items.JunkMediumSize",
        "Items.JunkSmallSize",
        "Items.MaelstromJunkItem1",
        "Items.MaelstromJunkItem2",
        "Items.MaelstromJunkItem3",
        "Items.MilitechJunkItem1",
        "Items.MilitechJunkItem2",
        "Items.MilitechJunkItem3",
        "Items.MoxiesJunkItem1",
        "Items.MoxiesJunkItem2",
        "Items.MoxiesJunkItem3",
        "Items.NomadsJunkItem1",
        "Items.NomadsJunkItem2",
        "Items.NomadsJunkItem3",
        "Items.ScavengersJunkItem1",
        "Items.ScavengersJunkItem2",
        "Items.ScavengersJunkItem3",
        "Items.SexToyJunkItem1",
        "Items.SexToyJunkItem2",
        "Items.SexToyJunkItem3",
        "Items.SexToyJunkItem4",
        "Items.SexToyJunkItem5",
        "Items.SexToyJunkItem6",
        "Items.SixthStreetJunkItem1",
        "Items.SixthStreetJunkItem2",
        "Items.SixthStreetJunkItem3",
        "Items.SouvenirJunkItem1",
        "Items.SouvenirJunkItem2",
        "Items.SouvenirJunkItem3",
        "Items.SouvenirJunkItem4",
        "Items.TygerClawsJunkItem1",
        "Items.TygerClawsJunkItem2",
        "Items.TygerClawsJunkItem3",
        "Items.ValentinosJunkItem1",
        "Items.ValentinosJunkItem2",
        "Items.ValentinosJunkItem3",
        "Items.VoodooBoysJunkItem1",
        "Items.VoodooBoysJunkItem2",
        "Items.VoodooBoysJunkItem3",
        "Items.WraithsJunkItem1",
        "Items.WraithsJunkItem2",
        "Items.WraithsJunkItem3"
    },
    {
        "Items.AnimalsJewellery", --junk expensive
        "Items.AnimalsJewellery1",
        "Items.AnimalsJewellery2",
        "Items.AnimalsJewellery3",
        "Items.HighQualityJewellery",
        "Items.HighQualityJewellery1",
        "Items.HighQualityJewellery2",
        "Items.HighQualityJewellery3",
        "Items.HighQualityJewellery4",
        "Items.HighQualityJewellery5",
        "Items.Jewellery",
        "Items.LowQualityJewellery",
        "Items.LowQualityJewellery1",
        "Items.LowQualityJewellery2",
        "Items.LowQualityJewellery3",
        "Items.LowQualityJewellery4",
        "Items.LowQualityJewellery5",
        "Items.MediumQualityJewellery",
        "Items.MediumQualityJewellery1",
        "Items.MediumQualityJewellery2",
        "Items.MediumQualityJewellery3",
        "Items.MediumQualityJewellery4",
        "Items.MediumQualityJewellery5",
        "Items.TygerClawsJewellery",
        "Items.TygerClawsJewellery1",
        "Items.TygerClawsJewellery2",
        "Items.TygerClawsJewellery3",
        "Items.ValentinosJewellery",
        "Items.ValentinosJewellery1",
        "Items.ValentinosJewellery2",
        "Items.ValentinosJewellery3",
        "Items.ValentinosJewellery4",
        "Items.ValentinosJewellery5"
    }
}

--process inventory item count of selected item type
function Shop.ProcessItems(type, mode)
    local player = Game.GetPlayer()
    local ts = Game.GetTransactionSystem()
    local ssc = Game.GetScriptableSystemsContainer()
    local es = ssc:Get(CName.new('EquipmentSystem'))
    local espd = es:GetPlayerData(player)
    local im = espd:GetInventoryManager()
    local totalItemCount = 0
    local totalMoney = 0

    for _, item in ipairs(items[type]) do
        --get ids
        local itemTDBID = TweakDBID.new(item)
        local itemID = ItemID.new(itemTDBID)
        --get item count and sell price
        local currentItemCount = ts:GetItemQuantity(player, itemID)
        local sellPrice = im:GetSellPrice(player, itemID)
        if (mode == "disassemble" and Game["gameRPGManager::CanItemBeDisassembled;GameInstanceItemID"](itemID)) then
            --execute disassemble
            Game['ItemActionsHelper::DisassembleItem;GameObjectItemIDInt32'](player, itemID, currentItemCount)
            --increase counter
            totalItemCount = totalItemCount + currentItemCount
        elseif (mode == "sell" and sellPrice > 0) then
            --calculate total value
            totalMoney = totalMoney + (sellPrice * currentItemCount)
            --remove all items of selected type
            ts:RemoveItem(player, itemID, currentItemCount)
            --increase counter
            totalItemCount = totalItemCount + currentItemCount
        elseif (mode == "convert") then
            --remove all items of selected type
            ts:RemoveItem(player, itemID, currentItemCount)
            --increase counter
            totalItemCount = totalItemCount + currentItemCount
        end
    end

    if (totalItemCount > 0) then
        if (mode == "disassemble") then
            print("[SimpleMenu] Shop: Disassembled", totalItemCount, "items.")
        elseif (mode == "sell") then
            Game.AddToInventory("Items.money", totalMoney)
            print("[SimpleMenu] Shop: Sold", totalItemCount, "items. Money sent to your account:", totalMoney, "Eddies")
        end
    else
        print("[SimpleMenu] Shop Error: No processable items found.")
    end

    return totalItemCount
end

function Shop.SellAll()
    for category, _ in ipairs(items) do
        Shop.ProcessItems(category, "sell")
    end
end

function Shop.ConvertItem(selectedDrink, selectedFood)
    if (selectedDrink < 1) then
        selectedDrink = 40
    end
    if (selectedFood < 1) then
        selectedFood = 61
    end
    
    local tableDrink = 2
    local tableFood = 3
    local totalDrinkCount = Shop.ProcessItems(tableDrink, "convert")
    local totalFoodCount = Shop.ProcessItems(tableFood, "convert")

    --add items to keep
    Game.AddToInventory(items[tableDrink][selectedDrink], totalDrinkCount)
    Game.AddToInventory(items[tableFood][selectedFood], totalFoodCount)

    print("[SimpleMenu] Shop: Converted", totalDrinkCount, "drinks and", totalFoodCount, "food")
end

return Shop