--[[
    TeleportManager.lua
    Purpose: Handle all location transitions
]]

local TeleportManager = {}
local Players = game:GetService("Players")

-- Teleport points (define spawn locations in workspace)
local TELEPORT_POINTS = {
    LOBBY = Vector3.new(0, 5, 0),
    RNG_GARAGE = Vector3.new(50, 5, 0),
    MERCHANT = Vector3.new(100, 5, 0),
    PLOT = Vector3.new(-50, 5, 0)
}

--[[
    Teleport player to location
    @param playerId: string - Player ID
    @param destination: string - Destination name
    @param args: table - Additional arguments
]]
function TeleportManager:Teleport(playerId, destination, args)
    local player = Players:FindFirstChild(tostring(playerId))
    if not player or not player.Character then
        return false
    end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    local position = self:GetTeleportPosition(destination)
    if not position then
        return false
    end
    
    humanoidRootPart.CFrame = CFrame.new(position)
    return true
end

--[[
    Teleport to RNG Garage
    @param playerId: string - Player ID
    @param tierType: string - Tier type
]]
function TeleportManager:TeleportToRNGGarage(playerId, tierType)
    return self:Teleport(playerId, "RNG_GARAGE", { tier = tierType })
end

--[[
    Teleport to Lobby
    @param playerId: string - Player ID
]]
function TeleportManager:TeleportToLobby(playerId)
    return self:Teleport(playerId, "LOBBY")
end

--[[
    Teleport to Merchant
    @param playerId: string - Player ID
]]
function TeleportManager:TeleportToMerchant(playerId)
    return self:Teleport(playerId, "MERCHANT")
end

--[[
    Get teleport position
    @param location: string - Location name
    @return: Vector3 - Position
]]
function TeleportManager:GetTeleportPosition(location)
    return TELEPORT_POINTS[location]
end

return TeleportManager
