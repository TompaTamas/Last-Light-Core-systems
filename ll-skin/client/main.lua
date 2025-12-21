-- Menü megnyitás parancs
if Config.Menu.EnableCommand then
    RegisterCommand(Config.Menu.Command, function()
        Skin.OpenMenu()
    end)
end

-- Menü megnyitás billentyű
if Config.Menu.EnableKey then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            
            if IsControlJustPressed(0, Config.Menu.KeyCode) and not Skin.IsMenuOpen then
                Skin.OpenMenu()
            end
        end
    end)
end

-- Menü megnyitás
function Skin.OpenMenu()
    -- Check: Megfelelő helyen van-e
    if not Config.Menu.AllowEverywhere then
        if not Skin.IsNearShop('clothing') and not Skin.IsNearShop('barber') then
            Skin.Notify(_('must_be_in_shop'), 'error')
            return
        end
    end
    
    -- Jelenlegi skin mentése
    Skin.OriginalSkin = Skin.GetCurrentSkin()
    Skin.CurrentSkin = Skin.DeepCopy(Skin.OriginalSkin)
    
    -- Menü megnyitása
    Skin.IsMenuOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'openMenu',
        skin = Skin.CurrentSkin,
        config = {
            price = Config.Menu.EnablePrice and Config.Menu.Price or 0,
            components = Config.Components,
            clothes = Config.Clothes,
            props = Config.Props,
            locale = Config.Locale
        }
    })
    
    -- Kamera beállítása
    if Config.Camera.Enable then
        Skin.CreateCamera('body')
    end
    
    Skin.Debug('Menu opened')
end

-- Menü bezárása
function Skin.CloseMenu(save)
    if save then
        -- Mentés
        if Skin.HasEnoughMoney() then
            Skin.PayForChanges()
            TriggerServerEvent('ll-skin:server:save', Skin.CurrentSkin)
            Skin.Notify(_('saved_successfully'), 'success')
        else
            Skin.Notify(_('not_enough_money', Config.Menu.Price), 'error')
            Skin.ApplySkin(Skin.OriginalSkin)
        end
    else
        -- Visszaállítás
        Skin.ApplySkin(Skin.OriginalSkin)
    end
    
    Skin.IsMenuOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeMenu'
    })
    
    -- Kamera törlése
    if Skin.Camera then
        Skin.DestroyCamera()
    end
    
    Skin.Debug('Menu closed')
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    Skin.CloseMenu(false)
    cb('ok')
end)

RegisterNUICallback('save', function(data, cb)
    Skin.CloseMenu(true)
    cb('ok')
end)

RegisterNUICallback('updateComponent', function(data, cb)
    Skin.UpdateComponent(data.component, data.drawable, data.texture)
    cb('ok')
end)

RegisterNUICallback('updateProp', function(data, cb)
    Skin.UpdateProp(data.prop, data.drawable, data.texture)
    cb('ok')
end)

RegisterNUICallback('updateHair', function(data, cb)
    Skin.UpdateHair(data.style, data.color, data.highlight)
    cb('ok')
end)

RegisterNUICallback('updateOverlay', function(data, cb)
    Skin.UpdateOverlay(data.overlay, data.style, data.color, data.opacity)
    cb('ok')
end)

RegisterNUICallback('updateFaceFeature', function(data, cb)
    Skin.UpdateFaceFeature(data.feature, data.value)
    cb('ok')
end)

RegisterNUICallback('updateCamera', function(data, cb)
    if Config.Camera.Enable then
        Skin.SetCamera(data.position)
    end
    cb('ok')
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    TriggerServerEvent('ll-skin:server:saveOutfit', data.name, data.category, Skin.CurrentSkin)
    cb('ok')
end)

RegisterNUICallback('loadOutfit', function(data, cb)
    TriggerServerEvent('ll-skin:server:loadOutfit', data.id)
    cb('ok')
end)

-- Outfit betöltve szerverről
RegisterNetEvent('ll-skin:client:loadOutfit', function(skin)
    if skin then
        Skin.CurrentSkin = skin
        Skin.ApplySkin(skin)
        Skin.Notify(_('outfit_loaded'), 'success')
    end
end)

