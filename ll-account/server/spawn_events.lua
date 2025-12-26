-- Spawn events kezelése

-- Karakter spawned esemény
RegisterNetEvent('ll-account:server:characterSpawned', function(charid)
    local source = source
    
    if not charid then
        Account.Debug('Character spawned event - no charid provided')
        return
    end
    
    Account.Debug('Character spawned: ' .. charid .. ' by player ' .. source)
    
    -- ll-core-nak értesítés
    TriggerEvent('ll-core:server:playerSpawned', source, charid)
end)

-- Kezdő pénz hozzáadása
RegisterNetEvent('ll-account:server:addStartingMoney', function(accountType, amount)
    local source = source
    
    if not accountType or not amount then
        return
    end
    
    -- ll-core export használata
    if GetResourceState('ll-core') == 'started' then
        exports['ll-core']:AddMoney(source, accountType, amount, 'Starting money')
        Account.Debug('Added ' .. amount .. ' to ' .. accountType .. ' for player ' .. source)
    end
end)

-- Pozíció mentése (disconnect előtt)
RegisterNetEvent('ll-account:server:savePosition', function(position)
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier or not position then
        return
    end
    
    -- Jelenlegi karakter ID lekérése
    local player = exports['ll-core']:GetPlayer(source)
    if not player or not player.charid then
        return
    end
    
    local positionJson = json.encode({
        x = position.x,
        y = position.y,
        z = position.z,
        heading = position.heading
    })
    
    -- Pozíció mentése adatbázisba
    MySQL.Async.execute('UPDATE characters SET position = @position WHERE id = @charid', {
        ['@position'] = positionJson,
        ['@charid'] = player.charid
    }, function(affectedRows)
        if affectedRows > 0 then
            Account.Debug('Position saved for character ' .. player.charid)
        end
    end)
end)

-- Kezdő apokalipszis státuszok beállítása
RegisterNetEvent('ll-account:server:setStartingStats', function(stats)
    local source = source
    
    if not stats then
        return
    end
    
    local player = exports['ll-core']:GetPlayer(source)
    if not player or not player.charid then
        return
    end
    
    Account.SetStartingApocalypseStats(player.charid, stats)
    
    Account.Debug('Starting apocalypse stats set for character ' .. player.charid)
end)

-- Player disconnect kezelése
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    Account.Debug('Player disconnected: ' .. source .. ' - Reason: ' .. reason)
    
    -- Auto-save pozíció
    local player = exports['ll-core']:GetPlayer(source)
    if player and player.charid then
        local ped = GetPlayerPed(source)
        if ped and DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            local positionJson = json.encode({
                x = coords.x,
                y = coords.y,
                z = coords.z,
                heading = heading
            })
            
            MySQL.Async.execute('UPDATE characters SET position = @position, last_login = NOW() WHERE id = @charid', {
                ['@position'] = positionJson,
                ['@charid'] = player.charid
            })
            
            Account.Debug('Auto-saved position for character ' .. player.charid .. ' on disconnect')
        end
    end
end)

-- AFK kick
RegisterNetEvent('ll-account:server:afkKick', function()
    local source = source
    
    Account.Debug('AFK kicking player: ' .. source)
    
    DropPlayer(source, 'Kicked for inactivity')
end)