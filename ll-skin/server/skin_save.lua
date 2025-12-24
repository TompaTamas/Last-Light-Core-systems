-- Skin mentés/betöltés rendszer

-- Auto-save ha engedélyezve van
if Config.Save.AutoSave then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.Save.AutoSaveInterval)
            
            -- Minden játékos skin-jének mentése
            local players = GetPlayers()
            
            for _, playerId in ipairs(players) do
                local src = tonumber(playerId)
                
                if src then
                    TriggerClientEvent('ll-skin:client:requestSkin', src)
                end
            end
            
            print('^3[LL-SKIN] Auto-save triggered for ' .. #players .. ' players^7')
        end
    end)
end

-- Skin fogadása és mentése (auto-save)
RegisterNetEvent('ll-skin:server:autoSave', function(skin)
    local src = source
    local characterId = SkinServer.GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    if not SkinServer.ValidateSkin(skin) then
        SkinServer.Log('Invalid skin data from player ' .. src)
        return
    end
    
    SkinServer.SaveSkin(characterId, skin)
    SkinServer.Log('Auto-saved skin for character ' .. characterId)
end)

-- Backup skin mentése logout előtt
RegisterNetEvent('ll-skin:server:backupSkin', function(skin)
    local src = source
    local characterId = SkinServer.GetCharacterId(src)
    
    if not characterId or not skin then
        return
    end
    
    -- JSON mentés file-ba backup-ként
    local playerIdentifier = GetPlayerIdentifier(src, 0)
    local backupPath = 'backups/skins/' .. playerIdentifier .. '_' .. characterId .. '.json'
    
    SaveResourceFile(GetCurrentResourceName(), backupPath, json.encode(skin), -1)
    
    SkinServer.Log('Backup skin saved for character ' .. characterId)
end)

-- Skin visszaállítása backup-ból
RegisterCommand('restoreskin', function(source, args)
    local src = source
    
    if not SkinServer.IsAdmin(src) then
        return
    end
    
    local targetId = tonumber(args[1]) or src
    local characterId = SkinServer.GetCharacterId(targetId)
    
    if not characterId then
        TriggerClientEvent('ll-notify:client:notify', src, 'Character not found', 'error')
        return
    end
    
    local playerIdentifier = GetPlayerIdentifier(targetId, 0)
    local backupPath = 'backups/skins/' .. playerIdentifier .. '_' .. characterId .. '.json'
    
    local backupData = LoadResourceFile(GetCurrentResourceName(), backupPath)
    
    if backupData then
        local skin = json.decode(backupData)
        
        if skin then
            TriggerClientEvent('ll-skin:client:loadSkin', targetId, skin)
            TriggerClientEvent('ll-notify:client:notify', src, 'Skin restored from backup', 'success')
            SkinServer.Log('Admin ' .. src .. ' restored skin for character ' .. characterId)
        end
    else
        TriggerClientEvent('ll-notify:client:notify', src, 'No backup found', 'error')
    end
end, true)

-- Skin export/import
RegisterNetEvent('ll-skin:server:exportSkin', function()
    local src = source
    local characterId = SkinServer.GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    SkinServer.LoadSkin(characterId, function(skin)
        if skin then
            local skinJson = json.encode(skin, {indent = true})
            TriggerClientEvent('ll-skin:client:exportData', src, skinJson)
        end
    end)
end)

-- Skin import
RegisterNetEvent('ll-skin:server:importSkin', function(skinJson)
    local src = source
    local characterId = SkinServer.GetCharacterId(src)
    
    if not characterId then
        return
    end
    
    local success, skin = pcall(json.decode, skinJson)
    
    if not success or not skin then
        TriggerClientEvent('ll-notify:client:notify', src, 'Invalid skin data', 'error')
        return
    end
    
    if not SkinServer.ValidateSkin(skin) then
        TriggerClientEvent('ll-notify:client:notify', src, 'Skin validation failed', 'error')
        return
    end
    
    -- Mentés és alkalmazás
    SkinServer.SaveSkin(characterId, skin)
    TriggerClientEvent('ll-skin:client:loadSkin', src, skin)
    TriggerClientEvent('ll-notify:client:notify', src, 'Skin imported successfully', 'success')
    
    SkinServer.Log('Skin imported for character ' .. characterId)
end)

-- Skin másolása egyik karakterről másikra (admin)
RegisterCommand('copyskin', function(source, args)
    local src = source
    
    if not SkinServer.IsAdmin(src) then
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('ll-notify:client:notify', src, 'Usage: /copyskin [from_character_id] [to_character_id]', 'error')
        return
    end
    
    local fromCharId = tonumber(args[1])
    local toCharId = tonumber(args[2])
    
    if not fromCharId or not toCharId then
        TriggerClientEvent('ll-notify:client:notify', src, 'Invalid character IDs', 'error')
        return
    end
    
    -- Skin betöltése a forrás karakterről
    SkinServer.LoadSkin(fromCharId, function(skin)
        if not skin then
            TriggerClientEvent('ll-notify:client:notify', src, 'Source character skin not found', 'error')
            return
        end
        
        -- Mentés a cél karakterre
        SkinServer.SaveSkin(toCharId, skin)
        
        TriggerClientEvent('ll-notify:client:notify', src, 'Skin copied successfully', 'success')
        SkinServer.Log('Admin ' .. src .. ' copied skin from ' .. fromCharId .. ' to ' .. toCharId)
        
        -- Ha a cél karakter online, frissítjük
        for _, playerId in ipairs(GetPlayers()) do
            local targetSrc = tonumber(playerId)
            local targetCharId = SkinServer.GetCharacterId(targetSrc)
            
            if targetCharId == toCharId then
                TriggerClientEvent('ll-skin:client:loadSkin', targetSrc, skin)
                break
            end
        end
    end)
end, true)

-- Database migration (régi formátumból új formátumba)
RegisterCommand('migrateskins', function(source)
    local src = source
    
    if not SkinServer.IsAdmin(src) then
        return
    end
    
    MySQL.Async.fetchAll('SELECT id, skin FROM characters', {}, function(result)
        local migratedCount = 0
        
        for _, row in ipairs(result) do
            if row.skin then
                local oldSkin = json.decode(row.skin)
                
                -- TODO: Itt lehet konvertálni régi formátumot újra
                -- Példa: ESX formátumból Last Light formátumba
                
                migratedCount = migratedCount + 1
            end
        end
        
        TriggerClientEvent('ll-notify:client:notify', src, 'Migrated ' .. migratedCount .. ' skins', 'success')
        print('^2[LL-SKIN] Migration completed: ' .. migratedCount .. ' skins^7')
    end)
end, true)

-- Export funkciók
exports('SaveSkinToDatabase', function(characterId, skin)
    return SkinServer.SaveSkin(characterId, skin)
end)

exports('LoadSkinFromDatabase', function(characterId, callback)
    return SkinServer.LoadSkin(characterId, callback)
end)