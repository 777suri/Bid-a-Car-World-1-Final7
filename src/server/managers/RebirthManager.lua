--[[
    RebirthManager.lua
    Purpose: Handle progression milestones and unlocks
]]

local RebirthManager = {}

local REBIRTH_COSTS = {
    [1] = 2000,
    [2] = 5000,
    [3] = 10000
}

local REBIRTH_UNLOCKS = {
    [1] = { conveyor = true, luckBoosts = true },
    [2] = { trading = true },
    [3] = { world2 = true, conveyor = true }
}

--[[
    Check if player can rebirth
    @param playerId: string - Player ID
    @param level: number - Rebirth level
    @return: boolean - Can rebirth
]]
function RebirthManager:CanRebirth(playerId, level)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    if player.rebirths.count + 1 ~= level then
        return false
    end
    
    local cost = REBIRTH_COSTS[level]
    if not cost then
        return false
    end
    
    return player.money >= cost
end

--[[
    Execute rebirth
    @param playerId: string - Player ID
    @param level: number - Rebirth level
    @return: boolean - Success
]]
function RebirthManager:ExecuteRebirth(playerId, level)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local PlotManager = require(script.Parent:WaitForChild("PlotManager"))
    
    if not self:CanRebirth(playerId, level) then
        return false
    end
    
    local player = PlayerDataManager:GetPlayer(playerId)
    local cost = REBIRTH_COSTS[level]
    
    -- Deduct cost and reset money
    player.money = 0
    player.rebirths.count = level
    table.insert(player.rebirths.timestamps, os.time())
    
    -- Unlock features
    local unlocks = REBIRTH_UNLOCKS[level]
    if unlocks and unlocks.conveyor then
        PlotManager:UnlockConveyor(playerId)
    end
    
    return true
end

--[[
    Unlock a specific feature
    @param playerId: string - Player ID
    @param feature: string - Feature name
]]
function RebirthManager:UnlockFeature(playerId, feature)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    if not player.unlockedFeatures then
        player.unlockedFeatures = {}
    end
    
    player.unlockedFeatures[feature] = true
end

--[[
    Get rebirth status
    @param playerId: string - Player ID
    @return: table - Rebirth data
]]
function RebirthManager:GetRebirthStatus(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:GetPlayer(playerId).rebirths
end

--[[
    Get next rebirth cost
    @param playerId: string - Player ID
    @return: number - Next cost
]]
function RebirthManager:GetNextRebirthCost(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    local nextLevel = player.rebirths.count + 1
    return REBIRTH_COSTS[nextLevel] or nil
end

--[[
    Get rebirth unlocks for a specific level
    @param level: number - Rebirth level
    @return: table - Unlocks for that level
]]
function RebirthManager:GetRebirthUnlocks(level)
    return REBIRTH_UNLOCKS[level] or {}
end

return RebirthManager
