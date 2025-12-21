-- APOKALIPSZIS RENDSZER - CLIENT SIDE

if not Config.Apocalypse.Enabled then return end

-- Játékos apokalipszis státuszai
local PlayerApocalypseData = {
    sanity = Config.Apocalypse.Sanity.StartingSanity,
    radiation = Config.Apocalypse.Radiation.StartingRadiation,
    hunger = Config.Apocalypse.Needs.Hunger.Starting,
    thirst = Config.Apocalypse.Needs.Thirst.Starting,
    infection = 0,
    inRadZone = false,
    inSafeZone = false,
    nearFire = false
}

-- Hallucinációk
local hallucinations = {}

-- Elme állapot csökkenés/növelés
Citizen.CreateThread(function()
    if not Config.Apocalypse.Sanity.Enabled then return end
    
    while true do
        Citizen.Wait(60000) -- 1 perc
        
        if not LL.PlayerLoaded then goto continue end
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local health = GetEntityHealth(ped)
        local timeHour = GetClockHours()
        
        local sanityChange = -Config.Apocalypse.Sanity.DecreaseRate
        
        -- Sötétség
        if timeHour >= 22 or timeHour <= 6 then
            sanityChange = sanityChange - Config.Apocalypse.Sanity.DecreaseFactors.InDark
        end
        
        -- Alacsony HP
        if health < 150 then
            sanityChange = sanityChange - Config.Apocalypse.Sanity.DecreaseFactors.LowHealth
        end
        
        -- Radiációs zóna
        if PlayerApocalypseData.inRadZone then
            sanityChange = sanityChange - Config.Apocalypse.Sanity.DecreaseFactors.InRadiation
        end
        
        -- Egyedül vagyok?
        local playersNearby = 0
        for _, player in pairs(GetActivePlayers()) do
            if player ~= PlayerId() then
                local otherPed = GetPlayerPed(player)
                local otherCoords = GetEntityCoords(otherPed)
                if #(coords - otherCoords) < 50.0 then
                    playersNearby = playersNearby + 1
                end
            end
        end
        
        if playersNearby == 0 then
            sanityChange = sanityChange - Config.Apocalypse.Sanity.DecreaseFactors.Alone
        else
            sanityChange = sanityChange + Config.Apocalypse.Sanity.IncreaseFactors.NearPlayers
        end
        
        -- Biztonságos zóna
        if PlayerApocalypseData.inSafeZone then
            sanityChange = sanityChange + Config.Apocalypse.Sanity.IncreaseFactors.InSafeZone
        end
        
        -- Tűz közelében
        if PlayerApocalypseData.nearFire then
            sanityChange = sanityChange + Config.Apocalypse.Sanity.IncreaseFactors.NearFire
        end
        
        -- Sanity frissítés
        PlayerApocalypseData.sanity = math.max(0, math.min(Config.Apocalypse.Sanity.MaxSanity, PlayerApocalypseData.sanity + sanityChange))
        
        -- Szerver értesítése
        TriggerServerEvent('ll-core:server:updateApocalypseStats', PlayerApocalypseData)
        
        -- UI frissítés
        TriggerEvent('ll-hud:updateApocalypseStats', PlayerApocalypseData)
        
        ::continue::
    end
end)

-- Radiáció kezelés
Citizen.CreateThread(function()
    if not Config.Apocalypse.Radiation.Enabled then return end
    
    while true do
        Citizen.Wait(1000) -- 1 másodperc
        
        if not LL.PlayerLoaded then goto continue end
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inRadZone = false
        local radiationIncrease = 0
        
        -- Radiációs zónák ellenőrzése
        for _, zone in pairs(Config.Apocalypse.Radiation.Zones) do
            local dist = #(coords - zone.coords)
            if dist < zone.radius then
                inRadZone = true
                
                -- Védelem számítás (pl. RadSuit, GasMask)
                local protection = 0
                
                -- TODO: Item check (ll-inventory integration)
                -- if hasItem('radsuit') then protection = Config.Apocalypse.Radiation.Protection.RadSuit end
                
                local effectiveRadiation = zone.radiationLevel * (1 - (protection / 100))
                radiationIncrease = radiationIncrease + effectiveRadiation
                
                -- Figyelmeztetés
                if zone.warning and not PlayerApocalypseData.inRadZone then
                    LL.Notify('⚠️ RADIÁCIÓS ZÓNA: ' .. zone.name, 'warning', 5000)
                end
                
                break
            end
        end
        
        PlayerApocalypseData.inRadZone = inRadZone
        
        -- Radiáció növelés
        if inRadZone then
            PlayerApocalypseData.radiation = math.min(Config.Apocalypse.Radiation.MaxRadiation, PlayerApocalypseData.radiation + radiationIncrease)
        else
            -- Természetes bomlás
            PlayerApocalypseData.radiation = math.max(0, PlayerApocalypseData.radiation - (Config.Apocalypse.Radiation.DecayRate / 60))
        end
        
        ::continue::
    end
end)

