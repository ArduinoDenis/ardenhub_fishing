local ESX = exports["es_extended"]:getSharedObject()
local isFishing = false
local currentZone = nil

-- Create blips for fishing areas
Citizen.CreateThread(function()
    for i, zone in ipairs(Config.FishingZones) do
        if zone.blip then
            local blip = AddBlipForCoord(zone.coords)
            SetBlipSprite(blip, zone.blip.sprite)
            SetBlipColour(blip, zone.blip.color)
            SetBlipScale(blip, zone.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    -- Create blip for fish vendor
    local sellerBlip = AddBlipForCoord(Config.FishSeller.coords.x, Config.FishSeller.coords.y, Config.FishSeller.coords.z)
    SetBlipSprite(sellerBlip, Config.FishSeller.blip.sprite)
    SetBlipColour(sellerBlip, Config.FishSeller.blip.color)
    SetBlipScale(sellerBlip, Config.FishSeller.blip.scale)
    SetBlipAsShortRange(sellerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.FishSeller.blip.label)
    EndTextCommandSetBlipName(sellerBlip)
    
    -- Create blip for the fishing store
    local shopBlip = AddBlipForCoord(Config.FishingShop.coords.x, Config.FishingShop.coords.y, Config.FishingShop.coords.z)
    SetBlipSprite(shopBlip, Config.FishingShop.blip.sprite)
    SetBlipColour(shopBlip, Config.FishingShop.blip.color)
    SetBlipScale(shopBlip, Config.FishingShop.blip.scale)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.FishingShop.blip.label)
    EndTextCommandSetBlipName(shopBlip)
end)

-- Create markers for fishing areas
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isNearZone = false
        
        for i, zone in ipairs(Config.FishingZones) do
            local distance = #(playerCoords - zone.coords)
            if distance < 100.0 then
                isNearZone = true
                DrawMarker(1, -- type the marker
                    zone.coords.x, zone.coords.y, zone.coords.z - 0.5, -- Position
                    0.0, 0.0, 0.0, -- Direction
                    0.0, 0.0, 0.0, -- Rotation
                    zone.radius * 2.0, zone.radius * 2.0, 1.0, -- Scale
                    30, 144, 255, 100, -- Color
                    false, false, 2, nil, nil, false)
                
                DrawMarker(6, -- type the marker
                    zone.coords.x, zone.coords.y, zone.coords.z + 1.0, -- Position
                    0.0, 0.0, 0.0, -- Direction
                    270.0, 0.0, 0.0, -- Rotation
                    1.5, 1.5, 1.5, -- Scale
                    0, 255, 255, 200, -- Color
                    false, true, 2, nil, nil, false)
                
                -- Add 3D text to indicate the fishing area
                if distance < 50.0 then
                    DrawText3D(zone.coords.x, zone.coords.y, zone.coords.z + 1.5, "~b~Zona di Pesca~w~\nPremi ~y~E~w~ per pescare")
                end
            end
        end
        if not isNearZone then
            Citizen.Wait(1000)
        end
    end
end)

