-- Spawn választás és kezelés (V2 - Creator SPAWN UTÁN)

-- Spawn választó megnyitása (karakter létrehozás után)
function Account.OpenSpawnSelector(characterData)
    Account.Debug('Opening spawn selector')
    
    -- Karakteradatok tárolása
    Account.PendingCharacter = characterData
    
    -- NUI-nak spawn lista küldése
    SendNUIMessage({
        action = 'showSpawnSelector',
        spawns = Config.Spawn.NewCharacterSpawns,
        character = {
            firstname = characterData.firstname,
            lastname = characterData.lastname,
            gender = characterData.gender
        }
    })
end

-- Spawn megerősítése (NUI callback)
RegisterNUICallback('confirmSpawn', function(data, cb)
    local spawnIndex = tonumber(data.spawnIndex)
    
    if not spawnIndex then
        Account.Debug('ERROR: Invalid spawn index: ' .. tostring(data.spawnIndex))
        cb({success = false, error = 'Invalid spawn index'})
        return
    end
    
    -- FONTOS: JavaScript 0-based, Lua 1-based
    local luaIndex = spawnIndex + 1
    
    Account.Debug('Spawn selected - JS index: ' .. spawnIndex .. ' | Lua index: ' .. luaIndex)
    
    local spawnData = Config.Spawn.NewCharacterSpawns[luaIndex]
    
    if not spawnData then
        Account.Debug('ERROR: Spawn not found at Lua index: ' .. luaIndex)
        Account.Debug('Available spawns: ' .. #Config.Spawn.NewCharacterSpawns)
        cb({success = false, error = 'Invalid spawn location'})
        return
    end
    
    Account.Debug('Spawn confirmed: ' .. spawnData.label)
    Account.Debug('Coords: ' .. spawnData.coords.x .. ', ' .. spawnData.coords.y .. ', ' .. spawnData.coords.z .. ', ' .. spawnData.coords.w)
    
    -- Spawn koordináták tárolása
    Account.SelectedSpawn = spawnData.coords
    
    -- NUI bezárása
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideUI'
    })
    
    -- Fade out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    
    Citizen.Wait(500)
    
    -- Először spawn-oljuk a karaktert az alap skin-nel
    -- UTÁNA nyitjuk meg a character creator-t
    Account.SpawnNewCharacter(Account.PendingCharacter, Account.SelectedSpawn)
    
    cb({success = true})
end)

-- Új karakter spawn (alap skin, MAJD creator)
function Account.SpawnNewCharacter(characterData, spawnCoords)
    Account.Debug('Spawning new character at location')
    
    -- Model beállítás
    local model = characterData.gender == 'm' and GetHashKey('mp_m_freemode_01') or GetHashKey('mp_f_freemode_01')
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    Citizen.Wait(500)
    
    local playerPed = PlayerPedId()
    
    -- Collision betöltése
    RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    
    -- Teleport
    SetEntityCoordsNoOffset(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
    SetEntityHeading(playerPed, spawnCoords.w or 0.0)
    
    -- Collision várakozás
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(playerPed) and timeout < 3000 do
        Citizen.Wait(10)
        timeout = timeout + 10
        RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    end
    
    -- Alap ruhák
    local clothes = characterData.gender == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
    
    SetPedComponentVariation(playerPed, 3, 15, 0, 0)
    SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
    SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
    SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
    SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
    
    -- Alapértelmezett heritage
    SetPedHeadBlendData(playerPed, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)
    
    Citizen.Wait(300)
    
    -- Láthatóság FIX
    SetEntityVisible(playerPed, true, false)
    SetEntityAlpha(playerPed, 255, false)
    ResetEntityAlpha(playerPed)
    
    -- Entity beállítások
    SetEntityAsMissionEntity(playerPed, true, true)
    SetPedCanRagdoll(playerPed, true)
    SetEntityCollision(playerPed, true, true)
    
    -- Network
    NetworkSetEntityInvisibleToNetwork(playerPed, false)
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(playerPed), true)
    
    -- HUD
    DisplayHud(true)
    DisplayRadar(true)
    
    -- State
    Account.IsLoggedIn = true
    Account.IsInCharacterSelection = false
    Account.CurrentCharacter = characterData
    
    -- Player UNFREEZE
    FreezeEntityPosition(playerPed, false)
    SetPlayerInvincible(PlayerId(), false)
    
    Citizen.Wait(500)
    
    -- Fade in
    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do
        Citizen.Wait(10)
    end
    
    -- Notify
    Account.Notify(_('character_loaded', characterData.firstname .. ' ' .. characterData.lastname), 'success', 5000)
    
    Account.Debug('Character spawned, opening ll-skin for customization')
    
    -- Most nyitjuk meg az ll-skin-t hogy szerkeszthesse a megjelenését
    Citizen.Wait(1000)
    
    if GetResourceState('ll-skin') == 'started' then
        -- ll-skin megnyitása
        exports['ll-skin']:OpenMenu()
        Account.Debug('ll-skin menu opened for new character')
    else
        Account.Debug('WARNING: ll-skin not started!')
        Account.Notify('You can customize your appearance later at a clothing shop', 'info', 5000)
        
        -- Karakter mentése alap skin-nel
        Account.FinalizeNewCharacter()
    end
end

-- ll-skin bezárás után finalizáljuk a karaktert
RegisterNetEvent('ll-skin:client:menuClosed', function(saved)
    if Account.CurrentCharacter and Account.CurrentCharacter.is_new then
        Account.Debug('ll-skin closed, finalizing character')
        Account.FinalizeNewCharacter()
    end
end)

