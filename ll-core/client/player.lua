-- Játékos spawn kezelése
RegisterNetEvent('ll-core:client:spawnPlayer', function(coords, heading)
    local ped = PlayerPedId()
    
    -- Screen fade
    LL.FadeScreen(true, 500)
    
    Citizen.Wait(500)
    
    -- Spawn beállítások
    if coords then
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(ped, heading or 0.0)
    else
        -- Alapértelmezett spawn
        local spawn = Config.DefaultSpawn
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        SetEntityHeading(ped, spawn.w)
    end
    
    -- Freeze player rövid időre
    FreezeEntityPosition(ped, true)
    
    Citizen.Wait(500)
    
    -- Screen fade vissza
    LL.FadeScreen(false, 500)
    
    Citizen.Wait(500)
    
    -- Unfreeze
    FreezeEntityPosition(ped, false)
    
    -- Spawn védelem aktiválása
    if Config.SpawnProtection and Config.SpawnProtection > 0 then
        LL.ApplySpawnProtection(Config.SpawnProtection)
    end
    
    -- Notify
    LL.Notify(_('spawning'), 'success')
    
    -- Trigger event
    TriggerEvent('ll-core:playerSpawned')
end)

-- Karakter betöltése
RegisterNetEvent('ll-core:client:loadCharacter', function(characterData)
    LL.Debug('Loading character data...')
    
    local ped = PlayerPedId()
    
    -- Játékos adatok beállítása
    LL.PlayerData = characterData
    LL.PlayerLoaded = true
    
    -- HP és Armor beállítása
    if characterData.health then
        SetEntityHealth(ped, characterData.health)
    end
    
    if characterData.armor then
        SetPedArmour(ped, characterData.armor)
    end
    
    -- Pozíció betöltése
    if characterData.position then
        local pos = json.decode(characterData.position)
        SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, true)
        SetEntityHeading(ped, pos.heading or 0.0)
    end
    
    LL.Notify(_('character_loaded'), 'success')
    
    -- Trigger event más resource-oknak
    TriggerEvent('ll-core:characterLoaded', characterData)
end)

-- Játékos adat mentése
RegisterNetEvent('ll-core:client:savePlayer', function()
    if not LL.PlayerLoaded then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local data = {
        position = json.encode({
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading
        }),
        health = GetEntityHealth(ped),
        armor = GetPedArmour(ped)
    }
    
    TriggerServerEvent('ll-core:server:updatePlayerData', data)
end)

-- Autómatikus mentés
if Config.Player.SaveInterval and Config.Player.SaveInterval > 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.Player.SaveInterval)
            
            if LL.PlayerLoaded then
                TriggerEvent('ll-core:client:savePlayer')
                LL.Debug('Auto-save triggered')
            end
        end
    end)
end

-- Játékos kilépéskor mentés
AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and LL.PlayerLoaded then
        -- Szinkron mentés kilépéskor
        TriggerServerEvent('ll-core:server:savePlayer')
    end
end)

-- PVP toggle (későbbi implementáció)
RegisterNetEvent('ll-core:client:togglePVP', function(enabled)
    SetCanAttackFriendly(PlayerPedId(), enabled, false)
    NetworkSetFriendlyFireOption(enabled)
end)

-- God mode toggle (admin)
RegisterNetEvent('ll-core:client:setGodMode', function(enabled)
    SetEntityInvincible(PlayerPedId(), enabled)
    
    if enabled then
        LL.Notify('God mode aktiválva', 'success')
    else
        LL.Notify('God mode kikapcsolva', 'error')
    end
end)

-- Invisible toggle (admin)
RegisterNetEvent('ll-core:client:setInvisible', function(enabled)
    SetEntityVisible(PlayerPedId(), not enabled, false)
    
    if enabled then
        LL.Notify('Láthatatlanság aktiválva', 'success')
    else
        LL.Notify('Láthatatlanság kikapcsolva', 'error')
    end
end)

-- Teleport
RegisterCommand('tpm', function()
    if LL.IsAdmin() then
        local waypoint = GetFirstBlipInfoId(8)
        
        if DoesBlipExist(waypoint) then
            local coords = GetBlipInfoIdCoord(waypoint)
            local ped = PlayerPedId()
            
            -- Ground Z-level keresése
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            
            if found then
                SetEntityCoords(ped, coords.x, coords.y, groundZ, false, false, false, true)
                LL.Notify(_('teleported'), 'success')
            else
                SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
                LL.Notify(_('teleported'), 'success')
            end
        else
            LL.Notify('Jelölj ki egy waypoint-ot a térképen!', 'error')
        end
    else
        LL.Notify(_('no_permission'), 'error')
    end
end)