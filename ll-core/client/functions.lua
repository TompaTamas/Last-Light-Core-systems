LL = {}
LL.PlayerData = {}
LL.PlayerLoaded = false

-- Lokalizáció
function _(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. str .. '] missing'
    end
end

-- Debug print
function LL.Debug(msg)
    if Config.Debug then
        print('^3[LL-CORE DEBUG]^7 ' .. msg)
    end
end

-- Notify wrapper (később ll-notify-val fog működni)
function LL.Notify(msg, type, duration)
    -- Alapértelmezett értékek
    type = type or 'info'
    duration = duration or 5000
    
    -- Ha van ll-notify resource
    if GetResourceState('ll-notify') == 'started' then
        exports['ll-notify']:Notify(msg, type, duration)
    else
        -- Fallback: beépített notify
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

-- Játékos adatok lekérése
function LL.GetPlayerData()
    return LL.PlayerData
end

-- Játékos betöltve van-e
function LL.IsPlayerLoaded()
    return LL.PlayerLoaded
end

-- Karakter ID lekérése
function LL.GetCharacterId()
    return LL.PlayerData.charid or 0
end

-- Pénz lekérése
function LL.GetMoney(account)
    account = account or 'cash'
    if LL.PlayerData.accounts then
        for _, acc in pairs(LL.PlayerData.accounts) do
            if acc.name == account then
                return acc.money
            end
        end
    end
    return 0
end

-- Координáták lekérése
function LL.GetCoords()
    return GetEntityCoords(PlayerPedId())
end

-- Heading lekérése
function LL.GetHeading()
    return GetEntityHeading(PlayerPedId())
end

-- Távolság számítás
function LL.GetDistanceBetweenCoords(coords1, coords2)
    return #(vector3(coords1.x, coords1.y, coords1.z) - vector3(coords2.x, coords2.y, coords2.z))
end

-- Spawn protection kezelése
function LL.ApplySpawnProtection(duration)
    local ped = PlayerPedId()
    
    -- God mode bekapcsolása
    SetEntityInvincible(ped, true)
    
    -- Timer indítása
    LL.Notify(_('spawn_protected', duration), 'info', duration * 1000)
    
    -- Időzítés
    Citizen.SetTimeout(duration * 1000, function()
        SetEntityInvincible(ped, false)
        LL.Notify(_('spawn_protection_ended'), 'success')
    end)
end

-- Screen fade kezelés
function LL.FadeScreen(fadeOut, duration)
    if fadeOut then
        DoScreenFadeOut(duration)
        while not IsScreenFadedOut() do
            Citizen.Wait(10)
        end
    else
        DoScreenFadeIn(duration)
        while not IsScreenFadedIn() do
            Citizen.Wait(10)
        end
    end
end

-- Kamera freeze
function LL.FreezeCamera(freeze)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    if freeze then
        local coords = LL.GetCoords()
        local heading = LL.GetHeading()
        
        SetCamCoord(cam, coords.x, coords.y, coords.z + 2.0)
        SetCamRot(cam, -20.0, 0.0, heading)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
    end
end

-- Admin check
function LL.IsAdmin()
    return LL.PlayerData.group and table.contains(Config.Commands.AdminGroups, LL.PlayerData.group)
end

-- Table contains helper
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Progressbar helper (későbbi integráció)
function LL.Progressbar(duration, label, callback)
    -- TODO: ll-progressbar integrálása
    Citizen.SetTimeout(duration, function()
        if callback then
            callback()
        end
    end)
end

-- Input helper
function LL.KeyboardInput(title, defaultText, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', title)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", defaultText or "", "", "", "", maxLength or 255)
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        return result
    else
        return nil
    end
end