-- Karakter előnézet (karakterválasztóban)
local previewPed = nil
local previewCam = nil

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
    if character.skin then
        local skin = json.decode(character.skin)
        -- TODO: ll-skin integration - skin alkalmazása
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
    
    SetCamCoord(previewCam, camOffset)
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

-- Kreátor preview (valós idejű változások)
local creatorPed = nil
local creatorCam = nil
local currentGender = 'm'

-- Kreátor ped létrehozása
function Account.CreateCreatorPed(gender)
    currentGender = gender or 'm'
    
    -- Ha már van, töröljük
    if creatorPed and DoesEntityExist(creatorPed) then
        DeleteEntity(creatorPed)
    end
    
    -- Model
    local model = currentGender == 'm' and GetHashKey(Config.Creator.Gender.Male) or GetHashKey(Config.Creator.Gender.Female)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    -- Spawn pozíció
    local coords = vector3(402.8664, -996.4108, -99.00027) -- Karakter kreátor interior
    
    creatorPed = CreatePed(4, model, coords.x, coords.y, coords.z, 180.0, false, true)
    
    FreezeEntityPosition(creatorPed, true)
    SetEntityInvincible(creatorPed, true)
    SetBlockingOfNonTemporaryEvents(creatorPed, true)
    
    -- Alap ruhák
    local clothes = currentGender == 'm' and Config.Creator.DefaultClothes.Male or Config.Creator.DefaultClothes.Female
    
    SetPedComponentVariation(creatorPed, 8, clothes.tshirt[1], clothes.tshirt[2], 0) -- Tshirt
    SetPedComponentVariation(creatorPed, 11, clothes.torso[1], clothes.torso[2], 0)  -- Torso
    SetPedComponentVariation(creatorPed, 4, clothes.legs[1], clothes.legs[2], 0)     -- Legs
    SetPedComponentVariation(creatorPed, 6, clothes.shoes[1], clothes.shoes[2], 0)   -- Shoes
    
    -- Kamera
    Account.SetupCreatorCamera(creatorPed)
    
    return creatorPed
end

-- Kreátor kamera
function Account.SetupCreatorCamera(ped)
    if creatorCam and DoesCamExist(creatorCam) then
        DestroyCam(creatorCam, false)
    end
    
    local coords = GetEntityCoords(ped)
    
    creatorCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(creatorCam, coords.x, coords.y - 2.0, coords.z + 0.5)
    PointCamAtEntity(creatorCam, ped, 0.0, 0.0, 0.5, true)
    SetCamFov(creatorCam, 40.0)
    SetCamActive(creatorCam, true)
    RenderScriptCams(true, true, 1000, true, true)
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
end

-- Nem változtatás (kreátorban)
RegisterNUICallback('changeGender', function(data, cb)
    Account.Debug('Gender changed to: ' .. data.gender)
    Account.CreateCreatorPed(data.gender)
    cb('ok')
end)

-- Kamera zoom (kreátorban)
RegisterNUICallback('cameraZoom', function(data, cb)
    if not creatorCam or not DoesCamExist(creatorCam) then
        cb('ok')
        return
    end
    
    local zoom = data.zoom -- 'head', 'body', 'full'
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
        Account.DestroyCamera()
    end
end)