-- Radiáció sebzés
Citizen.CreateThread(function()
    if not Config.Apocalypse.Radiation.Enabled then return end
    
    while true do
        Citizen.Wait(5000) -- 5 másodperc
        
        if not LL.PlayerLoaded then goto continue end
        
        if PlayerApocalypseData.radiation >= Config.Apocalypse.Radiation.DamageThreshold then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local newHealth = health - Config.Apocalypse.Radiation.DamagePerTick
            
            SetEntityHealth(ped, newHealth)
            
            -- Vizuális effekt
            SetPedMotionBlur(ped, true)
            ShakeGameplayCam('DRUNK_SHAKE', 0.5)
        end
        
        ::continue::
    end
end)

-- Éhség és Szomjúság
Citizen.CreateThread(function()
    if not Config.Apocalypse.Needs.Enabled then return end
    
    while true do
        Citizen.Wait(60000) -- 1 perc
        
        if not LL.PlayerLoaded then goto continue end
        
        -- Éhség csökkenés
        PlayerApocalypseData.hunger = math.max(0, PlayerApocalypseData.hunger - Config.Apocalypse.Needs.Hunger.DecreaseRate)
        
        -- Szomjúság csökkenés
        PlayerApocalypseData.thirst = math.max(0, PlayerApocalypseData.thirst - Config.Apocalypse.Needs.Thirst.DecreaseRate)
        
        -- Kritikus állapot sebzés
        if PlayerApocalypseData.hunger <= Config.Apocalypse.Needs.Hunger.CriticalThreshold then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped, health - Config.Apocalypse.Needs.Hunger.DamageWhenCritical)
            
            if PlayerApocalypseData.hunger == 0 then
                LL.Notify('⚠️ ÉHEN HALSZ!', 'error')
            end
        end
        
        if PlayerApocalypseData.thirst <= Config.Apocalypse.Needs.Thirst.CriticalThreshold then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped, health - Config.Apocalypse.Needs.Thirst.DamageWhenCritical)
            
            if PlayerApocalypseData.thirst == 0 then
                LL.Notify('⚠️ SZOMJAN HALSZ!', 'error')
            end
        end
        
        ::continue::
    end
end)

-- Fertőzés kezelés
Citizen.CreateThread(function()
    if not Config.Apocalypse.Infection.Enabled then return end
    
    while true do
        Citizen.Wait(60000) -- 1 perc
        
        if not LL.PlayerLoaded then goto continue end
        
        if PlayerApocalypseData.infection > 0 then
            PlayerApocalypseData.infection = math.min(Config.Apocalypse.Infection.MaxInfection, 
                PlayerApocalypseData.infection + Config.Apocalypse.Infection.ProgressionRate)
            
            -- Halál 100%-nál
            if PlayerApocalypseData.infection >= 100 and Config.Apocalypse.Infection.DeathAtMax then
                SetEntityHealth(PlayerPedId(), 0)
                LL.Notify('💀 Meghaltál a fertőzés miatt...', 'error')
            end
            
            -- Stage effektek
            for _, stage in pairs(Config.Apocalypse.Infection.Stages) do
                if PlayerApocalypseData.infection >= stage.level then
                    ApplyInfectionEffects(stage.effects)
                end
            end
        end
        
        ::continue::
    end
end)

-- Fertőzés effektek
function ApplyInfectionEffects(effects)
    local ped = PlayerPedId()
    
    for _, effect in pairs(effects) do
        if effect == 'cough' then
            -- Köhögés animáció
            -- TODO: animáció
        elseif effect == 'fatigue' then
            SetPedMoveRateOverride(ped, 0.9)
        elseif effect == 'fever' then
            SetPedMotionBlur(ped, true)
        elseif effect == 'reduced_speed' then
            SetPedMoveRateOverride(ped, 0.7)
        elseif effect == 'hallucinations' then
            TriggerHallucination()
        elseif effect == 'reduced_health' then
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped, health - 1)
        end
    end
end

