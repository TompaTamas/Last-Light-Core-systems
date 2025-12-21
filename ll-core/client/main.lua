-- Inicializálás player csatlakozáskor
AddEventHandler('playerSpawned', function()
    LL.Debug('playerSpawned event triggered')
end)

-- Core init
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Ha nincs betöltve a játékos, várunk
        if NetworkIsSessionStarted() then
            TriggerServerEvent('ll-core:server:playerLoaded')
            break
        end
    end
end)

-- Játékos adatok fogadása szerverről
RegisterNetEvent('ll-core:client:setPlayerData', function(data)
    LL.PlayerData = data
    LL.PlayerLoaded = true
    LL.Debug('Player data loaded: ' .. json.encode(data))
    
    -- Trigger player loaded event más resource-oknak
    TriggerEvent('ll-core:playerLoaded', data)
end)

-- Játékos adatok frissítése
RegisterNetEvent('ll-core:client:updatePlayerData', function(data)
    for key, value in pairs(data) do
        LL.PlayerData[key] = value
    end
    
    TriggerEvent('ll-core:playerDataUpdated', LL.PlayerData)
end)

-- Pénz frissítés
RegisterNetEvent('ll-core:client:updateMoney', function(account, amount)
    if LL.PlayerData.accounts then
        for i, acc in pairs(LL.PlayerData.accounts) do
            if acc.name == account then
                LL.PlayerData.accounts[i].money = amount
                TriggerEvent('ll-core:moneyUpdated', account, amount)
                break
            end
        end
    end
end)

-- Performancia optimalizációk
Citizen.CreateThread(function()
    -- Ambient NPC-k kikapcsolása
    if Config.Performance.DisableAmbientPeds then
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    end
    
    -- Ambient járművek kikapcsolása
    if Config.Performance.DisableAmbientVehicles then
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
    end
    
    -- Automatikus gyógyulás kikapcsolása
    if Config.Performance.DisableHealthRegen then
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)

-- HUD elemek letiltása
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Alap HUD elemek kikapcsolása (később ll-hud veszi át)
        HideHudComponentThisFrame(1)  -- Wanted Stars
        HideHudComponentThisFrame(2)  -- Weapon icon
        HideHudComponentThisFrame(3)  -- Cash
        HideHudComponentThisFrame(4)  -- MP Cash
        HideHudComponentThisFrame(6)  -- Vehicle name
        HideHudComponentThisFrame(7)  -- Area name
        HideHudComponentThisFrame(8)  -- Vehicle class
        HideHudComponentThisFrame(9)  -- Street name
        HideHudComponentThisFrame(13) -- Cash change
    end
end)

-- Radio wheel kikapcsolása (fegyverválasztó)
if Config.Performance.DisableWeaponWheel then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            BlockWeaponWheelThisFrame()
        end
    end)
end

-- Disconnect kezelése
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Játékos adat mentése leállításkor
        if LL.PlayerLoaded then
            TriggerServerEvent('ll-core:server:savePlayer')
        end
    end
end)

-- Exports
exports('GetPlayerData', function()
    return LL.GetPlayerData()
end)

exports('IsPlayerLoaded', function()
    return LL.IsPlayerLoaded()
end)

exports('GetCharacterId', function()
    return LL.GetCharacterId()
end)

exports('GetMoney', function(account)
    return LL.GetMoney(account)
end)

exports('Notify', function(msg, type, duration)
    LL.Notify(msg, type, duration)
end)

exports('IsAdmin', function()
    return LL.IsAdmin()
end)