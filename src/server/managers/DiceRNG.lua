--[[
    DiceRNG.lua
    Purpose: Generate random NPCs from dice
]]

local DiceRNG = {}

--[[
    Roll an NPC from dice
    @param diceType: string - Dice type
    @return: table - Generated NPC
]]
function DiceRNG:RollNPC(diceType)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local dice = ItemDatabase:GetDice(diceType)
    
    if not dice then
        return nil
    end
    
    local rarity = self:SelectRarity(dice.rarities)
    local boostPercent = self:GenerateBoostPercent(dice.boostMin, dice.boostMax)
    local npcName = self:GenerateRandomName()
    
    return {
        id = "npc_" .. os.time() .. "_" .. math.random(1, 9999),
        name = npcName,
        type = diceType,
        boostPercent = boostPercent,
        rarity = rarity,
        createdAt = os.time()
    }
end

--[[
    Select rarity based on chances
    @param rarities: table - Rarity chances
    @return: string - Selected rarity
]]
function DiceRNG:SelectRarity(rarities)
    local roll = math.random()
    local accumulated = 0
    
    for rarity, chance in pairs(rarities) do
        accumulated = accumulated + chance
        if roll <= accumulated then
            return rarity
        end
    end
    
    return "common"
end

--[[
    Generate random boost percentage
    @param minBoost: number - Min boost
    @param maxBoost: number - Max boost
    @return: number - Boost percentage
]]
function DiceRNG:GenerateBoostPercent(minBoost, maxBoost)
    return math.random(minBoost, maxBoost)
end

--[[
    Generate random NPC name
    @return: string - Random name
]]
function DiceRNG:GenerateRandomName()
    local names = {
        "Alpha", "Bravo", "Charlie", "Delta", "Echo",
        "Foxtrot", "Golf", "Hotel", "India", "Juliet",
        "Kilo", "Lima", "Mike", "November", "Oscar"
    }
    return names[math.random(1, #names)]
end

return DiceRNG
