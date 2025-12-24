-- Skin menü kezelés (NUI megnyitás, callback-ek)

-- Globális változók
Skin = Skin or {}
Skin.IsMenuOpen = false
Skin.CurrentSkin = {}
Skin.OriginalSkin = {}
Skin.Camera = nil

-- Menü megnyitás
function Skin.OpenMenu(forceOpen)
    -- Check: Már nyitva van-e
    if Skin.IsMenuOpen and not forceOpen then
        Skin.Notify('Menu is already open', 'error')
        return
    end
    
    -- Check: Megfelelő helyen van-e (ha engedélyezett a korlátozás)
    if not Config.Menu.AllowEverywhere and not forceOpen then
        local isNearClothing = Skin.IsNearShop('clothing')
        local isNearBarber = Skin.IsNearShop('barber')
        
        if not isNearClothing and not isNearBarber then
            Skin.Notify(_('must_be_in_shop'), 'error')
            return
        end
    end
    
    -- Jelenlegi skin mentése (ha nem sikerül, akkor visszaállítjuk)
    Skin.OriginalSkin = Skin.GetCurrentSkin()
    Skin.CurrentSkin = Skin.DeepCopy(Skin.OriginalSkin)
    
    -- Menü megnyitása
    Skin.IsMenuOpen = true
    SetNuiFocus(true, true)
    
    -- NUI-nak küldés
    SendNUIMessage({
        action = 'openMenu',
        skin = Skin.CurrentSkin,
        config = {
            price = Config.Menu.EnablePrice and Config.Menu.Price or 0,
            components = Config.Components,
            clothes = Config.Clothes,
            props = Config.Props,
            locale = Config.Locale,
            allowTattoos = Config.Tattoos.Enable,
            allowOutfits = Config.Outfits.Enable
        }
    })
    
    -- Kamera beállítása
    if Config.Camera.Enable then
        Skin.CreateCamera('body')
    end
    
    -- Preview mód
    Skin.EnterPreviewMode()
    
    Skin.Debug('Menu opened')
end

-- Menü bezárása
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
    
    Skin.Debug('Menu closed (saved: ' .. tostring(save) .. ')')
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

RegisterNUICallback('reset', function(data, cb)
    Skin.ResetAppearance()
    cb('ok')
end)

RegisterNUICallback('updateComponent', function(data, cb)
    Skin.UpdateComponent(data.component, data.drawable, data.texture)
    Skin.UpdatePreview()
    cb('ok')
end)

RegisterNUICallback('updateProp', function(data, cb)
    Skin.UpdateProp(data.prop, data.drawable, data.texture)
    Skin.UpdatePreview()
    cb('ok')
end)

RegisterNUICallback('updateHair', function(data, cb)
    Skin.UpdateHair(data.style, data.color, data.highlight)
    Skin.UpdatePreview()
    cb('ok')
end)

RegisterNUICallback('updateOverlay', function(data, cb)
    Skin.UpdateOverlay(data.overlay, data.style, data.color, data.opacity)
    Skin.UpdatePreview()
    cb('ok')
end)

RegisterNUICallback('updateFaceFeature', function(data, cb)
    Skin.UpdateFaceFeature(data.feature, data.value)
    Skin.UpdatePreview()
    cb('ok')
end)

RegisterNUICallback('updateCamera', function(data, cb)
    if Config.Camera.Enable then
        Skin.SetCamera(data.position)
        Skin.ResetPreview()
    end
    cb('ok')
end)

-- Menü parancs
if Config.Menu.EnableCommand then
    RegisterCommand(Config.Menu.Command, function()
        if not Skin.IsMenuOpen then
            Skin.OpenMenu()
        end
    end)
end

-- Menü billentyű
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

-- Skin betöltése szerverről (karakterválasztáskor)
RegisterNetEvent('ll-skin:client:loadSkin', function(skin)
    if skin then
        Skin.ApplySkin(skin)
        Skin.Debug('Skin loaded from server')
    else
        Skin.Debug('No skin data from server, using default')
        local isMale = GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01')
        local defaultSkin = isMale and SkinData.DefaultMale or SkinData.DefaultFemale
        Skin.ApplySkin(defaultSkin)
    end
end)

-- Auto-save request (szervertől jön)
RegisterNetEvent('ll-skin:client:requestSkin', function()
    if Skin.IsMenuOpen then
        -- Ne mentse ha épp szerkesztés alatt van
        return
    end
    
    local currentSkin = Skin.GetCurrentSkin()
    TriggerServerEvent('ll-skin:server:autoSave', currentSkin)
end)

-- Export funkciók
exports('OpenMenu', function()
    Skin.OpenMenu()
end)

exports('CloseMenu', function(save)
    Skin.CloseMenu(save or false)
end)

exports('IsMenuOpen', function()
    return Skin.IsMenuOpen
end)

exports('ApplySkin', function(skin)
    Skin.ApplySkin(skin)
end)

exports('GetCurrentSkin', function()
    return Skin.GetCurrentSkin()
end)

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

-- 3D Text marker boltok előtt (opcionális)
if Config.Menu.Show3DText then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            
            if not Skin.IsMenuOpen then
                local playerCoords = GetEntityCoords(PlayerPedId())
                
                -- Clothing shops
                for _, shop in pairs(Config.ClothingShops) do
                    local distance = #(playerCoords - shop.coords)
                    
                    if distance < 10.0 then
                        DrawMarker(27, shop.coords.x, shop.coords.y, shop.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 132, 204, 22, 100, false, true, 2, false, nil, nil, false)
                        
                        if distance < 2.0 then
                            -- ll-3dtextui használata ha van
                            if GetResourceState('ll-3dtextui') == 'started' then
                                exports['ll-3dtextui']:DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z, '[E] Ruhabolt')
                            end
                            
                            if IsControlJustPressed(0, 38) then -- E
                                Skin.OpenMenu()
                            end
                        end
                    end
                end
                
                -- Barber shops
                for _, shop in pairs(Config.BarberShops) do
                    local distance = #(playerCoords - shop.coords)
                    
                    if distance < 10.0 then
                        DrawMarker(27, shop.coords.x, shop.coords.y, shop.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 132, 204, 22, 100, false, true, 2, false, nil, nil, false)
                        
                        if distance < 2.0 then
                            if GetResourceState('ll-3dtextui') == 'started' then
                                exports['ll-3dtextui']:DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z, '[E] Fodrászat')
                            end
                            
                            if IsControlJustPressed(0, 38) then -- E
                                Skin.OpenMenu()
                            end
                        end
                    end
                end
            else
                Citizen.Wait(500)
            end
        end
    end)
end