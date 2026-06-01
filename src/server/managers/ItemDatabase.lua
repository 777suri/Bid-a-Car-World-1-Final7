--[[
    ItemDatabase.lua
    Purpose: Central database for all items, cars, and decorations
]]

local ItemDatabase = {}

-- All cars in the game (33 total)
ItemDatabase.CARS = {
    -- COMMON (4 cars, income 9-20)
    { id = "car_ford_caisu", name = "Ford Caisu", rarity = "common", income = 15 },
    { id = "car_telza_h", name = "Telza H", rarity = "common", income = 9 },
    { id = "car_viowo_b10", name = "Viowo B10", rarity = "common", income = 16 },
    { id = "car_dk_kyoto", name = "DK Kyoto", rarity = "common", income = 20 },
    
    -- UNCOMMON (4 cars, income 20-40)
    { id = "car_ford_caisu_rz", name = "Ford Caisu RZ", rarity = "uncommon", income = 25 },
    { id = "car_telza_cubic", name = "Telza Cubic", rarity = "uncommon", income = 20 },
    { id = "car_c4_bmx", name = "C4 BMX", rarity = "uncommon", income = 37 },
    { id = "car_fruity_1012", name = "Fruity 1012", rarity = "uncommon", income = 40 },
    
    -- RARE (9 cars, income 40-90)
    { id = "car_h46_bmx", name = "H46 BMX", rarity = "rare", income = 40 },
    { id = "car_ford_j200", name = "Ford J200", rarity = "rare", income = 50 },
    { id = "car_suru_brs", name = "Suru BRS", rarity = "rare", income = 63 },
    { id = "car_mekke_hls", name = "Mekke HLS", rarity = "rare", income = 65 },
    { id = "car_nizmo_silver_14", name = "Nizmo Silver 14", rarity = "rare", income = 70 },
    { id = "car_nizmo_silver_15", name = "Nizmo Silver 15", rarity = "rare", income = 70 },
    { id = "car_nizmo_silver_13", name = "Nizmo Silver 13", rarity = "rare", income = 80 },
    { id = "car_tesnas_square", name = "Tesnas Square", rarity = "rare", income = 80 },
    { id = "car_nizmo_f35", name = "Nizmo F35", rarity = "rare", income = 90 },
    
    -- EPIC (8 cars, income 90-180)
    { id = "car_dodota_upper5", name = "Dodota Upper 5", rarity = "epic", income = 120 },
    { id = "car_jolk_l80", name = "Jolk L80", rarity = "epic", income = 140 },
    { id = "car_snakey_burnout", name = "Snakey Burnout", rarity = "epic", income = 155 },
    { id = "car_fruity_spider", name = "Fruity Spider", rarity = "epic", income = 168 },
    { id = "car_nizmo_f34", name = "Nizmo F34", rarity = "epic", income = 170 },
    { id = "car_mekke_air", name = "Mekke Air", rarity = "epic", income = 100 },
    { id = "car_butti_06", name = "Butti 06", rarity = "epic", income = 180 },
    { id = "car_labubu_adventures", name = "Labubu Adventures", rarity = "epic", income = 180 },
    
    -- LEGENDARY (8 cars, income 180-500)
    { id = "car_mcarren_senior", name = "McArren Senior", rarity = "legendary", income = 280 },
    { id = "car_butti_106", name = "Butti 106", rarity = "legendary", income = 300 },
    { id = "car_masscar_gop", name = "Masscar GOP", rarity = "legendary", income = 300 },
    { id = "car_fruity_fkx", name = "Fruity FKX", rarity = "legendary", income = 400 },
    { id = "car_butti_206", name = "Butti 206", rarity = "legendary", income = 380 },
    { id = "car_koeralius_f5", name = "Koeralius F5", rarity = "legendary", income = 430 },
    { id = "car_masscar_wrx", name = "Masscar WRX", rarity = "legendary", income = 500 },
    
    -- SPEC (1 car, income 500-2000)
    { id = "car_g1_champions", name = "G1 Champions", rarity = "spec", income = 1000 }
}

