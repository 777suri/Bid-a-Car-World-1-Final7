# 🎮 BID A CAR (WORLD 1) - GAME ARCHITECTURE SCHEMA

**Game Type:** Roblox Bid Battle Simulator with RNG Garages & Progression  
**Status:** Development from scratch  
**Date Created:** May 19, 2026

---

## 📋 TABLE OF CONTENTS

1. [Game Overview](#game-overview)
2. [Game Flow & Player Journey](#game-flow--player-journey)
3. [Core Systems Architecture](#core-systems-architecture)
4. [Manager Breakdown](#manager-breakdown)
5. [DataStore Structure](#datastore-structure)
6. [UI/UX Wireframes](#uiux-wireframes)
7. [Folder Structure](#folder-structure)
8. [Bid Mechanics Deep Dive](#bid-mechanics-deep-dive)
9. [Item System](#item-system)
10. [Progression & Rebirths](#progression--rebirths)
11. [Complete Car Index](#complete-car-index)
12. [NPC & Decoration Details](#npc--decoration-details)
13. [Locker Contents](#locker-contents)

---

## 🎯 GAME OVERVIEW

### What is Bid A Car?
A Roblox game where players engage in **bid battles** to win RNG garages containing:
- **Random Rarity Cars** (Common → Rare → Epic → Legendary → SPEC)
- **Decorations** (#1-#N, $20 value each, 4-50 per garage based on tier)
- **Lockers** (time-locked containers with dice & potions)
- **NPCs** (from Dice Shop, provide income boosts on conveyors)

### Core Loop
```
Player → Select Bid Tier → Enter Bid Battle → Win/Lose → Collect Rewards → 
Place on Plot → Generate Income → Rebirth → Unlock World 2
```

### Start State
- **Starting Money:** $700
- **Starting Conveyors:** 3 (6 spots total on plot)
- **First Task:** Mini-tutorial (cursor guides click BID → BEGINNER) → Game starts

---

## 🎬 GAME FLOW & PLAYER JOURNEY

```
┌────────────────────────────────────────────────────────────────┐
│                    GAME START (New Player)                     │
└─────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Mini Tutorial   │
                    │ Cursor clicks:   │
                    │ 1. [BID] button  │
                    │ 2. [BEGINNER]    │
                    │ Duration: <1 min │
                    │ Mandatory        │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Main Lobby      │
                    │ $700 in pocket   │
                    │ Physical World   │
                    └────────┬─────────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐
    │ Garage   │      │ Events   │      │ Shop     │
    │ (BID)    │      │ (Future) │      │ (Dice)   │
    └────┬─────┘      └──────────┘      └──────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│  TIER SELECTION (Pop-up - Horizontal)    │
│  Scroll left/right for more tiers        │
│                                          │
│ [BEGINNER] [ADVANCED] [EXPERT] [CHOSEN] │
│   $200      $500       $1200    $2500    │
│                                          │
│ [TIER 5] (Unlocked after CHOSEN bid)     │
│   $5000                                  │
└────────────┬───────────────────────────┘
             │
             ▼ (Teleport to RNG Garage)
┌──────────────────────────────────────────┐
│   RNG GARAGE (Bid Battle Arena)          │
│   PHYSICALLY ON MAP (First-person POV)   │
│                                          │
│   Player + 3 Random Bots (from 6 total)  │
│   (Standing in line facing the car)      │
│                                          │
│   RNG GENERATED:                         │
│   - 1 Car (rarity by tier)               │
│   - 4-80 Decorations (#1-#N by tier)    │
│   - 0-2 Lockers (by tier chance)        │
│                                          │
│   Current Bid Display                    │
│   Countdown: 2 → 1 → 0                   │
│                                          │
│   [BID] Button (10% increment system)   │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┐
      ▼             ▼
    WIN           LOSS
     │              │
     ▼              ▼
┌─────────┐   ┌──────────────┐
│ Selection│   │ Money Refund │
│ 0-2 Deco │   │ (if no bid)  │
│ Auto-sell│   │ OR Lose All  │
│ Lockers  │   │ (if bidded)  │
└────┬─────┘   └──────────────┘
     │
     ▼ (Teleport back to Lobby)
┌─────────────────────────────┐
│ Inventory Updated           │
│ Items, Cars, Lockers        │
│ Income Ready to Collect     │
└────────────┬────────────────┘
             │
             ▼
    ┌────────────────────┐
    │  Place on Plot     │
    │ Or Trade/Sell      │
    │ Or Collect Income  │
    └────────┬───────────┘
             │
             ▼
    ┌────────────────────┐
    │  Rebirth Check?    │
    │ ($2000/$5000/etc)  │
    └────────┬───────────┘
             │
      ┌──────┴──────────┐
      ▼                 ▼
   YES (Rebirth)    NO (Continue)
     │                 │
     ▼                 ▼
  LOOP             LOOP
```

---

## 🏗️ CORE SYSTEMS ARCHITECTURE

### System Dependencies Graph
```
DataStoreManager (Foundation - Saves Everything)
      │
      ├─→ PlayerDataManager (Player State)
      │
      ├─→ BidEngine (Bid Battle Logic)
      │   ├─→ NPCBidController (Bot AI)
      │   └─→ RNGGarageGenerator (Garage Creation)
      │
      ├─→ InventoryManager (Items, Cars, Lockers, Decorations)
      │   └─→ ItemDatabase (All item definitions)
      │
      ├─→ PlotManager (Conveyor System, Placement)
      │   └─→ IncomeGenerator (Passive Money Generation)
      │
      ├─→ RebirthManager (Progression, Unlocks)
      │
      ├─→ ShopManager (Dice Shop)
      │   └─→ DiceRNG (NPC Generation)
      │
      ├─→ TradeManager (Player-to-Player Trading)
      │
      ├─→ UIManager (All UI Rendering)
      │   ├─→ BidUI
      │   ├─→ InventoryUI
      │   ├─→ TierSelectionUI
      │   └─→ PlotUI
      │
      └─→ TeleportManager (Location Transitions)
```

---

## 👨‍💼 MANAGER BREAKDOWN

### 1. **DataStoreManager**
**Purpose:** Auto-save all player data every 2 minutes

**Saves:**
```lua
{
  playerId = "player_id",
  timestamp = os.time(),
  money = 700,
  rebirthCount = 0,
  inventory = { ... },
  plot = { ... },
  stats = { ... }
}
```

**Key Functions:**
- `Save()` - Called every 2 min
- `Load()` - On player join
- `UpdateField(key, value)` - Real-time updates

---

### 2. **PlayerDataManager**
**Purpose:** Handle all player state in-memory

**Stores:**
```lua
players[playerId] = {
  money = 700,
  rebirths = {
    count = 0,
    timestamp = 0
  },
  inventory = {
    items = {},      -- Decorations, Potions
    cars = {},       -- Owned cars
    lockers = {},    -- Time-locked containers
    dice = {}        -- From shop
  },
  plot = {
    conveyors = {
      { car = nil, npc = nil },
      { car = nil, npc = nil },
      ...
    }
  },
  luckBoosts = {
    active = {},     -- Currently running
    expired = {}
  },
  stats = {
    totalBidsWon = 0,
    totalBidsLost = 0,
    totalMoneySpent = 0,
    totalMoneyEarned = 0
  }
}
```

**Key Functions:**
- `GetPlayer(playerId)`
- `UpdateMoney(playerId, amount)`
- `AddToInventory(playerId, itemType, item)`
- `RemoveFromInventory(playerId, itemType, itemId)`

---

### 3. **BidEngine**
**Purpose:** Control entire bid battle flow

**States:**
- `WAITING` - Waiting for players
- `BIDDING` - Active bidding phase
- `SETTLING` - Determining winner
- `COMPLETED` - Bid finished

**Flow:**
```
1. Player selects tier → Teleport to RNG Garage
2. RNG Garage generated (random car + decorations per tier specs)
3. 3 random bots selected from 6 available (Bacon, Barbara, Jack, Jeff, Mashallah, Roblofía)
4. Set starting bid price (tier-based)
5. Start bidding phase (2 sec player, 1 sec bots)
6. Bid raise with 10% of CURRENT BID VALUE
   Example: Current bid $300 → Next raise is $300 * 0.10 = $30 → New bid $330
7. Countdown: 2 → 1 → 0
8. If no bids: auto-end, refund entry fee
9. If bids made: Calculate winner (highest bid)
10. Winner selection phase (0-2 decorations can be selected)
11. Loser handling (money lost)
12. Teleport back to Lobby
```

**Key Functions:**
- `StartBid(playerId, tierPrice, garageType)`
- `PlayerBid(playerId, amount)`
- `BotBid(amount)` - Called by NPCBidController
- `CalculateWinner()`
- `SettleWin(playerId)`
- `SettleLoss(playerId, bidAmount)`
- `SelectDecorations(playerId, decorationIds[])`

---

### 4. **NPCBidController**
**Purpose:** AI brain for all bot bidders (shared across all bots)

**Core Logic:**
- All bots use **SINGLE SHARED AI** (not individual)
- Bids range: **35-65% of garage value**
- Each bid: random amount within that range
- Timing: 1 second between bids (not simultaneous)
- Stop condition: Random stop between 35-65%
- **BID INCREMENT USES 10% SYSTEM** (same as player)

**Algorithm:**
```
garageValue = CarPrice + (DecoCount * 20) + LockerBonus
minBid = garageValue * 0.35
maxBid = garageValue * 0.65
randomStopPoint = Random(minBid, maxBid)

while currentBidAmount < randomStopPoint:
    botIncrement = currentBidAmount * 0.10  -- 10% of current bid
    currentBidAmount += botIncrement
    wait(1 second)
    Bid(currentBidAmount)
    
    if currentBidAmount >= randomStopPoint:
        Stop()
```

**Key Functions:**
- `CalculateGarageValue(garage)`
- `DetermineBidRange(garageValue)`
- `GenerateNextBid(currentBid)`
- `ShouldContinueBidding(currentBid, stopPoint)`

---

### 5. **RNGGarageGenerator**
**Purpose:** Create random garages based on tier (ONE physical location, dynamic generation)

**Tier Specifications:**

| Tier | Entry | Car Rarity | Deco Count | Locker Rate |
|------|-------|-----------|-----------|------------|
| BEGINNER | $200 | Common-Rare | 4-7 | 1/10 |
| ADVANCED | $500 | Uncommon-Epic | 7-13 | 1/4 |
| EXPERT | $1200 | Rare-Legendary + 3% SPEC | 13-21 | 1/2 |
| CHOSEN | $2500 | Rare-Legendary + 10% SPEC | 21-50 | 1/1 (always) |
| TIER 5 | $5000 | Epic-Legendary +25% SPEC | 50-80 | 2x 1/1 (always double) |

**CAR RARITIES**

- BEGINNER: common 1/4 | uncommon 1/5 | rare 1/8
- ADVANCED: uncommon 1/8 | rare 1/6 | epic 1/10
- EXPERT: rare 1/10 | epic 1/6 | legendary 1/12 (3% SPEC INSTEAD OF LEGENDARY)
- CHOSEN: rare 1/36 | epic 1/24 | legendary 1/8 (10% SPEC INSTEAD OF LEGENDARY)
- TIER 5: epic 1/24 | legendary 1/8 (25% SPEC INSTEAD OF LEGENDARY)

**Generation:**
```
1. Roll car rarity based on tier
2. Roll car model from that rarity pool (see Complete Car Index)
3. Roll decoration count (min-max based on tier)
4. Generate decoration indices (#1, #2, #3... based on count)
5. Determine if locker drops (based on rate)
6. If locker: Roll locker rarity (33% equal chance Silver/Gold/Black)
7. Populate locker with contents (see Locker Contents)
8. Spawn on map in RNG Garage location (ONE physical location)
9. Display car + decorations + locker (if any)
```

**Key Functions:**
- `GenerateGarage(tierType)`
- `RollCarRarity(tier)`
- `SelectCarModel(rarity)`
- `GenerateDecorations(count)`
- `RollLocker(tier)`
- `PopulateLockerContents(lockerRarity)`

---

### 6. **InventoryManager**
**Purpose:** Manage all inventory items (Items, Cars, Lockers, Index)

**Structure:**
```lua
inventory[playerId] = {
  -- Items Tab
  items = {
    { id = "deco_001", name = "#1", value = 20, rarity = "common" },
    { id = "deco_002", name = "#2", value = 20, rarity = "common" },
    { id = "potion_luck_001", name = "Luck Boost", duration = 3600, type = "silver" },
    { id = "dice_basic_001", name = "Basic Dice", type = "basic" },
    { id = "locker_001", name = "Silver Locker", rarity = "silver", openedAt = 0, unopened = true }
  },
  
  -- Cars Tab
  cars = {
    { id = "car_ford_caisu_001", name = "Ford Caisu", rarity = "common", income = 15, owned = true },
    { id = "car_mcArren_senior_001", name = "McArren Senior", rarity = "legendary", income = 280, owned = false },
  },
  
  -- Locker Tab
  lockers = {
    { id = "locker_silver_001", rarity = "silver", timeToOpen = 3600, unopened = true },
    { id = "locker_gold_001", rarity = "gold", timeToOpen = 14400, unopened = false, contents = {...} }
  },
  
  -- Index Tab (View Only - All Cars)
  index = {
    -- Shows all cars in game with rarity, income, and lock status
  }
}
```

**UI Tab Structure:**

1. **Items Tab** - Grid layout
   - Decorations (numbered #1, #2, etc. - 4 per row, scrollable)
   - Potions (4 per row, scrollable)
   - Dice (4 per row, scrollable)
   - Lockers (separate section)

2. **Cars Tab** - Modern Grid with Rarity Sections
   - `Common` cars - Full row, 4 cars
   - `Uncommon` cars - Full row, 4 cars
   - `Rare` - Full row, 4 cars
   - `Epic` - Full row, 4 cars
   - `Legendary` - Full row, 4 cars
   - `SPEC` - Full row, 4 cars
   
   **Each car shows:**
   - Color image (no background)
   - Car name
   - Income $/min
   - If owned: Colored image + Income visible
   - If not owned: Black image + Lock icon + "???" income

3. **Locker Tab** - List with time remaining
   - Silver (1 hour) - [OPEN] button if ready
   - Gold (4 hours) - Timer or [OPEN]
   - Black (8 hours) - Timer or [OPEN]
   
   **When opened:**
   - Modal popup showing rewards
   - Auto-collect into inventory
   - Timer resets

4. **Index Tab** - View only
   - All cars in game
   - Owned cars: Colored + Income value
   - Locked cars: Black + Lock icon + "???" income
   - Sorted by rarity

**Key Functions:**
- `GetInventory(playerId)`
- `AddItem(playerId, itemType, item)`
- `RemoveItem(playerId, itemType, itemId)`
- `ListItems(playerId)`
- `GetCars(playerId, ownedOnly = true)`
- `OpenLocker(playerId, lockerId)`
- `UsePotion(playerId, potionId)`
- `ConsumeItem(playerId, itemType, itemId, quantity)`

---

### 7. **PlotManager**
**Purpose:** Manage player plot, conveyors, and placements (Physical on map)

**Plot Structure:**
```lua
plot[playerId] = {
  conveyors = {
    {
      id = "conveyor_1",
      car = { id = "car_x1", income = 50, boosted = false },
      npc = { id = "npc_booster_1", boostType = "golden_dice", boostPercent = 50 },
      income_accumulated = 1250,
      lastCollected = os.time()
    },
    { id = "conveyor_2", car = nil, npc = nil, income_accumulated = 0, lastCollected = 0 },
    ...
  },
  totalConveyors = 3,
  unlockedCount = 3
}
```

**Conveyor System:**
- Max 6 conveyors total
- Start with 3 free
- +1 at Rebirth 1 ($2000)
- +1 at Rebirth 3 ($10000)
- +1 at Robux 19 (premium)
- **1 car + 1 NPC per conveyor**
- Income: BASE (car) + BOOST (NPC %)

**Income Generation:**
```
Base Income = Car's $/min
With NPC = Car Income * (1 + NPC Boost%)

Example:
Car X1 = $50/min
NPC Booster (Golden Dice) = 50% boost
Total = $50 * 1.5 = $75/min

Offline MAX = 8 hours
$75/min * 60 = $4,500/hour
$4,500 * 8 = $36,000 max offline
```

**Collection Mechanic:**
- Player walks to car on plot
- Press `E` → "Collect" prompt
- Shows total accumulated since last collect
- Updates in real-time
- Money added to player wallet
- Counter resets

**Key Functions:**
- `PlaceCar(playerId, carId, conveyorId)`
- `PlaceNPC(playerId, npcId, conveyorId)`
- `RemoveCar(playerId, conveyorId)`
- `RemoveNPC(playerId, conveyorId)`
- `CollectIncome(playerId, conveyorId)`
- `CalculateOfflineIncome(playerId)`
- `UnlockConveyor(playerId)` - Rebirth system calls this
- `GetPlotStatus(playerId)`

---

### 8. **IncomeGenerator**
**Purpose:** Passive money generation system (offline included)

**Logic:**
```
When player joins/loads:
1. Check last logout time
2. Calculate time offline (max 8 hours per conveyor)
3. For each conveyor with a car:
   - Calculate: minutes_offline * income_per_minute (capped at 8 hours)
   - Add to accumulated income
4. When player presses E on car:
   - Show accumulated amount
   - Add to wallet
   - Reset counter
   - Reset lastCollected timestamp
```

**Calculation:**
```lua
function CalculateAccumulatedIncome(conveyor, timeSinceLastCollect)
    maxOfflineTime = 8 * 60 * 60  -- 8 hours in seconds
    actualTime = min(timeSinceLastCollect, maxOfflineTime)
    
    baseIncome = conveyor.car.income
    npcBoost = conveyor.npc ? conveyor.npc.boostPercent : 0
    totalIncomePerSecond = (baseIncome / 60) * (1 + npcBoost/100)
    
    accumulated = totalIncomePerSecond * actualTime
    return floor(accumulated)
end
```

**Key Functions:**
- `CalculateOfflineIncome(playerId, conveyorId)`
- `AddAccumulatedIncome(playerId, conveyorId, amount)`
- `CollectAll(playerId)` - Collect from all conveyors at once
- `UpdateIncomePerSecond(playerId, conveyorId)`

---

### 9. **RebirthManager**
**Purpose:** Handle progression milestones and unlocks

**Rebirth Levels:**

| Level | Cost | Effect | Unlocks |
|-------|------|--------|---------|
| 0 (Start) | - | - | - |
| 1 | $2,000 | Reset money to $0 | +1 Conveyor (4 total), +2 Luck Boosts |
| 2 | $5,000 | Reset money to $0 | Trade System (Player ↔ Player) |
| 3 | $10,000 | Reset money to $0 | +1 Conveyor (5 total), Access World 2 |

**Mechanics:**
```
1. Player has $2000+ → click on rebirth button → Rebirth UI
2. Player confirms rebirth
3. Money set to $0 (lose all)
4. Rebirth count +1
5. Unlock new features
6. Keep all items/cars/lockers
7. Keep NPCs on conveyors
8. Reset money only
9. Update DataStore
```

**Key Functions:**
- `CanRebirth(playerId, level)`
- `ExecuteRebirth(playerId, level)`
- `UnlockFeature(playerId, feature)`
- `GetRebirthStatus(playerId)`
- `GetNextRebirthCost(playerId)`

---

### 10. **ShopManager**
**Purpose:** Dice shop where players buy dice for NPC generation

**Shop Interface:**
Modern smooth UI style (Cyan/Purple theme - Bid Battles aesthetic)

```
┌────────────────────────────────┐
│         DICE SHOP              │
├────────────────────────────────┤
│                                │
│ [BASIC DICE] [GOLDEN DICE]     │
│ $150         $300              │
│ [BUY]        [BUY]             │
│                                │
│ [DIAMOND DICE] [NA-SPEC DICE]  │
│ $1100        $2500             │
│ [BUY]        [BUY]             │
│                                │
└────────────────────────────────┘
```

**Dice Types & Contents:**

| Dice | Price | NPC Rarity | Boost Range | Availability |
|------|-------|------------|-------------|--------------|
| Basic | $150 | Common-Rare | 10-30%+ | Always |
| Golden | $300 | Uncommon-Epic | 20-60% | Always |
| Diamond | $1100 | Rare-Legendary | 50-100% | Always |
| NA-SPEC | $2500 | Rare-SPEC | 50-150% | Rebirth 1+ |

**RNG Breakdown:**
- Basic: 1/2 common | 1/6 uncommon | 1/10 rare
- Golden: 1/4 uncommon | 1/6 rare | 1/10 epic
- Diamond: 1/10 rare | 1/6 epic | 1/12 legendary
- NA-SPEC: 1/21 rare | 1/16 epic | 1/4 legendary | 1/8 SPEC

**Flow:**
```
0. Player clicks Shop button and teleports to Merchant
1. Player presses E on NPC → DiceShopUI opens
2. Player buys dice ($X deducted from wallet)
3. Dice goes to Items → Inventory
4. Player opens dice → RNG rolls NPC
5. NPC goes to Items → Inventory
6. Player places NPC on conveyor
```

**Key Functions:**
- `BuyDice(playerId, diceType)`
- `OpenDice(playerId, diceId)` - RNG NPC generation
- `GetDiceShop()` - Returns all available dice
- `CanAffordDice(playerId, diceType)`

---

### 11. **DiceRNG**
**Purpose:** Generate random NPCs from dice

**NPC Generation:**
```lua
function GenerateNPC(diceType)
    rarities = GetRaritiesForDice(diceType)
    boostPercent = RandomRange(MinBoost[diceType], MaxBoost[diceType])
    npcName = GenerateRandomName()
    
    return {
        id = generateUUID(),
        name = npcName,
        type = diceType,
        boostPercent = boostPercent,
        rarity = SelectRarity(rarities),
        createdAt = os.time()
    }
end
```

**Key Functions:**
- `RollNPC(diceType)`
- `GetNPCStats(npcId)`
- `GenerateBoostPercent(diceType)`

---

### 12. **TradeManager** (Rebirth 2+)
**Purpose:** Player-to-player trading

**Trade System:**
- Modern UI (Pet Simulator style)
- 1v1 trades
- Only cars & NPCs tradeable
- No cash trading
- Confirm from both sides required

**Flow:**
```
1. Player A opens trade
2. Adds car/NPC to offer
3. Sends to Player B
4. Player B sees incoming trade
5. Player B adds car/NPC to counter
6. Both confirm [ACCEPT] or [DECLINE]
7. If both accept: Swap items
8. Update DataStore
```

**Key Functions:**
- `InitiateTrade(playerAId, playerBId)`
- `AddToTrade(playerId, tradeId, itemType, itemId)`
- `RemoveFromTrade(playerId, tradeId, itemType, itemId)`
- `AcceptTrade(playerId, tradeId)`
- `DeclineTrade(playerId, tradeId)`
- `CompleteTrade(tradeId)`
- `GetPendingTrades(playerId)`

---

### 13. **UIManager**
**Purpose:** Central hub for all UI rendering

**UI Screens & Styling:**
- **Color Theme:** Cyan (#00D4FF) / Purple (#7B2CBF) - Modern Bid Battles aesthetic
- **Button Colors:**
  - Events: Purple (#7B2CBF)
  - Garage: Cyan (#00D4FF)
  - Shop: Lime Green (#00FF41)
  - BID: Red (#FF1744) - Large, prominent
  - Secondary buttons: Dark Blue (#1A1F71)

**UI Screens:**

1. **Main Lobby Screen** - Physical world (not a UI pop-up)
   - Top-right buttons: [Events] (Purple) [Garage] (Cyan) [Shop] (Green)
   - Bottom-right: Wallet display ($700)
   - Bottom-center: [Inventory] [Settings] buttons
   - Settings icon on left side
   - Merchant NPC visible with "E - Dice Shop - Open Shop" prompt
   - Garage teleporter visible
   - All overlaid on 3D world

2. **Tier Selection UI** - Pop-up Window (Scrollable Horizontal)
   - Single horizontal row of bid tiers
   - Scroll left/right to view more tiers
   - Visible tiers: [BEGINNER $200] [ADVANCED $500] [EXPERT $1200] [CHOSEN $2500] [TIER 5 $5000]
   - Click on tier to select and confirm
   - Modern gradient background (Cyan to Purple)

3. **Bid Battle UI** - Physical World (First-person POV)
   - Live arena with player + 3 random bots physically positioned
   - Player on left, bots in line facing the car
   - Car at back with decorations displayed
   - Bid status panel showing current bid and all player bids
   - Countdown timer (2 → 1 → 0)
   - Large RED [BID] button at bottom-center
   - [Inventory] and [Settings] buttons accessible
   - Wallet display visible

4. **Inventory UI** - Pop-up Window
   - **Tabs at top:** [Items] [Cars] [Lockers] [Index]
   - **Cars Tab shows:**
     - Car image (no background, colored if owned, black if locked)
     - Car name
     - Income value ($/min)
     - Grid layout, scrollable
   - **Items Tab shows:**
     - Decorations (#1, #2, #3...), Potions, Dice in grid layout
   - **Lockers Tab shows:**
     - List of lockers with timer/open status
   - **Index Tab shows:**
     - All cars in game, filtered by rarity
     - Colored if owned, black if locked

5. **RebirthUI** - Pop-up confirmation with benefits display

6. **TradeUI** - Pet Simulator style modern smooth (Rebirth 2+)

7. **DiceShopUI** - Pop-up window on Merchant NPC interaction (E key)

8. **ShopGamePassUI** - General shop grid (COMING SOON)

**Key Functions:**
- `ShowMainLobby(playerId)`
- `ShowTierSelection(playerId)`
- `ShowBidUI(playerId, garageInfo)`
- `ShowInventory(playerId, tab = "cars")`
- `ShowRebirthUI(playerId)`
- `ShowTradeUI(playerAId, playerBId)`
- `HideUI(playerId, uiName)`
- `UpdateUIElement(uiName, element, value)`

---

### 14. **TeleportManager**
**Purpose:** Handle all location transitions

**Teleport Points:**

| From | To | Trigger |
|------|-----|---------|
| Lobby | RNG Garage | BID tier selection |
| RNG Garage | Lobby | Exit/Lose bid |
| Lobby | Merchant | SHOP button click |
| Merchant | Plot | GARAGE button click |
| Plot | RNG Garage | BID button click |

**Key Functions:**
- `Teleport(playerId, destination, args = {})`
- `TeleportToRNGGarage(playerId, tierType)`
- `TeleportToLobby(playerId)`
- `TeleportToMerchant(playerId)`
- `GetTeleportPosition(location)`

---

## 💾 DATASTORE STRUCTURE

### Main Save File Schema

```json
{
  "playerId": "player_id_12345",
  "timestamp": 1715113200,
  "gameVersion": "1.0.0",
  
  "account": {
    "username": "PlayerName",
    "joinDate": 1715000000,
    "lastLogin": 1715113200,
    "totalPlaytime": 3600
  },
  
  "wallet": {
    "money": 1500,
    "lastUpdated": 1715113200
  },
  
  "progression": {
    "rebirthCount": 0,
    "rebirthTimestamps": [],
    "currentWorld": 1,
    "tutorialCompleted": true
  },
  
  "inventory": {
    "items": [
      {
        "id": "deco_001",
        "type": "decoration",
        "name": "#1",
        "quantity": 1,
        "value": 20,
        "acquiredAt": 1715112000
      },
      {
        "id": "potion_luck_001",
        "type": "potion",
        "name": "Luck Boost",
        "rarity": "silver",
        "durationSeconds": 3600,
        "expiresAt": 1715116600
      },
      {
        "id": "dice_basic_001",
        "type": "dice",
        "diceType": "basic",
        "unopened": true,
        "acquiredAt": 1715110000
      },
      {
        "id": "locker_silver_001",
        "type": "locker",
        "rarity": "silver",
        "openedAt": 0,
        "unopened": true,
        "acquiredAt": 1715109000
      }
    ],
    
    "cars": [
      {
        "id": "car_ford_caisu_001",
        "model": "Ford Caisu",
        "rarity": "common",
        "income": 15,
        "acquiredAt": 1715107000,
        "onConveyorId": "conveyor_1"
      },
      {
        "id": "car_mcArren_senior_001",
        "model": "McArren Senior",
        "rarity": "legendary",
        "income": 280,
        "acquiredAt": 1715105000,
        "onConveyorId": null
      }
    ]
  },
  
  "plot": {
    "totalConveyors": 3,
    "unlockedCount": 3,
    "conveyors": [
      {
        "id": "conveyor_1",
        "carId": "car_ford_caisu_001",
        "npcId": "npc_golden_001",
        "incomeAccumulated": 1250,
        "lastCollected": 1715112000
      },
      {
        "id": "conveyor_2",
        "carId": null,
        "npcId": null,
        "incomeAccumulated": 0,
        "lastCollected": 0
      },
      {
        "id": "conveyor_3",
        "carId": null,
        "npcId": null,
        "incomeAccumulated": 0,
        "lastCollected": 0
      }
    ]
  },
  
  "luckBoosts": {
    "active": [
      {
        "id": "boost_001",
        "type": "silver",
        "expiresAt": 1715116600,
        "percentIncrease": 20
      }
    ],
    "expired": []
  },
  
  "stats": {
    "totalBidsParticipated": 42,
    "totalBidsWon": 28,
    "totalBidsLost": 14,
    "totalMoneySpent": 8400,
    "totalMoneyEarned": 12500,
    "totalIncomeCollected": 5200,
    "longestWinStreak": 5,
    "favoriteCarModel": "Ford Caisu",
    "favoriteTier": "BEGINNER"
  }
}
```

---

## 📁 NPC & DECORATION DETAILS

### Bot Names (6 Available - 3 per Bid)
When a player enters a bid, 3 bots are **randomly selected** from:
- Bacon
- Barbara
- Jack
- Jeff
- Mashallah
- Roblofía

**Bot Selection:** Each bid instance randomly picks 3 unique bots from the 6 available (probability 1/2 per bot).

### Decorations
All decorations are stored in **ReplicatedStorage > Assets > Decorations**

- **Numbering:** #1, #2, #3, ... #N (no custom names, just numbers)
- **Value:** $20 each (universal)
- **Physical Models:** Each number corresponds to a different model in the Decorations folder
- **Spawning:** RNG garage randomly selects decoration count (4-80 based on tier) and spawns corresponding models

---

## 🎁 LOCKER CONTENTS

Lockers are 3 physical objects in **Workspace > Lockers**

### Silver Locker (1 hour open time)
**Contents (random selection per locker):**
- 0-1 Dice (random type: Basic/Golden/Diamond)
- 0-1 Luck Boost Potion (Silver type, 1 hour duration)
- 1-3 Decorations (random from #1-#N)

**Example locker content:**
```
{
  items: [
    { type: "dice", diceType: "basic" },
    { type: "potion", rarity: "silver", duration: 3600 },
    { type: "decoration", id: "#7" },
    { type: "decoration", id: "#12" }
  ]
}
```

### Gold Locker (4 hours open time)
**Contents (random selection per locker):**
- 1-2 Dice (random type: Basic/Golden/Diamond)
- 1 Luck Boost Potion (Gold type, potentially higher boost)
- 4-6 Decorations (random from #1-#N)

**Example locker content:**
```
{
  items: [
    { type: "dice", diceType: "golden" },
    { type: "dice", diceType: "basic" },
    { type: "potion", rarity: "gold", duration: 14400 },
    { type: "decoration", id: "#3" },
    { type: "decoration", id: "#8" },
    { type: "decoration", id: "#15" },
    { type: "decoration", id: "#21" },
    { type: "decoration", id: "#5" }
  ]
}
```

### Black Locker (8 hours open time)
**Contents (random selection per locker):**
- 1-4 Dice (random type: Basic/Golden/Diamond/NA-SPEC if available)
- 1-3 Luck Boost Potions (Gold or higher tier)
- 1-10 Decorations (random from #1-#N)

**Example locker content:**
```
{
  items: [
    { type: "dice", diceType: "diamond" },
    { type: "dice", diceType: "golden" },
    { type: "dice", diceType: "basic" },
    { type: "dice", diceType: "golden" },
    { type: "potion", rarity: "gold", duration: 14400 },
    { type: "potion", rarity: "gold", duration: 14400 },
    { type: "decoration", id: "#2" },
    { type: "decoration", id: "#9" },
    ... (up to 10 total decorations)
  ]
}
```

**Locker Opening:**
- Players interact with locker (E key)
- Confirms cracking the locker
- Receives contents instantly
- Locker disappears or resets for next player
- Items added to inventory

---

## 🚗 COMPLETE CAR INDEX

### COMMON CARS (Income: 9-20 $/min)
1. **Ford Caisu** - Income: $15/min
2. **Telza H** - Income: $9/min
3. **Viowo B10** - Income: $16/min
4. **DK Kyoto** - Income: $20/min

### UNCOMMON CARS (Income: 20-40 $/min)
5. **Ford Caisu RZ** - Income: $25/min
6. **Telza Cubic** - Income: $20/min
7. **C4 BMX** - Income: $37/min
8. **Fruity 1012** - Income: $40/min

### RARE CARS (Income: 40-90 $/min)
9. **H46 BMX** - Income: $40/min
10. **Ford J200** - Income: $50/min
11. **Suru BRS** - Income: $63/min
12. **Mekke HLS** - Income: $65/min
13. **Nizmo Silver 14** - Income: $70/min
14. **Nizmo Silver 15** - Income: $70/min
15. **Nizmo Silver 13** - Income: $80/min
16. **Tesnas Square** - Income: $80/min
17. **Nizmo F35** - Income: $90/min

### EPIC CARS (Income: 90-180 $/min)
18. **Dodota Upper 5** - Income: $120/min
19. **Jolk L80** - Income: $140/min
20. **Snakey Burnout** - Income: $155/min
21. **Fruity Spider** - Income: $168/min
22. **Nizmo F34** - Income: $170/min
23. **Mekke Air** - Income: $100/min
24. **Butti 06** - Income: $180/min
25. **Labubu Adventures** - Income: $180/min

### LEGENDARY CARS (Income: 180-500 $/min)
26. **McArren Senior** - Income: $280/min
27. **Butti 106** - Income: $300/min
28. **Masscar GOP** - Income: $300/min
29. **Fruity FKX** - Income: $400/min
30. **Butti 206** - Income: $380/min
31. **Koeralius F5** - Income: $430/min
32. **Masscar WRX** - Income: $500/min

### SPEC CARS (Income: 500-2000 $/min)
33. **G1 Champions** - Income: $1000/min

---

**Total: 33 cars**
- 4 Common
- 4 Uncommon
- 9 Rare
- 8 Epic
- 8 Legendary
- 1 SPEC

---

**Schema Version:** 2.0  
**Last Updated:** June 1, 2026  
**Status:** Complete - Ready for Backend Implementation