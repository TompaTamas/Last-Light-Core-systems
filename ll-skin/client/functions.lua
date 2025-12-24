Skin = {}
Skin.IsMenuOpen = false
Skin.CurrentSkin = {}
Skin.OriginalSkin = {}
Skin.Camera = nil

-- Lokalizáció
function _(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return str
    end
end

-- Debug
function Skin.Debug(msg)
    if Config.Debug then
        print('^3[LL-SKIN DEBUG]^7 ' .. msg)
    end
end

-- Notify wrapper
function Skin.Notify(msg, type, duration)
    if GetResourceState('ll-notify') == 'started' then
        exports['ll-notify']:Notify(msg, type or 'info', duration or 5000)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

-- Jelenlegi skin lekérése
function Skin.GetCurrentSkin()
    local ped = PlayerPedId()
    local skin = {}
    
    -- Model
    skin.model = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01') and 'mp_m_freemode_01' or 'mp_f_freemode_01'
    
    -- Heritage & Face
    skin.headBlend = {}
    skin.face = {}
    
    -- Components
    skin.components = {}
    for i = 0, 11 do
        skin.components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end
    
    -- Props
    skin.props = {}
    for i = 0, 7 do
        if i ~= 3 and i ~= 4 and i ~= 5 then -- Skip unused prop slots
            skin.props[i] = {
                drawable = GetPedPropIndex(ped, i),
                texture = GetPedPropTextureIndex(ped, i)
            }
        end
    end
    
    -- Hair
    skin.hair = {
        style = GetPedDrawableVariation(ped, 2),
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped)
    }
    
    -- Overlays
    skin.eyebrows = {
        style = GetPedHeadOverlayValue(ped, 2),
        opacity = 1.0
    }
    
    skin.beard = {
        style = GetPedHeadOverlayValue(ped, 1),
        opacity = 1.0
    }
    
    skin.eyeColor = GetPedEyeColor(ped)
    
    -- Tattoos
    skin.tattoos = Skin.GetAppliedTattoos()
    
    return skin
end

