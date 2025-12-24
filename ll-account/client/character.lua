-- Karakter előnézet (karakterválasztóban)
local previewPed = nil
local previewCam = nil
local creatorPed = nil
local creatorCam = nil
local currentGender = 'm'

-- Karakter preview létrehozása
function Account.CreateCharacterPreview(character)
    Account.Debug('Creating character preview for: ' .. character.firstname)
    
    -- Ha már van preview ped, töröljük
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
    end
    
    -- Model betöltés
    local model = character.sex == 'm' and GetHashKey(Config.Creator.Gender.Male) or GetHashKey(Config.Creator.Gender.Female)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    -- Preview pozíció (játékos előtt)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    local previewCoords = coords + vector3(2.0, 0.0, 0.0)
    
    -- Ped létrehozása
    previewPed = CreatePed(4, model, previewCoords.x, previewCoords.y, previewCoords.z, heading, false, true)
    
    -- Beállítások
    FreezeEntityPosition(previewPed, true)
    SetEntityInvincible(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)
    
    -- Megjelenés alkalmazása
    if character.skin and character.skin ~= '' and character.skin ~= '{}' then
        local success, skin = pcall(json.decode, character.skin)
        if success and skin and GetResourceState('ll-skin') == 'started' then
            exports['ll-skin']:ApplySkin(skin)
        end
    end
    
    -- Animáció
    TaskStartScenarioInPlace(previewPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    
    -- Kamera beállítás
    Account.SetupPreviewCamera(previewPed)
    
    return previewPed
end

-- Preview kamera
function Account.SetupPreviewCamera(ped)
    if previewCam and DoesCamExist(previewCam) then
        DestroyCam(previewCam, false)
    end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    local camOffset = vector3(
        coords.x + (Config.SelectionCamera.Distance * math.cos(math.rad(heading))),
        coords.y + (Config.SelectionCamera.Distance * math.sin(math.rad(heading))),
        coords.z + Config.SelectionCamera.Height
    )
    
    SetCamCoord(previewCam, camOffset.x, camOffset.y, camOffset.z)
    PointCamAtEntity(previewCam, ped, 0.0, 0.0, 0.5, true)
    SetCamFov(previewCam, Config.SelectionCamera.Fov)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 1000, true, true)
end

-- Preview törlése
function Account.DestroyCharacterPreview()
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
        previewPed = nil
    end
    
    if previewCam and DoesCamExist(previewCam) then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
    
    Account.Debug('Character preview destroyed')
end

-- Karakter preview váltás (balra/jobbra nyíl)
RegisterNUICallback('previewCharacter', function(data, cb)
    Account.Debug('Preview character: ' .. data.charid)
    
    -- Karakter keresése
    local character = nil
    for _, char in pairs(Account.Characters) do
        if char.id == data.charid then
            character = char
            break
        end
    end
    
    if character then
        Account.CreateCharacterPreview(character)
    end
    
    cb('ok')
end)

