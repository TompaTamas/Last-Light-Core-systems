-- Ruházat kezelés (Components & Props)

-- Komponens max értékek lekérése
function Skin.GetComponentMax(component)
    local ped = PlayerPedId()
    return GetNumberOfPedDrawableVariations(ped, component)
end

-- Texture max értékek lekérése
function Skin.GetTextureMax(component, drawable)
    local ped = PlayerPedId()
    return GetNumberOfPedTextureVariations(ped, component, drawable)
end

-- Prop max értékek lekérése
function Skin.GetPropMax(prop)
    local ped = PlayerPedId()
    return GetNumberOfPedPropDrawableVariations(ped, prop)
end

-- Prop texture max
function Skin.GetPropTextureMax(prop, drawable)
    local ped = PlayerPedId()
    return GetNumberOfPedPropTextureVariations(ped, prop, drawable)
end

-- NUI Callback: Komponens max értékek lekérése
RegisterNUICallback('getComponentMax', function(data, cb)
    local max = Skin.GetComponentMax(data.component)
    cb({max = max})
end)

-- NUI Callback: Texture max értékek lekérése
RegisterNUICallback('getTextureMax', function(data, cb)
    local max = Skin.GetTextureMax(data.component, data.drawable)
    cb({max = max})
end)

-- Összes ruha eltávolítása (túlélő default)
function Skin.StripToUnderwear()
    local ped = PlayerPedId()
    local isMale = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
    
    -- Torso (arms)
    SetPedComponentVariation(ped, 3, 15, 0, 0)
    
    -- Undershirt (basic)
    SetPedComponentVariation(ped, 8, 15, 0, 0)
    
    -- Pants (underwear)
    if isMale then
        SetPedComponentVariation(ped, 4, 61, 0, 0) -- Boxer
    else
        SetPedComponentVariation(ped, 4, 15, 0, 0) -- Panties
    end
    
    -- Shoes (bare feet)
    SetPedComponentVariation(ped, 6, 34, 0, 0)
    
    -- Jacket (none)
    SetPedComponentVariation(ped, 11, 15, 0, 0)
    
    -- Mask (none)
    SetPedComponentVariation(ped, 1, 0, 0, 0)
    
    -- Bag (none)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    
    -- Clear all props
    for i = 0, 7 do
        ClearPedProp(ped, i)
    end
    
    Skin.Notify('Stripped to underwear', 'info')
end

-- Túlélő outfit alkalmazása
function Skin.ApplySurvivorOutfit(type)
    local ped = PlayerPedId()
    local isMale = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
    
    if type == 'raider' then
        -- Raider outfit (aggressive survivor)
        if isMale then
            Skin.UpdateComponent(11, 243, 0) -- Leather jacket
            Skin.UpdateComponent(4, 86, 0)   -- Cargo pants
            Skin.UpdateComponent(6, 25, 0)   -- Combat boots
            Skin.UpdateComponent(8, 15, 0)   -- Undershirt
            Skin.UpdateComponent(1, 54, 0)   -- Bandana mask
        else
            Skin.UpdateComponent(11, 251, 0) -- Leather jacket
            Skin.UpdateComponent(4, 88, 0)   -- Cargo pants
            Skin.UpdateComponent(6, 25, 0)   -- Combat boots
            Skin.UpdateComponent(8, 14, 0)   -- Undershirt
        end
        
    elseif type == 'scavenger' then
        -- Scavenger outfit (resourceful survivor)
        if isMale then
            Skin.UpdateComponent(11, 49, 0)  -- Worn jacket
            Skin.UpdateComponent(4, 36, 0)   -- Jeans
            Skin.UpdateComponent(6, 12, 0)   -- Sneakers
            Skin.UpdateComponent(5, 45, 0)   -- Backpack
        else
            Skin.UpdateComponent(11, 48, 0)  -- Worn jacket
            Skin.UpdateComponent(4, 38, 0)   -- Jeans
            Skin.UpdateComponent(6, 12, 0)   -- Sneakers
            Skin.UpdateComponent(5, 45, 0)   -- Backpack
        end
        
    elseif type == 'medic' then
        -- Medic outfit
        if isMale then
            Skin.UpdateComponent(11, 250, 3) -- Paramedic jacket (white)
            Skin.UpdateComponent(4, 28, 0)   -- Work pants
            Skin.UpdateComponent(6, 51, 0)   -- Work boots
            Skin.UpdateComponent(8, 15, 0)   -- White undershirt
        else
            Skin.UpdateComponent(11, 258, 3) -- Paramedic jacket (white)
            Skin.UpdateComponent(4, 37, 0)   -- Work pants
            Skin.UpdateComponent(6, 52, 0)   -- Work boots
            Skin.UpdateComponent(8, 14, 0)   -- White undershirt
        end
        
    elseif type == 'military' then
        -- Military survivor
        if isMale then
            Skin.UpdateComponent(11, 220, 0) -- Tactical vest
            Skin.UpdateComponent(4, 31, 0)   -- Camo pants
            Skin.UpdateComponent(6, 24, 0)   -- Military boots
            Skin.UpdateComponent(8, 15, 0)   -- Undershirt
            Skin.UpdateProp(0, 106, 0)       -- Military cap
        else
            Skin.UpdateComponent(11, 230, 0) -- Tactical vest
            Skin.UpdateComponent(4, 32, 0)   -- Camo pants
            Skin.UpdateComponent(6, 24, 0)   -- Military boots
            Skin.UpdateComponent(8, 14, 0)   -- Undershirt
        end
    end
    
    Skin.Notify('Survivor outfit applied: ' .. type, 'success')
end

-- Export
exports('StripToUnderwear', Skin.StripToUnderwear)
exports('ApplySurvivorOutfit', Skin.ApplySurvivorOutfit)