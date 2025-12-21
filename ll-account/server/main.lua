-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[LL-ACCOUNT]^7 Last Light Account started successfully!')
    end
end)

-- Játékos karakterek lekérése
RegisterNetEvent('ll-account:server:getCharacters', function()
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('ll-account:client:error', source, _('database_error'))
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE identifier = @identifier ORDER BY last_login DESC', {
        ['@identifier'] = identifier
    }, function(characters)
        Account.Debug('Found ' .. #characters .. ' characters for ' .. identifier)
        
        -- Karakterek feldolgozása (érzékeny adatok eltávolítása ha kell)
        local processedChars = {}
        for _, char in pairs(characters) do
            table.insert(processedChars, {
                id = char.id,
                firstname = char.firstname,
                lastname = char.lastname,
                dateofbirth = char.dateofbirth,
                sex = char.sex,
                height = char.height,
                skin = char.skin,
                created_at = char.created_at,
                last_login = char.last_login
            })
        end
        
        TriggerClientEvent('ll-account:client:loadCharacters', source, processedChars)
    end)
end)

-- Karakter kiválasztása
RegisterNetEvent('ll-account:server:selectCharacter', function(charid)
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('ll-account:client:error', source, _('database_error'))
        return
    end
    
    -- Ellenőrzés: a karakter a játékosé-e
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE id = @charid AND identifier = @identifier', {
        ['@charid'] = charid,
        ['@identifier'] = identifier
    }, function(result)
        if not result[1] then
            TriggerClientEvent('ll-account:client:error', source, _('character_not_found'))
            return
        end
        
        local character = result[1]
        
        -- Last login frissítése
        MySQL.Async.execute('UPDATE characters SET last_login = NOW() WHERE id = @charid', {
            ['@charid'] = charid
        })
        
        -- ll-core-nak karakter betöltése
        TriggerEvent('ll-core:server:loadCharacter', source, charid)
        
        -- Karakter spawn
        TriggerClientEvent('ll-account:client:spawnCharacter', source, character)
        
        -- Discord log
        if Config.Logging.LogCharacterSelection then
            Account.LogToDiscord(
                'Character Selected',
                GetPlayerName(source) .. ' selected character',
                3066993,
                {
                    {name = 'Character', value = character.firstname .. ' ' .. character.lastname, inline = true},
                    {name = 'ID', value = charid, inline = true}
                }
            )
        end
        
        Account.Debug('Character selected: ' .. character.firstname .. ' ' .. character.lastname)
    end)
end)

-- Kezdő apokalipszis státuszok beállítása
RegisterNetEvent('ll-account:server:setStartingStats', function(stats)
    local source = source
    local player = exports['ll-core']:GetPlayer(source)
    
    if not player or not player.charid then return end
    
    Account.SetStartingApocalypseStats(player.charid, stats)
    Account.Debug('Starting apocalypse stats set for character: ' .. player.charid)
end)