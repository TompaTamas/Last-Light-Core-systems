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
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
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
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
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

-- =====================================================
-- HOZZÁADANDÓ az ll-skin/client/main.lua-hoz vagy 
-- ll-skin/client/skin_menu.lua-hoz a CloseMenu függvényhez
-- =====================================================

-- Eredeti CloseMenu függvény frissítése:
function Skin.CloseMenu(save)
    if not Skin.IsMenuOpen then
        return
    end
    
    if save then
        -- Mentés
        if Config.Menu.EnablePrice and Config.Menu.Price > 0 then
            if Skin.HasEnoughMoney() then
                Skin.PayForChanges()
                TriggerServerEvent('ll-skin:server:save', Skin.CurrentSkin)
                Skin.Notify(_('saved_successfully'), 'success')
            else
                Skin.Notify(_('not_enough_money', Config.Menu.Price), 'error')
                Skin.ApplySkin(Skin.OriginalSkin)
            end
        else
            -- Ingyenes mentés
            TriggerServerEvent('ll-skin:server:save', Skin.CurrentSkin)
            Skin.Notify(_('saved_successfully'), 'success')
        end
    else
        -- Visszaállítás original skin-re
        Skin.ApplySkin(Skin.OriginalSkin)
    end
    
    -- Menü bezárása
    Skin.IsMenuOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeMenu'
    })
    
    -- Kamera törlése
    if Skin.Camera then
        Skin.DestroyCamera()
    end
    
    -- Preview mód vége
    Skin.ExitPreviewMode()
    
    -- ====================================================
    -- ÚJ: ll-account event trigger (karakter finalizáláshoz)
    -- ====================================================
    TriggerEvent('ll-skin:client:menuClosed', save)
    -- ====================================================
    
    Skin.Debug('Menu closed (saved: ' .. tostring(save) .. ')')
end

-- =====================================================
-- VAGY ha külön file-ban akarod:
-- Hozz létre egy új file-t: ll-skin/client/integrations.lua
-- És add hozzá az fxmanifest.lua-hoz:
-- =====================================================

--[[
-- ll-skin/client/integrations.lua

-- ll-account integration
AddEventHandler('ll-skin:client:menuClosed', function(saved)
    -- Event továbbítása ll-account-nak ha fut
    if GetResourceState('ll-account') == 'started' then
        TriggerEvent('ll-account:client:skinMenuClosed', saved)
    end
end)
]]

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