-- Skin alkalmazása
function Skin.ApplySkin(skin, ped)
    ped = ped or PlayerPedId()
    
    if not skin then
        Skin.Debug('ApplySkin: skin is nil')
        return
    end
    
    -- Model check
    local currentModel = GetEntityModel(ped)
    local targetModel = GetHashKey(skin.model or 'mp_m_freemode_01')
    
    if currentModel ~= targetModel then
        RequestModel(targetModel)
        while not HasModelLoaded(targetModel) do
            Citizen.Wait(10)
        end
        
        SetPlayerModel(PlayerId(), targetModel)
        SetModelAsNoLongerNeeded(targetModel)
        ped = PlayerPedId()
    end
    
    -- Heritage & Face
    if skin.headBlend then
        SetPedHeadBlendData(ped,
            skin.headBlend.shapeFirst or 0,
            skin.headBlend.shapeSecond or 0,
            skin.headBlend.shapeThird or 0,
            skin.headBlend.skinFirst or 0,
            skin.headBlend.skinSecond or 0,
            skin.headBlend.skinThird or 0,
            skin.headBlend.shapeMix or 0.0,
            skin.headBlend.skinMix or 0.0,
            skin.headBlend.thirdMix or 0.0,
            false
        )
    end
    
    -- Face features
    if skin.face then
        for feature, index in pairs(SkinData.FaceFeatures) do
            if skin.face[feature] then
                SetPedFaceFeature(ped, index, skin.face[feature])
            end
        end
    end
    
    -- Components
    if skin.components then
        for i = 0, 11 do
            if skin.components[i] then
                SetPedComponentVariation(ped, i,
                    skin.components[i].drawable or 0,
                    skin.components[i].texture or 0,
                    skin.components[i].palette or 0
                )
            end
        end
    end
    
    -- Props
    if skin.props then
        for i = 0, 7 do
            if skin.props[i] then
                if skin.props[i].drawable == -1 then
                    ClearPedProp(ped, i)
                else
                    SetPedPropIndex(ped, i,
                        skin.props[i].drawable,
                        skin.props[i].texture or 0,
                        true
                    )
                end
            end
        end
    end
    
    -- Hair
    if skin.hair then
        SetPedComponentVariation(ped, 2, skin.hair.style or 0, 0, 0)
        SetPedHairColor(ped, skin.hair.color or 0, skin.hair.highlight or 0)
    end
    
    -- Overlays
    if skin.eyebrows then
        SetPedHeadOverlay(ped, 2, skin.eyebrows.style or 0, skin.eyebrows.opacity or 1.0)
        SetPedHeadOverlayColor(ped, 2, 1, skin.eyebrows.color or 0, skin.eyebrows.color or 0)
    end
    
    if skin.beard then
        SetPedHeadOverlay(ped, 1, skin.beard.style or -1, skin.beard.opacity or 1.0)
        SetPedHeadOverlayColor(ped, 1, 1, skin.beard.color or 0, skin.beard.color or 0)
    end
    
    if skin.chest then
        SetPedHeadOverlay(ped, 10, skin.chest.style or -1, skin.chest.opacity or 1.0)
        SetPedHeadOverlayColor(ped, 10, 1, skin.chest.color or 0, skin.chest.color or 0)
    end
    
    if skin.makeup then
        SetPedHeadOverlay(ped, 4, skin.makeup.style or -1, skin.makeup.opacity or 0.0)
        SetPedHeadOverlayColor(ped, 4, 2, skin.makeup.color or 0, skin.makeup.color or 0)
    end
    
    if skin.lipstick then
        SetPedHeadOverlay(ped, 8, skin.lipstick.style or -1, skin.lipstick.opacity or 0.0)
        SetPedHeadOverlayColor(ped, 8, 2, skin.lipstick.color or 0, skin.lipstick.color or 0)
    end
    
    if skin.eyeColor then
        SetPedEyeColor(ped, skin.eyeColor)
    end
    
    if skin.ageing then
        SetPedHeadOverlay(ped, 3, skin.ageing.style or -1, skin.ageing.opacity or 0.0)
    end
    
    if skin.blemishes then
        SetPedHeadOverlay(ped, 0, skin.blemishes.style or -1, skin.blemishes.opacity or 0.0)
    end
    
    if skin.sun_damage then
        SetPedHeadOverlay(ped, 7, skin.sun_damage.style or -1, skin.sun_damage.opacity or 0.0)
    end
    
    if skin.complexion then
        SetPedHeadOverlay(ped, 6, skin.complexion.style or -1, skin.complexion.opacity or 0.0)
    end
    
    if skin.moles then
        SetPedHeadOverlay(ped, 9, skin.moles.style or -1, skin.moles.opacity or 0.0)
    end
    
    -- Tattoos
    if skin.tattoos then
        Skin.ApplyTattoos(skin.tattoos, ped)
    end
end

-- Játékos bolt közelében van-e
function Skin.IsNearShop(shopType)
    local coords = GetEntityCoords(PlayerPedId())
    local shops = shopType == 'clothing' and Config.ClothingShops or Config.BarberShops
    
    for _, shop in pairs(shops) do
        if #(coords - shop.coords) < 3.0 then
            return true
        end
    end
    
    return false
end

-- Pénz check
function Skin.HasEnoughMoney()
    if not Config.Menu.EnablePrice then
        return true
    end
    
    -- Admin check
    if Config.Menu.FreeForAdmins then
        if exports['ll-core']:IsAdmin() then
            return true
        end
    end
    
    -- Pénz check
    local money = exports['ll-core']:GetMoney('cash')
    return money >= Config.Menu.Price
end

-- Pénz levonás
function Skin.PayForChanges()
    if not Config.Menu.EnablePrice then
        return true
    end
    
    if Config.Menu.FreeForAdmins and exports['ll-core']:IsAdmin() then
        return true
    end
    
    TriggerServerEvent('ll-skin:server:pay', Config.Menu.Price)
    return true
end

-- Tetoválások lekérése
function Skin.GetAppliedTattoos()
    -- TODO: Implement tattoo tracking
    return {}
end

-- Tetoválások alkalmazása
function Skin.ApplyTattoos(tattoos, ped)
    ped = ped or PlayerPedId()
    
    -- Clear existing tattoos
    ClearPedDecorations(ped)
    
    -- Apply tattoos
    for _, tattoo in pairs(tattoos) do
        if tattoo.collection and tattoo.name then
            AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(tattoo.name))
        end
    end
end