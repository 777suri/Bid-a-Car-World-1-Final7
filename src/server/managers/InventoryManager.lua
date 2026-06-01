--[[
    InventoryManager.lua
    Purpose: Manage all inventory items (Items, Cars, Lockers, Index)
]]

local InventoryManager = {}

--[[
    Get inventory for player
    @param playerId: string - Player ID
    @return: table - Inventory table
]]
function InventoryManager:GetInventory(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local player = PlayerDataManager:GetPlayer(playerId)
    return player.inventory
end

--[[
    Add item to inventory
    @param playerId: string - Player ID
    @param itemType: string - Type (items, cars, lockers, dice)
    @param item: table - Item data
]]
function InventoryManager:AddItem(playerId, itemType, item)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:AddToInventory(playerId, itemType, item)
end

--[[
    Remove item from inventory
    @param playerId: string - Player ID
    @param itemType: string - Type (items, cars, lockers, dice)
    @param itemId: string - Item ID
]]
function InventoryManager:RemoveItem(playerId, itemType, itemId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:RemoveFromInventory(playerId, itemType, itemId)
end

--[[
    List items in inventory
    @param playerId: string - Player ID
    @return: table - Items list
]]
function InventoryManager:ListItems(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:GetInventory(playerId, "items")
end

--[[
    Get dice list from inventory
    @param playerId: string - Player ID
    @return: table - Dice list
]]
function InventoryManager:GetDiceList(playerId)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    return PlayerDataManager:GetInventory(playerId, "dice")
end

--[[
    Get owned cars
    @param playerId: string - Player ID
    @param ownedOnly: boolean - Only owned cars
    @return: table - Cars list
]]
function InventoryManager:GetCars(playerId, ownedOnly)
    local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
    local cars = PlayerDataManager:GetInventory(playerId, "cars")
    
    if ownedOnly then
        local ownedCars = {}
        for _, car in ipairs(cars) do
            if car.owned then
                table.insert(ownedCars, car)
            end
        end
        return ownedCars
    end
    
    return cars
end

--[[
    Open a locker (with time-lock checking)
    @param playerId: string - Player ID
    @param lockerId: string - Locker ID
    @return: table - Locker contents or nil if not ready
]]
function InventoryManager:OpenLocker(playerId, lockerId)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local inventory = self:GetInventory(playerId)
    
    for i, locker in ipairs(inventory.lockers) do
        if locker.id == lockerId and locker.unopened then
            -- Check if locker is ready to open
            local lockerSpec = ItemDatabase.LOCKER_CONTENTS[locker.rarity]
            if not lockerSpec then
                return nil
            end
            
            local timeRequired = lockerSpec.openTime
            local timePassed = os.time() - (locker.acquiredAt or os.time())
            
            -- If not enough time has passed, don't open
            if timePassed < timeRequired then
                return nil  -- Locker not ready yet
            end
            
            locker.unopened = false
            locker.openedAt = os.time()
            
            -- Add contents to inventory
            if locker.contents then
                for _, content in ipairs(locker.contents) do
                    if content.type == "dice" then
                        self:AddItem(playerId, "dice", content)
                    elseif content.type == "potion" then
                        self:AddItem(playerId, "items", content)
                    elseif content.type == "decoration" then
                        self:AddItem(playerId, "items", content)
                    end
                end
            end
            
            return locker.contents or {}
        end
    end
    
    return nil
end

--[[
    Check if a locker is ready to open
    @param playerId: string - Player ID
    @param lockerId: string - Locker ID
    @return: boolean - Ready status
]]
function InventoryManager:IsLockerReady(playerId, lockerId)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local inventory = self:GetInventory(playerId)
    
    for _, locker in ipairs(inventory.lockers) do
        if locker.id == lockerId and locker.unopened then
            local lockerSpec = ItemDatabase.LOCKER_CONTENTS[locker.rarity]
            if not lockerSpec then
                return false
            end
            
            local timeRequired = lockerSpec.openTime
            local timePassed = os.time() - (locker.acquiredAt or os.time())
            
            return timePassed >= timeRequired
        end
    end
    
    return false
end

--[[
    Get time remaining for locker to open
    @param playerId: string - Player ID
    @param lockerId: string - Locker ID
    @return: number - Seconds remaining (0 if ready or not found)
]]
function InventoryManager:GetLockerTimeRemaining(playerId, lockerId)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    local inventory = self:GetInventory(playerId)
    
    for _, locker in ipairs(inventory.lockers) do
        if locker.id == lockerId and locker.unopened then
            local lockerSpec = ItemDatabase.LOCKER_CONTENTS[locker.rarity]
            if not lockerSpec then
                return 0
            end
            
            local timeRequired = lockerSpec.openTime
            local timePassed = os.time() - (locker.acquiredAt or os.time())
            
            return math.max(0, timeRequired - timePassed)
        end
    end
    
    return 0
end

--[[
    Use a potion
    @param playerId: string - Player ID
    @param potionId: string - Potion ID
]]
function InventoryManager:UsePotion(playerId, potionId)
    return self:RemoveItem(playerId, "items", potionId)
end

--[[
    Consume item
    @param playerId: string - Player ID
    @param itemType: string - Type
    @param itemId: string - Item ID
    @param quantity: number - Quantity
]]
function InventoryManager:ConsumeItem(playerId, itemType, itemId, quantity)
    for i = 1, (quantity or 1) do
        self:RemoveItem(playerId, itemType, itemId)
    end
    return true
end

return InventoryManager
