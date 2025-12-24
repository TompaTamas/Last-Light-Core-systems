-- Server main

-- Skin betöltése adatbázisból karakterválasztáskor
RegisterNetEvent('ll-skin:server:loadSkin', function(characterId)
    local src = source
    
    if not characterId then
        print('^1[LL-SKIN] No character ID provided^7')
        return
    end
    
    MySQL.Async.fetchAll('SELECT skin FROM characters WHERE id = @id', {
        ['@id'] = characterId
    }, function(result)
        if result[1] then
            local skin = json.decode(result[1].skin)
            
            if skin then
                TriggerClientEvent('ll-skin:client:loadSkin', src, skin)
                print('^2[LL-SKIN] Skin loaded for character ' .. characterId .. '^7')
            else
                print('^3[LL-SKIN] No skin data found for character ' .. characterId .. '^7')
            end
        end
    end)
end)

-- Skin mentése
RegisterNetEvent('ll-skin:server:save', function(skin)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        TriggerClientEvent('ll-notify:client:notify', src, 'Error saving skin', 'error')
        return
    end
    
    local skinJson = json.encode(skin)
    
    MySQL.Async.execute('UPDATE characters SET skin = @skin WHERE id = @id', {
        ['@skin'] = skinJson,
        ['@id'] = characterId
    }, function(affectedRows)
        if affectedRows > 0 then
            print('^2[LL-SKIN] Skin saved for character ' .. characterId .. '^7')
        else
            print('^1[LL-SKIN] Failed to save skin for character ' .. characterId .. '^7')
        end
    end)
end)

-- Pénz levonás
RegisterNetEvent('ll-skin:server:pay', function(amount)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    -- Pénz levonása (ll-core export használata)
    exports['ll-core']:RemoveMoney(src, 'cash', amount, 'Skin changes')
    
    print('^2[LL-SKIN] Player ' .. src .. ' paid $' .. amount .. ' for skin changes^7')
end)

-- Helper: Character ID lekérése
function GetCharacterId(src)
    -- ll-core exportból
    local character = exports['ll-core']:GetPlayerCharacter(src)
    return character and character.id or nil
end

-- Outfit mentése
RegisterNetEvent('ll-skin:server:saveOutfit', function(outfit)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    -- Check: Maximum outfits
    MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM outfits WHERE character_id = @character_id', {
        ['@character_id'] = characterId
    }, function(result)
        if result[1] and result[1].count >= Config.Outfits.MaxOutfits then
            TriggerClientEvent('ll-notify:client:notify', src, 'Maximum outfits reached', 'error')
            return
        end
        
        -- Outfit mentése
        local outfitJson = json.encode({
            components = outfit.components,
            props = outfit.props
        })
        
        MySQL.Async.execute('INSERT INTO outfits (character_id, name, category, outfit_data) VALUES (@character_id, @name, @category, @outfit_data)', {
            ['@character_id'] = characterId,
            ['@name'] = outfit.name,
            ['@category'] = outfit.category,
            ['@outfit_data'] = outfitJson
        }, function(insertId)
            if insertId then
                TriggerClientEvent('ll-skin:client:outfitSaved', src, outfit.name)
                print('^2[LL-SKIN] Outfit saved: ' .. outfit.name .. ' for character ' .. characterId .. '^7')
            end
        end)
    end)
end)

-- Outfit betöltése
RegisterNetEvent('ll-skin:server:loadOutfit', function(outfitId)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM outfits WHERE id = @id AND character_id = @character_id', {
        ['@id'] = outfitId,
        ['@character_id'] = characterId
    }, function(result)
        if result[1] then
            local outfit = json.decode(result[1].outfit_data)
            outfit.name = result[1].name
            
            TriggerClientEvent('ll-skin:client:loadOutfit', src, outfit)
        else
            TriggerClientEvent('ll-notify:client:notify', src, 'Outfit not found', 'error')
        end
    end)
end)

-- Outfit törlése
RegisterNetEvent('ll-skin:server:deleteOutfit', function(outfitId)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    MySQL.Async.fetchAll('SELECT name FROM outfits WHERE id = @id AND character_id = @character_id', {
        ['@id'] = outfitId,
        ['@character_id'] = characterId
    }, function(result)
        if result[1] then
            local outfitName = result[1].name
            
            MySQL.Async.execute('DELETE FROM outfits WHERE id = @id AND character_id = @character_id', {
                ['@id'] = outfitId,
                ['@character_id'] = characterId
            }, function(affectedRows)
                if affectedRows > 0 then
                    TriggerClientEvent('ll-skin:client:outfitDeleted', src, outfitName)
                end
            end)
        end
    end)
end)

-- Outfit lista lekérése
RegisterNetEvent('ll-skin:server:getOutfits', function()
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM outfits WHERE character_id = @character_id ORDER BY id DESC', {
        ['@character_id'] = characterId
    }, function(result)
        local outfits = {}
        
        for _, row in ipairs(result) do
            table.insert(outfits, {
                id = row.id,
                name = row.name,
                category = row.category,
                created_at = row.created_at
            })
        end
        
        TriggerClientEvent('ll-skin:client:outfitList', src, outfits)
    end)
end)

-- Outfit megosztása
RegisterNetEvent('ll-skin:server:shareOutfit', function(outfitId, targetId)
    local src = source
    local characterId = GetCharacterId(src)
    
    if not characterId or not targetId then
        return
    end
    
    -- Outfit lekérése
    MySQL.Async.fetchAll('SELECT * FROM outfits WHERE id = @id AND character_id = @character_id', {
        ['@id'] = outfitId,
        ['@character_id'] = characterId
    }, function(result)
        if result[1] then
            local outfit = json.decode(result[1].outfit_data)
            outfit.name = result[1].name
            outfit.category = result[1].category
            
            local playerName = GetPlayerName(src)
            
            TriggerClientEvent('ll-skin:client:receiveOutfit', targetId, outfit, playerName)
            TriggerClientEvent('ll-notify:client:notify', src, 'Outfit shared successfully', 'success')
        end
    end)
end)

-- Admin parancs: Skin reset
RegisterCommand('resetskin', function(source, args)
    local src = source
    
    -- Admin check
    if not exports['ll-core']:IsAdmin(src) then
        return
    end
    
    local targetId = tonumber(args[1]) or src
    
    -- Default skin küldése
    local isMale = true -- TODO: Check character gender
    local defaultSkin = isMale and SkinData.DefaultMale or SkinData.DefaultFemale
    
    TriggerClientEvent('ll-skin:client:loadSkin', targetId, defaultSkin)
    TriggerClientEvent('ll-notify:client:notify', src, 'Skin reset for player ' .. targetId, 'success')
    
    print('^3[LL-SKIN] Admin ' .. src .. ' reset skin for player ' .. targetId .. '^7')
end, true)

-- Server induláskor
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    print('^2[LL-SKIN] Resource started^7')
end)