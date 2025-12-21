Account = {}
Account.IsInCharacterSelection = false
Account.CurrentCharacter = nil
Account.Characters = {}

-- Lokalizáció
function _(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return str
    end
end

-- Debug print
function Account.Debug(msg)
    if Config.Debug then
        print('^3[LL-ACCOUNT DEBUG]^7 ' .. msg)
    end
end

-- NUI megjelenítése
function Account.ShowUI(show)
    SetNuiFocus(show, show)
    SendNUIMessage({
        action = 'setVisible',
        visible = show
    })
    
    Account.IsInCharacterSelection = show
end

-- Karakterválasztó megnyitása
function Account.OpenCharacterSelection(characters)
    Account.Characters = characters or {}
    Account.Debug('Opening character selection with ' .. #Account.Characters .. ' characters')
    
    -- Config küldése NUI-nak
    SendNUIMessage({
        action = 'setConfig',
        config = {
            maxCharacters = Config.Character.MaxCharacters,
            enableDelete = Config.Character.EnableDelete,
            locale = Config.Locale
        }
    })
    
    -- Karakterek küldése
    SendNUIMessage({
        action = 'loadCharacters',
        characters = Account.Characters
    })
    
    Account.ShowUI(true)
    
    -- Kamera beállítás
    if Config.SelectionCamera.Enable then
        Account.SetupSelectionCamera()
    end
end

-- Karakter kreátor megnyitása
function Account.OpenCharacterCreator()
    Account.Debug('Opening character creator')
    
    SendNUIMessage({
        action = 'openCreator',
        config = {
            minAge = Config.Character.DateOfBirth.MinAge,
            maxAge = Config.Character.DateOfBirth.MaxAge,
            minHeight = Config.Character.Height.Min,
            maxHeight = Config.Character.Height.Max,
            nameMinLength = Config.Character.Name.MinLength,
            nameMaxLength = Config.Character.Name.MaxLength,
            spawnLocations = Config.Spawn.NewCharacterSpawns
        }
    })
end

-- Karakterválasztó kamera
function Account.SetupSelectionCamera()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Kamera létrehozása
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    local camCoords = coords + vector3(
        Config.SelectionCamera.Distance * math.cos(0),
        Config.SelectionCamera.Distance * math.sin(0),
        Config.SelectionCamera.Height
    )
    
    SetCamCoord(cam, camCoords)
    PointCamAtEntity(cam, playerPed, 0.0, 0.0, 0.0, true)
    SetCamFov(cam, Config.SelectionCamera.Fov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    Account.CurrentCamera = cam
end

-- Kamera törlése
function Account.DestroyCamera()
    if Account.CurrentCamera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(Account.CurrentCamera, false)
        Account.CurrentCamera = nil
    end
end

-- Név validáció
function Account.ValidateName(name)
    if not name or name == '' then
        return false, _('all_fields_required')
    end
    
    local len = string.len(name)
    
    if len < Config.Character.Name.MinLength then
        return false, _('name_too_short', Config.Character.Name.MinLength)
    end
    
    if len > Config.Character.Name.MaxLength then
        return false, _('name_too_long', Config.Character.Name.MaxLength)
    end
    
    if not string.match(name, Config.Character.Name.Pattern) then
        return false, _('name_invalid')
    end
    
    -- Blacklist check
    local lowerName = string.lower(name)
    for _, blacklisted in pairs(Config.Security.BlacklistedNames) do
        if string.find(lowerName, string.lower(blacklisted)) then
            return false, _('name_blacklisted')
        end
    end
    
    return true
end

-- Dátum validáció
function Account.ValidateDateOfBirth(dateStr)
    if not dateStr then
        return false, _('date_invalid')
    end
    
    -- Parse dátum (YYYY-MM-DD)
    local year, month, day = string.match(dateStr, '(%d+)-(%d+)-(%d+)')
    
    if not year or not month or not day then
        return false, _('date_invalid')
    end
    
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    
    -- Életkor számítás
    local currentYear = GetLocalTime()
    local age = currentYear - year
    
    if age < Config.Character.DateOfBirth.MinAge then
        return false, _('age_too_young', Config.Character.DateOfBirth.MinAge)
    end
    
    if age > Config.Character.DateOfBirth.MaxAge then
        return false, _('age_too_old', Config.Character.DateOfBirth.MaxAge)
    end
    
    return true
end

-- Magasság validáció
function Account.ValidateHeight(height)
    height = tonumber(height)
    
    if not height then
        return false, _('height_invalid', Config.Character.Height.Min, Config.Character.Height.Max)
    end
    
    if height < Config.Character.Height.Min or height > Config.Character.Height.Max then
        return false, _('height_invalid', Config.Character.Height.Min, Config.Character.Height.Max)
    end
    
    return true
end

-- Screen fade
function Account.FadeScreen(fadeOut, duration)
    duration = duration or 1000
    
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

-- Freeze player
function Account.FreezePlayer(freeze)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, freeze)
    SetPlayerInvincible(PlayerId(), freeze)
    
    if freeze then
        SetEntityVisible(ped, false, false)
    else
        SetEntityVisible(ped, true, false)
    end
end

-- Notify wrapper
function Account.Notify(msg, type, duration)
    if GetResourceState('ll-notify') == 'started' then
        exports['ll-notify']:Notify(msg, type or 'info', duration or 5000)
    else
        -- Fallback
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

-- Tutorial megjelenítés
function Account.ShowTutorial()
    if not Config.Tutorial.Enable or not Config.Tutorial.ShowForNewPlayers then
        return
    end
    
    for i, step in ipairs(Config.Tutorial.Steps) do
        Citizen.Wait(step.duration)
        Account.Notify(step.description, 'info', step.duration)
    end
end