-- Car rarity distribution by bid tier
ItemDatabase.CAR_RARITY_CHANCES = {
    BEGINNER = { common = 1/4, uncommon = 1/5, rare = 1/8 },
    ADVANCED = { uncommon = 1/8, rare = 1/6, epic = 1/10 },
    EXPERT = { rare = 1/10, epic = 1/6, legendary = 1/12, spec = 0.03 },
    CHOSEN = { rare = 1/36, epic = 1/24, legendary = 1/8, spec = 0.10 },
    TIER5 = { epic = 1/24, legendary = 1/8, spec = 0.25 }
}

-- NPCs (bot names)
ItemDatabase.BOT_NAMES = {
    "Bacon",
    "Barbara",
    "Jack",
    "Jeff",
    "Mashallah",
    "Roblofía"
}

-- Luck boost potions
ItemDatabase.POTIONS = {
    { id = "potion_silver", name = "Silver Luck Boost", duration = 3600, boost = 10 },
    { id = "potion_gold", name = "Gold Luck Boost", duration = 14400, boost = 25 },
    { id = "potion_black", name = "Black Luck Boost", duration = 28800, boost = 50 }
}

-- Dice types
ItemDatabase.DICE = {
    {
        id = "dice_basic",
        name = "Basic Dice",
        price = 150,
        boostMin = 10,
        boostMax = 30,
        availability = "always",
        rarities = { common = 1/2, uncommon = 1/6, rare = 1/10 }
    },
    {
        id = "dice_golden",
        name = "Golden Dice",
        price = 300,
        boostMin = 20,
        boostMax = 60,
        availability = "always",
        rarities = { uncommon = 1/4, rare = 1/6, epic = 1/10 }
    },
    {
        id = "dice_diamond",
        name = "Diamond Dice",
        price = 1100,
        boostMin = 50,
        boostMax = 100,
        availability = "always",
        rarities = { rare = 1/10, epic = 1/6, legendary = 1/12 }
    },
    {
        id = "dice_naspec",
        name = "NA-SPEC Dice",
        price = 2500,
        boostMin = 50,
        boostMax = 150,
        availability = "rebirth1",
        rarities = { rare = 1/21, epic = 1/16, legendary = 1/4, spec = 1/8 }
    }
}

-- Locker contents (random generation per open)
ItemDatabase.LOCKER_CONTENTS = {
    silver = {
        diceChance = 0.5,
        diceCount = { min = 0, max = 1 },
        potionChance = 0.5,
        potionCount = { min = 0, max = 1 },
        decoCount = { min = 1, max = 3 },
        openTime = 3600
    },
    gold = {
        diceChance = 0.8,
        diceCount = { min = 1, max = 2 },
        potionChance = 1.0,
        potionCount = { min = 1, max = 1 },
        decoCount = { min = 4, max = 6 },
        openTime = 14400
    },
    black = {
        diceChance = 1.0,
        diceCount = { min = 1, max = 4 },
        potionChance = 1.0,
        potionCount = { min = 1, max = 3 },
        decoCount = { min = 1, max = 10 },
        openTime = 28800
    }
}

--[[
    Get car by ID
    @param carId: string - Car ID
    @return: table - Car data
]]
function ItemDatabase:GetCar(carId)
    for _, car in ipairs(self.CARS) do
        if car.id == carId then
            return car
        end
    end
    return nil
end

--[[
    Get cars by rarity
    @param rarity: string - Rarity level
    @return: table - List of cars
]]
function ItemDatabase:GetCarsByRarity(rarity)
    local cars = {}
    for _, car in ipairs(self.CARS) do
        if car.rarity == rarity then
            table.insert(cars, car)
        end
    end
    return cars
end

--[[
    Get dice by ID
    @param diceId: string - Dice ID
    @return: table - Dice data
]]
function ItemDatabase:GetDice(diceId)
    for _, dice in ipairs(self.DICE) do
        if dice.id == diceId then
            return dice
        end
    end
    return nil
end

--[[
    Get random bot name (3 from 6 available)
    @return: table - Array of 3 unique bot names
]]
function ItemDatabase:GetRandomBots()
    local bots = {}
    local selected = {}
    
    while #bots < 3 do
        local randomIdx = math.random(1, #self.BOT_NAMES)
        if not selected[randomIdx] then
            selected[randomIdx] = true
            table.insert(bots, self.BOT_NAMES[randomIdx])
        end
    end
    
    return bots
end

return ItemDatabase