-- Új karakter finalizálása (skin mentés után)
function Account.FinalizeNewCharacter()
    if not Account.CurrentCharacter or not Account.CurrentCharacter.is_new then
        return
    end
    
    Account.Debug('Finalizing new character')
    
    -- Jelenlegi skin lekérése
    local currentSkin = {}
    
    if GetResourceState('ll-skin') == 'started' then
        currentSkin = exports['ll-skin']:GetCurrentSkin()
    else
        -- Alap skin
        currentSkin = {
            model = Account.CurrentCharacter.gender == 'm' and 'mp_m_freemode_01' or 'mp_f_freemode_01',
            heritage = {mom = 0, dad = 0, similarity = 0.5, skin_similarity = 0.5},
            components = {},
            props = {}
        }
    end
    
    local skinJson = json.encode(currentSkin)
    
    -- Szervernek küldés véglegesítéshez
    TriggerServerEvent('ll-account:server:finalizeCharacter', Account.CurrentCharacter.id, skinJson)
    
    -- is_new flag törlése
    Account.CurrentCharacter.is_new = false
    
    -- Kezdő csomag
    Citizen.Wait(1000)
    Account.GiveStartingKit()
    
    -- Tutorial
    if Config.Tutorial and Config.Tutorial.Enable and Config.Tutorial.ShowForNewPlayers then
        Citizen.SetTimeout(3000, function()
            Account.ShowTutorial()
        end)
    end
    
    -- Events
    TriggerEvent('ll-core:client:characterLoaded', Account.CurrentCharacter)
    TriggerServerEvent('ll-account:server:characterSpawned', Account.CurrentCharacter.id)
    
    Account.Debug('New character finalized successfully')
end

-- Karakter spawn (meglévő karakter betöltése)
RegisterNetEvent('ll-account:client:spawnCharacter', function(characterData)
    Account.Debug('Spawning existing character: ' .. characterData.firstname)
    
    -- NUI fade out
    SendNUIMessage({
        action = 'fadeOut'
    })
    
    Citizen.Wait(1000)
    
    -- NUI bezárása
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideUI'
    })
    
    -- Fade out
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    
    -- Camera cleanup
    if Account.CurrentCamera and DoesCamExist(Account.CurrentCamera) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(Account.CurrentCamera, false)
        Account.CurrentCamera = nil
    end
    
    -- Spawn coords meghatározása
    local spawnCoords
    
    if Config.Spawn.UseLastPosition and characterData.position then
        -- Utolsó pozíció
        local success, pos = pcall(json.decode, characterData.position)
        if success and pos and pos.x and pos.y and pos.z then
            spawnCoords = vector4(tonumber(pos.x), tonumber(pos.y), tonumber(pos.z), tonumber(pos.heading or 0.0))
            Account.Debug('Using last position: ' .. spawnCoords.x .. ', ' .. spawnCoords.y .. ', ' .. spawnCoords.z)
        else
            spawnCoords = Config.Spawn.DefaultSpawn
            Account.Debug('Invalid position data, using default spawn')
        end
    else
        -- Alapértelmezett spawn
        spawnCoords = Config.Spawn.DefaultSpawn
        Account.Debug('Using default spawn')
    end
    
    -- Model beállítás
    local model = characterData.sex == 'm' and GetHashKey(Config.Creator.Gender.Male) or GetHashKey(Config.Creator.Gender.Female)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    Citizen.Wait(500)
    
    local playerPed = PlayerPedId()
    
    -- Entity setup
    SetEntityAsMissionEntity(playerPed, true, true)
    SetPedCanRagdoll(playerPed, true)
    
    -- Collision
    RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    
    -- Teleport
    SetEntityCoordsNoOffset(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
    SetEntityHeading(playerPed, spawnCoords.w or 0.0)
    
    -- Collision várakozás
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(playerPed) and timeout < 3000 do
        Citizen.Wait(10)
        timeout = timeout + 10
        RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    end
    
    -- Skin betöltése
    Citizen.Wait(200)
    
    if characterData.skin and characterData.skin ~= '' and characterData.skin ~= '{}' then
        local success, skin = pcall(json.decode, characterData.skin)
        
        if success and skin and GetResourceState('ll-skin') == 'started' then
            Citizen.Wait(200)
            exports['ll-skin']:ApplySkin(skin)
        else
            -- Alap ruhák fallback
            local clothes = characterData.sex == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
            
            SetPedComponentVariation(playerPed, 3, 15, 0, 0)
            SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
            SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
            SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
            SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
        end
    else
        -- Alap ruhák
        local clothes = characterData.sex == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
        
        SetPedComponentVariation(playerPed, 3, 15, 0, 0)
        SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
        SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
        SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
        SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
    end
    
    Citizen.Wait(500)
    
    -- Láthatóság FIX
    SetEntityVisible(playerPed, true, false)
    SetEntityAlpha(playerPed, 255, false)
    ResetEntityAlpha(playerPed)
    SetPedDefaultComponentVariation(playerPed)
    
    -- Unfreeze
    FreezeEntityPosition(playerPed, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityCollision(playerPed, true, true)
    
    -- Network
    NetworkSetEntityInvisibleToNetwork(playerPed, false)
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(playerPed), true)
    
    -- HUD
    DisplayHud(true)
    DisplayRadar(true)
    
    -- State
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
    
    -- Events
    TriggerEvent('ll-core:client:characterLoaded', characterData)
    TriggerServerEvent('ll-account:server:characterSpawned', characterData.id)
    
    Account.Debug('Existing character spawned successfully')
end)

-- Kezdő csomag
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
    
    -- Kezdő pénz
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
    
    -- Apokalipszis stats
    if Config.StartingKit.ApocalypseStats then
        TriggerServerEvent('ll-account:server:setStartingStats', Config.StartingKit.ApocalypseStats)
    end
end