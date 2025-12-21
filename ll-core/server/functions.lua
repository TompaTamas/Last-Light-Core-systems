LL = {}
LL.Players = {}
LL.Commands = {}

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

-- Játékos lekérése source alapján
function LL.GetPlayer(source)
    return LL.Players[source]
end

-- Játékos lekérése character ID alapján
function LL.GetPlayerByCharId(charid)
    for _, player in pairs(LL.Players) do
        if player.charid == charid then
            return player
        end
    end
    return nil
end

-- Összes játékos lekérése
function LL.GetPlayers()
    return LL.Players
end

-- Játékos létrehozása
function LL.CreatePlayer(source, data)
    local self = {}
    
    self.source = source
    self.identifier = data.identifier
    self.charid = data.charid
    self.name = data.name
    self.group = data.group or 'user'
    self.accounts = data.accounts or {
        {name = 'cash', money = Config.Player.DefaultMoney},
        {name = 'bank', money = Config.Player.DefaultBank}
    }
    self.position = data.position or nil
    self.health = data.health or 200
    self.armor = data.armor or 0
    
    -- Pénz kezelés
    function self.getMoney(account)
        account = account or 'cash'
        for _, acc in pairs(self.accounts) do
            if acc.name == account then
                return acc.money
            end
        end
        return 0
    end
    
    function self.addMoney(account, amount)
        account = account or 'cash'
        amount = math.floor(tonumber(amount))
        
        if amount <= 0 then return false end
        
        for i, acc in pairs(self.accounts) do
            if acc.name == account then
                self.accounts[i].money = self.accounts[i].money + amount
                
                -- Frissítés kliensnek
                TriggerClientEvent('ll-core:client:updateMoney', self.source, account, self.accounts[i].money)
                
                -- Log
                LL.Debug(string.format('Player %s received $%d in %s', self.name, amount, account))
                
                return true
            end
        end
        return false
    end
    
    function self.removeMoney(account, amount)
        account = account or 'cash'
        amount = math.floor(tonumber(amount))
        
        if amount <= 0 then return false end
        
        for i, acc in pairs(self.accounts) do
            if acc.name == account then
                if self.accounts[i].money >= amount then
                    self.accounts[i].money = self.accounts[i].money - amount
                    
                    -- Frissítés kliensnek
                    TriggerClientEvent('ll-core:client:updateMoney', self.source, account, self.accounts[i].money)
                    
                    -- Log
                    LL.Debug(string.format('Player %s lost $%d in %s', self.name, amount, account))
                    
                    return true
                else
                    return false
                end
            end
        end
        return false
    end
    
    function self.setMoney(account, amount)
        account = account or 'cash'
        amount = math.floor(tonumber(amount))
        
        if amount < 0 then return false end
        
        for i, acc in pairs(self.accounts) do
            if acc.name == account then
                self.accounts[i].money = amount
                
                -- Frissítés kliensnek
                TriggerClientEvent('ll-core:client:updateMoney', self.source, account, amount)
                
                return true
            end
        end
        return false
    end
    
    -- Group/permission kezelés
    function self.getGroup()
        return self.group
    end
    
    function self.setGroup(group)
        self.group = group
        
        -- Frissítés adatbázisban
        MySQL.Async.execute('UPDATE users SET `group` = @group WHERE identifier = @identifier', {
            ['@identifier'] = self.identifier,
            ['@group'] = group
        })
        
        -- Frissítés kliensnek
        TriggerClientEvent('ll-core:client:updatePlayerData', self.source, {group = group})
    end
    
    function self.hasPermission(permission)
        if self.group == 'superadmin' then
            return true
        end
        
        if permission == 'admin' and (self.group == 'admin' or self.group == 'superadmin') then
            return true
        end
        
        if permission == 'moderator' and table.contains(Config.Commands.AdminGroups, self.group) then
            return true
        end
        
        return false
    end
    
    -- Játékos adat mentése
    function self.save()
        MySQL.Async.execute([[
            UPDATE characters SET
                position = @position,
                health = @health,
                armor = @armor,
                accounts = @accounts
            WHERE id = @charid
        ]], {
            ['@charid'] = self.charid,
            ['@position'] = self.position or '{}',
            ['@health'] = self.health,
            ['@armor'] = self.armor,
            ['@accounts'] = json.encode(self.accounts)
        }, function(affectedRows)
            if affectedRows > 0 then
                LL.Debug('Player data saved: ' .. self.name)
            end
        end)
    end
    
    return self
end

-- Admin check
function LL.IsAdmin(source)
    local player = LL.GetPlayer(source)
    if player then
        return player.hasPermission('admin')
    end
    return false
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

-- Discord webhook logger
function LL.SendWebhook(title, message, color)
    if not Config.DiscordWebhook.Enabled then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or 3447003,
            ["footer"] = {
                ["text"] = Config.ServerName .. " | " .. os.date('%Y-%m-%d %H:%M:%S'),
            },
        }
    }
    
    PerformHttpRequest(Config.DiscordWebhook.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = Config.DiscordWebhook.BotName,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end