-- Hallucinációk (alacsony sanity-nál)
function TriggerHallucination()
    if not Config.Apocalypse.Sanity.Effects.Hallucinations then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Random NPC spawn a közelben
    local randomModel = Config.Apocalypse.Zombies.Types[math.random(#Config.Apocalypse.Zombies.Types)].model
    
    RequestModelSync(randomModel)
    
    local hallucination = CreatePed(4, GetHashKey(randomModel), 
        coords.x + math.random(-10, 10),
        coords.y + math.random(-10, 10),
        coords.z,
        0.0, false, true)
    
    SetEntityAlpha(hallucination, 150, false)
    SetEntityInvincible(hallucination, true)
    FreezeEntityPosition(hallucination, true)
    
    table.insert(hallucinations, hallucination)
    
    -- 5 másodperc után eltűnik
    Citizen.SetTimeout(5000, function()
        DeleteEntity(hallucination)
    end)
end

-- Sanity effektek
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if PlayerApocalypseData.sanity <= Config.Apocalypse.Sanity.LowSanityThreshold then
            -- Képernyő hatás
            if PlayerApocalypseData.sanity <= Config.Apocalypse.Sanity.CriticalSanityThreshold then
                SetPedMotionBlur(PlayerPedId(), true)
                ShakeGameplayCam('DRUNK_SHAKE', 1.0)
                
                -- Random hallucinációk
                if math.random(100) < 2 then -- 2% esély tickenként
                    TriggerHallucination()
                end
            else
                -- Enyhe hatás
                if math.random(100) < 1 then
                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

-- Biztonságos zóna detektálás
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        
        if not LL.PlayerLoaded then goto continue end
        
        local coords = GetEntityCoords(PlayerPedId())
        local inSafeZone = false
        
        for _, zone in pairs(Config.Apocalypse.SafeZones) do
            if #(coords - zone.coords) < zone.radius then
                inSafeZone = true
                break
            end
        end
        
        if inSafeZone and not PlayerApocalypseData.inSafeZone then
            LL.Notify('✅ Biztonságos zónába léptél', 'success')
        elseif not inSafeZone and PlayerApocalypseData.inSafeZone then
            LL.Notify('⚠️ Elhagytad a biztonságos zónát', 'warning')
        end
        
        PlayerApocalypseData.inSafeZone = inSafeZone
        
        ::continue::
    end
end)

-- Tűz detektálás (sanity növeléshez)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        
        if not LL.PlayerLoaded then goto continue end
        
        local coords = GetEntityCoords(PlayerPedId())
        local nearFire = false
        
        -- TODO: Tűz objektumok detektálása
        
        PlayerApocalypseData.nearFire = nearFire
        
        ::continue::
    end
end)

-- Apokalipszis adatok lekérése
function LL.GetApocalypseData()
    return PlayerApocalypseData
end

-- Étel/ital fogyasztás
RegisterNetEvent('ll-core:client:consumeFood', function(item, hunger, thirst)
    if hunger then
        PlayerApocalypseData.hunger = math.min(Config.Apocalypse.Needs.Hunger.Max, PlayerApocalypseData.hunger + hunger)
        
        -- Sanity növelés étkezésnél
        if Config.Apocalypse.Sanity.Enabled then
            PlayerApocalypseData.sanity = math.min(Config.Apocalypse.Sanity.MaxSanity, 
                PlayerApocalypseData.sanity + Config.Apocalypse.Sanity.IncreaseFactors.Eating)
        end
    end
    
    if thirst then
        PlayerApocalypseData.thirst = math.min(Config.Apocalypse.Needs.Thirst.Max, PlayerApocalypseData.thirst + thirst)
    end
    
    LL.Notify('Fogyasztottad: ' .. item, 'success')
end)

-- Gyógyszer használat (fertőzés ellen)
RegisterNetEvent('ll-core:client:useAntibiotics', function()
    if PlayerApocalypseData.infection > 0 then
        PlayerApocalypseData.infection = math.max(0, PlayerApocalypseData.infection - Config.Apocalypse.Infection.Cure.ReduceAmount)
        LL.Notify('Antibiotikum használva! Fertőzés csökkent.', 'success')
    else
        LL.Notify('Nem vagy fertőzött!', 'info')
    end
end)

-- Fertőzés hozzáadása (zombie támadás)
RegisterNetEvent('ll-core:client:addInfection', function(amount)
    PlayerApocalypseData.infection = math.min(Config.Apocalypse.Infection.MaxInfection, PlayerApocalypseData.infection + amount)
    LL.Notify('⚠️ MEGFERTŐZŐDTÉL!', 'error', 7000)
end)

-- Exports
exports('GetApocalypseData', function()
    return LL.GetApocalypseData()
end)