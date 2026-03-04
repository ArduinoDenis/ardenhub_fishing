-- ═══════════════════════════════════════════════════════════
-- ARDENHUB FISHING - SERVER
-- ═══════════════════════════════════════════════════════════

local ESX = exports["es_extended"]:getSharedObject()
local playerActions = {}

-- ═══════════════════════════════════════════════════════════
-- ANTI-EXPLOIT SYSTEM
-- ═══════════════════════════════════════════════════════════
function CheckExploit(source)
    if not Config.AntiExploit.enabled then return false end
    
    local identifier = GetPlayerIdentifier(source, 0)
    local currentTime = os.time()
    
    if not playerActions[identifier] then
        playerActions[identifier] = {
            actions = {},
            lastReset = currentTime
        }
    end
    
    local playerData = playerActions[identifier]
    
    
    if currentTime - playerData.lastReset >= 60 then
        playerData.actions = {}
        playerData.lastReset = currentTime
    end
    
    table.insert(playerData.actions, currentTime)
    
    if #playerData.actions > Config.AntiExploit.maxActionsPerMinute then
        if Config.AntiExploit.logToDiscord then
            SendDiscordLog('exploit', {
                title = '🚨 Possibile Exploit Rilevato',
                description = 'Giocatore: ' .. GetPlayerName(source) .. ' (ID: ' .. source .. ')',
                color = 15158332,
                fields = {
                    {name = 'Azioni al minuto', value = tostring(#playerData.actions), inline = true},
                    {name = 'Limite', value = tostring(Config.AntiExploit.maxActionsPerMinute), inline = true}
                }
            })
        end
        
        if Config.AntiExploit.kickOnExploit then
            DropPlayer(source, 'Anti-Exploit: Troppe azioni rilevate')
        end
        
        return true
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════
-- DISCORD WEBHOOK
-- ═══════════════════════════════════════════════════════════
function SendDiscordLog(logType, data)
    if not Config.Webhooks.enabled or not Config.Webhooks.url or Config.Webhooks.url == "" then 
        return 
    end
    
    local embed = {
        {
            title = data.title or "Log Sistema Pesca",
            description = data.description or "",
            color = data.color or Config.Webhooks.color,
            fields = data.fields or {},
            footer = {
                text = Config.Webhooks.footer .. " • " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }
    }
    
    PerformHttpRequest(Config.Webhooks.url, function(err, text, headers) 
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end

-- ═══════════════════════════════════════════════════════════
-- CALLBACK: CONTROLLA ITEMS
-- ═══════════════════════════════════════════════════════════
ESX.RegisterServerCallback('ardenhub_fishing:checkItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false, false) end
    
    local hasRod = xPlayer.getInventoryItem(Config.FishingRodItem).count > 0
    local hasBait = xPlayer.getInventoryItem(Config.BaitItem).count > 0
    
    cb(hasRod, hasBait)
end)

-- ═══════════════════════════════════════════════════════════
-- EVENT: CONSUMA ESCA
-- ═══════════════════════════════════════════════════════════
RegisterNetEvent('ardenhub_fishing:consumeBait', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if math.random(100) <= Config.BaitConsumeChance then
        xPlayer.removeInventoryItem(Config.BaitItem, 1)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- EVENT: PESCA PESCE
-- ═══════════════════════════════════════════════════════════
RegisterNetEvent('ardenhub_fishing:catchFish', function(zoneBonus)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    
    if CheckExploit(source) then return end
    
    if math.random(100) <= Config.BaitConsumeChance then
        xPlayer.removeInventoryItem(Config.BaitItem, 1)
    end
    
    local totalChance = 0
    for _, fish in ipairs(Config.FishTypes) do
        totalChance = totalChance + fish.chance
    end
    
    local roll = math.random(1, totalChance)
    local caughtFish = nil
    local currentChance = 0
    
    for _, fish in ipairs(Config.FishTypes) do
        currentChance = currentChance + fish.chance
        if roll <= currentChance then
            caughtFish = fish
            break
        end
    end
    
    if not caughtFish then
        caughtFish = Config.FishTypes[1] 
    end
    
    local weight = math.random(caughtFish.weight.min * 10, caughtFish.weight.max * 10) / 10
    
    if xPlayer.canCarryItem(caughtFish.item, 1) then
        xPlayer.addInventoryItem(caughtFish.item, 1)
        
        local notifMsg = string.format(Config.Notifications.caughtFish, caughtFish.name, weight)
        if caughtFish.rarity == "leggendario" or caughtFish.rarity == "raro" then
            notifMsg = string.format(Config.Notifications.caughtRareFish, caughtFish.name, weight)
        end
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Pesca',
            description = notifMsg,
            type = 'success',
            duration = 5000
        })
        
        if Config.Webhooks.enabled and Config.Webhooks.logFishing then
            SendDiscordLog('fishing', {
                title = '🎣 Pesce Pescato',
                description = GetPlayerName(source) .. ' ha pescato un pesce',
                fields = {
                    {name = 'Giocatore', value = GetPlayerName(source) .. ' (ID: ' .. source .. ')', inline = false},
                    {name = 'Pesce', value = caughtFish.name, inline = true},
                    {name = 'Peso', value = weight .. ' kg', inline = true},
                    {name = 'Rarità', value = caughtFish.rarity, inline = true}
                }
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Pesca',
            description = Config.Notifications.inventoryFull,
            type = 'error'
        })
    end
end)

-- ═══════════════════════════════════════════════════════════
-- EVENT: VENDI PESCE
-- ═══════════════════════════════════════════════════════════
RegisterNetEvent('ardenhub_fishing:sellFish', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local totalMoney = 0
    local totalFish = 0
    local soldItems = {}
    
    local hour = tonumber(os.date("%H"))
    local priceMultiplier = 1.0
    local isNight = false
    
    if Config.FishSeller.dynamicPricing.enabled then
        if hour >= 22 or hour < 6 then
            priceMultiplier = Config.FishSeller.dynamicPricing.nightBonus
            isNight = true
        end
    end
    
    for _, fish in ipairs(Config.FishTypes) do
        local item = xPlayer.getInventoryItem(fish.item)
        
        if item and item.count > 0 then
            local count = item.count
            local basePrice = math.random(fish.price.min, fish.price.max)
            local finalPrice = math.floor(basePrice * priceMultiplier)
            local totalPrice = finalPrice * count
            
            totalMoney = totalMoney + totalPrice
            totalFish = totalFish + count
            
            table.insert(soldItems, {
                name = fish.name,
                count = count,
                price = totalPrice
            })
            
            xPlayer.removeInventoryItem(fish.item, count)
        end
    end
    
    if totalFish > 0 then
        xPlayer.addMoney(totalMoney)
        
        local notifMsg = string.format(Config.Notifications.soldFish, totalFish, totalMoney)
        if isNight then
            notifMsg = notifMsg .. "\n" .. Config.Notifications.nightBonus
        end
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Mercato del Pesce',
            description = notifMsg,
            type = 'success',
            duration = 5000
        })
        
   
        if Config.Webhooks.enabled and Config.Webhooks.logSelling then
            local fields = {
                {name = 'Giocatore', value = GetPlayerName(source) .. ' (ID: ' .. source .. ')', inline = false},
                {name = 'Totale Pesci', value = tostring(totalFish), inline = true},
                {name = 'Guadagno', value = '$' .. totalMoney, inline = true}
            }
            
            if isNight then
                table.insert(fields, {name = 'Bonus Notturno', value = 'Attivo (+20%)', inline = true})
            end
            
            for _, item in ipairs(soldItems) do
                table.insert(fields, {
                    name = item.name, 
                    value = item.count .. 'x = $' .. item.price, 
                    inline = true
                })
            end
            
            SendDiscordLog('selling', {
                title = '💰 Vendita Pesce',
                description = GetPlayerName(source) .. ' ha venduto del pesce',
                fields = fields
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Mercato del Pesce',
            description = Config.Notifications.noFishToSell,
            type = 'error'
        })
    end
end)

-- ═══════════════════════════════════════════════════════════
-- EVENT: ACQUISTA ITEM
-- ═══════════════════════════════════════════════════════════
RegisterNetEvent('ardenhub_fishing:buyItem', function(itemName, price, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    amount = amount or 1
    
    local validItem = false
    for _, shopItem in ipairs(Config.FishingShop.items) do
        if shopItem.name == itemName then
            validItem = true
            break
        end
    end
    
    if not validItem then
        return
    end
    
    if xPlayer.getMoney() >= price then
        if xPlayer.canCarryItem(itemName, amount) then
            xPlayer.removeMoney(price)
            xPlayer.addInventoryItem(itemName, amount)
            
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Negozio di Pesca',
                description = string.format(Config.Notifications.purchaseSuccess, amount .. 'x ' .. itemName),
                type = 'success'
            })
            
            if Config.Webhooks.enabled and Config.Webhooks.logPurchases then
                SendDiscordLog('shop', {
                    title = '🏪 Acquisto Negozio',
                    description = GetPlayerName(source) .. ' ha acquistato un item',
                    fields = {
                        {name = 'Giocatore', value = GetPlayerName(source) .. ' (ID: ' .. source .. ')', inline = false},
                        {name = 'Item', value = itemName, inline = true},
                        {name = 'Quantità', value = tostring(amount), inline = true},
                        {name = 'Prezzo', value = '$' .. price, inline = true}
                    }
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Negozio di Pesca',
                description = Config.Notifications.inventoryFull,
                type = 'error'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Negozio di Pesca',
            description = Config.Notifications.notEnoughMoney,
            type = 'error'
        })
    end
end)

-- ═══════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════
AddEventHandler('playerDropped', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    if playerActions[identifier] then
        playerActions[identifier] = nil
    end
end)

print('^2[ARDENHUB Fishing]^7 Script caricato correttamente!')
