-- ═══════════════════════════════════════════════════════════
-- ARDENHUB FISHING - CLIENT
-- ═══════════════════════════════════════════════════════════

local ESX = exports["es_extended"]:getSharedObject()
local isFishing = false
local currentZone = nil
local lastFishingTime = 0
local fishingProp = nil

-- ═══════════════════════════════════════════════════════════
-- INIZIALIZZAZIONE BLIPS
-- ═══════════════════════════════════════════════════════════
CreateThread(function()
    
    for _, zone in ipairs(Config.FishingZones) do
        if zone.blip and zone.blip.enabled then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite)
            SetBlipColour(blip, zone.blip.color)
            SetBlipScale(blip, zone.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    
    if Config.FishSeller.blip.enabled then
        local sellerBlip = AddBlipForCoord(Config.FishSeller.coords.x, Config.FishSeller.coords.y, Config.FishSeller.coords.z)
        SetBlipSprite(sellerBlip, Config.FishSeller.blip.sprite)
        SetBlipColour(sellerBlip, Config.FishSeller.blip.color)
        SetBlipScale(sellerBlip, Config.FishSeller.blip.scale)
        SetBlipAsShortRange(sellerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.FishSeller.blip.label)
        EndTextCommandSetBlipName(sellerBlip)
    end
    
   
    if Config.FishingShop.blip.enabled then
        local shopBlip = AddBlipForCoord(Config.FishingShop.coords.x, Config.FishingShop.coords.y, Config.FishingShop.coords.z)
        SetBlipSprite(shopBlip, Config.FishingShop.blip.sprite)
        SetBlipColour(shopBlip, Config.FishingShop.blip.color)
        SetBlipScale(shopBlip, Config.FishingShop.blip.scale)
        SetBlipAsShortRange(shopBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.FishingShop.blip.label)
        EndTextCommandSetBlipName(shopBlip)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- MARKERS ZONE DI PESCA
-- ═══════════════════════════════════════════════════════════
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, zone in ipairs(Config.FishingZones) do
            local distance = #(playerCoords - zone.coords)
            
            if distance < 100.0 then
                sleep = 0
                
                
                DrawMarker(1, 
                    zone.coords.x, zone.coords.y, zone.coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    zone.radius * 2.0, zone.radius * 2.0, 1.0,
                    52, 152, 219, 80,
                    false, false, 2, nil, nil, false
                )
                
                
                if distance < zone.radius then
                    DrawText3D(zone.coords.x, zone.coords.y, zone.coords.z + 1.0, 
                        "~b~" .. zone.name .. "~w~\nPremi ~g~[E]~w~ per pescare")
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FUNZIONI UTILITY
-- ═══════════════════════════════════════════════════════════
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = #(camCoords - vector3(x, y, z))
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function IsInFishingZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, zone in ipairs(Config.FishingZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            currentZone = zone
            return true
        end
    end
    
    currentZone = nil
    return false
end

function CanFish()
    local currentTime = GetGameTimer()
    if currentTime - lastFishingTime < Config.Fishing.cooldown then
        return false, Config.Notifications.cooldown
    end
    return true, nil
end

-- ═══════════════════════════════════════════════════════════
-- FUNZIONE PRINCIPALE PESCA
-- ═══════════════════════════════════════════════════════════
function StartFishing()
    if isFishing then
        lib.notify({
            title = 'Pesca',
            description = Config.Notifications.alreadyFishing,
            type = 'error'
        })
        return
    end
    
    local canFish, errorMsg = CanFish()
    if not canFish then
        lib.notify({
            title = 'Pesca',
            description = errorMsg,
            type = 'error'
        })
        return
    end
    
    if not IsInFishingZone() then
        lib.notify({
            title = 'Pesca',
            description = Config.Notifications.notInZone,
            type = 'error'
        })
        return
    end
    
    ESX.TriggerServerCallback('ardenhub_fishing:checkItems', function(hasRod, hasBait)
        if not hasRod then
            lib.notify({
                title = 'Pesca',
                description = Config.Notifications.noRod,
                type = 'error'
            })
            return
        end
        
        if not hasBait then
            lib.notify({
                title = 'Pesca',
                description = Config.Notifications.noBait,
                type = 'error'
            })
            return
        end
        
        isFishing = true
        lastFishingTime = GetGameTimer()
        local playerPed = PlayerPedId()
        
        RequestAnimDict(Config.Fishing.animation.dict)
        while not HasAnimDictLoaded(Config.Fishing.animation.dict) do
            Wait(10)
        end
        
        local propModel = GetHashKey(Config.Fishing.prop.model)
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(10)
        end
        
        local coords = GetEntityCoords(playerPed)
        fishingProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(
            fishingProp, playerPed, 
            GetPedBoneIndex(playerPed, Config.Fishing.prop.bone),
            Config.Fishing.prop.offset.x, Config.Fishing.prop.offset.y, Config.Fishing.prop.offset.z,
            Config.Fishing.prop.rotation.x, Config.Fishing.prop.rotation.y, Config.Fishing.prop.rotation.z,
            true, true, false, true, 1, true
        )
        
        TaskPlayAnim(playerPed, Config.Fishing.animation.dict, Config.Fishing.animation.anim, 
            8.0, -8.0, -1, Config.Fishing.animation.flag, 0, false, false, false)
        
        lib.notify({
            title = 'Pesca',
            description = Config.Notifications.startFishing,
            type = 'info'
        })
        
        
        local waitTime = math.random(Config.Fishing.waitTime.min, Config.Fishing.waitTime.max)
        Wait(waitTime)
        
        
        local success = lib.skillCheck(Config.Fishing.skillCheck.difficulty, Config.Fishing.skillCheck.inputs)
        
      
        ClearPedTasks(playerPed)
        if DoesEntityExist(fishingProp) then
            DeleteObject(fishingProp)
            fishingProp = nil
        end
        
        isFishing = false
        
        if success then
            TriggerServerEvent('ardenhub_fishing:catchFish', currentZone.rarityBonus)
        else
            lib.notify({
                title = 'Pesca',
                description = Config.Notifications.failedCatch,
                type = 'error'
            })
            TriggerServerEvent('ardenhub_fishing:consumeBait')
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- KEYBIND PESCA
-- ═══════════════════════════════════════════════════════════
lib.addKeybind({
    name = 'start_fishing',
    description = 'Inizia a pescare',
    defaultKey = 'E',
    onPressed = function()
        if IsInFishingZone() and not isFishing then
            StartFishing()
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- NPC VENDITORE PESCE
-- ═══════════════════════════════════════════════════════════
CreateThread(function()
    local modelHash = GetHashKey(Config.FishSeller.model)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    local npc = CreatePed(4, modelHash, 
        Config.FishSeller.coords.x, 
        Config.FishSeller.coords.y, 
        Config.FishSeller.coords.z - 1.0, 
        Config.FishSeller.coords.w, 
        false, true)
    
    SetEntityHeading(npc, Config.FishSeller.coords.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'sell_fish',
            icon = 'fas fa-fish',
            label = 'Vendi Pesce',
            onSelect = function()
                TriggerServerEvent('ardenhub_fishing:sellFish')
            end
        }
    })
end)

-- ═══════════════════════════════════════════════════════════
-- NPC NEGOZIO PESCA
-- ═══════════════════════════════════════════════════════════
CreateThread(function()
    local modelHash = GetHashKey(Config.FishingShop.model)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    local npc = CreatePed(4, modelHash, 
        Config.FishingShop.coords.x, 
        Config.FishingShop.coords.y, 
        Config.FishingShop.coords.z - 1.0, 
        Config.FishingShop.coords.w, 
        false, true)
    
    SetEntityHeading(npc, Config.FishingShop.coords.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'fishing_shop',
            icon = 'fas fa-store',
            label = 'Apri Negozio',
            onSelect = function()
                OpenFishingShop()
            end
        }
    })
end)

-- ═══════════════════════════════════════════════════════════
-- MENU NEGOZIO PESCA
-- ═══════════════════════════════════════════════════════════
function OpenFishingShop()
    local options = {}
    
    for _, item in ipairs(Config.FishingShop.items) do
        table.insert(options, {
            title = item.label,
            description = 'Prezzo: $' .. item.price,
            icon = item.icon,
            onSelect = function()
                local amount = item.amount or 1
                TriggerServerEvent('ardenhub_fishing:buyItem', item.name, item.price, amount)
            end
        })
    end
    
    lib.registerContext({
        id = 'fishing_shop',
        title = '🏪 Negozio di Pesca',
        options = options
    })
    
    lib.showContext('fishing_shop')
end

-- ═══════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if DoesEntityExist(fishingProp) then
        DeleteObject(fishingProp)
    end
    
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end)
