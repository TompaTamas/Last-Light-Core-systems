-- Kamera kezelés

-- Kamera létrehozása
function Skin.CreateCamera(position)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Ha már van kamera, töröljük
    if Skin.Camera then
        Skin.DestroyCamera()
    end
    
    -- Új kamera létrehozása
    Skin.Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    -- Pozíció beállítása
    local camPos = Config.Camera.Positions[position] or Config.Camera.Positions.body
    
    local offsetX = camPos.offset.x
    local offsetY = camPos.offset.y
    local offsetZ = camPos.offset.z
    
    -- Kamera koordináták számítása (előtte áll)
    local camCoords = GetOffsetFromEntityInWorldCoords(ped, offsetX, offsetY, offsetZ)
    
    SetCamCoord(Skin.Camera, camCoords)
    PointCamAtEntity(Skin.Camera, ped, 0.0, 0.0, 0.0, true)
    SetCamFov(Skin.Camera, camPos.fov)
    SetCamActive(Skin.Camera, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    Skin.Debug('Camera created: ' .. position)
end

-- Kamera pozíció váltása
function Skin.SetCamera(position)
    if not Skin.Camera then
        Skin.CreateCamera(position)
        return
    end
    
    local ped = PlayerPedId()
    local camPos = Config.Camera.Positions[position] or Config.Camera.Positions.body
    
    local offsetX = camPos.offset.x
    local offsetY = camPos.offset.y
    local offsetZ = camPos.offset.z
    
    local camCoords = GetOffsetFromEntityInWorldCoords(ped, offsetX, offsetY, offsetZ)
    
    -- Smooth transition
    SetCamCoord(Skin.Camera, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(Skin.Camera, ped, 0.0, 0.0, 0.0, true)
    SetCamFov(Skin.Camera, camPos.fov)
    
    Skin.Debug('Camera position: ' .. position)
end

-- Kamera törlése
function Skin.DestroyCamera()
    if Skin.Camera then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(Skin.Camera, false)
        Skin.Camera = nil
        Skin.Debug('Camera destroyed')
    end
end

-- Kamera forgatás egérrel
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if Skin.IsMenuOpen and Config.Camera.AllowRotation and Skin.Camera then
            local ped = PlayerPedId()
            
            -- Egér mozgás detektálása
            local mouseX = GetDisabledControlNormal(0, 1) -- Mouse left/right
            
            if math.abs(mouseX) > 0.01 then
                local currentHeading = GetEntityHeading(ped)
                local newHeading = currentHeading + (mouseX * Config.Camera.RotationSpeed)
                
                SetEntityHeading(ped, newHeading)
                
                -- Kamera frissítése
                local camPos = GetCamCoord(Skin.Camera)
                PointCamAtEntity(Skin.Camera, ped, 0.0, 0.0, 0.0, true)
            end
        else
            Citizen.Wait(500)
        end
    end
end)