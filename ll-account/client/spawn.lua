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
    Account.Debug('Spawn confirmed: ' .. data.spawnIndex)
    
    local spawnData = Config.Spawn.NewCharacterSpawns[data.spawnIndex]
    
    if not spawnData then
        cb({success = false, error = 'Invalid spawn location'})
        return
    end
    
    -- Spawn koordináták tárolása karakterhez
    Account.SelectedSpawn = spawnData.coords
    
    cb({success = true})
end)

-- Karakter spawn (betöltés után)
RegisterNetEvent('ll-account:client:spawnCharacter', function(characterData)
    Account.Debug('Spawning character: ' .. characterData.firstname)
    
    -- Fade out
    Account.FadeScreen(true, 1000)
    
    Citizen.Wait(1000)
    
    -- Preview ped törlése
    Account.DestroyCharacterPreview()
    Account.DestroyCreatorPed()
    
    -- Spawn pozíció
    local spawnCoords
    
    if Config.Spawn.UseLastPosition and characterData.position then
        -- Utolsó pozíció
        local pos = json.decode(characterData.position)
        if pos and pos.x and pos.y and pos.z then
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
    
    -- Player ped spawn
    local playerPed = PlayerPedId()
    
    SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
    SetEntityHeading(playerPed, spawnCoords.w or 0.0)
    
    -- Model beállítás
    local model = characterData.sex == 'm' and GetHashKey(Config.Creator.Gender.Male) or GetHashKey(Config.Creator.Gender.Female)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    playerPed = PlayerPedId()
    
    -- Megjelenés betöltése
    if characterData.skin then
        local skin = json.decode(characterData.skin)
        -- TODO: ll-skin integration
        -- Alap ruhák átmeneti
        local clothes = characterData.sex == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
        
        SetPedComponentVariation(playerPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
        SetPedComponentVariation(playerPed, 11, clothes.torso[1], clothes.torso[2], 0)
        SetPedComponentVariation(playerPed, 4, clothes.legs[1], clothes.legs[2], 0)
        SetPedComponentVariation(playerPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
    end
    
    -- Player unfreeze
    Account.FreezePlayer(false)
    
    -- Kamera visszaállítása
    Account.DestroyCamera()
    
    Citizen.Wait(500)
    
    -- Fade in
    Account.FadeScreen(false, 1000)
    
    -- Notify
    Account.Notify(_('character_loaded', characterData.firstname .. ' ' .. characterData.lastname), 'success', 5000)
    
    -- Kezdő csomag (ha új karakter)
    if characterData.is_new then
        Citizen.SetTimeout(2000, function()
            Account.GiveStartingKit()
            
            -- Tutorial
            if Config.Tutorial.Enable and Config.Tutorial.ShowForNewPlayers then
                Citizen.SetTimeout(3000, function()
                    Account.ShowTutorial()
                end)
            end
        end)
    end
    
    -- Karakter betöltve trigger
    TriggerEvent('ll-core:characterLoaded', characterData)
end)

-- Kezdő csomag kiosztása
function Account.GiveStartingKit()
    if not Config.StartingKit.Enable then return end
    
    Account.Debug('Giving starting kit')
    
    -- Notify
    if GetResourceState('ll-notify') == 'started' then
        exports['ll-notify']:Info(_('starting_kit'), 5000, _('welcome_survivor'))
    end
    
    -- Kezdő itemek
    if Config.StartingKit.Items and #Config.StartingKit.Items > 0 then
        for _, item in pairs(Config.StartingKit.Items) do
            -- TODO: ll-inventory integration
            -- TriggerServerEvent('ll-inventory:server:addItem', item.item, item.count)
            Account.Debug('Added item: ' .. item.item .. ' x' .. item.count)
        end
    end
    
    -- Kezdő pénz
    if Config.StartingKit.Money then
        if Config.StartingKit.Money.cash > 0 then
            -- TODO: ll-core integration
            Account.Debug('Added cash: $' .. Config.StartingKit.Money.cash)
        end
        
        if Config.StartingKit.Money.bank > 0 then
            Account.Debug('Added bank: $' .. Config.StartingKit.Money.bank)
        end
    end
    
    -- Apokalipszis kezdő státuszok szerverhez
    if Config.StartingKit.ApocalypseStats then
        TriggerServerEvent('ll-account:server:setStartingStats', Config.StartingKit.ApocalypseStats)
    end
end

-- Spawn kamera (cinematic)
function Account.SpawnCamera(coords)
    if not Config.Spawn.EnableSpawnCam then return end
    
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    SetCamCoord(cam, Config.Spawn.CameraPosition)
    SetCamRot(cam, Config.Spawn.CameraRotation, 2)
    SetCamFov(cam, Config.Spawn.CameraFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    -- 3 másodperc után interpolálás a játékoshoz
    Citizen.SetTimeout(3000, function()
        local targetCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        SetCamCoord(targetCam, playerCoords.x, playerCoords.y - 2.0, playerCoords.z + 1.0)
        PointCamAtCoord(targetCam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
        SetCamActiveWithInterp(targetCam, cam, 2000, 1, 1)
        
        Citizen.SetTimeout(2000, function()
            RenderScriptCams(false, true, 1000, true, true)
            DestroyCam(cam, false)
            DestroyCam(targetCam, false)
        end)
    end)
end