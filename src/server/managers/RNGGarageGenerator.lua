--[[
    RNGGarageGenerator.lua
    Purpose: Create random garages based on tier
    Generates car, decorations, and locker contents
]]

local RNGGarageGenerator = {}

-- Tier specifications
local TIER_SPECS = {
    BEGINNER = {
        entryFee = 200,
        carRarities = { common = 1/4, uncommon = 1/5, rare = 1/8 },
        decoRange = { min = 4, max = 7 },
        lockerChance = 1/10
    },
    ADVANCED = {
        entryFee = 500,
        carRarities = { uncommon = 1/8, rare = 1/6, epic = 1/10 },
        decoRange = { min = 7, max = 13 },
        lockerChance = 1/4
    },
    EXPERT = {
        entryFee = 1200,
        carRarities = { rare = 1/10, epic = 1/6, legendary = 1/12, spec = 0.03 },
        decoRange = { min = 13, max = 21 },
        lockerChance = 1/2
    },
    CHOSEN = {
        entryFee = 2500,
        carRarities = { rare = 1/36, epic = 1/24, legendary = 1/8, spec = 0.10 },
        decoRange = { min = 21, max = 50 },
        lockerChance = 1/1
    },
    TIER5 = {
        entryFee = 5000,
        carRarities = { epic = 1/24, legendary = 1/8, spec = 0.25 },
        decoRange = { min = 50, max = 80 },
        lockerChance = 2
    }
}

--[[
    Generate a random garage
    @param tierType: string - Tier type
    @return: table - Generated garage
]]
function RNGGarageGenerator:GenerateGarage(tierType)
    local spec = TIER_SPECS[tierType]
    if not spec then
        error("Unknown tier type: " .. tostring(tierType))
    end
    
    return {
        tier = tierType,
        car = self:GenerateCar(spec.carRarities),
        decorations = self:GenerateDecorations(spec.decoRange),
        locker = self:GenerateLocker(spec.lockerChance)
    }
end

--[[
    Roll car rarity based on tier
    @param rarities: table - Rarity chances
    @return: string - Rarity (common, uncommon, rare, epic, legendary, spec)
]]
function RNGGarageGenerator:RollCarRarity(rarities)
    local roll = math.random()
    local accumulated = 0
    
    for rarity, chance in pairs(rarities) do
        accumulated = accumulated + chance
        if roll <= accumulated then
            return rarity
        end
    end
    
    return "common"  -- Fallback
end

--[[
    Generate a car
    @param rarities: table - Rarity chances
    @return: table - Car data
]]
function RNGGarageGenerator:GenerateCar(rarities)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    
    local rarity = self:RollCarRarity(rarities)
    local carsOfRarity = ItemDatabase:GetCarsByRarity(rarity)
    
    if #carsOfRarity == 0 then
        -- Fallback to common car
        carsOfRarity = ItemDatabase:GetCarsByRarity("common")
    end
    
    local selectedCar = carsOfRarity[math.random(1, #carsOfRarity)]
    return {
        id = selectedCar.id,
        name = selectedCar.name,
        rarity = selectedCar.rarity,
        income = selectedCar.income
    }
end

--[[
    Generate decorations
    @param decoRange: table - Min/max count
    @return: table - Decoration list
]]
function RNGGarageGenerator:GenerateDecorations(decoRange)
    local decoCount = math.random(decoRange.min, decoRange.max)
    local decorations = {}
    
    for i = 1, decoCount do
        table.insert(decorations, {
            id = "deco_" .. i,
            name = "#" .. i,
            value = 20
        })
    end
    
    return decorations
end

--[[
    Generate locker (if dropped)
    @param lockerChance: number - Chance to get locker
    @return: table - Locker data or nil
]]
function RNGGarageGenerator:GenerateLocker(lockerChance)
    local roll = math.random()
    
    if roll <= lockerChance then
        local rarities = { "silver", "gold", "black" }
        local rarity = rarities[math.random(1, 3)]
        
        return {
            id = "locker_" .. rarity .. "_" .. os.time(),
            rarity = rarity,
            unopened = true,
            contents = self:PopulateLockerContents(rarity)
        }
    end
    
    return nil
end

--[[
    Populate locker with random contents
    @param rarity: string - Locker rarity
    @return: table - Locker contents
]]
function RNGGarageGenerator:PopulateLockerContents(rarity)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local lockerSpec = ItemDatabase.LOCKER_CONTENTS[rarity]
    
    if not lockerSpec then
        return {}
    end
    
    local contents = {}
    
    -- Add dice
    if math.random() <= lockerSpec.diceChance then
        local diceCount = math.random(lockerSpec.diceCount.min, lockerSpec.diceCount.max)
        for i = 1, diceCount do
            local diceIdx = math.random(1, #ItemDatabase.DICE)
            table.insert(contents, ItemDatabase.DICE[diceIdx])
        end
    end
    
    -- Add potion
    if math.random() <= lockerSpec.potionChance then
        local potionCount = math.random(lockerSpec.potionCount.min, lockerSpec.potionCount.max)
        for i = 1, potionCount do
            local potionIdx = math.random(1, #ItemDatabase.POTIONS)
            table.insert(contents, ItemDatabase.POTIONS[potionIdx])
        end
    end
    
    -- Add decorations
    local decoCount = math.random(lockerSpec.decoCount.min, lockerSpec.decoCount.max)
    for i = 1, decoCount do
        table.insert(contents, {
            id = "deco_" .. math.random(1, 100),
            name = "#" .. math.random(1, 100),
            value = 20
        })
    end
    
    return contents
end

return RNGGarageGenerator
