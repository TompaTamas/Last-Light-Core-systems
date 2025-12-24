-- Outfit rendszer (mentett ruhakészletek)

-- Outfit mentése
RegisterNUICallback('saveOutfit', function(data, cb)
    if not Config.Outfits.Enable then
        cb('disabled')
        return
    end
    
    if not data.name or data.name == '' then
        Skin.Notify(_('invalid_outfit_name'), 'error')
        cb('invalid_name')
        return
    end
    
    -- Jelenlegi ruhák kinyerése
    local outfit = {
        name = data.name,
        category = data.category or 'Egyéb',
        components = Skin.CurrentSkin.components,
        props = Skin.CurrentSkin.props
    }
    
    -- Szervernek küldés mentésre
    TriggerServerEvent('ll-skin:server:saveOutfit', outfit)
    
    Skin.Debug('Outfit save request: ' .. data.name)
    cb('ok')
end)

-- Outfit betöltése
RegisterNUICallback('loadOutfit', function(data, cb)
    if not data.id then
        cb('error')
        return
    end
    
    -- Szervertől lekérés
    TriggerServerEvent('ll-skin:server:loadOutfit', data.id)
    
    cb('ok')
end)

-- Outfit betöltve szerverről
RegisterNetEvent('ll-skin:client:loadOutfit', function(outfit)
    if not outfit then
        Skin.Notify(_('error_loading'), 'error')
        return
    end
    
    -- Outfit alkalmazása
    if outfit.components then
        Skin.CurrentSkin.components = outfit.components
        
        local ped = PlayerPedId()
        for component, data in pairs(outfit.components) do
            SetPedComponentVariation(ped, component, data.drawable, data.texture, data.palette or 0)
        end
    end
    
    if outfit.props then
        Skin.CurrentSkin.props = outfit.props
        
        local ped = PlayerPedId()
        for prop, data in pairs(outfit.props) do
            if data.drawable == -1 then
                ClearPedProp(ped, prop)
            else
                SetPedPropIndex(ped, prop, data.drawable, data.texture, true)
            end
        end
    end
    
    -- NUI frissítése
    SendNUIMessage({
        action = 'updateSkin',
        skin = Skin.CurrentSkin
    })
    
    Skin.Notify(_('outfit_loaded', outfit.name or 'Outfit'), 'success')
    Skin.Debug('Outfit loaded: ' .. (outfit.name or 'Unknown'))
end)

-- Outfit törlése
RegisterNUICallback('deleteOutfit', function(data, cb)
    if not data.id then
        cb('error')
        return
    end
    
    TriggerServerEvent('ll-skin:server:deleteOutfit', data.id)
    cb('ok')
end)

-- Outfit lista lekérése
RegisterNUICallback('getOutfits', function(data, cb)
    -- Szervertől lekérés
    TriggerServerEvent('ll-skin:server:getOutfits')
end)

-- Outfit lista visszaküldése NUI-nak
RegisterNetEvent('ll-skin:client:outfitList', function(outfits)
    SendNUIMessage({
        action = 'updateOutfitList',
        outfits = outfits or {}
    })
end)

-- Outfit mentve
RegisterNetEvent('ll-skin:client:outfitSaved', function(outfitName)
    Skin.Notify(_('outfit_saved', outfitName), 'success')
    
    -- Lista frissítése
    TriggerServerEvent('ll-skin:server:getOutfits')
end)

-- Outfit törölve
RegisterNetEvent('ll-skin:client:outfitDeleted', function(outfitName)
    Skin.Notify(_('outfit_deleted', outfitName), 'success')
    
    -- Lista frissítése
    TriggerServerEvent('ll-skin:server:getOutfits')
end)

-- Gyors outfit váltás (command)
RegisterCommand('outfit', function(source, args)
    if #args < 1 then
        Skin.Notify('Usage: /outfit [number]', 'error')
        return
    end
    
    local outfitId = tonumber(args[1])
    if not outfitId then
        Skin.Notify('Invalid outfit ID', 'error')
        return
    end
    
    TriggerServerEvent('ll-skin:server:loadOutfit', outfitId)
end)

-- Outfit megosztása más játékossal
RegisterNUICallback('shareOutfit', function(data, cb)
    if not Config.Outfits.AllowSharing then
        cb('disabled')
        return
    end
    
    if not data.id or not data.targetId then
        cb('error')
        return
    end
    
    TriggerServerEvent('ll-skin:server:shareOutfit', data.id, data.targetId)
    cb('ok')
end)

-- Megosztott outfit fogadása
RegisterNetEvent('ll-skin:client:receiveOutfit', function(outfit, fromPlayer)
    Skin.Notify('You received an outfit from ' .. fromPlayer, 'info')
    
    -- Automatikus mentés
    outfit.name = outfit.name .. ' (from ' .. fromPlayer .. ')'
    TriggerServerEvent('ll-skin:server:saveOutfit', outfit)
end)

-- Előre definiált outfitek betöltése (példák)
function Skin.LoadPresetOutfit(preset)
    local ped = PlayerPedId()
    local isMale = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
    
    if preset == 'default' then
        -- Alapértelmezett túlélő outfit
        Skin.ApplySurvivorOutfit('scavenger')
        
    elseif preset == 'raider' then
        Skin.ApplySurvivorOutfit('raider')
        
    elseif preset == 'medic' then
        Skin.ApplySurvivorOutfit('medic')
        
    elseif preset == 'military' then
        Skin.ApplySurvivorOutfit('military')
    end
end

-- Export
exports('LoadPresetOutfit', Skin.LoadPresetOutfit)