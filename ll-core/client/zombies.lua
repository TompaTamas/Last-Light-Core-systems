-- ZOMBIE / MUTÁNS RENDSZER - CLIENT SIDE

if not Config.Apocalypse.Zombies.Enabled then return end

local spawnedZombies = {}
local lastSpawnTime = 0

-- Zombie spawolás
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Apocalypse.Zombies.SpawnInterval * 1000)
        
        if not LL.PlayerLoaded then goto continue end
        
        local currentTime = GetGameTimer()
        
        -- Spawn cooldown
        if currentTime - lastSpawnTime < (Config.Apocalypse.Zombies.SpawnInterval * 1000) then
            goto continue
        end
        
        -- Éjszaka check
        local timeHour = GetClockHours()
        local isNight = timeHour >= 22 or timeHour <= 6
        
        if Config.Apocalypse.Zombies.NightOnly and not isNight then
            goto continue
        end
        
        -- Maximum zombik ellenőrzése
        local activeZombies = 0
        for _, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) then
                activeZombies = activeZombies + 1
            else
                spawnedZombies[_] = nil
            end
        end
        
        if activeZombies >= Config.Apocalypse.Zombies.MaxZombies then
            goto continue
        end
        
        -- Spawn számítás (több éjjel)
        local spawnCount = 1
        if isNight and Config.Apocalypse.Zombies.MoreAtNight then
            spawnCount = math.random(1, 3)
        end
        
        for i = 1, spawnCount do
            SpawnZombie()
        end
        
        lastSpawnTime = currentTime
        
        ::continue::
    end
end)

-- Zombie spawn logika
function SpawnZombie()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Random típus kiválasztása (weighted)
    local zombieType = SelectZombieType()
    
    -- Random spawn pozíció a játékos körül
    local angle = math.random() * 2 * math.pi
    local distance = Config.Apocalypse.Zombies.SpawnRadius
    
    local spawnCoords = vector3(
        coords.x + math.cos(angle) * distance,
        coords.y + math.sin(angle) * distance,
        coords.z
    )
    
    -- Ground Z-level keresése
    local found, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 100.0, false)
    if found then
        spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)
    end
    
    -- Model betöltése
    if not RequestModelSync(zombieType.model) then
        LL.Debug('Failed to load zombie model: ' .. zombieType.model)
        return
    end
    
    -- Zombie létrehozása
    local zombie = CreatePed(4, GetHashKey(zombieType.model), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    
    -- Beállítások
    SetEntityHealth(zombie, zombieType.health)
    SetPedArmour(zombie, 0)
    SetPedCanRagdoll(zombie, true)
    SetPedFleeAttributes(zombie, 0, false)
    SetPedCombatAttributes(zombie, 46, true)
    SetPedCombatAbility(zombie, 2)
    SetPedCombatMovement(zombie, 2)
    SetPedCombatRange(zombie, 2)
    SetPedSeeingRange(zombie, 80.0)
    SetPedHearingRange(zombie, 80.0)
    SetPedAlertness(zombie, 3)
    
    -- Agresszió
    SetPedAsEnemy(zombie, true)
    SetPedRelationshipGroupHash(zombie, GetHashKey("HATES_PLAYER"))
    
    -- Melee fegyver (kéz)
    GiveWeaponToPed(zombie, GetHashKey("WEAPON_UNARMED"), 0, false, true)
    SetCurrentPedWeapon(zombie, GetHashKey("WEAPON_UNARMED"), true)
    
    -- Zombie AI - követés
    TaskCombatPed(zombie, ped, 0, 16)
    
    -- Sebesség módosítás
    if zombieType.speed then
        SetPedMoveRateOverride(zombie, zombieType.speed)
    end
    
    -- Zombie tárolása
    table.insert(spawnedZombies, {
        entity = zombie,
        type = zombieType,
        spawnTime = GetGameTimer()
    })
    
    LL.Debug('Zombie spawned: ' .. zombieType.name .. ' at ' .. tostring(spawnCoords))
end

-- Zombie típus kiválasztása (súlyozott random)
function SelectZombieType()
    local totalChance = 0
    for _, zType in pairs(Config.Apocalypse.Zombies.Types) do
        totalChance = totalChance + zType.spawnChance
    end
    
    local roll = math.random(totalChance)
    local currentChance = 0
    
    for _, zType in pairs(Config.Apocalypse.Zombies.Types) do
        currentChance = currentChance + zType.spawnChance
        if roll <= currentChance then
            return zType
        end
    end
    
    return Config.Apocalypse.Zombies.Types[1]
end

-- Zombie sebzés kezelése
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local ped = PlayerPedId()
        
        for i, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) then
                -- Halott zombie cleanup
                if IsEntityDead(zombie.entity) then
                    -- Loot spawn (később)
                    -- TODO: ll-loot integration
                    
                    Citizen.SetTimeout(30000, function() -- 30 másodperc után törlés
                        DeleteEntity(zombie.entity)
                    end)
                    
                    spawnedZombies[i] = nil
                else
                    -- Zombie támadás detektálás
                    local zombieCoords = GetEntityCoords(zombie.entity)
                    local playerCoords = GetEntityCoords(ped)
                    
                    if #(zombieCoords - playerCoords) < 2.0 then
                        -- Támadás esély
                        if math.random(100) < 10 then -- 10% esély tickenként
                            ApplyDamageToPed(ped, zombie.type.damage, false)
                            
                            -- Fertőzés esély
                            if Config.Apocalypse.Infection.Enabled then
                                if math.random(100) <= Config.Apocalypse.Zombies.InfectionChance then
                                    TriggerEvent('ll-core:client:addInfection', 10)
                                end
                            end
                        end
                    end
                end
            else
                spawnedZombies[i] = nil
            end
        end
    end
