-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[LL-CORE]^7 Last Light Core started successfully!')
        
        -- Adatbázis séma ellenőrzése
        CheckDatabaseSchema()
    end
end)

-- Resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Összes játékos mentése
        for _, player in pairs(LL.Players) do
            player.save()
        end
        
        print('^1[LL-CORE]^7 Last Light Core stopped!')
    end
end)

-- Adatbázis séma ellenőrzése
function CheckDatabaseSchema()
    MySQL.ready(function()
        LL.Debug('Database connection established')
        
        -- Táblák létrehozása, ha nem léteznek (lásd ll_core.sql)
        LL.Debug('Database schema check completed')
    end)
end

-- Játékos csatlakozás
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local identifier = nil
    
    -- License identifier keresése
    for _, id in pairs(identifiers) do
        if string.match(id, 'license:') then
            identifier = id
            break
        end
    end
    
    if not identifier then
        deferrals.done('Nem található Steam/License azonosító!')
        return
    end
    
    LL.Debug('Player connecting: ' .. name .. ' (' .. identifier .. ')')
    
    -- Discord webhook log
    if Config.DiscordWebhook.Enabled and Config.DiscordWebhook.LogConnect then
        LL.SendWebhook('Player Connecting', name .. ' csatlakozik a szerverhez', 3066993)
    end
end)

-- Játékos betöltése
RegisterNetEvent('ll-core:server:playerLoaded', function()
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local identifier = nil
    
    for _, id in pairs(identifiers) do
        if string.match(id, 'license:') then
            identifier = id
            break
        end
    end
    
    if not identifier then
        DropPlayer(source, 'Nem található Steam/License azonosító!')
        return
    end
    
    -- Felhasználó ellenőrzése/létrehozása az adatbázisban
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            -- Meglévő felhasználó
            LL.Debug('User found: ' .. identifier)
            
            -- Trigger account system to show character selection
            TriggerClientEvent('ll-account:client:showCharacterSelect', source)
        else
            -- Új felhasználó létrehozása
            MySQL.Async.execute('INSERT INTO users (identifier, `group`) VALUES (@identifier, @group)', {
                ['@identifier'] = identifier,
                ['@group'] = 'user'
            }, function(insertId)
                LL.Debug('New user created: ' .. identifier)
                
                -- Trigger account system
                TriggerClientEvent('ll-account:client:showRegistration', source)
            end)
        end
    end)
end)

-- Karakter betöltése
RegisterNetEvent('ll-core:server:loadCharacter', function(charid)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local identifier = nil
    
    for _, id in pairs(identifiers) do
        if string.match(id, 'license:') then
            identifier = id
            break
        end
    end
    
    if not identifier then return end
    
    -- Karakter adatok lekérése
    MySQL.Async.fetchAll([[
        SELECT c.*, u.`group` 
        FROM characters c
        LEFT JOIN users u ON c.identifier = u.identifier
        WHERE c.id = @charid AND c.identifier = @identifier
    ]], {
        ['@charid'] = charid,
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            local charData = result[1]
            
            -- Játékos objektum létrehozása
            local playerData = {
                identifier = identifier,
                charid = charData.id,
                name = charData.firstname .. ' ' .. charData.lastname,
                group = charData.group or 'user',
                accounts = json.decode(charData.accounts) or {
                    {name = 'cash', money = Config.Player.DefaultMoney},
                    {name = 'bank', money = Config.Player.DefaultBank}
                },
                position = charData.position,
                health = charData.health or 200,
                armor = charData.armor or 0
            }
            
            LL.Players[source] = LL.CreatePlayer(source, playerData)
            
            -- Kliens értesítése
            TriggerClientEvent('ll-core:client:setPlayerData', source, playerData)
            TriggerClientEvent('ll-core:client:loadCharacter', source, playerData)
            
            -- Welcome message
            TriggerClientEvent('chat:addMessage', source, {
                args = {_('welcome', Config.ServerName)}
            })
            
            LL.Debug('Character loaded: ' .. playerData.name .. ' (ID: ' .. charid .. ')')
            
            -- Trigger event más resource-oknak
            TriggerEvent('ll-core:playerLoaded', source, LL.Players[source])
        end
    end)
end)

-- Játékos adat frissítése
RegisterNetEvent('ll-core:server:updatePlayerData', function(data)
    local source = source
    local player = LL.GetPlayer(source)
    
    if not player then return end
    
    -- Adatok frissítése
    for key, value in pairs(data) do
        player[key] = value
    end
    
    LL.Debug('Player data updated for: ' .. player.name)
end)

-- Játékos mentése
RegisterNetEvent('ll-core:server:savePlayer', function()
    local source = source
    local player = LL.GetPlayer(source)
    
    if player then
        player.save()
    end
end)

-- Játékos halála
RegisterNetEvent('ll-core:server:onPlayerDeath', function(coords)
    local source = source
    local player = LL.GetPlayer(source)
    
    if player then
        LL.Debug('Player died: ' .. player.name)
        
        -- Trigger event
        TriggerEvent('ll-core:onPlayerDeath', source, coords)
        
        -- Inventory elvesztése (ha engedélyezve)
        if Config.Death.LoseInventory then
            -- TODO: ll-inventory integration
        end
    end
end)

-- Játékos újraéledése
RegisterNetEvent('ll-core:server:onPlayerRespawn', function()
    local source = source
    local player = LL.GetPlayer(source)
    
    if player then
        LL.Debug('Player respawned: ' .. player.name)
        
        -- Trigger event
        TriggerEvent('ll-core:onPlayerRespawn', source)
    end
end)

-- Játékos kilépés
AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = LL.GetPlayer(source)
    
    if player then
        -- Adat mentése
        player.save()
        
        LL.Debug('Player disconnected: ' .. player.name .. ' (' .. reason .. ')')
        
        -- Discord webhook log
        if Config.DiscordWebhook.Enabled and Config.DiscordWebhook.LogDisconnect then
            LL.SendWebhook('Player Disconnected', player.name .. ' kilépett: ' .. reason, 15158332)
        end
        
        -- Trigger event
        TriggerEvent('ll-core:playerDropped', source, reason)
        
        -- Törlés a Players táblából
        LL.Players[source] = nil
    end
end)

-- Exports
exports('GetPlayer', function(source)
    return LL.GetPlayer(source)
end)

exports('GetPlayerByCharId', function(charid)
    return LL.GetPlayerByCharId(charid)
end)

exports('GetPlayers', function()
    return LL.GetPlayers()
end)