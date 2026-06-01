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
            PlayerDataManager:UpdateStats(playerId, "totalIncomeCollected", accumulated)
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
    Increments totalConveyors up to MAX_CONVEYORS (6)
    @param playerId: string - Player ID
    @return: boolean - Success
]]
function PlotManager:UnlockConveyor(playerId)
    local Config = require(script.Parent.Parent:WaitForChild("Config"))
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    local MAX_CONVEYORS = Config.MAX_CONVEYORS or 6
    
    if player.plot.totalConveyors < MAX_CONVEYORS then
        player.plot.totalConveyors = player.plot.totalConveyors + 1
        player.plot.unlockedCount = player.plot.unlockedCount + 1
        
        -- Add new empty conveyor to the list
        table.insert(player.plot.conveyors, {
            id = "conveyor_" .. player.plot.totalConveyors,
            car = nil,
            npc = nil,
            income_accumulated = 0,
            lastCollected = 0
        })
        
        return true
    end
    return false
end

--[[
    Check if conveyor slot is unlocked
    @param playerId: string - Player ID
    @param conveyorIndex: number - Index of conveyor (1-6)
    @return: boolean - Unlocked status
]]
function PlotManager:IsConveyorUnlocked(playerId, conveyorIndex)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    
    return conveyorIndex <= player.plot.unlockedCount
end

return PlotManager