end)

-- Zombik törlése távoli távolságban (optimalizálás)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
        local coords = GetEntityCoords(PlayerPedId())
        
        for i, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) then
                local zombieCoords = GetEntityCoords(zombie.entity)
                
                -- Ha túl messze van (2x spawn radius), töröljük
                if #(coords - zombieCoords) > (Config.Apocalypse.Zombies.SpawnRadius * 2) then
                    DeleteEntity(zombie.entity)
                    spawnedZombies[i] = nil
                    LL.Debug('Zombie deleted (too far)')
                end
            end
        end
    end
end)

-- Zombie audio (morgás, nyögés)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(5000, 10000))
        
        for _, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) and not IsEntityDead(zombie.entity) then
                local zombieCoords = GetEntityCoords(zombie.entity)
                local playerCoords = GetEntityCoords(PlayerPedId())
                
                -- Ha közel van, játszik hangot
                if #(zombieCoords - playerCoords) < 30.0 then
                    -- TODO: Custom zombie hangok
                    PlayPain(zombie.entity, math.random(1, 7), 0)
                end
            end
        end
    end
end)

-- Relationship group beállítás
AddRelationshipGroup('ZOMBIE')
SetRelationshipBetweenGroups(5, GetHashKey("ZOMBIE"), GetHashKey("PLAYER"))
SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("ZOMBIE"))

-- Zombie cleanup resource stop-nál
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) then
                DeleteEntity(zombie.entity)
            end
        end
    end
end)

-- Force spawn zombie (admin/debug)
RegisterNetEvent('ll-core:client:spawnZombieForce', function(zombieType)
    if LL.IsAdmin() then
        local zType = nil
        
        for _, zt in pairs(Config.Apocalypse.Zombies.Types) do
            if zt.name == zombieType then
                zType = zt
                break
            end
        end
        
        if not zType then
            zType = Config.Apocalypse.Zombies.Types[1]
        end
        
        SpawnZombie()
        LL.Notify('Zombie spawned: ' .. zType.name, 'success')
    end
end)

-- Összes zombie törlése (admin)
RegisterCommand('clearzombies', function()
    if LL.IsAdmin() then
        for _, zombie in pairs(spawnedZombies) do
            if DoesEntityExist(zombie.entity) then
                DeleteEntity(zombie.entity)
            end
        end
        spawnedZombies = {}
        LL.Notify('Összes zombie törölve', 'success')
    end
end)