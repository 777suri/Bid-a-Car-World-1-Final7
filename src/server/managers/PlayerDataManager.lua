--[[
    PlayerDataManager.lua
    Purpose: Handle all player state in-memory
    Manages player money, inventory, plot, stats, and progression
]]

local PlayerDataManager = {}
local activePlayers = {}

--[[
    Get or create player data structure
    @param playerId: string - Player ID
    @return: table - Player data table
]]
function PlayerDataManager:GetPlayer(playerId)
    if not activePlayers[playerId] then
        activePlayers[playerId] = self:CreateNewPlayerData(playerId)
    end
    return activePlayers[playerId]
end

--[[
    Create a new player data structure
    @param playerId: string - Player ID
    @return: table - New player data
]]
function PlayerDataManager:CreateNewPlayerData(playerId)
    return {
        playerId = playerId,
        money = 700,
        rebirths = {
            count = 0,
            timestamps = {}
        },
        inventory = {
            items = {},
            cars = {},
            lockers = {},
            dice = {}
        },
        plot = {
            conveyors = {
                { id = "conveyor_1", car = nil, npc = nil, income_accumulated = 0, lastCollected = 0 },
                { id = "conveyor_2", car = nil, npc = nil, income_accumulated = 0, lastCollected = 0 },
                { id = "conveyor_3", car = nil, npc = nil, income_accumulated = 0, lastCollected = 0 }
            },
            totalConveyors = 3,
            unlockedCount = 3
        },
        luckBoosts = {
            active = {},
            expired = {}
        },
        stats = {
            totalBidsWon = 0,
            totalBidsLost = 0,
            totalMoneySpent = 0,
            totalMoneyEarned = 0,
            totalBidsParticipated = 0,
            totalIncomeCollected = 0,
            longestWinStreak = 0
        },
        account = {
            username = "Player",
            joinDate = os.time(),
            lastLogin = os.time(),
            totalPlaytime = 0
        }
    }
end

--[[
    Load existing player data from DataStore
    @param playerId: string - Player ID
    @param savedData: table - Data from DataStore
]]
function PlayerDataManager:LoadPlayerData(playerId, savedData)
    if savedData then
        activePlayers[playerId] = savedData
    else
        activePlayers[playerId] = self:CreateNewPlayerData(playerId)
    end
    return activePlayers[playerId]
end

--[[
    Update player money
    @param playerId: string - Player ID
    @param amount: number - Amount to add/subtract
]]
function PlayerDataManager:UpdateMoney(playerId, amount)
    local player = self:GetPlayer(playerId)
    player.money = math.max(0, player.money + amount)
    return player.money
end

--[[
    Set player money directly
    @param playerId: string - Player ID
    @param amount: number - New amount
]]
function PlayerDataManager:SetMoney(playerId, amount)
    local player = self:GetPlayer(playerId)
    player.money = math.max(0, amount)
    return player.money
end

--[[
    Get player money
    @param playerId: string - Player ID
    @return: number - Current money
]]
function PlayerDataManager:GetMoney(playerId)
    return self:GetPlayer(playerId).money
end

--[[
    Add item to inventory
    @param playerId: string - Player ID
    @param itemType: string - Type (items, cars, lockers, dice)
    @param item: table - Item data
]]
function PlayerDataManager:AddToInventory(playerId, itemType, item)
    local player = self:GetPlayer(playerId)
    local inventory = player.inventory[itemType]
    
    if inventory then
        table.insert(inventory, item)
        return true
    end
    return false
end

--[[
    Remove item from inventory
    @param playerId: string - Player ID
    @param itemType: string - Type (items, cars, lockers, dice)
    @param itemId: string - Item ID
]]
function PlayerDataManager:RemoveFromInventory(playerId, itemType, itemId)
    local player = self:GetPlayer(playerId)
    local inventory = player.inventory[itemType]
    
    if inventory then
        for i, item in ipairs(inventory) do
            if item.id == itemId then
                table.remove(inventory, i)
                return true
            end
        end
    end
    return false
end

--[[
    Get inventory by type
    @param playerId: string - Player ID
    @param itemType: string - Type (items, cars, lockers, dice)
    @return: table - Inventory items
]]
function PlayerDataManager:GetInventory(playerId, itemType)
    local player = self:GetPlayer(playerId)
    if itemType then
        return player.inventory[itemType] or {}
    end
    return player.inventory
end

--[[
    Update player stats
    @param playerId: string - Player ID
    @param statKey: string - Stat key
    @param value: number - Value to add
]]
function PlayerDataManager:UpdateStats(playerId, statKey, value)
    local player = self:GetPlayer(playerId)
    if player.stats[statKey] then
        player.stats[statKey] = player.stats[statKey] + (value or 1)
    end
end

--[[
    Get player stats
    @param playerId: string - Player ID
    @return: table - Stats table
]]
function PlayerDataManager:GetStats(playerId)
    return self:GetPlayer(playerId).stats
end

--[[
    Remove player from active memory
    @param playerId: string - Player ID
]]
function PlayerDataManager:RemovePlayer(playerId)
    activePlayers[playerId] = nil
end

return PlayerDataManager
