--[[
    IncomeGenerator.lua
    Purpose: Passive money generation system (offline included)
]]

local IncomeGenerator = {}

--[[
    Calculate accumulated income for a conveyor
    @param conveyor: table - Conveyor data
    @return: number - Accumulated income
]]
function IncomeGenerator:CalculateAccumulatedIncome(conveyor)
    if not conveyor.car then
        return 0
    end
    
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local carData = ItemDatabase:GetCar(conveyor.car.id)
    
    if not carData then
        return 0
    end
    
    local maxOfflineTime = 8 * 60 * 60  -- 8 hours in seconds
    local timeSinceLastCollect = os.time() - conveyor.lastCollected
    local actualTime = math.min(timeSinceLastCollect, maxOfflineTime)
    
    local baseIncomePerSecond = carData.income / 60
    local npcBoost = (conveyor.npc and conveyor.npc.boostPercent) or 0
    local totalIncomePerSecond = baseIncomePerSecond * (1 + npcBoost / 100)
    
    local accumulated = math.floor(totalIncomePerSecond * actualTime)
    return accumulated
end

--[[
    Calculate offline income for all conveyors
    @param playerId: string - Player ID
    @return: number - Total offline income
]]
function IncomeGenerator:CalculateOfflineIncome(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    local totalOfflineIncome = 0
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.car then
            totalOfflineIncome = totalOfflineIncome + self:CalculateAccumulatedIncome(conveyor)
        end
    end
    
    return totalOfflineIncome
end

--[[
    Add accumulated income to conveyor
    @param playerId: string - Player ID
    @param conveyorId: string - Conveyor ID
    @param amount: number - Amount to add
]]
function IncomeGenerator:AddAccumulatedIncome(playerId, conveyorId, amount)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            conveyor.income_accumulated = conveyor.income_accumulated + amount
            return true
        end
    end
    return false
end

--[[
    Collect all income at once
    @param playerId: string - Player ID
    @return: number - Total collected
]]
function IncomeGenerator:CollectAll(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    local totalCollected = 0
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.car then
            local accumulated = self:CalculateAccumulatedIncome(conveyor)
            totalCollected = totalCollected + accumulated
            conveyor.income_accumulated = 0
            conveyor.lastCollected = os.time()
        end
    end
    
    PlayerDataManager:UpdateMoney(playerId, totalCollected)
    return totalCollected
end

return IncomeGenerator
