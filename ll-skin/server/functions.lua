-- Server functions

SkinServer = {}

-- Character ID lekérése
function SkinServer.GetCharacterId(src)
    -- ll-core export check
    if GetResourceState('ll-core') ~= 'started' then
        return nil
    end
    
    -- Próbáljuk meg a GetPlayer export-ot
    local success, player = pcall(function()
        return exports['ll-core']:GetPlayer(src)
    end)
    
    if success and player then
        return player.charid or player.id or nil
    end
    
    -- Fallback: próbáljuk közvetlenül lekérni az adatbázisból
    local identifier = GetPlayerIdentifier(src, 0)
    if not identifier then return nil end
    
    local result = MySQL.Sync.fetchAll('SELECT id FROM characters WHERE identifier = @identifier ORDER BY last_login DESC LIMIT 1', {
        ['@identifier'] = identifier
    })
    
    if result[1] then
        return result[1].id
    end
    
    return nil
end

-- Player adatok lekérése
function SkinServer.GetPlayerData(src)
    return exports['ll-core']:GetPlayerCharacter(src)
end

-- Admin check
function SkinServer.IsAdmin(src)
    return exports['ll-core']:IsAdmin(src)
end

-- Pénz check
function SkinServer.HasMoney(src, amount)
    local money = exports['ll-core']:GetMoney(src, 'cash')
    return money >= amount
end

-- Pénz levonás
function SkinServer.RemoveMoney(src, amount, reason)
    return exports['ll-core']:RemoveMoney(src, 'cash', amount, reason or 'Skin changes')
end

-- Pénz hozzáadás
function SkinServer.AddMoney(src, amount, reason)
    return exports['ll-core']:AddMoney(src, 'cash', amount, reason or 'Skin refund')
end

-- Skin validálás
function SkinServer.ValidateSkin(skin)
    if type(skin) ~= 'table' then
        return false
    end
    
    -- Model check
    if skin.model ~= 'mp_m_freemode_01' and skin.model ~= 'mp_f_freemode_01' then
        return false
    end
    
    -- Components check
    if skin.components then
        for component, data in pairs(skin.components) do
            if type(component) ~= 'number' or component < 0 or component > 11 then
                return false
            end
            
            if type(data.drawable) ~= 'number' or type(data.texture) ~= 'number' then
                return false
            end
        end
    end
    
    -- Props check
    if skin.props then
        for prop, data in pairs(skin.props) do
            if type(prop) ~= 'number' or prop < 0 or prop > 7 then
                return false
            end
            
            if type(data.drawable) ~= 'number' or type(data.texture) ~= 'number' then
                return false
            end
        end
    end
    
    return true
end

-- Outfit validálás
function SkinServer.ValidateOutfit(outfit)
    if type(outfit) ~= 'table' then
        return false
    end
    
    if not outfit.name or outfit.name == '' then
        return false
    end
    
    if not outfit.components and not outfit.props then
        return false
    end
    
    return true
end

-- Skin mentése adatbázisba
function SkinServer.SaveSkin(characterId, skin)
    if not SkinServer.ValidateSkin(skin) then
        print('^1[LL-SKIN] Invalid skin data for character ' .. characterId .. '^7')
        return false
    end
    
    local skinJson = json.encode(skin)
    
    local success = false
    
    MySQL.Async.execute('UPDATE characters SET skin = @skin WHERE id = @id', {
        ['@skin'] = skinJson,
        ['@id'] = characterId
    }, function(affectedRows)
        success = affectedRows > 0
    end)
    
    Citizen.Wait(100) -- Wait for query
    
    return success
end

-- Skin betöltése adatbázisból
function SkinServer.LoadSkin(characterId, callback)
    MySQL.Async.fetchAll('SELECT skin FROM characters WHERE id = @id', {
        ['@id'] = characterId
    }, function(result)
        if result[1] and result[1].skin then
            local skin = json.decode(result[1].skin)
            callback(skin)
        else
            callback(nil)
        end
    end)
end

-- Outfit mentése
function SkinServer.SaveOutfit(characterId, outfit, callback)
    if not SkinServer.ValidateOutfit(outfit) then
        callback(false, 'Invalid outfit data')
        return
    end
    
    -- Check max outfits
    MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM outfits WHERE character_id = @character_id', {
        ['@character_id'] = characterId
    }, function(result)
        if result[1] and result[1].count >= Config.Outfits.MaxOutfits then
            callback(false, 'Maximum outfits reached')
            return
        end
        
        local outfitJson = json.encode({
            components = outfit.components,
            props = outfit.props
        })
        
        MySQL.Async.execute('INSERT INTO outfits (character_id, name, category, outfit_data) VALUES (@character_id, @name, @category, @outfit_data)', {
            ['@character_id'] = characterId,
            ['@name'] = outfit.name,
            ['@category'] = outfit.category or 'Egyéb',
            ['@outfit_data'] = outfitJson
        }, function(insertId)
            if insertId then
                callback(true, insertId)
            else
                callback(false, 'Database error')
            end
        end)
    end)
end

-- Outfit betöltése
function SkinServer.LoadOutfit(characterId, outfitId, callback)
    MySQL.Async.fetchAll('SELECT * FROM outfits WHERE id = @id AND character_id = @character_id', {
        ['@id'] = outfitId,
        ['@character_id'] = characterId
    }, function(result)
        if result[1] then
            local outfit = json.decode(result[1].outfit_data)
            outfit.name = result[1].name
            outfit.category = result[1].category
            outfit.id = result[1].id
            
            callback(outfit)
        else
            callback(nil)
        end
    end)
end

-- Outfit törlése
function SkinServer.DeleteOutfit(characterId, outfitId, callback)
    MySQL.Async.execute('DELETE FROM outfits WHERE id = @id AND character_id = @character_id', {
        ['@id'] = outfitId,
        ['@character_id'] = characterId
    }, function(affectedRows)
        callback(affectedRows > 0)
    end)
end

-- Összes outfit lekérése
function SkinServer.GetOutfits(characterId, callback)
    MySQL.Async.fetchAll('SELECT id, name, category, created_at FROM outfits WHERE character_id = @character_id ORDER BY id DESC', {
        ['@character_id'] = characterId
    }, function(result)
        callback(result or {})
    end)
end

-- Log
function SkinServer.Log(message)
    if Config.Debug then
        print('^3[LL-SKIN SERVER]^7 ' .. message)
    end
end

-- Export
exports('GetCharacterId', SkinServer.GetCharacterId)
exports('ValidateSkin', SkinServer.ValidateSkin)
exports('SaveSkin', SkinServer.SaveSkin)
exports('LoadSkin', SkinServer.LoadSkin)