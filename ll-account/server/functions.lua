Account = {}
Account.PlayerCreationTimestamps = {} -- Rate limiting
Account.PlayerCreationCount = {}      -- Daily limit tracking

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

-- Identifier lekérése
function Account.GetIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, id in pairs(identifiers) do
        if string.match(id, 'license:') then
            return id
        end
    end
    
    return nil
end

-- Név validáció (server-side)
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
    
    -- Blacklist
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
    
    local year, month, day = string.match(dateStr, '(%d+)-(%d+)-(%d+)')
    
    if not year or not month or not day then
        return false, _('date_invalid')
    end
    
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    
    -- Életkor
    local currentYear = tonumber(os.date('%Y'))
    local age = currentYear - year
    
    if age < Config.Character.DateOfBirth.MinAge then
        return false, _('age_too_young', Config.Character.DateOfBirth.MinAge)
    end
    
    if age > Config.Character.DateOfBirth.MaxAge then
        return false, _('age_too_old', Config.Character.DateOfBirth.MaxAge)
    end
    
    return true
end

-- Rate limit check (cooldown)
function Account.CheckRateLimit(source)
    if not Config.Security.EnableAnticheat then
        return true
    end
    
    local identifier = Account.GetIdentifier(source)
    if not identifier then return false end
    
    local lastCreation = Account.PlayerCreationTimestamps[identifier]
    
    if lastCreation then
        local timeSince = os.time() - lastCreation
        
        if timeSince < Config.Security.CooldownBetweenCreations then
            local remaining = Config.Security.CooldownBetweenCreations - timeSince
            return false, _('creation_cooldown', remaining)
        end
    end
    
    return true
end

-- Napi limit check
function Account.CheckDailyLimit(source)
    if not Config.Security.EnableAnticheat then
        return true
    end
    
    local identifier = Account.GetIdentifier(source)
    if not identifier then return false end
    
    local today = os.date('%Y-%m-%d')
    
    if not Account.PlayerCreationCount[identifier] then
        Account.PlayerCreationCount[identifier] = {date = today, count = 0}
    end
    
    local data = Account.PlayerCreationCount[identifier]
    
    -- Ha más nap, reset
    if data.date ~= today then
        data.date = today
        data.count = 0
    end
    
    if data.count >= Config.Security.MaxCharactersPerDay then
        return false, _('too_many_today')
    end
    
    return true
end

-- Rate limit frissítése
function Account.UpdateRateLimit(source)
    local identifier = Account.GetIdentifier(source)
    if not identifier then return end
    
    Account.PlayerCreationTimestamps[identifier] = os.time()
    
    if not Account.PlayerCreationCount[identifier] then
        Account.PlayerCreationCount[identifier] = {date = os.date('%Y-%m-%d'), count = 0}
    end
    
    Account.PlayerCreationCount[identifier].count = Account.PlayerCreationCount[identifier].count + 1
end

-- Discord webhook log
function Account.LogToDiscord(title, description, color, fields)
    if not Config.Logging.EnableDiscordLog or Config.Logging.WebhookURL == '' then
        return
    end
    
    local embed = {
        {
            ['title'] = title,
            ['description'] = description,
            ['color'] = color or 3447003,
            ['fields'] = fields or {},
            ['footer'] = {
                ['text'] = Config.ServerName .. ' | ' .. os.date('%Y-%m-%d %H:%M:%S')
            }
        }
    }
    
    PerformHttpRequest(Config.Logging.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = 'Last Light Account',
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

-- Kezdő apokalipszis státuszok beállítása
function Account.SetStartingApocalypseStats(charid, stats)
    if not stats then return end
    
    MySQL.Async.execute([[
        INSERT INTO apocalypse_stats (charid, sanity, radiation, hunger, thirst, infection)
        VALUES (@charid, @sanity, @radiation, @hunger, @thirst, @infection)
        ON DUPLICATE KEY UPDATE
            sanity = @sanity,
            radiation = @radiation,
            hunger = @hunger,
            thirst = @thirst,
            infection = @infection
    ]], {
        ['@charid'] = charid,
        ['@sanity'] = stats.sanity or 100,
        ['@radiation'] = stats.radiation or 0,
        ['@hunger'] = stats.hunger or 100,
        ['@thirst'] = stats.thirst or 100,
        ['@infection'] = stats.infection or 0
    })
end