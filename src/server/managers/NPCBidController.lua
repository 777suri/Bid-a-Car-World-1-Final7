--[[
    NPCBidController.lua
    Purpose: AI brain for all bot bidders (shared across all bots)
    Implements 10% bid increment system and 35-65% garage value bidding
]]

local NPCBidController = {}

--[[
    Calculate total garage value
    @param garage: table - Garage data
    @return: number - Total value
]]
function NPCBidController:CalculateGarageValue(garage)
    local ItemDatabase = require(script.Parent:WaitForChild("ItemDatabase"))
    
    local carPrice = 0
    if garage.car then
        local carData = ItemDatabase:GetCar(garage.car.id)
        carPrice = (carData and carData.income * 10) or 0  -- Estimate: income * 10
    end
    
    local decoValue = (garage.decorations and #garage.decorations or 0) * 20
    local lockerBonus = (garage.locker and 100) or 0
    
    return carPrice + decoValue + lockerBonus
end

--[[
    Determine bot bidding range (35-65% of garage value)
    @param garageValue: number - Total garage value
    @return: table - Min and max bid amounts
]]
function NPCBidController:DetermineBidRange(garageValue)
    return {
        min = math.floor(garageValue * 0.35),
        max = math.floor(garageValue * 0.65)
    }
end

--[[
    Generate next bot bid (with 10% increment)
    @param currentBid: number - Current bid amount
    @return: number - Next bid amount
]]
function NPCBidController:GenerateNextBid(currentBid)
    local increment = math.ceil(currentBid * 0.10)
    return currentBid + increment
end

--[[
    Execute bot bidding logic
    @param bidSession: table - Current bid session
    @param botName: string - Bot name
    @return: table - Bid actions to execute
]]
function NPCBidController:ExecuteBotLogic(bidSession, botName)
    local BidEngine = require(script.Parent:WaitForChild("BidEngine"))
    
    local garageValue = self:CalculateGarageValue(bidSession.garage)
    local bidRange = self:DetermineBidRange(garageValue)
    local randomStopPoint = math.random(bidRange.min, bidRange.max)
    
    local bidActions = {}
    local currentBid = bidSession.currentBid
    
    -- Bot bids until reaching random stop point
    while currentBid < randomStopPoint do
        currentBid = self:GenerateNextBid(currentBid)
        
        if currentBid >= randomStopPoint then
            table.insert(bidActions, {
                botName = botName,
                amount = currentBid,
                delay = 1
            })
            break
        end
        
        table.insert(bidActions, {
            botName = botName,
            amount = currentBid,
            delay = 1
        })
    end
    
    return bidActions
end

--[[
    Check if bot should continue bidding
    @param currentBid: number - Current bid
    @param stopPoint: number - Bot's stop point
    @return: boolean - Continue status
]]
function NPCBidController:ShouldContinueBidding(currentBid, stopPoint)
    return currentBid < stopPoint
end

return NPCBidController
