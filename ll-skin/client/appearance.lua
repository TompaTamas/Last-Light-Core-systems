-- Appearance kezelés (Heritage, Face Features, Overlays)

-- Heritage frissítése
RegisterNUICallback('updateHeritage', function(data, cb)
    local ped = PlayerPedId()
    
    if not Skin.CurrentSkin.heritage then
        Skin.CurrentSkin.heritage = {}
    end
    
    Skin.CurrentSkin.heritage.mom = data.mom
    Skin.CurrentSkin.heritage.dad = data.dad
    Skin.CurrentSkin.heritage.similarity = data.similarity
    Skin.CurrentSkin.heritage.skin_similarity = data.skin_similarity
    
    -- HeadBlend beállítása
    if not Skin.CurrentSkin.headBlend then
        Skin.CurrentSkin.headBlend = {}
    end
    
    Skin.CurrentSkin.headBlend.shapeFirst = data.mom
    Skin.CurrentSkin.headBlend.shapeSecond = data.dad
    Skin.CurrentSkin.headBlend.shapeThird = 0
    Skin.CurrentSkin.headBlend.skinFirst = data.mom
    Skin.CurrentSkin.headBlend.skinSecond = data.dad
    Skin.CurrentSkin.headBlend.skinThird = 0
    Skin.CurrentSkin.headBlend.shapeMix = data.similarity
    Skin.CurrentSkin.headBlend.skinMix = data.skin_similarity
    Skin.CurrentSkin.headBlend.thirdMix = 0.0
    
    -- Alkalmazás
    SetPedHeadBlendData(ped,
        data.mom,
        data.dad,
        0,
        data.mom,
        data.dad,
        0,
        data.similarity,
        data.skin_similarity,
        0.0,
        false
    )
    
    Skin.Debug('Heritage updated: Mom=' .. data.mom .. ' Dad=' .. data.dad)
    cb('ok')
end)

-- Face feature frissítése (már van a main.lua-ban, de itt részletesebb)
function Skin.UpdateFaceFeature(feature, value)
    local ped = PlayerPedId()
    local featureId = SkinData.FaceFeatures[feature]
    
    if not featureId then
        Skin.Debug('Invalid face feature: ' .. feature)
        return
    end
    
    if not Skin.CurrentSkin.face then
        Skin.CurrentSkin.face = {}
    end
    
    Skin.CurrentSkin.face[feature] = value
    SetPedFaceFeature(ped, featureId, value)
    
    Skin.Debug('Face feature updated: ' .. feature .. ' = ' .. value)
end

-- Overlay frissítése (szemöldök, szakáll, smink stb.)
function Skin.UpdateOverlay(overlay, style, color, opacity)
    local ped = PlayerPedId()
    local overlayId = SkinData.Overlays[overlay]
    
    if not overlayId then
        Skin.Debug('Invalid overlay: ' .. overlay)
        return
    end
    
    if not Skin.CurrentSkin[overlay] then
        Skin.CurrentSkin[overlay] = {}
    end
    
    Skin.CurrentSkin[overlay].style = style
    Skin.CurrentSkin[overlay].color = color
    Skin.CurrentSkin[overlay].opacity = opacity
    
    -- Overlay alkalmazása
    SetPedHeadOverlay(ped, overlayId, style, opacity)
    
    -- Szín alkalmazása (ha van)
    if color then
        local colorType = 1 -- Hair color (1)
        
        -- Makeup és lipstick használ 2-es típust (makeup color)
        if overlay == 'makeup' or overlay == 'lipstick' or overlay == 'blush' then
            colorType = 2
        end
        
        SetPedHeadOverlayColor(ped, overlayId, colorType, color, color)
    end
    
    Skin.Debug('Overlay updated: ' .. overlay .. ' style=' .. style .. ' opacity=' .. opacity)
end

-- Hajszín frissítése
function Skin.UpdateHair(style, color, highlight)
    local ped = PlayerPedId()
    
    if not Skin.CurrentSkin.hair then
        Skin.CurrentSkin.hair = {}
    end
    
    Skin.CurrentSkin.hair.style = style
    Skin.CurrentSkin.hair.color = color
    Skin.CurrentSkin.hair.highlight = highlight
    
    -- Hajstílus (component 2)
    SetPedComponentVariation(ped, 2, style, 0, 0)
    
    -- Hajszín
    SetPedHairColor(ped, color, highlight)
    
    Skin.Debug('Hair updated: style=' .. style .. ' color=' .. color .. ' highlight=' .. highlight)
end

-- Szemszín frissítése
RegisterNUICallback('updateEyeColor', function(data, cb)
    local ped = PlayerPedId()
    
    Skin.CurrentSkin.eyeColor = data.color
    SetPedEyeColor(ped, data.color)
    
    Skin.Debug('Eye color updated: ' .. data.color)
    cb('ok')
end)

-- Bőrhiba/ráncok stb. frissítése
RegisterNUICallback('updateBlemish', function(data, cb)
    Skin.UpdateOverlay(data.type, data.style, nil, data.opacity)
    cb('ok')
end)

-- Teljes appearance reset
function Skin.ResetAppearance()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01') and 'mp_m_freemode_01' or 'mp_f_freemode_01'
    local defaultSkin = model == 'mp_m_freemode_01' and SkinData.DefaultMale or SkinData.DefaultFemale
    
    Skin.CurrentSkin = Skin.DeepCopy(defaultSkin)
    Skin.ApplySkin(Skin.CurrentSkin)
    
    -- NUI frissítése
    SendNUIMessage({
        action = 'updateSkin',
        skin = Skin.CurrentSkin
    })
    
    Skin.Notify(_('changes_reset'), 'info')
end

-- Reset gomb
RegisterNUICallback('reset', function(data, cb)
    Skin.ResetAppearance()
    cb('ok')
end)