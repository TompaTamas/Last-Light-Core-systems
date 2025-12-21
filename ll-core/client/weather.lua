-- IDŐJÁRÁS ÉS RADIÁCIÓS VIHAR - CLIENT SIDE

if not Config.Apocalypse.Environment.DynamicWeather then return end

local currentWeather = 'EXTRASUNNY'
local isRadStorm = false
local stormWarningActive = false

-- Időjárás szinkronizálás szerverről
RegisterNetEvent('ll-core:client:syncWeather', function(weather)
    currentWeather = weather
    SetWeatherTypePersist(weather)
    SetWeatherTypeNow(weather)
    SetWeatherTypeNowPersist(weather)
    
    LL.Debug('Weather synced: ' .. weather)
end)

-- Radiációs vihar
RegisterNetEvent('ll-core:client:startRadStorm', function()
    isRadStorm = true
    
    -- Időjárás változás
    SetWeatherTypePersist(Config.Weather.RadStorm.Weather)
    SetWeatherTypeNow(Config.Weather.RadStorm.Weather)
    
    -- Notification
    LL.Notify('☢️ RADIÁCIÓS VIHAR KÖZELEDIK!', 'error', 10000)
    
    -- Sziréna hang
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
    
    LL.Debug('Radiation storm started')
end)

-- Radiációs vihar vége
RegisterNetEvent('ll-core:client:endRadStorm', function()
    isRadStorm = false
    
    LL.Notify('☢️ A radiációs vihar elvonult', 'success', 5000)
    
    LL.Debug('Radiation storm ended')
end)

-- Radiációs vihar sebzés
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if isRadStorm and Config.Apocalypse.Radiation.Enabled then
            local apocalypseData = LL.GetApocalypseData()
            
            -- Radiáció növelés vihar alatt
            local radiationIncrease = Config.Weather.RadStorm.RadiationIncrease
            
            -- Védelem számítás
            local protection = 0
            -- TODO: Item check (radsuit)
            
            local effectiveRadiation = radiationIncrease * (1 - (protection / 100))
            
            TriggerEvent('ll-core:client:addRadiation', effectiveRadiation)
            
            -- Vizuális effekt
            SetTimecycleModifier('scanline_cam_cheap')
            SetTimecycleModifierStrength(0.5)
        else
            ClearTimecycleModifier()
        end
    end
end)

-- Apokaliptikus környezeti effektek
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Sötétebb éjszakák
        local hour = GetClockHours()
        if hour >= 22 or hour <= 6 then
            SetArtificialLightsState(true)
        end
        
        -- Ködös/füstös hatás
        if currentWeather == 'SMOG' or currentWeather == 'FOGGY' then
            SetRainLevel(0.0)
        end
    end
end)