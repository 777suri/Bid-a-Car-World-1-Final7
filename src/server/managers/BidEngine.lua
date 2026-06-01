--[[
    BidEngine.lua
    Purpose: Control entire bid battle flow
    Manages bidding mechanics, 10% increment system, winner calculation
]]

local BidEngine = {}
local activeBids = {}

--[[
    Start a new bid session
    @param playerId: string - Player ID
    @param tierType: string - Bid tier (BEGINNER, ADVANCED, etc)
    @param entryFee: number - Entry fee amount
    @return: table - Bid session data
]]
function BidEngine:StartBid(playerId, tierType, entryFee)
    local RNGGarageGenerator = require(script.Parent:WaitForChild("RNGGarageGenerator"))
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    
    local bidId = "bid_" .. playerId .. "_" .. os.time()
    local garage = RNGGarageGenerator:GenerateGarage(tierType)
    local bots = ItemDatabase:GetRandomBots()
    
    local bidSession = {
        id = bidId,
        playerId = playerId,
        tierType = tierType,
        entryFee = entryFee,
        garage = garage,
        bots = bots,
        state = "WAITING",
        currentBid = 0,
        biddingHistory = {
            { player = playerId, amount = 0, time = os.time() }
        },
        playerBids = { [playerId] = 0 },
        botBids = {},
        startTime = os.time(),
        bidCountdown = 2
    }
    
    -- Initialize bot bids
    for _, botName in ipairs(bots) do
        bidSession.botBids[botName] = 0
    end
    
    activeBids[bidId] = bidSession
    return bidSession
end

--[[
    Player places a bid (10% increment system)
    @param bidId: string - Bid session ID
    @param playerId: string - Player ID
    @param bidAmount: number - Amount to bid
    @return: boolean - Success status
]]
function BidEngine:PlayerBid(bidId, playerId, bidAmount)
    local bid = activeBids[bidId]
    if not bid then
        return false
    end
    
    -- Validate bid amount (must be 10% increment of current bid)
    local minBidIncrease = math.ceil(bid.currentBid * 0.10)
    local expectedNewBid = bid.currentBid + minBidIncrease
    
    if bidAmount ~= expectedNewBid then
        return false
    end
    
    bid.currentBid = bidAmount
    bid.playerBids[playerId] = bidAmount
    table.insert(bid.biddingHistory, {
        player = playerId,
        amount = bidAmount,
        time = os.time()
    })
    
    return true
end

--[[
    Bot places a bid (10% increment system)
    @param bidId: string - Bid session ID
    @param botName: string - Bot name
    @param bidAmount: number - Amount to bid
]]
function BidEngine:BotBid(bidId, botName, bidAmount)
    local bid = activeBids[bidId]
    if not bid then
        return false
    end
    
    bid.currentBid = bidAmount
    bid.botBids[botName] = bidAmount
    table.insert(bid.biddingHistory, {
        player = botName,
        amount = bidAmount,
        time = os.time()
    })
    
    return true
end

--[[
    Calculate bid winner
    @param bidId: string - Bid session ID
    @return: string - Winner (playerId or botName)
]]
function BidEngine:CalculateWinner(bidId)
    local bid = activeBids[bidId]
    if not bid then
        return nil
    end
    
    local maxBid = 0
    local winner = nil
    
    -- Check player bid
    if bid.playerBids[bid.playerId] > maxBid then
        maxBid = bid.playerBids[bid.playerId]
        winner = bid.playerId
    end
    
    -- Check bot bids
    for botName, amount in pairs(bid.botBids) do
        if amount > maxBid then
            maxBid = amount
            winner = botName
        end
    end
    
    return winner
end

--[[
    Settle a win (player wins the bid)
    @param bidId: string - Bid session ID
    @param playerId: string - Player ID
    @return: table - Garage contents (car, decorations, locker)
]]
function BidEngine:SettleWin(bidId, playerId)
    local bid = activeBids[bidId]
    if not bid then
        return nil
    end
    
    local rewards = {
        car = bid.garage.car,
        decorations = bid.garage.decorations,
        locker = bid.garage.locker,
        bidAmount = bid.currentBid
    }
    
    bid.state = "COMPLETED"
    activeBids[bidId] = nil
    
    return rewards
end

--[[
    Settle a loss (player loses the bid)
    @param bidId: string - Bid session ID
    @param playerId: string - Player ID
    @return: boolean - Success status
]]
function BidEngine:SettleLoss(bidId, playerId)
    local bid = activeBids[bidId]
    if not bid then
        return false
    end
    
    bid.state = "COMPLETED"
    activeBids[bidId] = nil
    
    return true
end

--[[
    Get active bid session
    @param bidId: string - Bid session ID
    @return: table - Bid session data
]]
function BidEngine:GetBid(bidId)
    return activeBids[bidId]
end

return BidEngine
