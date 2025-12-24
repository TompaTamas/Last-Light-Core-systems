-- Spawn kiválasztás és kezelés

-- Spawn választó megnyitása
RegisterNUICallback('selectSpawn', function(data, cb)
    Account.Debug('Spawn selection opened')
    
    -- Config küldése
    SendNUIMessage({
        action = 'showSpawnSelector',
        spawns = Config.Spawn.NewCharacterSpawns
    })
    
    cb('ok')
end)

-- Spawn megerősítése
RegisterNUICallback('confirmSpawn', function(data, cb)
    Account.Debug('Spawn confirmed: ' .. tostring(data.spawnIndex))
    
    local spawnIndex = tonumber(data.spawnIndex)
    if not spawnIndex then
        cb({success = false, error = 'Invalid spawn index'})
        return
    end
    
    -- +1 mert JS 0-based index
    local actualIndex = spawnIndex + 1
    local spawnData = Config.Spawn.NewCharacterSpawns[actualIndex]
    
    if not spawnData then
        Account.Debug('Spawn not found at index: ' .. actualIndex)
        cb({success = false, error = 'Invalid spawn location'})
        return
    end
    
    -- Spawn koordináták tárolása karakterhez
    Account.SelectedSpawn = spawnData.coords
    
    Account.Debug('Spawn selected: ' .. spawnData.label .. ' at ' .. tostring(spawnData.coords))
    
    cb({success = true})
end)

-- Karakter spawn (betöltés után)
RegisterNetEvent('ll-account:client:spawnCharacter', function(characterData)
    Account.Debug('Spawning character: ' .. characterData.firstname)
    
    -- NUI fade out animáció
    SendNUIMessage({
        action = 'fadeOut'
    })
    
    -- Várunk az animációra
    Citizen.Wait(1000)
    
    -- MOST bezárjuk az NUI-t
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideUI'
    })
    
    -- Fade out
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    
    -- Teljes cleanup
    RenderScriptCams(false, false, 0, true, true)
    
    -- Camera destroy
    if Account.CurrentCamera and DoesCamExist(Account.CurrentCamera) then
        DestroyCam(Account.CurrentCamera, false)
        Account.CurrentCamera = nil
    end
    
    -- Spawn pozíció
    local spawnCoords
    
    if Config.Spawn.UseLastPosition and characterData.position then
        -- Utolsó pozíció
        local success, pos = pcall(json.decode, characterData.position)
        if success and pos and pos.x and pos.y and pos.z then
            spawnCoords = vector4(tonumber(pos.x), tonumber(pos.y), tonumber(pos.z), tonumber(pos.heading or 0.0))
        else
            spawnCoords = Config.Spawn.DefaultSpawn
        end
    elseif Account.SelectedSpawn then
        -- Kiválasztott spawn (új karakter)
        spawnCoords = Account.SelectedSpawn
    else
        -- Alapértelmezett spawn
        spawnCoords = Config.Spawn.DefaultSpawn
    end
    
    -- Model beállítás ELŐSZÖR
    local model = characterData.sex == 'm' and GetHashKey(Config.Creator.Gender.Male) or GetHashKey(Config.Creator.Gender.Female)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    Citizen.Wait(500) -- Várunk hogy a model teljesen betöltődjön
    
    local playerPed = PlayerPedId()
    
    -- KRITIKUS: Entity beállítások
    SetEntityAsMissionEntity(playerPed, true, true)
    SetPedCanRagdoll(playerPed, true)
    
    -- Collision betöltése
    RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    
    -- Teleport
    SetEntityCoordsNoOffset(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
    SetEntityHeading(playerPed, spawnCoords.w or 0.0)
    
    -- Várunk a collision-re
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(playerPed) and timeout < 3000 do
        Citizen.Wait(10)
        timeout = timeout + 10
        RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    end
    
    -- Megjelenés betöltése
    Citizen.Wait(200)
    
    if characterData.skin and characterData.skin ~= '' and characterData.skin ~= '{}' then
        local success, skin = pcall(json.decode, characterData.skin)
        
        -- ll-skin integration
        if success and skin and GetResourceState('ll-skin') == 'started' then
            Citizen.Wait(200)
            exports['ll-skin']:ApplySkin(skin)
        else
            -- Alap ruhák átmeneti
            local clothes = characterData.sex == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
            
            SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
            SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
            SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
            SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
        end
    else
        -- Ha nincs skin, alap ruhák MINDENKÉPP
        local clothes = characterData.sex == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
        
        SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
        SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
        SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
        SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
    end
    
    Citizen.Wait(500)
    
    -- KRITIKUS: Láthatóság FIX (ez oldja meg a problémát!)
    SetEntityVisible(playerPed, true, false)
    SetEntityAlpha(playerPed, 255, false)
    ResetEntityAlpha(playerPed)
    SetPedDefaultComponentVariation(playerPed)
    
    -- Player unfreeze
    FreezeEntityPosition(playerPed, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityCollision(playerPed, true, true)
    
    -- Network
    NetworkSetEntityInvisibleToNetwork(playerPed, false)
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(playerPed), true)
    
    -- HUD megjelenítése
    DisplayHud(true)
    DisplayRadar(true)
    
    -- Account state
    Account.IsLoggedIn = true
    Account.IsInCharacterSelection = false
    Account.CurrentCharacter = characterData
    
    Citizen.Wait(500)
    
    -- Fade in
    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do
        Citizen.Wait(10)
    end
    
    -- Notify
    Account.Notify(_('character_loaded', characterData.firstname .. ' ' .. characterData.lastname), 'success', 5000)
    
    -- Kezdő csomag (ha új karakter)
    if characterData.is_new then
        Citizen.SetTimeout(2000, function()
            Account.GiveStartingKit()
            
            -- Tutorial
            if Config.Tutorial and Config.Tutorial.Enable and Config.Tutorial.ShowForNewPlayers then
                Citizen.SetTimeout(3000, function()
                    Account.ShowTutorial()
                end)
            end
        end)
    end
    
    -- Karakter betöltve trigger (ll-core-nak)
    TriggerEvent('ll-core:client:characterLoaded', characterData)
    TriggerServerEvent('ll-account:server:characterSpawned', characterData.id)
    
    Account.Debug('Character spawned successfully - IN GAME NOW')
end)

