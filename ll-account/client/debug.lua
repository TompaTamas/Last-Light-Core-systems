-- Debug commands

if Config.Debug then
    -- Force cleanup and spawn
    RegisterCommand('forcespawn', function()
        local playerPed = PlayerPedId()
        
        print('^3[DEBUG] Force spawn initiated^7')
        
        -- Cleanup
        SetNuiFocus(false, false)
        SendNUIMessage({action = 'hideUI'})
        
        Account.DestroyCamera()
        Account.DestroyCharacterPreview()
        Account.DestroyCreatorPed()
        
        -- Unfreeze
        FreezeEntityPosition(playerPed, false)
        SetPlayerInvincible(PlayerId(), false)
        SetEntityCollision(playerPed, true, true)
        SetEntityVisible(playerPed, true, false)
        SetEntityAlpha(playerPed, 255, false)
        ResetEntityAlpha(playerPed)
        
        -- Show HUD
        DisplayHud(true)
        DisplayRadar(true)
        
        -- Fade in
        DoScreenFadeIn(1000)
        
        -- Set state
        Account.IsLoggedIn = true
        Account.IsInCharacterSelection = false
        
        print('^2[DEBUG] Force spawned^7')
    end, false)
    
    -- Fix invisible
    RegisterCommand('fixinvis', function()
        local ped = PlayerPedId()
        
        SetEntityVisible(ped, true, false)
        SetEntityAlpha(ped, 255, false)
        ResetEntityAlpha(ped)
        
        print('^2[DEBUG] Visibility fixed^7')
    end, false)
    
    -- Check creator ped
    RegisterCommand('checkcreator', function()
        print('^3[DEBUG] Creator Ped Check:^7')
        
        if creatorPed and DoesEntityExist(creatorPed) then
            local coords = GetEntityCoords(creatorPed)
            local visible = IsEntityVisible(creatorPed)
            local alpha = GetEntityAlpha(creatorPed)
            local model = GetEntityModel(creatorPed)
            
            print('  Exists: ^2YES^7')
            print('  Visible: ' .. (visible and '^2YES^7' or '^1NO^7'))
            print('  Alpha: ' .. alpha)
            print('  Model: ' .. model)
            print('  Coords: ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
            
            -- Distance from player
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(coords - playerCoords)
            print('  Distance from player: ' .. string.format('%.2f', distance) .. 'm')
        else
            print('  ^1Creator ped does NOT exist!^7')
        end
        
        -- Camera check
        if creatorCam and DoesCamExist(creatorCam) then
            print('  Camera: ^2Active^7')
            local camActive = IsCamActive(creatorCam)
            print('  Camera rendering: ' .. (camActive and '^2YES^7' or '^1NO^7'))
        else
            print('  Camera: ^1Not created^7')
        end
    end, false)
    
    -- Toggle NUI visibility (debug)
    RegisterCommand('togglenui', function()
        SendNUIMessage({
            action = 'setVisible',
            visible = false
        })
        SetNuiFocus(false, false)
        
        print('^2[DEBUG] NUI hidden - you should see the ped now^7')
        
        Citizen.SetTimeout(5000, function()
            SendNUIMessage({
                action = 'setVisible',
                visible = true
            })
            SetNuiFocus(true, true)
            print('^3[DEBUG] NUI restored^7')
        end)
    end, false)
    
    -- Show only ped (hide NUI completely)
    RegisterCommand('showped', function()
        SendNUIMessage({
            action = 'setVisible',
            visible = false
        })
        SetNuiFocus(false, false)
        print('^2[DEBUG] NUI hidden - ped should be visible^7')
    end, false)
    
    -- Show NUI back
    RegisterCommand('shownui', function()
        SendNUIMessage({
            action = 'setVisible',
            visible = true
        })
        SetNuiFocus(true, true)
        print('^2[DEBUG] NUI shown^7')
    end, false)
    
    -- Reopen menu
    RegisterCommand('accountmenu', function()
        Account.IsLoggedIn = false
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'showLogin'
        })
        
        DisplayHud(false)
        DisplayRadar(false)
        
        print('^2[DEBUG] Account menu reopened^7')
    end, false)
    
    -- Toggle NUI focus
    RegisterCommand('nuifocus', function(source, args)
        local state = args[1] == 'true'
        SetNuiFocus(state, state)
        print('^2[DEBUG] NUI Focus: ' .. tostring(state) .. '^7')
    end, false)
    
    -- Check state
    RegisterCommand('accountstate', function()
        print('^3[DEBUG] Account State:^7')
        print('  IsLoggedIn: ' .. tostring(Account.IsLoggedIn))
        print('  CurrentCharacter: ' .. (Account.CurrentCharacter and Account.CurrentCharacter.firstname or 'nil'))
        print('  Camera: ' .. (Account.Camera and 'active' or 'nil'))
        print('  PreviewPed: ' .. (Account.PreviewPed and 'exists' or 'nil'))
        print('  CreatorPed: ' .. (Account.CreatorPed and 'exists' or 'nil'))
        
        local playerPed = PlayerPedId()
        print('  Frozen: ' .. tostring(IsEntityPositionFrozen(playerPed)))
        print('  Invincible: ' .. tostring(GetPlayerInvincible(PlayerId())))
    end, false)
    
    -- Reload character
    RegisterCommand('reloadchar', function()
        if Account.CurrentCharacter then
            TriggerEvent('ll-account:client:spawnCharacter', Account.CurrentCharacter)
            print('^2[DEBUG] Character reloaded^7')
        else
            print('^1[DEBUG] No character loaded^7')
        end
    end, false)
    
    -- Test notification
    RegisterCommand('testnotify', function()
        Account.Notify('Test notification', 'success', 5000)
    end, false)
end

-- ESC to close (emergency)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if not Account.IsLoggedIn and IsControlJustPressed(0, 322) then -- ESC
            -- Emergency cleanup
            SetNuiFocus(false, false)
            
            if Config.Debug then
                print('^1[EMERGENCY] ESC pressed - forcing cleanup^7')
            end
        end
    end
end)