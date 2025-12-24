-- Tetoválás rendszer

-- Tetoválás menü megnyitása
function Skin.OpenTattooMenu()
    if not Config.Tattoos.Enable then
        Skin.Notify('Tattoos are disabled', 'error')
        return
    end
    
    local collections = Skin.GetTattooCollections()
    local current = Skin.CurrentSkin.tattoos or {}
    
    SendNUIMessage({
        action = 'openTattooMenu',
        collections = collections,
        current = current,
        maxTattoos = Config.Tattoos.MaxTattoos,
        price = Config.Tattoos.Price,
        removalPrice = Config.Tattoos.RemovalPrice
    })
end

-- Tetoválás preview
function Skin.PreviewTattoo(collection, name)
    local ped = PlayerPedId()
    
    -- Ideiglenes alkalmazás
    AddPedDecorationFromHashes(ped, GetHashKey(collection), GetHashKey(name))
    
    Skin.Debug('Tattoo preview: ' .. collection .. ' - ' .. name)
end

-- Tetoválás preview törlése
function Skin.ClearTattooPreview()
    local ped = PlayerPedId()
    
    -- Visszaállítás eredeti tetoválásokra
    ClearPedDecorations(ped)
    
    if Skin.CurrentSkin.tattoos then
        for _, tattoo in ipairs(Skin.CurrentSkin.tattoos) do
            AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(tattoo.name))
        end
    end
end

-- NUI Callback: Tetoválás preview
RegisterNUICallback('previewTattoo', function(data, cb)
    Skin.PreviewTattoo(data.collection, data.name)
    cb('ok')
end)

-- NUI Callback: Preview törlése
RegisterNUICallback('clearTattooPreview', function(data, cb)
    Skin.ClearTattooPreview()
    cb('ok')
end)

-- Tattoo lista szerverről lekérése
RegisterNUICallback('getTattooList', function(data, cb)
    -- GTA Online tattoo hashek (példa)
    local tattoos = {
        -- mpbeach_overlays
        {
            collection = 'mpbeach_overlays',
            name = 'MP_Bea_M_Chest_000',
            label = 'Tribal Sun',
            zone = 'ZONE_TORSO',
            category = 'Tribal'
        },
        {
            collection = 'mpbeach_overlays',
            name = 'MP_Bea_M_Head_000',
            label = 'Beach Skull',
            zone = 'ZONE_HEAD',
            category = 'Tribal'
        },
        -- mpbiker_overlays
        {
            collection = 'mpbiker_overlays',
            name = 'MP_MP_Biker_Tat_000_M',
            label = 'Skull Chain',
            zone = 'ZONE_TORSO',
            category = 'Biker'
        },
        {
            collection = 'mpbiker_overlays',
            name = 'MP_MP_Biker_Tat_001_M',
            label = 'Spider Web',
            zone = 'ZONE_LEFT_ARM',
            category = 'Biker'
        },
        -- mphipster_overlays
        {
            collection = 'mphipster_overlays',
            name = 'FM_Hip_M_Tat_000',
            label = 'Anchor',
            zone = 'ZONE_RIGHT_ARM',
            category = 'Hipster'
        },
        {
            collection = 'mphipster_overlays',
            name = 'FM_Hip_M_Tat_001',
            label = 'Compass',
            zone = 'ZONE_TORSO',
            category = 'Hipster'
        }
        -- ... További tetoválások
    }
    
    -- Filter by collection if provided
    if data.collection then
        local filtered = {}
        for _, tattoo in ipairs(tattoos) do
            if tattoo.collection == data.collection then
                table.insert(filtered, tattoo)
            end
        end
        cb(filtered)
    else
        cb(tattoos)
    end
end)

-- Összes elérhető tetoválás collection
function Skin.GetTattooCollections()
    return {
        {
            name = 'mpbeach_overlays',
            label = 'Beach Bum',
            category = 'Tribal'
        },
        {
            name = 'mpbiker_overlays',
            label = 'Bikers',
            category = 'Biker'
        },
        {
            name = 'mpbusiness_overlays',
            label = 'Business',
            category = 'Business'
        },
        {
            name = 'mphipster_overlays',
            label = 'Hipster',
            category = 'Hipster'
        },
        {
            name = 'mplowrider_overlays',
            label = 'Lowriders',
            category = 'Lowrider'
        },
        {
            name = 'mplowrider2_overlays',
            label = 'Lowriders 2',
            category = 'Lowrider'
        },
        {
            name = 'mpluxe_overlays',
            label = 'Executives',
            category = 'Luxury'
        },
        {
            name = 'mpluxe2_overlays',
            label = 'Executives 2',
            category = 'Luxury'
        },
        {
            name = 'mpsmuggler_overlays',
            label = 'Smuggler\'s Run',
            category = 'Smuggler'
        },
        {
            name = 'mpstunt_overlays',
            label = 'Cunning Stunts',
            category = 'Stunt'
        },
        {
            name = 'mpgunrunning_overlays',
            label = 'Gunrunning',
            category = 'Military'
        },
        {
            name = 'mpvinewood_overlays',
            label = 'Diamond Casino',
            category = 'Casino'
        },
        {
            name = 'multiplayer_overlays',
            label = 'Multiplayer',
            category = 'General'
        }
    }
end

-- Tetoválás zónák
function Skin.GetTattooZones()
    return {
        'ZONE_HEAD',
        'ZONE_TORSO',
        'ZONE_LEFT_ARM',
        'ZONE_RIGHT_ARM',
        'ZONE_LEFT_LEG',
        'ZONE_RIGHT_LEG'
    }
end

-- Check: Van-e már ilyen tetoválás
function Skin.HasTattoo(collection, name)
    if not Skin.CurrentSkin.tattoos then
        return false
    end
    
    for _, tattoo in ipairs(Skin.CurrentSkin.tattoos) do
        if tattoo.collection == collection and tattoo.name == name then
            return true
        end
    end
    
    return false
end

-- Tetoválás költség számítása
function Skin.CalculateTattooCost()
    local count = Skin.CurrentSkin.tattoos and #Skin.CurrentSkin.tattoos or 0
    return count * Config.Tattoos.Price
end

-- Export
exports('OpenTattooMenu', Skin.OpenTattooMenu)
exports('HasTattoo', Skin.HasTattoo)