Config = {}

-- General Settings
Config.Debug = false
Config.EnableTricks = true

-- Keybinds
Config.Keys = {
    Wheelie = {0, 21}, -- Left Shift
    Stoppie = {0, 19}, -- Left Alt
    Flip = {0, 22}, -- Space
    ToggleUI = {0, 166}, -- F5
}

-- Trick Settings
Config.TrickSettings = {
    MinSpeed = 10.0, -- Minimum speed required for tricks (km/h)
    MaxSpeed = 200.0, -- Maximum speed for tricks
    MinTrickTime = 1000, -- Minimum time to hold trick (ms)
    ScoreMultiplier = 1.0,
    ComboTimeout = 3000, -- Time to chain tricks for combo (ms)
}

-- Motorcycle Models (add more as needed)
Config.MotorcycleModels = {
    "akuma",
    "avarus", 
    "bagger",
    "bati",
    "bati2",
    "bf400",
    "carbonrs",
    "chimera",
    "cliffhanger",
    "daemon",
    "daemon2",
    "defiler",
    "diabolus",
    "double",
    "enduro",
    "esskey",
    "faggio",
    "faggio2",
    "faggio3",
    "fcr",
    "fcr2",
    "gargoyle",
    "hakuchou",
    "hakuchou2",
    "hexer",
    "innovation",
    "lectro",
    "manchez",
    "nemesis",
    "nightblade",
    "pcj",
    "ruffian",
    "sanchez",
    "sanchez2",
    "sovereign",
    "thrust",
    "vader",
    "vortex",
    "wolfsbane",
    "zombiea",
    "zombieb",
}

-- Scoring System
Config.Scores = {
    Wheelie = {
        base = 10,
        perSecond = 5,
        perfect = 50, -- Bonus for long wheelies
    },
    Stoppie = {
        base = 15,
        perSecond = 7,
        perfect = 60,
    },
    Flip = {
        base = 50,
        barrel = 75,
        backflip = 100,
        frontflip = 100,
    },
    Combo = {
        multiplier = 1.5,
        maxMultiplier = 3.0,
    },
    Speed = {
        bonusThreshold = 80.0, -- km/h
        bonusMultiplier = 1.2,
    },
}

-- UI Settings
Config.UI = {
    ShowScore = true,
    ShowCombo = true,
    ShowTrickName = true,
    NotificationTime = 3000,
    Position = {
        x = 50, -- Percentage from left
        y = 10, -- Percentage from top
    },
}