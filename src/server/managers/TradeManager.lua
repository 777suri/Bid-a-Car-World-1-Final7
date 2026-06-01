--[[
    TradeManager.lua
    Purpose: Player-to-player trading (Rebirth 2+)
]]

local TradeManager = {}
local activeTrades = {}

--[[
    Initiate a trade between two players
    @param playerAId: string - Player A ID
    @param playerBId: string - Player B ID
    @return: string - Trade ID
]]
function TradeManager:InitiateTrade(playerAId, playerBId)
    local tradeId = "trade_" .. os.time()
    
    activeTrades[tradeId] = {
        id = tradeId,
        playerA = playerAId,
        playerB = playerBId,
        playerAItems = {},
        playerBItems = {},
        playerAAccepted = false,
        playerBAccepted = false,
        status = "PENDING"
    }
    
    return tradeId
end

--[[
    Add item to trade
    @param playerId: string - Player ID
    @param tradeId: string - Trade ID
    @param itemType: string - Item type
    @param itemId: string - Item ID
]]
function TradeManager:AddToTrade(playerId, tradeId, itemType, itemId)
    local trade = activeTrades[tradeId]
    if not trade then
        return false
    end
    
    if trade.playerA == playerId then
        table.insert(trade.playerAItems, { type = itemType, id = itemId })
    elseif trade.playerB == playerId then
        table.insert(trade.playerBItems, { type = itemType, id = itemId })
    else
        return false
    end
    
    return true
end

--[[
    Remove item from trade
    @param playerId: string - Player ID
    @param tradeId: string - Trade ID
    @param itemType: string - Item type
    @param itemId: string - Item ID
]]
function TradeManager:RemoveFromTrade(playerId, tradeId, itemType, itemId)
    local trade = activeTrades[tradeId]
    if not trade then
        return false
    end
    
    local items = (trade.playerA == playerId) and trade.playerAItems or trade.playerBItems
    
    for i, item in ipairs(items) do
        if item.type == itemType and item.id == itemId then
            table.remove(items, i)
            return true
        end
    end
    
    return false
end

--[[
    Accept trade
    @param playerId: string - Player ID
    @param tradeId: string - Trade ID
]]
function TradeManager:AcceptTrade(playerId, tradeId)
    local trade = activeTrades[tradeId]
    if not trade then
        return false
    end
    
    if trade.playerA == playerId then
        trade.playerAAccepted = true
    elseif trade.playerB == playerId then
        trade.playerBAccepted = true
    else
        return false
    end
    
    if trade.playerAAccepted and trade.playerBAccepted then
        return self:CompleteTrade(tradeId)
    end
    
    return true
end

--[[
    Decline trade
    @param playerId: string - Player ID
    @param tradeId: string - Trade ID
]]
function TradeManager:DeclineTrade(playerId, tradeId)
    activeTrades[tradeId] = nil
    return true
end

--[[
    Complete trade (swap items)
    @param tradeId: string - Trade ID
]]
function TradeManager:CompleteTrade(tradeId)
    local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))
    local trade = activeTrades[tradeId]
    
    if not trade then
        return false
    end
    
    -- Swap items
    for _, item in ipairs(trade.playerAItems) do
        InventoryManager:RemoveItem(trade.playerA, item.type, item.id)
        InventoryManager:AddItem(trade.playerB, item.type, item)
    end
    
    for _, item in ipairs(trade.playerBItems) do
        InventoryManager:RemoveItem(trade.playerB, item.type, item.id)
        InventoryManager:AddItem(trade.playerA, item.type, item)
    end
    
    trade.status = "COMPLETED"
    activeTrades[tradeId] = nil
    
    return true
end

--[[
    Get pending trades for player
    @param playerId: string - Player ID
    @return: table - Pending trades
]]
function TradeManager:GetPendingTrades(playerId)
    local pending = {}
    
    for _, trade in pairs(activeTrades) do
        if (trade.playerA == playerId or trade.playerB == playerId) and trade.status == "PENDING" then
            table.insert(pending, trade)
        end
    end
    
    return pending
end

return TradeManager
