-- IDŐJÁRÁS RENDSZER - SERVER SIDE

if not Config.Apocalypse.Environment.DynamicWeather then return end

local currentWeather = 'EXTRASUNNY'
local isRadStormActive = false
local nextStormTime = 0

-- Időjárás változás
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- 10 perc
        
        -- Random időjárás kiválasztás
        local newWeather = Config.Weather.Types[math.random(#Config.Weather.Types)]
        
        -- Ne legyen vihar, ha rad storm aktív
        if not isRadStormActive then
            currentWeather = newWeather
            
            -- Sync minden kliensnek
            TriggerClientEvent('ll-core:client:syncWeather', -1, currentWeather)
            
            LL.Debug('Weather changed to: ' .. currentWeather)
        end
    end
end)

-- Radiációs vihar rendszer
Citizen.CreateThread(function()
    if not Config.Apocalypse.Environment.RadiationStorms then return end
    
    -- Első vihar időpont
    nextStormTime = os.time() + math.random(Config.Apocalypse.Environment.StormInterval.min, Config.Apocalypse.Environment.StormInterval.max)
    
    while true do
        Citizen.Wait(10000) -- 10 másodperc
        
        local currentTime = os.time()
        
        if currentTime >= nextStormTime and not isRadStormActive then
            -- Radiációs vihar indítása
            StartRadiationStorm()
            
            -- Következő vihar időpont
            nextStormTime = currentTime + math.random(Config.Apocalypse.Environment.StormInterval.min, Config.Apocalypse.Environment.StormInterval.max)
        end
    end
end)

-- Radiációs vihar indítása
function StartRadiationStorm()
    isRadStormActive = true
    
    -- Figyelmeztetés
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 0, 0},
        multiline = true,
        args = {"[FIGYELEM]", "☢️ RADIÁCIÓS VIHAR KÖZELEDIK! Keress menedéket!"}
    })
    
    -- Figyelmeztetési idő
    Citizen.SetTimeout(Config.Weather.RadStorm.WarningTime * 1000, function()
        -- Vihar kezdete
        TriggerClientEvent('ll-core:client:startRadStorm', -1)
        
        LL.Debug('Radiation storm started')
        
        -- Vihar vége
        Citizen.SetTimeout(Config.Apocalypse.Environment.StormDuration * 1000, function()
            EndRadiationStorm()
        end)
    end)
end

-- Radiációs vihar vége
function EndRadiationStorm()
    isRadStormActive = false
    
    TriggerClientEvent('ll-core:client:endRadStorm', -1)
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = {0, 255, 0},
        multiline = true,
        args = {"[INFO]", "☢️ A radiációs vihar elvonult."}
    })
    
    LL.Debug('Radiation storm ended')
end

-- Admin parancs: időjárás változtatás
RegisterCommand('weather', function(source, args)
    if not LL.IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, 'Nincs jogosultságod!', 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, 'Használat: /weather [type]', 'info')
        return
    end
    
    local weather = string.upper(args[1])
    currentWeather = weather
    
    TriggerClientEvent('ll-core:client:syncWeather', -1, weather)
    TriggerClientEvent('ll-core:client:notify', source, 'Időjárás megváltoztatva: ' .. weather, 'success')
end)

-- Admin parancs: radiációs vihar indítása
RegisterCommand('radstorm', function(source, args)
    if not LL.IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, 'Nincs jogosultságod!', 'error')
        return
    end
    
    if isRadStormActive then
        EndRadiationStorm()
        TriggerClientEvent('ll-core:client:notify', source, 'Radiációs vihar leállítva', 'success')
    else
        StartRadiationStorm()
        TriggerClientEvent('ll-core:client:notify', source, 'Radiációs vihar indítva', 'success')
    end
end)

-- Új játékos csatlakozásakor sync
AddEventHandler('ll-core:playerLoaded', function(source, player)
    TriggerClientEvent('ll-core:client:syncWeather', source, currentWeather)
    
    if isRadStormActive then
        TriggerClientEvent('ll-core:client:startRadStorm', source)
    end
end)