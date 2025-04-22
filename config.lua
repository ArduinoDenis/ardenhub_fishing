Config = {}

Config.Debug = false
Config.UseTarget = true

Config.FishingRodItem = 'fishingrod'
Config.BaitItem = 'fishbait'
Config.FishingTime = {min = 5000, max = 15000}
Config.SkillCheckDifficulty = 'easy'

Config.FishingZones = {
    {
        name = "Beach Pier",
        coords = vector3(-1850.16, -1249.71, 8.62),
        radius = 50.0,
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = "Fishing Zone"
        }
    },
    {
        name = "Alamo Lake",
        coords = vector3(1301.19, 4218.46, 33.91),
        radius = 80.0,
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = "Fishing Zone"
        }
    },
    {
        name = "Chumash Pier",
        coords = vector3(-3428.19, 968.53, 8.35),
        radius = 50.0,
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = "Fishing Zone"
        }
    }
}

Config.FishTypes = {
    {
        name = "Tuna",
        item = "tuna",
        chance = 20,
        price = {min = 80, max = 120},
        weight = {min = 1, max = 5}
    },
    {
        name = "Salmon",
        item = "salmon",
        chance = 25,
        price = {min = 60, max = 90},
        weight = {min = 0.5, max = 3}
    },
    {
        name = "Trout",
        item = "trout",
        chance = 25,
        price = {min = 60, max = 90},
        weight = {min = 0.5, max = 3}
    },
    {
        name = "Anchovy",
        item = "anchovy",
        chance = 30,
        price = {min = 40, max = 70},
        weight = {min = 0.3, max = 2}
    }
}

Config.FishSeller = {
    model = "s_m_m_dockwork_01",
    coords = vector4(-1038.45, -1397.97, 5.55, 75.0),
    blip = {
        sprite = 356,
        color = 3,
        scale = 0.8,
        label = "Fish Market"
    }
}

Config.FishingShop = {
    model = "s_m_m_linecook",
    coords = vector4(-1592.07, 5202.9, 4.31, 297.76),
    blip = {
        sprite = 371,
        color = 3,
        scale = 0.8,
        label = "Fishing Shop"
    },
    items = {
        {
            name = "fishingrod",
            label = "Fishing Rod",
            price = 150,
            icon = "fa-solid fa-fish-fins"
        },
        {
            name = "fishbait",
            label = "Fishing Bait",
            price = 5,
            icon = "fa-solid fa-worm"
        }
    }
}

Config.Notifications = {
    noRod = "You need a fishing rod to fish",
    noBait = "You need bait to fish",
    startFishing = "You started fishing...",
    failedCatch = "The fish got away!",
    caughtFish = "You caught a %s weighing %.1f kg",
    inventoryFull = "Your inventory is full",
    noFishToSell = "You don't have any fish to sell",
    soldFish = "You sold %d fish for $%d",
    notEnoughMoney = "You don't have enough money"
}

Config.Webhooks = {
    enabled = true,
    fishing = {
        url = "https://discord.com/api/webhooks/",
        color = 3447003,
        footer = "Fishing Logs",
        title = "Fishing System"
    },
    selling = {
        url = "https://discord.com/api/webhooks/",
        color = 15158332,
        footer = "Fishing Logs",
        title = "Fish Sales"
    }
}