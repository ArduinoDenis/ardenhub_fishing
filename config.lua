Config = {}

-- ═══════════════════════════════════════════════════════════
-- IMPOSTAZIONI GENERALI
-- ═══════════════════════════════════════════════════════════
Config.Debug = false
Config.Locale = 'it'

-- ITEMS NECESSARI
Config.FishingRodItem = 'fishingrod' -- Canna da Pesca
Config.BaitItem = 'fishbait' -- Esche Per Pesci
Config.BaitConsumeChance = 100 -- % di consumare esca ad ogni tentativo (100 = sempre)

-- ═══════════════════════════════════════════════════════════
-- MECCANICHE DI PESCA
-- ═══════════════════════════════════════════════════════════
Config.Fishing = {
    cooldown = 3000, -- Cooldown tra una pesca e l'altra in ms
    waitTime = {min = 3000, max = 8000}, -- Tempo di attesa prima dello skillcheck
    skillCheck = {
        difficulty = {'easy'}, -- Difficoltà skillcheck
        inputs = {'w', 'a', 's', 'd'}
    },
    animation = {
        dict = "amb@world_human_stand_fishing@idle_a",
        anim = "idle_c",
        flag = 1
    },
    prop = {
        model = "prop_fishing_rod_01",
        bone = 60309,
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0)
    }
}

-- ═══════════════════════════════════════════════════════════
-- ZONE DI PESCA
-- ═══════════════════════════════════════════════════════════
Config.FishingZones = {
    {
        name = "Molo della Spiaggia",
        coords = vector3(-1849.68, -1250.14, 8.62),
        radius = 50.0,
        rarityBonus = 1.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 38,
            scale = 0.7,
            label = "Zona di Pesca"
        }
    },
    {
        name = "Lago Alamo",
        coords = vector3(1301.19, 4218.46, 33.91),
        radius = 80.0,
        rarityBonus = 1.3,
        blip = {
            enabled = true,
            sprite = 68,
            color = 38,
            scale = 0.7,
            label = "Zona di Pesca"
        }
    },
    {
        name = "Molo di Chumash",
        coords = vector3(-3428.19, 968.53, 8.35),
        radius = 60.0,
        rarityBonus = 1.1,
        blip = {
            enabled = true,
            sprite = 68,
            color = 38,
            scale = 0.7,
            label = "Zona di Pesca"
        }
    },
    {
        name = "Pier del Pacifico",
        coords = vector3(-1683.1810, -1166.4042, 13.0174),
        radius = 45.0,
        rarityBonus = 1.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 38,
            scale = 0.7,
            label = "Zona di Pesca"
        }
    }
}

-- ═══════════════════════════════════════════════════════════
-- TIPI DI PESCE
-- ═══════════════════════════════════════════════════════════
Config.FishTypes = {
    {
        name = "Acciuga",
        item = "anchovy",
        rarity = "comune",
        chance = 40,
        price = {min = 25, max = 45},
        weight = {min = 0.1, max = 0.8}
    },
    {
        name = "Trota",
        item = "trout",
        rarity = "non comune",
        chance = 30,
        price = {min = 50, max = 75},
        weight = {min = 0.5, max = 2.5}
    },
    {
        name = "Salmone",
        item = "salmon",
        rarity = "non comune",
        chance = 20,
        price = {min = 70, max = 100},
        weight = {min = 1.0, max = 4.0}
    },
    {
        name = "Tonno",
        item = "tuna",
        rarity = "raro",
        chance = 8,
        price = {min = 120, max = 180},
        weight = {min = 3.0, max = 10.0}
    },
    {
        name = "Pesce Spada",
        item = "swordfish",
        rarity = "leggendario",
        chance = 2,
        price = {min = 250, max = 400},
        weight = {min = 8.0, max = 20.0}
    }
}

-- ═══════════════════════════════════════════════════════════
-- VENDITORE PESCE
-- ═══════════════════════════════════════════════════════════
Config.FishSeller = {
    model = "s_m_m_dockwork_01",
    coords = vector4(-1038.45, -1397.97, 5.55, 108.0),
    blip = {
        enabled = true,
        sprite = 356,
        color = 2,
        scale = 0.7,
        label = "Mercato del Pesce"
    },
    dynamicPricing = {
        enabled = true,
        nightBonus = 1.20,    -- +20% di notte (22:00-06:00)
        dayMultiplier = 1.0
    }
}

-- ═══════════════════════════════════════════════════════════
-- NEGOZIO PESCA 
-- ═══════════════════════════════════════════════════════════
Config.FishingShop = {
    model = "s_m_m_linecook",
    coords = vector4(-1592.07, 5202.9, 4.31, 297.76),
    blip = {
        enabled = true,
        sprite = 371,
        color = 3,
        scale = 0.7,
        label = "Negozio di Pesca"
    },
    items = {
        {
            name = "fishingrod",
            label = "Canna da Pesca",
            price = 250,
            icon = "fish-fins"
        },
        {
            name = "fishbait",
            label = "Esca (x10)",
            price = 50,
            amount = 10,
            icon = "worm"
        }
    }
}

-- ═══════════════════════════════════════════════════════════
-- NOTIFICHE
-- ═══════════════════════════════════════════════════════════
Config.Notifications = {
    noRod = "Ti serve una canna da pesca!",
    noBait = "Ti servono esche per pescare!",
    startFishing = "Stai pescando...",
    failedCatch = "Il pesce è scappato!",
    caughtFish = "Hai pescato: %s (%.1f kg)",
    caughtRareFish = "🌟 RARO! Hai pescato: %s (%.1f kg)",
    inventoryFull = "Inventario pieno!",
    noFishToSell = "Non hai pesci da vendere!",
    soldFish = "Hai venduto %d pesci per $%d",
    notEnoughMoney = "Non hai abbastanza soldi!",
    cooldown = "Aspetta prima di pescare di nuovo!",
    notInZone = "Devi essere in una zona di pesca!",
    alreadyFishing = "Stai già pescando!",
    purchaseSuccess = "Hai acquistato %s",
    nightBonus = "🌙 Bonus notturno attivo! +20%"
}

-- ═══════════════════════════════════════════════════════════
-- WEBHOOKS DISCORD
-- ═══════════════════════════════════════════════════════════
Config.Webhooks = {
    enabled = true,
    url = "https://discord.com/api/webhooks/", -- Inserisci il tuo webhook Discord
    color = 3447003,
    footer = "ArDenHub Fishing System",
    logFishing = true,
    logSelling = true,
    logPurchases = true
}

-- ═══════════════════════════════════════════════════════════
-- ANTI-EXPLOIT
-- ═══════════════════════════════════════════════════════════
Config.AntiExploit = {
    enabled = true,
    maxActionsPerMinute = 15,
    kickOnExploit = true,
    logToDiscord = true
}