--[[
    PlotManager.lua
    Purpose: Manage player plot, conveyors, and placements
]]

local PlotManager = {}

--[[
    Place car on conveyor
    @param playerId: string - Player ID
    @param carId: string - Car ID
    @param conveyorId: string - Conveyor ID
]]
function PlotManager:PlaceCar(playerId, carId, conveyorId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            conveyor.car = { id = carId }
            return true
        end
    end
    return false
end

--[[
    Place NPC on conveyor
    @param playerId: string - Player ID
    @param npcId: string - NPC ID
    @param conveyorId: string - Conveyor ID
]]
function PlotManager:PlaceNPC(playerId, npcId, conveyorId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            conveyor.npc = { id = npcId }
            return true
        end
    end
    return false
end

--[[
    Remove car from conveyor
    @param playerId: string - Player ID
    @param conveyorId: string - Conveyor ID
]]
function PlotManager:RemoveCar(playerId, conveyorId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            conveyor.car = nil
            return true
        end
    end
    return false
end

--[[
    Remove NPC from conveyor
    @param playerId: string - Player ID
    @param conveyorId: string - Conveyor ID
]]
function PlotManager:RemoveNPC(playerId, conveyorId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            conveyor.npc = nil
            return true
        end
    end
    return false
end

--[[
    Collect income from conveyor
    @param playerId: string - Player ID
    @param conveyorId: string - Conveyor ID
    @return: number - Amount collected
]]
function PlotManager:CollectIncome(playerId, conveyorId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local IncomeGenerator = require(script.Parent:WaitForChild("IncomeGenerator"))
    
    local player = PlayerDataManager:GetPlayer(playerId)
    
    for _, conveyor in ipairs(player.plot.conveyors) do
        if conveyor.id == conveyorId then
            local accumulated = IncomeGenerator:CalculateAccumulatedIncome(conveyor)
            PlayerDataManager:UpdateMoney(playerId, accumulated)
            conveyor.income_accumulated = 0
            conveyor.lastCollected = os.time()
            return accumulated
        end
    end
    return 0
end

--[[
    Get plot status
    @param playerId: string - Player ID
    @return: table - Plot data
]]
function PlotManager:GetPlotStatus(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:GetPlayer(playerId).plot
end

--[[
    Unlock a new conveyor (via rebirth)
    @param playerId: string - Player ID
]]
function PlotManager:UnlockConveyor(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    if player.plot.unlockedCount < player.plot.totalConveyors then
        player.plot.unlockedCount = player.plot.unlockedCount + 1
        return true
    end
    return false
end

return PlotManager