-- Kreátor ped létrehozása
function Account.CreateCreatorPed(gender)
    currentGender = gender or 'm'
    
    Account.Debug('Creating creator ped: ' .. currentGender)
    
    -- Régi kamera törlése
    if creatorCam and DoesCamExist(creatorCam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(creatorCam, false)
        creatorCam = nil
    end
    
    -- Ha már van, töröljük
    if creatorPed and DoesEntityExist(creatorPed) then
        DeleteEntity(creatorPed)
        creatorPed = nil
    end
    
    -- Model
    local model = currentGender == 'm' and GetHashKey('mp_m_freemode_01') or GetHashKey('mp_f_freemode_01')
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    -- Player pozíció
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Ped spawn előre (5 méter)
    local forwardVector = GetEntityForwardVector(playerPed)
    local spawnX = playerCoords.x + (forwardVector.x * 5.0)
    local spawnY = playerCoords.y + (forwardVector.y * 5.0)
    local spawnZ = playerCoords.z
    
    creatorPed = CreatePed(4, model, spawnX, spawnY, spawnZ, playerHeading - 180.0, false, true)
    
    -- Beállítások
    SetEntityAsMissionEntity(creatorPed, true, true)
    FreezeEntityPosition(creatorPed, true)
    SetEntityInvincible(creatorPed, true)
    SetBlockingOfNonTemporaryEvents(creatorPed, true)
    SetPedCanRagdoll(creatorPed, false)
    
    -- LÁTHATÓSÁG EXPLICIT
    SetEntityVisible(creatorPed, true, false)
    SetEntityAlpha(creatorPed, 255, false)
    ResetEntityAlpha(creatorPed)
    
    -- Collision
    SetEntityCollision(creatorPed, false, false)
    
    -- Alap ruhák
    Citizen.Wait(100)
    local clothes = currentGender == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
    
    SetPedComponentVariation(creatorPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0)
    SetPedComponentVariation(creatorPed, 11, clothes.torso[1], clothes.torso[2], 0)
    SetPedComponentVariation(creatorPed, 4, clothes.legs[1], clothes.legs[2], 0)
    SetPedComponentVariation(creatorPed, 6, clothes.shoes[1], clothes.shoes[2], 0)
    
    -- Animáció
    RequestAnimDict('anim@heists@heist_corona@single_team')
    while not HasAnimDictLoaded('anim@heists@heist_corona@single_team') do
        Citizen.Wait(10)
    end
    TaskPlayAnim(creatorPed, 'anim@heists@heist_corona@single_team', 'single_team_loop_boss', 8.0, 8.0, -1, 1, 0, false, false, false)
    
    -- Kamera beállítás
    Citizen.Wait(200)
    Account.SetupCreatorCamera(creatorPed)
    
    Account.Debug('Creator ped created at: ' .. spawnX .. ', ' .. spawnY .. ', ' .. spawnZ)
    
    return creatorPed
end

-- Kreátor kamera
function Account.SetupCreatorCamera(ped)
    if not ped or not DoesEntityExist(ped) then
        Account.Debug('Cannot setup camera - ped does not exist')
        return
    end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    Account.Debug('Setting up camera at: ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
    
    -- Új kamera
    creatorCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    -- Kamera pozíció (ped előtt, 2 méter, kicsit feljebb)
    local camX = coords.x + (math.sin(math.rad(-heading)) * 2.0)
    local camY = coords.y + (math.cos(math.rad(-heading)) * 2.0)
    local camZ = coords.z + 0.6
    
    SetCamCoord(creatorCam, camX, camY, camZ)
    PointCamAtEntity(creatorCam, ped, 0.0, 0.0, 0.0, true)
    SetCamFov(creatorCam, 50.0)
    SetCamActive(creatorCam, true)
    
    -- Render
    RenderScriptCams(true, true, 1000, true, true)
    
    Account.Debug('Creator camera active')
end

-- Kreátor ped törlése
function Account.DestroyCreatorPed()
    if creatorPed and DoesEntityExist(creatorPed) then
        DeleteEntity(creatorPed)
        creatorPed = nil
    end
    
    if creatorCam and DoesCamExist(creatorCam) then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(creatorCam, false)
        creatorCam = nil
    end
    
    Account.Debug('Creator ped destroyed')
end

-- Nem változtatás (kreátorban)
RegisterNUICallback('changeGender', function(data, cb)
    Account.Debug('Gender changed to: ' .. data.gender)
    Account.CreateCreatorPed(data.gender)
    cb('ok')
end)

-- Heritage frissítése (kreátorban)
RegisterNUICallback('updateHeritage', function(data, cb)
    if not creatorPed or not DoesEntityExist(creatorPed) then
        cb('ok')
        return
    end
    
    Account.Debug('Updating heritage: mom=' .. data.mom .. ' dad=' .. data.dad)
    
    -- Heritage alkalmazása
    SetPedHeadBlendData(
        creatorPed,
        data.mom or 0,
        data.dad or 0,
        0,
        data.mom or 0,
        data.dad or 0,
        0,
        data.similarity or 0.5,
        data.skin_similarity or 0.5,
        0.0,
        false
    )
    
    cb('ok')
end)

-- Kamera zoom (kreátorban)
RegisterNUICallback('cameraZoom', function(data, cb)
    if not creatorCam or not DoesCamExist(creatorCam) then
        cb('ok')
        return
    end
    
    local zoom = data.zoom -- 'head', 'body', 'full'
    
    if not creatorPed or not DoesEntityExist(creatorPed) then
        cb('ok')
        return
    end
    
    local coords = GetEntityCoords(creatorPed)
    
    if zoom == 'head' then
        SetCamCoord(creatorCam, coords.x, coords.y - 1.0, coords.z + 0.6)
        SetCamFov(creatorCam, 30.0)
    elseif zoom == 'body' then
        SetCamCoord(creatorCam, coords.x, coords.y - 1.5, coords.z + 0.3)
        SetCamFov(creatorCam, 35.0)
    else -- full
        SetCamCoord(creatorCam, coords.x, coords.y - 2.5, coords.z + 0.5)
        SetCamFov(creatorCam, 40.0)
    end
    
    PointCamAtEntity(creatorCam, creatorPed, 0.0, 0.0, 0.5, true)
    
    cb('ok')
end)

-- Cleanup resource stop-nál
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Account.DestroyCharacterPreview()
        Account.DestroyCreatorPed()
    end
end)