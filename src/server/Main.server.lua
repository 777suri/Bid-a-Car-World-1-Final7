--[[
    Main.server.lua
    Purpose: Main game server script - initializes all managers and systems
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Load all managers
local managersFolder = script.Parent:WaitForChild("managers")
local DataStoreManager = require(managersFolder:WaitForChild("DataStoreManager"))
local PlayerDataManager = require(managersFolder:WaitForChild("PlayerDataManager"))
local Config = require(script.Parent:WaitForChild("Config"))

print("[BID A CAR] Game Server Initializing...")
print("[BID A CAR] Version: " .. Config.GAME_VERSION)
print("[BID A CAR] Managers loaded successfully")

--[[
    Initialize new player
]]
local function initializePlayer(player)
    local playerId = tostring(player.UserId)
    print("[BID A CAR] Player joined: " .. player.Name .. " (ID: " .. playerId .. ")")
    
    -- Load data from DataStore
    local savedData = DataStoreManager:Load(playerId)
    
    -- Load into memory
    PlayerDataManager:LoadPlayerData(playerId, savedData)
    
    -- Initialize auto-save
    DataStoreManager:InitializePlayer(playerId, PlayerDataManager:GetPlayer(playerId))
    
    print("[BID A CAR] Player " .. player.Name .. " initialized with $" .. PlayerDataManager:GetMoney(playerId))
end

--[[
    Handle player leaving
]]
local function onPlayerLeaving(player)
    local playerId = tostring(player.UserId)
    print("[BID A CAR] Player leaving: " .. player.Name)
    
    -- Final save
    DataStoreManager:PlayerLeaving(playerId)
    PlayerDataManager:RemovePlayer(playerId)
end

-- Connect player events
Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(onPlayerLeaving)

-- Initialize existing players (in case of script reload)
for _, player in ipairs(Players:GetPlayers()) do
    initializePlayer(player)
end

print("[BID A CAR] Server initialization complete!")
