-- Karakterválasztó megjelenítése
RegisterNetEvent('ll-account:client:showCharacterSelect', function()
    Account.Debug('Show character select event received')
    
    -- Karakterek lekérése szerverről
    TriggerServerEvent('ll-account:server:getCharacters')
end)

-- Karakterek betöltése
RegisterNetEvent('ll-account:client:loadCharacters', function(characters)
    Account.Debug('Received ' .. #characters .. ' characters from server')
    
    -- Player freeze
    Account.FreezePlayer(true)
    
    -- Screen fade
    Account.FadeScreen(true, 500)
    
    Citizen.Wait(500)
    
    -- Karakterválasztó megnyitása
    Account.OpenCharacterSelection(characters)
    
    -- Screen fade in
    Account.FadeScreen(false, 500)
end)

-- Regisztrációs képernyő megjelenítése
RegisterNetEvent('ll-account:client:showRegistration', function()
    Account.Debug('Show registration event received')
    
    -- Player freeze
    Account.FreezePlayer(true)
    
    -- Karakter kreátor megnyitása azonnal
    Account.ShowUI(true)
    
    Citizen.SetTimeout(500, function()
        Account.OpenCharacterCreator()
        
        -- Creator ped létrehozása
        Citizen.SetTimeout(1000, function()
            Account.CreateCreatorPed('m')
        end)
    end)
end)

-- NUI Callback-ek
-- Karakter kiválasztása
RegisterNUICallback('selectCharacter', function(data, cb)
    Account.Debug('Character selected: ' .. data.charid)
    
    -- UI bezárása
    Account.ShowUI(false)
    Account.DestroyCamera()
    
    -- Kamera fade
    Account.FadeScreen(true, 1000)
    
    -- Karakter betöltése
    TriggerServerEvent('ll-account:server:selectCharacter', data.charid)
    
    cb('ok')
end)

-- Karakter létrehozása
RegisterNUICallback('createCharacter', function(data, cb)
    Account.Debug('Creating character: ' .. data.firstname .. ' ' .. data.lastname)
    
    -- Validáció client oldalon
    local valid, error = Account.ValidateName(data.firstname)
    if not valid then
        cb({success = false, error = error})
        return
    end
    
    valid, error = Account.ValidateName(data.lastname)
    if not valid then
        cb({success = false, error = error})
        return
    end
    
    valid, error = Account.ValidateDateOfBirth(data.dateofbirth)
    if not valid then
        cb({success = false, error = error})
        return
    end
    
    valid, error = Account.ValidateHeight(data.height)
    if not valid then
        cb({success = false, error = error})
        return
    end
    
    -- Szerver validáció és létrehozás
    TriggerServerEvent('ll-account:server:createCharacter', data)
    
    cb({success = true})
end)

-- Karakter törölése
RegisterNUICallback('deleteCharacter', function(data, cb)
    Account.Debug('Deleting character: ' .. data.charid)
    
    if Config.Character.DeleteConfirmation then
        -- Megerősítés (NUI-ban van kezelve)
        TriggerServerEvent('ll-account:server:deleteCharacter', data.charid)
    end
    
    cb('ok')
end)

-- Karakter törlés sikeres
RegisterNetEvent('ll-account:client:characterDeleted', function()
    Account.Notify(_('character_deleted'), 'success')
    
    -- Karakterlista frissítése
    TriggerServerEvent('ll-account:server:getCharacters')
end)

-- Karakter létrehozás sikeres
RegisterNetEvent('ll-account:client:characterCreated', function(charid)
    Account.Debug('Character created successfully: ' .. charid)
    
    Account.Notify(_('character_created'), 'success')
    
    -- UI bezárása
    Account.ShowUI(false)
    
    -- Fade
    Account.FadeScreen(true, 1000)
    
    -- Karakter betöltése
    TriggerServerEvent('ll-account:server:selectCharacter', charid)
end)

-- Karakter betöltés hiba
RegisterNetEvent('ll-account:client:error', function(message)
    Account.Notify(message, 'error', 7000)
end)

-- NUI bezárás
RegisterNUICallback('close', function(data, cb)
    Account.ShowUI(false)
    Account.DestroyCamera()
    cb('ok')
end)

-- ESC gomb kezelés (bezárás megakadályozása)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if Account.IsInCharacterSelection then
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 200, true) -- ESC (2)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Discord Rich Presence
if Config.DiscordRichPresence.Enable then
    Citizen.CreateThread(function()
        while Account.IsInCharacterSelection do
            Citizen.Wait(1000)
            
            SetDiscordAppId(Config.DiscordRichPresence.ApplicationId)
            SetDiscordRichPresenceAsset(Config.DiscordRichPresence.LargeImage)
            SetDiscordRichPresenceAssetText(Config.DiscordRichPresence.LargeText)
            SetDiscordRichPresenceAssetSmall(Config.DiscordRichPresence.SmallImage)
            SetDiscordRichPresenceAssetSmallText(Config.DiscordRichPresence.SmallText)
        end
    end)
end