-- Kezdő csomag kiosztása
function Account.GiveStartingKit()
    if not Config.StartingKit or not Config.StartingKit.Enable then return end
    
    Account.Debug('Giving starting kit')
    
    -- Notify
    if GetResourceState('ll-notify') == 'started' then
        exports['ll-notify']:Info(_('starting_kit'), 5000, _('welcome_survivor'))
    end
    
    -- Kezdő itemek
    if Config.StartingKit.Items and #Config.StartingKit.Items > 0 then
        if GetResourceState('ll-inventory') == 'started' then
            for _, item in pairs(Config.StartingKit.Items) do
                TriggerServerEvent('ll-inventory:server:addItem', item.item, item.count)
                Account.Debug('Added item: ' .. item.item .. ' x' .. item.count)
            end
        end
    end
    
    -- Kezdő pénz (ll-core)
    if Config.StartingKit.Money then
        if Config.StartingKit.Money.cash and Config.StartingKit.Money.cash > 0 then
            TriggerServerEvent('ll-account:server:addStartingMoney', 'cash', Config.StartingKit.Money.cash)
            Account.Debug('Added cash: $' .. Config.StartingKit.Money.cash)
        end
        
        if Config.StartingKit.Money.bank and Config.StartingKit.Money.bank > 0 then
            TriggerServerEvent('ll-account:server:addStartingMoney', 'bank', Config.StartingKit.Money.bank)
            Account.Debug('Added bank: $' .. Config.StartingKit.Money.bank)
        end
    end
    
    -- Apokalipszis kezdő státuszok szerverhez
    if Config.StartingKit.ApocalypseStats then
        TriggerServerEvent('ll-account:server:setStartingStats', Config.StartingKit.ApocalypseStats)
    end
end