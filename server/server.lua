local ESX = exports["es_extended"]:getSharedObject()

-- Discord webhook function
function SendDiscordWebhook(webhookData, message, fields)
    if not Config.Webhooks.enabled then return end
    
    local embed = {
        {
            ["color"] = webhookData.color,
            ["title"] = webhookData.title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = webhookData.footer .. " • " .. os.date("%d/%m/%Y %H:%M:%S")
            },
            ["fields"] = fields or {}
        }
    }
    
    PerformHttpRequest(webhookData.url, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Check if player has fishing rod and bait
ESX.RegisterServerCallback('ardenhub_fishing:hasItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasRod = xPlayer.getInventoryItem(Config.FishingRodItem).count > 0
    local hasBait = xPlayer.getInventoryItem(Config.BaitItem).count > 0
    
    cb(hasRod, hasBait)
end)

-- Remove bait when fishing starts
RegisterServerEvent('ardenhub_fishing:removeBait')
AddEventHandler('ardenhub_fishing:removeBait', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(Config.BaitItem, 1)
    
    if Config.Webhooks.enabled then
        local playerName = GetPlayerName(source)
        local message = "**" .. playerName .. "** (ID: " .. source .. ") started fishing"
        SendDiscordWebhook(Config.Webhooks.fishing, message)
    end
end)

-- Catch fish event
RegisterServerEvent('ardenhub_fishing:catchFish')
AddEventHandler('ardenhub_fishing:catchFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Determine which fish was caught based on probability
    local totalChance = 0
    local fishChances = {}
    
    for i, fish in ipairs(Config.FishTypes) do
        totalChance = totalChance + fish.chance
        table.insert(fishChances, {
            fish = fish,
            minChance = totalChance - fish.chance,
            maxChance = totalChance
        })
    end
    
    local roll = math.random(1, totalChance)
    local caughtFish = nil
    
    for i, chance in ipairs(fishChances) do
        if roll > chance.minChance and roll <= chance.maxChance then
            caughtFish = chance.fish
            break
        end
    end
    
    if caughtFish then
        local weight = math.random(caughtFish.weight.min * 10, caughtFish.weight.max * 10) / 10
        
        if xPlayer.canCarryItem(caughtFish.item, 1) then
            xPlayer.addInventoryItem(caughtFish.item, 1, {
                weight = weight,
                type = caughtFish.name
            })
            
            TriggerClientEvent('ardenhub_fishing:notify', source, 'Fishing', 
                string.format(Config.Notifications.caughtFish, caughtFish.name, weight), 
                3000, 'success')
                
            if Config.Webhooks.enabled then
                local playerName = GetPlayerName(source)
                local message = "**" .. playerName .. "** (ID: " .. source .. ") caught a fish"
                local fields = {
                    {
                        ["name"] = "Fish Type",
                        ["value"] = caughtFish.name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Weight",
                        ["value"] = weight .. " kg",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Item",
                        ["value"] = caughtFish.item,
                        ["inline"] = true
                    }
                }
                SendDiscordWebhook(Config.Webhooks.fishing, message, fields)
            end
        else
            TriggerClientEvent('ardenhub_fishing:notify', source, 'Fishing', 
                Config.Notifications.inventoryFull, 
                3000, 'error', true)
        end
    end
end)

-- Sell fish event
RegisterServerEvent('ardenhub_fishing:sellFish')
AddEventHandler('ardenhub_fishing:sellFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalEarnings = 0
    local fishCount = 0
    local soldFishDetails = {}
    
    for _, fish in ipairs(Config.FishTypes) do
        local fishItem = xPlayer.getInventoryItem(fish.item)
        
        if fishItem and fishItem.count > 0 then
            local count = fishItem.count
            fishCount = fishCount + count
            
            -- Calculate price based on fish type
            local price = math.random(fish.price.min, fish.price.max) * count
            totalEarnings = totalEarnings + price
            
            -- Add details for logging
            table.insert(soldFishDetails, {
                name = fish.name,
                count = count,
                price = price
            })
            
            -- Remove fish from inventory
            xPlayer.removeInventoryItem(fish.item, count)
        end
    end
    
    if fishCount > 0 then
        -- Add money to player
        xPlayer.addMoney(totalEarnings)
        
        TriggerClientEvent('ardenhub_fishing:notify', source, 'Fish Market', 
            string.format(Config.Notifications.soldFish, fishCount, totalEarnings), 
            3000, 'success', true)
            
        if Config.Webhooks.enabled then
            local playerName = GetPlayerName(source)
            local message = "**" .. playerName .. "** (ID: " .. source .. ") sold " .. fishCount .. " fish for $" .. totalEarnings
            
            local fields = {}
            for _, fishDetail in ipairs(soldFishDetails) do
                table.insert(fields, {
                    ["name"] = fishDetail.name,
                    ["value"] = fishDetail.count .. " x $" .. math.floor(fishDetail.price / fishDetail.count) .. " = $" .. fishDetail.price,
                    ["inline"] = true
                })
            end
            
            SendDiscordWebhook(Config.Webhooks.selling, message, fields)
        end
    else
        TriggerClientEvent('ardenhub_fishing:notify', source, 'Fish Market', 
            Config.Notifications.noFishToSell, 
            3000, 'error', true)
    end
end)

-- Buy item event
RegisterServerEvent('ardenhub_fishing:buyItem')
AddEventHandler('ardenhub_fishing:buyItem', function(itemName, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Check if player has enough money
    if xPlayer.getMoney() >= price then
        if xPlayer.canCarryItem(itemName, 1) then
            -- Remove money and add item
            xPlayer.removeMoney(price)
            xPlayer.addInventoryItem(itemName, 1)
            
            TriggerClientEvent('ardenhub_fishing:notify', source, 'Fishing Shop', 
                'You bought an item for $' .. price, 
                3000, 'success', true)
                
            if Config.Webhooks.enabled then
                local playerName = GetPlayerName(source)
                local message = "**" .. playerName .. "** (ID: " .. source .. ") bought " .. itemName .. " for $" .. price
                
                local fields = {
                    {
                        ["name"] = "Item",
                        ["value"] = itemName,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Price",
                        ["value"] = "$" .. price,
                        ["inline"] = true
                    }
                }
                
                SendDiscordWebhook(Config.Webhooks.fishing, message, fields)
            end
        else
            TriggerClientEvent('ardenhub_fishing:notify', source, 'Fishing Shop', 
                Config.Notifications.inventoryFull, 
                3000, 'error', true)
        end
    else
        TriggerClientEvent('ardenhub_fishing:notify', source, 'Fishing Shop', 
            Config.Notifications.notEnoughMoney, 
            3000, 'error', true)
    end
end)