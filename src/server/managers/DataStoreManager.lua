--[[
    DataStoreManager.lua
    Purpose: Auto-save all player data every 2 minutes
    Handles persistent data storage and retrieval
]]--

local DataStoreManager = {}
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Configuration
local SAVE_INTERVAL = 120  -- 2 minutes in seconds
local DATASTORE_NAME = "BidACarGameData"

-- DataStore reference
local gameDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)

-- Active save tasks
local activeSaveTasks = {}

--[[
    Initialize a player's data save loop
    @param playerId: string - Player ID
    @param initialData: table - Player's initial data structure
]]
function DataStoreManager:InitializePlayer(playerId, initialData)
    if activeSaveTasks[playerId] then
        return
    end
    
    activeSaveTasks[playerId] = true
    
    -- Start automatic save loop for this player
    task.spawn(function()
        while activeSaveTasks[playerId] do
            task.wait(SAVE_INTERVAL)
            self:Save(playerId)
        end
    end)
end

--[[
    Save player data to DataStore
    @param playerId: string - Player ID
    @return: boolean - Success status
]]
function DataStoreManager:Save(playerId)
    if not playerId then
        warn("DataStoreManager:Save() - No playerId provided")
        return false
    end
    
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local playerData = PlayerDataManager:GetPlayer(playerId)
    
    if not playerData then
        warn("DataStoreManager:Save() - No player data found for " .. tostring(playerId))
        return false
    end
    
    -- Prepare save data
    local saveData = {
        playerId = playerId,
        timestamp = os.time(),
        money = playerData.money,
        rebirthCount = playerData.rebirths.count,
        rebirthTimestamps = playerData.rebirths.timestamps or {},
        inventory = playerData.inventory,
        plot = playerData.plot,
        luckBoosts = playerData.luckBoosts,
        stats = playerData.stats,
        account = playerData.account
    }
    
    -- Attempt to save with retries
    local success = false
    local attempts = 0
    local maxAttempts = 3
    
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        
        pcall(function()
            gameDataStore:SetAsync(playerId, saveData)
            success = true
        end)
        
        if not success and attempts < maxAttempts then
            task.wait(1)
        end
    end
    
    if success then
        print("DataStoreManager: Saved data for player " .. tostring(playerId))
    else
        warn("DataStoreManager: Failed to save data for player " .. tostring(playerId) .. " after " .. attempts .. " attempts")
    end
    
    return success
end

--[[
    Load player data from DataStore
    @param playerId: string - Player ID
    @return: table - Player data or nil if not found
]]
function DataStoreManager:Load(playerId)
    if not playerId then
        warn("DataStoreManager:Load() - No playerId provided")
        return nil
    end
    
    local loadedData = nil
    local success = pcall(function()
        loadedData = gameDataStore:GetAsync(playerId)
    end)
    
    if success and loadedData then
        print("DataStoreManager: Loaded data for player " .. tostring(playerId))
        return loadedData
    else
        print("DataStoreManager: No existing data found for player " .. tostring(playerId) .. " (new player)")
        return nil
    end
end

--[[
    Update a specific field in player data
    @param playerId: string - Player ID
    @param key: string - Field key to update
    @param value: any - New value
    @return: boolean - Success status
]]
function DataStoreManager:UpdateField(playerId, key, value)
    if not playerId or not key then
        warn("DataStoreManager:UpdateField() - Missing playerId or key")
        return false
    end
    
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local playerData = PlayerDataManager:GetPlayer(playerId)
    
    if not playerData then
        warn("DataStoreManager:UpdateField() - No player data found for " .. tostring(playerId))
        return false
    end
    
    -- Update field in memory first
    if key == "money" then
        playerData.money = value
    elseif key == "inventory" then
        playerData.inventory = value
    elseif key == "plot" then
        playerData.plot = value
    elseif key == "stats" then
        playerData.stats = value
    elseif key == "luckBoosts" then
        playerData.luckBoosts = value
    else
        playerData[key] = value
    end
    
    -- Queue immediate save
    task.spawn(function()
        self:Save(playerId)
    end)
    
    return true
end

--[[
    Remove a player from active save tasks
    Triggers final save before removal
    @param playerId: string - Player ID
]]
function DataStoreManager:PlayerLeaving(playerId)
    if activeSaveTasks[playerId] then
        -- Final save before cleanup
        self:Save(playerId)
        activeSaveTasks[playerId] = nil
        print("DataStoreManager: Cleaned up save task for player " .. tostring(playerId))
    end
end

--[[
    Get save interval (for testing/debugging)
    @return: number - Save interval in seconds
]]
function DataStoreManager:GetSaveInterval()
    return SAVE_INTERVAL
end

--[[
    Check if player has save task active
    @param playerId: string - Player ID
    @return: boolean - Active status
]]
function DataStoreManager:IsPlayerActive(playerId)
    return activeSaveTasks[playerId] or false
end

return DataStoreManager