-- Funzione per disegnare testo 3D nel mondo
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.35
    
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Checks whether the player is in a fishing zone.
function IsInFishingZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for i, zone in ipairs(Config.FishingZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            currentZone = zone
            return true
        end
    end
    currentZone = nil
    return false
end

-- Function to start fishing
function StartFishing()
    if isFishing then return end
    
    ESX.TriggerServerCallback('ardenhub_fishing:hasItems', function(hasRod, hasBait)
        if not hasRod then
            lib.notify({
                title = 'Fishing',
                description = Config.Notifications.noRod,
                type = 'error'
            })
            return
        end
        
        if not hasBait then
            lib.notify({
                title = 'Fishing',
                description = Config.Notifications.noBait,
                type = 'error'
            })
            return
        end
        
        if not IsInFishingZone() then
            lib.notify({
                title = 'Fishing',
                description = Config.Notifications.notInZone,
                type = 'error'
            })
            return
        end
        
        -- Start fishing animation
        isFishing = true
        local playerPed = PlayerPedId()
        
        -- Request animation dictionary
        RequestAnimDict("amb@world_human_stand_fishing@idle_a")
        while not HasAnimDictLoaded("amb@world_human_stand_fishing@idle_a") do
            Citizen.Wait(100)
        end
        
        -- Create fishing rod object
        local x, y, z = table.unpack(GetEntityCoords(playerPed))
        local prop = CreateObject(GetHashKey("prop_fishing_rod_01"), x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        -- Run animation
        TaskPlayAnim(playerPed, "amb@world_human_stand_fishing@idle_a", "idle_c", 8.0, -8.0, -1, 1, 0, false, false, false)
        
        lib.notify({
            title = 'Fishing',
            description = Config.Notifications.startFishing,
            type = 'info'
        })
        
        -- Bait remover
        TriggerServerEvent('ardenhub_fishing:removeBait')
        
        -- Skill control using ox_lib
        local success = lib.skillCheck(Config.SkillCheckDifficulty)
        
        if success then
            TriggerServerEvent('ardenhub_fishing:catchFish')
        else
            lib.notify({
                title = 'Fishing',
                description = Config.Notifications.failedCatch,
                type = 'error'
            })
        end
    end)
end

-- Create NPC fish seller
Citizen.CreateThread(function()
    local hash = GetHashKey(Config.FishSeller.model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(1)
    end
    
    local npc = CreatePed(4, hash, Config.FishSeller.coords.x, Config.FishSeller.coords.y, Config.FishSeller.coords.z - 1.0, Config.FishSeller.coords.w, false, true)
    SetEntityHeading(npc, Config.FishSeller.coords.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    -- Add interaction with ox_target
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'sell_fish',
            icon = 'fas fa-fish',
            label = 'Vendita di Pesce',
            onSelect = function()
                TriggerServerEvent('ardenhub_fishing:sellFish')
            end
        }
    })
end)

-- Create NPC fishing store
Citizen.CreateThread(function()
    local hash = GetHashKey(Config.FishingShop.model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(1)
    end
    
    local npc = CreatePed(4, hash, Config.FishingShop.coords.x, Config.FishingShop.coords.y, Config.FishingShop.coords.z - 1.0, Config.FishingShop.coords.w, false, true)
    SetEntityHeading(npc, Config.FishingShop.coords.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    -- Add interaction with ox_target
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'buy_fishing_gear',
            icon = 'fas fa-shopping-basket',
            label = 'Negozio di Pesca',
            onSelect = function()
                OpenFishingShop()
            end
        }
    })
end)

-- Record command to start fishing
RegisterCommand('fish', function()
    StartFishing()
end, false)

-- Register key with ox_lib
lib.addKeybind({
    name = 'start_fishing',
    description = 'Inizia a Pescare',
    defaultKey = 'E',
    onPressed = function()
        if IsInFishingZone() and not isFishing then
            StartFishing()
        end
    end
})

-- Function to open the fishing store
function OpenFishingShop()
    local options = {}
    
    for i, item in ipairs(Config.FishingShop.items) do
        table.insert(options, {
            title = item.label,
            description = 'Prezzo: $' .. item.price,
            icon = item.icon,
            onSelect = function()
                TriggerServerEvent('ardenhub_fishing:buyItem', item.name, item.price)
            end
        })
    end
    
    lib.registerContext({
        id = 'fishing_shop_menu',
        title = 'Negozio di Pesca',
        options = options
    })
    
    lib.showContext('fishing_shop_menu')
end

-- Event handler for notifications from the server
RegisterNetEvent('ardenhub_fishing:notify')
AddEventHandler('ardenhub_fishing:notify', function(title, message, duration, type)
    lib.notify({
        title = title,
        description = message,
        type = type,
        duration = duration
    })
end)