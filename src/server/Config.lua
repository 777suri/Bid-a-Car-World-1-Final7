--[[
    Config.lua
    Purpose: Global configuration for the game
]]

local Config = {}

-- Game Settings
Config.GAME_VERSION = "1.0.0"
Config.STARTING_MONEY = 700
Config.STARTING_CONVEYORS = 3
Config.MAX_CONVEYORS = 6

-- Save Settings
Config.SAVE_INTERVAL = 120  -- 2 minutes

-- Bid Settings
Config.BID_INCREMENT_PERCENT = 0.10  -- 10% increment
Config.BOT_BID_RANGE_MIN = 0.35  -- 35% of garage value
Config.BOT_BID_RANGE_MAX = 0.65  -- 65% of garage value
Config.BOT_COUNT_PER_BID = 3  -- 3 bots per bid instance

-- Bidding Phases
Config.PLAYER_BID_TIME = 2  -- seconds
Config.BOT_BID_TIME = 1  -- seconds
Config.BID_COUNTDOWN = 2  -- seconds

-- Income Settings
Config.OFFLINE_INCOME_CAP = 8 * 60 * 60  -- 8 hours in seconds

-- Rebirth Settings
Config.REBIRTH_COSTS = {
    [1] = 2000,
    [2] = 5000,
    [3] = 10000
}

-- UI Colors
Config.UI_COLORS = {
    PRIMARY_CYAN = "#00D4FF",
    PRIMARY_PURPLE = "#7B2CBF",
    ACCENT_GREEN = "#00FF41",
    ACCENT_RED = "#FF1744",
    DARK_BLUE = "#1A1F71"
}

-- Tier Specifications
Config.TIER_SPECS = {
    BEGINNER = { cost = 200, minDeco = 4, maxDeco = 7 },
    ADVANCED = { cost = 500, minDeco = 7, maxDeco = 13 },
    EXPERT = { cost = 1200, minDeco = 13, maxDeco = 21 },
    CHOSEN = { cost = 2500, minDeco = 21, maxDeco = 50 },
    TIER5 = { cost = 5000, minDeco = 50, maxDeco = 80 }
}

return Config
