local isDead = false
local deathTime = 0
local respawnTimer = 0

-- Halál figyelése
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        local ped = PlayerPedId()
        
        if IsEntityDead(ped) and not isDead then
            OnPlayerDeath()
        end
        
        if isDead and not IsEntityDead(ped) then
            OnPlayerRevive()
        end
    end
end)

-- Halál kezelése
function OnPlayerDeath()
    isDead = true
    deathTime = GetGameTimer()
    respawnTimer = Config.Death.RespawnTime
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    LL.Debug('Player died at: ' .. json.encode(coords))
    
    -- Notify
    LL.Notify(_('you_died'), 'error', 5000)
    
    -- Szerver értesítése
    TriggerServerEvent('ll-core:server:onPlayerDeath', coords)
    
    -- Death screen effect
    StartScreenEffect('DeathFailOut', 0, true)
    
    -- Trigger event
    TriggerEvent('ll-core:onPlayerDeath')
    
    -- Respawn timer indítása
    StartRespawnTimer()
end

-- Újraélesztés kezelése
function OnPlayerRevive()
    isDead = false
    respawnTimer = 0
    
    LL.Debug('Player revived')
    
    -- Screen effect eltávolítása
    StopScreenEffect('DeathFailOut')
    
    -- Health visszaállítása
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    
    -- Notify
    LL.Notify(_('revived'), 'success')
    
    -- Trigger event
    TriggerEvent('ll-core:onPlayerRevive')
end

-- Respawn timer
function StartRespawnTimer()
    Citizen.CreateThread(function()
        while isDead and respawnTimer > 0 do
            Citizen.Wait(1000)
            respawnTimer = respawnTimer - 1
            
            -- UI frissítés (NUI-hoz később)
            SendNUIMessage({
                action = 'updateDeathTimer',
                timer = respawnTimer
            })
        end
        
        -- Ha lejárt az idő, respawn lehetősége
        if isDead and respawnTimer <= 0 then
            CanRespawn()
        end
    end)
end

-- Respawn lehetőség
function CanRespawn()
    Citizen.CreateThread(function()
        while isDead do
            Citizen.Wait(0)
            
            -- Kiírás
            SetTextFont(4)
            SetTextProportional(true)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextEntry("STRING")
            AddTextComponentString(_('respawn_now'))
            DrawText(0.5, 0.8)
            
            -- E gomb figyelése
            if IsControlJustPressed(0, 38) then -- E key
                RespawnPlayer()
            end
        end
    end)
end

-- Játékos respawn
function RespawnPlayer()
    if not isDead then return end
    
    local ped = PlayerPedId()
    
    -- Fade out
    LL.FadeScreen(true, 500)
    
    Citizen.Wait(500)
    
    -- Újraélesztés
    ResurrectPed(ped)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    
    -- Spawn pozíció kiválasztása
    local spawnPos
    
    if Config.Death.RespawnAtHospital then
        -- Random kórház kiválasztása
        local hospitals = Config.Death.HospitalSpawns
        spawnPos = hospitals[math.random(#hospitals)]
    else
        -- Alapértelmezett spawn
        spawnPos = Config.DefaultSpawn
    end
    
    -- Teleportálás
    SetEntityCoords(ped, spawnPos.x, spawnPos.y, spawnPos.z, false, false, false, true)
    SetEntityHeading(ped, spawnPos.w)
    
    -- Screen effect stop
    StopScreenEffect('DeathFailOut')
    
    Citizen.Wait(500)
    
    -- Fade in
    LL.FadeScreen(false, 500)
    
    -- State reset
    isDead = false
    respawnTimer = 0
    
    -- Notify
    LL.Notify(_('respawning'), 'success')
    
    -- Szerver értesítése
    TriggerServerEvent('ll-core:server:onPlayerRespawn')
    
    -- Trigger event
    TriggerEvent('ll-core:onPlayerRespawn')
end

-- Külső újraélesztés (admin/medic)
RegisterNetEvent('ll-core:client:revive', function()
    if isDead then
        local ped = PlayerPedId()
        
        -- Újraélesztés
        ResurrectPed(ped)
        SetEntityHealth(ped, 200)
        ClearPedBloodDamage(ped)
        
        -- Screen effect stop
        StopScreenEffect('DeathFailOut')
        
        -- State reset
        isDead = false
        respawnTimer = 0
        
        -- Notify
        LL.Notify(_('revived'), 'success')
        
        -- Trigger event
        TriggerEvent('ll-core:onPlayerRevive')
    end
end)

-- Death timer kijelzés
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isDead and respawnTimer > 0 then
            -- Timer kiírás
            SetTextFont(4)
            SetTextProportional(true)
            SetTextScale(0.7, 0.7)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextEntry("STRING")
            AddTextComponentString(_('respawn_in', respawnTimer))
            DrawText(0.5, 0.7)
        end
    end
end)

-- Exports
exports('IsDead', function()
    return isDead
end)

exports('Revive', function()
    TriggerEvent('ll-core:client:revive')
end)