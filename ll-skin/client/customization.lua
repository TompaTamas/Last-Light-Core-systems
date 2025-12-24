-- Tetoválás, speciális customization

-- Tetoválás hozzáadása
RegisterNUICallback('addTattoo', function(data, cb)
    if not Config.Tattoos.Enable then
        cb('disabled')
        return
    end
    
    if not Skin.CurrentSkin.tattoos then
        Skin.CurrentSkin.tattoos = {}
    end
    
    -- Maximum check
    if #Skin.CurrentSkin.tattoos >= Config.Tattoos.MaxTattoos then
        Skin.Notify(_('max_tattoos'), 'error')
        cb('max_reached')
        return
    end
    
    -- Tetoválás hozzáadása
    local tattoo = {
        collection = data.collection,
        name = data.name,
        zone = data.zone,
        category = data.category
    }
    
    table.insert(Skin.CurrentSkin.tattoos, tattoo)
    
    -- Alkalmazás
    local ped = PlayerPedId()
    AddPedDecorationFromHashes(ped, GetHashKey(data.collection), GetHashKey(data.name))
    
    Skin.Notify(_('tattoo_added'), 'success')
    Skin.Debug('Tattoo added: ' .. data.collection .. ' - ' .. data.name)
    
    cb('ok')
end)

-- Tetoválás eltávolítása
RegisterNUICallback('removeTattoo', function(data, cb)
    if not Skin.CurrentSkin.tattoos then
        cb('error')
        return
    end
    
    -- Tetoválás keresése és törlése
    for i, tattoo in ipairs(Skin.CurrentSkin.tattoos) do
        if tattoo.collection == data.collection and tattoo.name == data.name then
            table.remove(Skin.CurrentSkin.tattoos, i)
            break
        end
    end
    
    -- Összes tetoválás újra alkalmazása
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    
    for _, tattoo in ipairs(Skin.CurrentSkin.tattoos) do
        AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(tattoo.name))
    end
    
    Skin.Notify(_('tattoo_removed'), 'success')
    cb('ok')
end)

-- Összes tetoválás törlése
function Skin.ClearAllTattoos()
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    Skin.CurrentSkin.tattoos = {}
end



-- Tetoválás lista lekérése NUI-nak
RegisterNUICallback('getTattoos', function(data, cb)
    local collections = Skin.GetTattooCollections()
    local zones = Skin.GetTattooZones()
    
    cb({
        collections = collections,
        zones = zones,
        current = Skin.CurrentSkin.tattoos or {}
    })
end)

-- Speciális customization (pl. sérülések, dirt overlay)
function Skin.ApplyDirtOverlay(level)
    local ped = PlayerPedId()
    
    -- Dirt overlay (0.0 = tiszta, 1.0 = nagyon piszkos)
    level = math.max(0.0, math.min(1.0, level))
    
    -- Damage overlay hozzáadása
    -- Note: Direct dirt level not supported, using damage to simulate wear
    if level > 0 then
        ApplyDamageToPed(ped, math.floor(level * 10), false)
    end
    
    Skin.Debug('Dirt overlay applied: ' .. level)
end

-- Vér overlay
function Skin.ApplyBloodOverlay(level)
    local ped = PlayerPedId()
    
    level = math.max(0.0, math.min(1.0, level))
    
    -- Vér overlay - apply damage to simulate blood
    if level > 0 then
        ApplyDamageToPed(ped, math.floor(level * 100), false)
    end
    
    Skin.Debug('Blood overlay applied: ' .. level)
end

-- Sérülés overlay törlése
function Skin.ClearDamageOverlays()
    local ped = PlayerPedId()
    
    ClearPedBloodDamage(ped)
    
    Skin.Debug('Damage overlays cleared')
end

-- Apokalipszis themed: Túlélő kinézet randomizálása
function Skin.ApplySurvivorLook()
    local ped = PlayerPedId()
    local isMale = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
    
    -- Piszkos, kopott kinézet
    Skin.ApplyDirtOverlay(math.random(50, 100) / 100)
    
    -- Szakáll (férfiaknál)
    if isMale then
        local beardStyle = math.random(1, 10)
        Skin.UpdateOverlay('beard', beardStyle, math.random(0, 10), math.random(80, 100) / 100)
    end
    
    -- Ráncok/öregedés
    local ageingStyle = math.random(0, 5)
    Skin.UpdateOverlay('ageing', ageingStyle, nil, math.random(30, 70) / 100)
    
    -- Bőrhibák
    local blemishStyle = math.random(0, 10)
    Skin.UpdateOverlay('blemishes', blemishStyle, nil, math.random(20, 50) / 100)
    
    -- Napégés
    local sunDamageStyle = math.random(0, 5)
    Skin.UpdateOverlay('sun_damage', sunDamageStyle, nil, math.random(30, 60) / 100)
    
    Skin.Notify('Survivor appearance applied', 'success')
end

-- Export
exports('ApplySurvivorLook', Skin.ApplySurvivorLook)