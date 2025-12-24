-- Account initialization és cleanup

Account.IsLoggedIn = false
Account.CurrentCharacter = nil
Account.SelectedSpawn = nil

-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Hide HUD initially
    DisplayHud(false)
    DisplayRadar(false)
    
    -- Trigger login check
    Citizen.SetTimeout(1000, function()
        TriggerServerEvent('ll-account:server:checkAuth')
    end)
end)

-- Player spawn
AddEventHandler('playerSpawned', function()
    if not Account.IsLoggedIn then
        -- Hide HUD
        DisplayHud(false)
        DisplayRadar(false)
        
        -- Freeze player
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
    end
end)

-- Resource stop - cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Cleanup
    Account.DestroyCamera()
    Account.DestroyCharacterPreview()
    Account.DestroyCreatorPed()
    
    -- Reset NUI
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'hideUI'})
    
    -- Show HUD
    DisplayHud(true)
    DisplayRadar(true)
    
    -- Unfreeze
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
end)

-- Emergency cleanup thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Check every 5 seconds
        
        if Account.IsLoggedIn and Account.CurrentCharacter then
            -- Ellenőrizzük, hogy tényleg spawned vagyunk
            local ped = PlayerPedId()
            
            -- Ha spawned vagyunk de még fagyva vagyunk, unfreezelünk
            if IsEntityPositionFrozen(ped) then
                FreezeEntityPosition(ped, false)
                SetPlayerInvincible(PlayerId(), false)
                DisplayHud(true)
                DisplayRadar(true)
                Account.Debug('Emergency unfreeze triggered')
            end
            
            -- NUI check
            if IsPauseMenuActive() then
                SetNuiFocus(false, false)
            end
        end
    end
end)

-- Disconnect kezelés
AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Pozíció mentése
    if Account.IsLoggedIn and Account.CurrentCharacter then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)
        
        TriggerServerEvent('ll-account:server:savePosition', {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading
        })
    end
end)

-- Halál kezelés
AddEventHandler('ll-core:client:playerDied', function()
    if not Account.IsLoggedIn then return end
    
    -- Death screen
    Account.Debug('Player died')
end)

-- Respawn kezelés
AddEventHandler('ll-core:client:playerRespawned', function(coords)
    if not Account.IsLoggedIn then return end
    
    local playerPed = PlayerPedId()
    
    if coords then
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(playerPed, coords.heading or 0.0)
    end
    
    Account.Debug('Player respawned')
end)

-- Session timeout (AFK kick)
if Config.Session.EnableTimeout then
    Citizen.CreateThread(function()
        local lastActivity = GetGameTimer()
        
        while true do
            Citizen.Wait(60000) -- Check every minute
            
            if Account.IsLoggedIn then
                local playerPed = PlayerPedId()
                local currentCoords = GetEntityCoords(playerPed)
                
                if Account.LastCoords then
                    local distance = #(currentCoords - Account.LastCoords)
                    
                    if distance > 1.0 then
                        lastActivity = GetGameTimer()
                    end
                end
                
                Account.LastCoords = currentCoords
                
                -- Check timeout
                if GetGameTimer() - lastActivity > (Config.Session.TimeoutMinutes * 60000) then
                    Account.Notify(_('afk_kick'), 'error', 10000)
                    Citizen.Wait(10000)
                    TriggerServerEvent('ll-account:server:afkKick')
                end
            end
        end
    end)
end

-- Controls disable menü alatt
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if not Account.IsLoggedIn then
            -- Disable all controls
            DisableAllControlActions(0)
            
            -- Enable csak az ESC menüt
            EnableControlAction(0, 322, true) -- ESC
            EnableControlAction(0, 288, true) -- F1
            EnableControlAction(0, 289, true) -- F2
        else
            Citizen.Wait(1000)
        end
    end
end)