-- Skin betöltése karakterválasztáskor
RegisterNetEvent('ll-skin:client:loadSkin', function(skin)
    if skin then
        Skin.ApplySkin(skin)
        Skin.Debug('Skin loaded from database')
    end
end)

-- Komponens frissítése
function Skin.UpdateComponent(component, drawable, texture)
    local ped = PlayerPedId()
    
    if not Skin.CurrentSkin.components then
        Skin.CurrentSkin.components = {}
    end
    
    Skin.CurrentSkin.components[component] = {
        drawable = drawable,
        texture = texture,
        palette = 0
    }
    
    SetPedComponentVariation(ped, component, drawable, texture, 0)
end

-- Prop frissítése
function Skin.UpdateProp(prop, drawable, texture)
    local ped = PlayerPedId()
    
    if not Skin.CurrentSkin.props then
        Skin.CurrentSkin.props = {}
    end
    
    Skin.CurrentSkin.props[prop] = {
        drawable = drawable,
        texture = texture
    }
    
    if drawable == -1 then
        ClearPedProp(ped, prop)
    else
        SetPedPropIndex(ped, prop, drawable, texture, true)
    end
end

-- Haj frissítése
function Skin.UpdateHair(style, color, highlight)
    local ped = PlayerPedId()
    
    Skin.CurrentSkin.hair = {
        style = style,
        color = color,
        highlight = highlight
    }
    
    SetPedComponentVariation(ped, 2, style, 0, 0)
    SetPedHairColor(ped, color, highlight)
end

-- Overlay frissítése
function Skin.UpdateOverlay(overlay, style, color, opacity)
    local ped = PlayerPedId()
    local overlayId = SkinData.Overlays[overlay]
    
    if not overlayId then return end
    
    if not Skin.CurrentSkin[overlay] then
        Skin.CurrentSkin[overlay] = {}
    end
    
    Skin.CurrentSkin[overlay].style = style
    Skin.CurrentSkin[overlay].color = color
    Skin.CurrentSkin[overlay].opacity = opacity
    
    SetPedHeadOverlay(ped, overlayId, style, opacity)
    
    if color then
        local colorType = (overlay == 'makeup' or overlay == 'lipstick') and 2 or 1
        SetPedHeadOverlayColor(ped, overlayId, colorType, color, color)
    end
end

-- Face feature frissítése
function Skin.UpdateFaceFeature(feature, value)
    local ped = PlayerPedId()
    local featureId = SkinData.FaceFeatures[feature]
    
    if not featureId then return end
    
    if not Skin.CurrentSkin.face then
        Skin.CurrentSkin.face = {}
    end
    
    Skin.CurrentSkin.face[feature] = value
    
    SetPedFaceFeature(ped, featureId, value)
end

-- Deep copy helper
function Skin.DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for k, v in pairs(original) do
            copy[k] = Skin.DeepCopy(v)
        end
    else
        copy = original
    end
    return copy
end

-- Blipek létrehozása
Citizen.CreateThread(function()
    -- Clothing shops
    for _, shop in pairs(Config.ClothingShops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.coords)
            SetBlipSprite(blip, Config.Blips.ClothingShop.sprite)
            SetBlipColour(blip, Config.Blips.ClothingShop.color)
            SetBlipScale(blip, Config.Blips.ClothingShop.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blips.ClothingShop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    -- Barber shops
    for _, shop in pairs(Config.BarberShops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.coords)
            SetBlipSprite(blip, Config.Blips.BarberShop.sprite)
            SetBlipColour(blip, Config.Blips.BarberShop.color)
            SetBlipScale(blip, Config.Blips.BarberShop.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blips.BarberShop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Exports
exports('OpenMenu', function()
    Skin.OpenMenu()
end)

exports('ApplySkin', function(skin)
    Skin.ApplySkin(skin)
end)

exports('GetCurrentSkin', function()
    return Skin.GetCurrentSkin()
end)