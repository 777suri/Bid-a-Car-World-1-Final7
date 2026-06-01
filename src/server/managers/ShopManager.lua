--[[
    ShopManager.lua
    Purpose: Dice shop where players buy dice for NPC generation
]]

local ShopManager = {}

--[[
    Buy dice from shop
    @param playerId: string - Player ID
    @param diceType: string - Dice type (basic, golden, diamond, naspec)
    @return: boolean - Success
]]
function ShopManager:BuyDice(playerId, diceType)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    
    local dice = nil
    for _, d in ipairs(ItemDatabase.DICE) do
        if d.id == diceType then
            dice = d
            break
        end
    end
    
    if not dice then
        return false
    end
    
    local player = PlayerDataManager:GetPlayer(playerId)
    if player.money < dice.price then
        return false
    end
    
    PlayerDataManager:UpdateMoney(playerId, -dice.price)
    PlayerDataManager:UpdateStats(playerId, "totalMoneySpent", dice.price)
    
    local diceItem = {
        id = "dice_" .. os.time() .. "_" .. math.random(1, 9999),
        type = "dice",
        diceType = diceType,
        unopened = true,
        acquiredAt = os.time()
    }
    
    InventoryManager:AddItem(playerId, "dice", diceItem)
    return true
end

--[[
    Open dice to get NPC
    @param playerId: string - Player ID
    @param diceId: string - Dice ID
    @return: table - Generated NPC
]]
function ShopManager:OpenDice(playerId, diceId)
    local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))
    local DiceRNG = require(script.Parent:WaitForChild("DiceRNG"))
    
    local diceList = InventoryManager:GetDiceList(playerId)
    local dice = nil
    
    for _, d in ipairs(diceList) do
        if d.id == diceId then
            dice = d
            break
        end
    end
    
    if not dice or not dice.unopened then
        return nil
    end
    
    local npc = DiceRNG:RollNPC(dice.diceType)
    InventoryManager:RemoveItem(playerId, "dice", diceId)
    InventoryManager:AddItem(playerId, "items", npc)
    
    return npc
end

--[[
    Get dice shop inventory
    @return: table - Available dice
]]
function ShopManager:GetDiceShop()
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    return ItemDatabase.DICE
end

--[[
    Check if player can afford dice
    @param playerId: string - Player ID
    @param diceType: string - Dice type
    @return: boolean - Can afford
]]
function ShopManager:CanAffordDice(playerId, diceType)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, dice in ipairs(ItemDatabase.DICE) do
        if dice.id == diceType then
            return player.money >= dice.price
        end
    end
    
    return false
end

--[[
    Check if player can purchase NA-SPEC dice (requires Rebirth 1+)
    @param playerId: string - Player ID
    @return: boolean - Can purchase
]]
function ShopManager:CanBuyNASpec(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    return player.rebirths.count >= 1
end

return ShopManager
