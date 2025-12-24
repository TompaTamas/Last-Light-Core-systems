-- 3D Preview és kamera vezérlés

local currentCameraZoom = 0.0

-- Kamera rotálás (NUI-ból jövő input)
RegisterNUICallback('rotateCamera', function(data, cb)
    if not Skin.Camera or not Skin.IsMenuOpen then
        cb('ok')
        return
    end
    
    local ped = PlayerPedId()
    local rotation = data.rotation or 0
    
    -- Karakter forgatása a rotation alapján
    local currentHeading = GetEntityHeading(ped)
    local newHeading = rotation % 360
    
    SetEntityHeading(ped, newHeading)
    
    cb('ok')
end)

-- Kamera zoom (opcionális)
RegisterNUICallback('zoomCamera', function(data, cb)
    if not Skin.Camera or not Skin.IsMenuOpen then
        cb('ok')
        return
    end
    
    local zoomDelta = data.zoom or 0
    currentCameraZoom = math.max(-1.0, math.min(1.0, currentCameraZoom + zoomDelta))
    
    -- FOV módosítása zoom helyett
    local currentFov = GetCamFov(Skin.Camera)
    local newFov = math.max(20.0, math.min(80.0, currentFov + (zoomDelta * 10)))
    
    SetCamFov(Skin.Camera, newFov)
    
    cb('ok')
end)

-- Preview frissítése amikor változik valami
function Skin.UpdatePreview()
    if not Skin.IsMenuOpen then
        return
    end
    
    -- NUI-nak jelezzük, hogy frissült a preview
    SendNUIMessage({
        action = 'previewUpdated',
        skin = Skin.CurrentSkin
    })
end

-- Preview reset
function Skin.ResetPreview()
    currentCameraZoom = 0.0
    
    SendNUIMessage({
        action = 'resetRotation'
    })
end

-- Karakter animáció preview közben
Citizen.CreateThread(function()
    local lastAnim = GetGameTimer()
    
    while true do
        Citizen.Wait(0)
        
        if Skin.IsMenuOpen then
            local ped = PlayerPedId()
            
            -- Idle animáció
            if not IsEntityPlayingAnim(ped, 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', 'idle_a', 3) and
               not IsEntityPlayingAnim(ped, 'amb@world_human_hang_out_street@male_b@idle_a', 'idle_a', 3) then
                
                if GetGameTimer() - lastAnim > 5000 then
                    local isMale = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
                    
                    if isMale then
                        RequestAnimDict('amb@world_human_hang_out_street@male_b@idle_a')
                        while not HasAnimDictLoaded('amb@world_human_hang_out_street@male_b@idle_a') do
                            Citizen.Wait(10)
                        end
                        
                        TaskPlayAnim(ped, 'amb@world_human_hang_out_street@male_b@idle_a', 'idle_a', 8.0, 8.0, -1, 1, 0, false, false, false)
                    else
                        RequestAnimDict('amb@world_human_hang_out_street@female_arms_crossed@idle_a')
                        while not HasAnimDictLoaded('amb@world_human_hang_out_street@female_arms_crossed@idle_a') do
                            Citizen.Wait(10)
                        end
                        
                        TaskPlayAnim(ped, 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', 'idle_a', 8.0, 8.0, -1, 1, 0, false, false, false)
                    end
                    
                    lastAnim = GetGameTimer()
                end
            end
            
            -- Kontrollok letiltása
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)   -- Mouse look (kamera mozgatás)
            EnableControlAction(0, 2, true)   -- Mouse look
            EnableControlAction(0, 249, true) -- Push to talk (ha van)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Lighting setup preview közben
function Skin.SetupPreviewLighting()
    -- Időjárás és világítás fix preview közben
    SetWeatherTypePersist('CLEAR')
    SetWeatherTypeNow('CLEAR')
    SetWeatherTypeNowPersist('CLEAR')
    
    -- Fényerő növelése
    SetArtificialLightsState(true)
end

-- Lighting reset
function Skin.ResetPreviewLighting()
    ClearWeatherTypePersist()
    SetArtificialLightsState(false)
end

-- Preview state mentése
Skin.PreviewState = {
    originalPos = nil,
    originalHeading = nil,
    inPreview = false
}

-- Preview mód aktiválása
function Skin.EnterPreviewMode()
    local ped = PlayerPedId()
    
    Skin.PreviewState.originalPos = GetEntityCoords(ped)
    Skin.PreviewState.originalHeading = GetEntityHeading(ped)
    Skin.PreviewState.inPreview = true
    
    -- Freeze player
    FreezeEntityPosition(ped, true)
    
    -- Lighting
    Skin.SetupPreviewLighting()
    
    Skin.Debug('Entered preview mode')
end

-- Preview mód elhagyása
function Skin.ExitPreviewMode()
    local ped = PlayerPedId()
    
    -- Unfreeze
    FreezeEntityPosition(ped, false)
    
    -- Animáció törlése
    ClearPedTasks(ped)
    
    -- Lighting reset
    Skin.ResetPreviewLighting()
    
    Skin.PreviewState.inPreview = false
    
    Skin.Debug('Exited preview mode')
end

-- Component preview (hover effect)
RegisterNUICallback('previewComponent', function(data, cb)
    local ped = PlayerPedId()
    
    -- Temp alkalmazás preview-hoz
    if data.component and data.drawable then
        SetPedComponentVariation(ped, data.component, data.drawable, data.texture or 0, 0)
    end
    
    cb('ok')
end)

-- Component preview cancel
RegisterNUICallback('cancelPreview', function(data, cb)
    -- Visszaállítás eredeti skin-re
    if Skin.CurrentSkin and Skin.CurrentSkin.components then
        local ped = PlayerPedId()
        
        if data.component and Skin.CurrentSkin.components[data.component] then
            local comp = Skin.CurrentSkin.components[data.component]
            SetPedComponentVariation(ped, data.component, comp.drawable, comp.texture, comp.palette or 0)
        end
    end
    
    cb('ok')
end)

-- Screenshot készítése (opcionális - outfit thumbnail-hez)
function Skin.TakeOutfitScreenshot(callback)
    -- TODO: Screenshot native használata
    -- Jelenleg nem támogatott natívan, külső resource kell hozzá
    
    if callback then
        callback(nil)
    end
end