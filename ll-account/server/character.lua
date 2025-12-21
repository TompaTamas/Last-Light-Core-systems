-- Karakter létrehozása
RegisterNetEvent('ll-account:server:createCharacter', function(data)
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('ll-account:client:error', source, _('database_error'))
        return
    end
    
    -- Rate limit check
    local canCreate, error = Account.CheckRateLimit(source)
    if not canCreate then
        TriggerClientEvent('ll-account:client:error', source, error)
        return
    end
    
    -- Daily limit check
    canCreate, error = Account.CheckDailyLimit(source)
    if not canCreate then
        TriggerClientEvent('ll-account:client:error', source, error)
        return
    end
    
    -- Karakterek számának ellenőrzése
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM characters WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(count)
        if count >= Config.Character.MaxCharacters then
            TriggerClientEvent('ll-account:client:error', source, _('max_characters', Config.Character.MaxCharacters))
            return
        end
        
        -- Validáció
        local valid, errorMsg = Account.ValidateName(data.firstname)
        if not valid then
            TriggerClientEvent('ll-account:client:error', source, errorMsg)
            return
        end
        
        valid, errorMsg = Account.ValidateName(data.lastname)
        if not valid then
            TriggerClientEvent('ll-account:client:error', source, errorMsg)
            return
        end
        
        valid, errorMsg = Account.ValidateDateOfBirth(data.dateofbirth)
        if not valid then
            TriggerClientEvent('ll-account:client:error', source, errorMsg)
            return
        end
        
        -- Magasság validáció
        local height = tonumber(data.height)
        if not height or height < Config.Character.Height.Min or height > Config.Character.Height.Max then
            TriggerClientEvent('ll-account:client:error', source, _('height_invalid', Config.Character.Height.Min, Config.Character.Height.Max))
            return
        end
        
        -- Kezdő pénz
        local accounts = json.encode({
            {name = 'cash', money = Config.StartingKit.Money.cash or 500},
            {name = 'bank', money = Config.StartingKit.Money.bank or 0}
        })
        
        -- Alap skin (később ll-skin-ből jön)
        local defaultSkin = json.encode({})
        
        -- Karakter létrehozása
        MySQL.Async.insert([[
            INSERT INTO characters (identifier, firstname, lastname, dateofbirth, sex, height, accounts, skin, position)
            VALUES (@identifier, @firstname, @lastname, @dateofbirth, @sex, @height, @accounts, @skin, @position)
        ]], {
            ['@identifier'] = identifier,
            ['@firstname'] = data.firstname,
            ['@lastname'] = data.lastname,
            ['@dateofbirth'] = data.dateofbirth,
            ['@sex'] = data.gender or 'm',
            ['@height'] = height,
            ['@accounts'] = accounts,
            ['@skin'] = defaultSkin,
            ['@position'] = '{}'
        }, function(charid)
            if charid then
                Account.Debug('Character created: ' .. data.firstname .. ' ' .. data.lastname .. ' (ID: ' .. charid .. ')')
                
                -- Rate limit frissítése
                Account.UpdateRateLimit(source)
                
                -- Kezdő apokalipszis státuszok
                if Config.StartingKit.ApocalypseStats then
                    Account.SetStartingApocalypseStats(charid, Config.StartingKit.ApocalypseStats)
                end
                
                -- Discord log
                if Config.Logging.LogCharacterCreation then
                    Account.LogToDiscord(
                        'Character Created',
                        GetPlayerName(source) .. ' created a new character',
                        3066993,
                        {
                            {name = 'Name', value = data.firstname .. ' ' .. data.lastname, inline = true},
                            {name = 'Gender', value = data.gender == 'm' and 'Male' or 'Female', inline = true},
                            {name = 'ID', value = charid, inline = true}
                        }
                    )
                end
                
                -- Kliens értesítése
                TriggerClientEvent('ll-account:client:characterCreated', source, charid)
            else
                TriggerClientEvent('ll-account:client:error', source, _('error_creating'))
            end
        end)
    end)
end)

-- Karakter törlése
RegisterNetEvent('ll-account:server:deleteCharacter', function(charid)
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('ll-account:client:error', source, _('database_error'))
        return
    end
    
    if not Config.Character.EnableDelete then
        TriggerClientEvent('ll-account:client:error', source, 'Character deletion is disabled')
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
        
        -- Törlés
        MySQL.Async.execute('DELETE FROM characters WHERE id = @charid', {
            ['@charid'] = charid
        }, function(affectedRows)
            if affectedRows > 0 then
                Account.Debug('Character deleted: ' .. character.firstname .. ' ' .. character.lastname)
                
                -- Discord log
                if Config.Logging.LogCharacterDeletion then
                    Account.LogToDiscord(
                        'Character Deleted',
                        GetPlayerName(source) .. ' deleted a character',
                        15158332,
                        {
                            {name = 'Name', value = character.firstname .. ' ' .. character.lastname, inline = true},
                            {name = 'ID', value = charid, inline = true}
                        }
                    )
                end
                
                TriggerClientEvent('ll-account:client:characterDeleted', source)
            else
                TriggerClientEvent('ll-account:client:error', source, _('error_deleting'))
            end
        end)
    end)
end)

-- Karakter frissítés (szerkesztés - később)
RegisterNetEvent('ll-account:server:updateCharacter', function(charid, data)
    local source = source
    local identifier = Account.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('ll-account:client:error', source, _('database_error'))
        return
    end
    
    -- Ellenőrzés
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE id = @charid AND identifier = @identifier', {
        ['@charid'] = charid,
        ['@identifier'] = identifier
    }, function(result)
        if not result[1] then
            TriggerClientEvent('ll-account:client:error', source, _('character_not_found'))
            return
        end
        
        -- TODO: Karakter adatok frissítése (firstname, lastname, stb.)
        -- Ez később ll-skin-nel integrálva lesz a megjelenéshez
        
        Account.Debug('Character updated: ' .. charid)
    end)
end)