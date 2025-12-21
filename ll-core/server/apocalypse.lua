-- APOKALIPSZIS RENDSZER - SERVER SIDE

if not Config.Apocalypse.Enabled then return end

-- Játékos apokalipszis adatok tárolása
local PlayerApocalypseStats = {}

-- Játékos apokalipszis adatainak betöltése
AddEventHandler('ll-core:playerLoaded', function(source, player)
    -- Adatbázisból betöltés
    MySQL.Async.fetchAll('SELECT * FROM apocalypse_stats WHERE charid = @charid', {
        ['@charid'] = player.charid
    }, function(result)
        if result[1] then
            PlayerApocalypseStats[source] = {
                sanity = result[1].sanity,
                radiation = result[1].radiation,
                hunger = result[1].hunger,
                thirst = result[1].thirst,
                infection = result[1].infection
            }
        else
            -- Új játékos, alapértelmezett értékek
            PlayerApocalypseStats[source] = {
                sanity = Config.Apocalypse.Sanity.StartingSanity,
                radiation = Config.Apocalypse.Radiation.StartingRadiation,
                hunger = Config.Apocalypse.Needs.Hunger.Starting,
                thirst = Config.Apocalypse.Needs.Thirst.Starting,
                infection = 0
            }
            
            -- Beszúrás adatbázisba
            MySQL.Async.execute([[
                INSERT INTO apocalypse_stats (charid, sanity, radiation, hunger, thirst, infection)
                VALUES (@charid, @sanity, @radiation, @hunger, @thirst, @infection)
            ]], {
                ['@charid'] = player.charid,
                ['@sanity'] = PlayerApocalypseStats[source].sanity,
                ['@radiation'] = PlayerApocalypseStats[source].radiation,
                ['@hunger'] = PlayerApocalypseStats[source].hunger,
                ['@thirst'] = PlayerApocalypseStats[source].thirst,
                ['@infection'] = PlayerApocalypseStats[source].infection
            })
        end
        
        LL.Debug('Apocalypse stats loaded for player: ' .. player.name)
    end)
end)

-- Apokalipszis státuszok frissítése
RegisterNetEvent('ll-core:server:updateApocalypseStats', function(stats)
    local source = source
    local player = LL.GetPlayer(source)
    
    if not player then return end
    
    PlayerApocalypseStats[source] = stats
    
    -- Adatbázis mentés
    MySQL.Async.execute([[
        UPDATE apocalypse_stats SET
            sanity = @sanity,
            radiation = @radiation,
            hunger = @hunger,
            thirst = @thirst,
            infection = @infection
        WHERE charid = @charid
    ]], {
        ['@charid'] = player.charid,
        ['@sanity'] = stats.sanity,
        ['@radiation'] = stats.radiation,
        ['@hunger'] = stats.hunger,
        ['@thirst'] = stats.thirst,
        ['@infection'] = stats.infection
    })
end)

-- Játékos kilépéskor mentés
AddEventHandler('ll-core:playerDropped', function(source, reason)
    if PlayerApocalypseStats[source] then
        local player = LL.GetPlayer(source)
        
        if player then
            MySQL.Async.execute([[
                UPDATE apocalypse_stats SET
                    sanity = @sanity,
                    radiation = @radiation,
                    hunger = @hunger,
                    thirst = @thirst,
                    infection = @infection
                WHERE charid = @charid
            ]], {
                ['@charid'] = player.charid,
                ['@sanity'] = PlayerApocalypseStats[source].sanity,
                ['@radiation'] = PlayerApocalypseStats[source].radiation,
                ['@hunger'] = PlayerApocalypseStats[source].hunger,
                ['@thirst'] = PlayerApocalypseStats[source].thirst,
                ['@infection'] = PlayerApocalypseStats[source].infection
            })
        end
        
        PlayerApocalypseStats[source] = nil
    end
end)

-- Apokalipszis státuszok lekérése
function LL.GetApocalypseStats(source)
    return PlayerApocalypseStats[source]
end

-- Étel/ital használat
RegisterNetEvent('ll-core:server:consumeItem', function(item, hunger, thirst)
    local source = source
    local player = LL.GetPlayer(source)
    
    if not player then return end
    
    -- TODO: Item eltávolítás inventory-ból (ll-inventory integration)
    
    -- Kliens értesítése
    TriggerClientEvent('ll-core:client:consumeFood', source, item, hunger, thirst)
end)

-- Fertőzés hozzáadása (zombie támadás)
RegisterNetEvent('ll-core:server:addInfection', function(target, amount)
    local source = source
    
    -- Admin check vagy validálás
    if not LL.IsAdmin(source) then
        -- Validálás: közel van-e a target?
        -- TODO: távolság ellenőrzés
    end
    
    if PlayerApocalypseStats[target] then
        PlayerApocalypseStats[target].infection = math.min(100, PlayerApocalypseStats[target].infection + amount)
        
        TriggerClientEvent('ll-core:client:addInfection', target, amount)
    end
end)

-- Admin parancsok apokalipszis státuszokhoz
RegisterCommand('setstat', function(source, args)
    if not LL.IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, 'Nincs jogosultságod!', 'error')
        return
    end
    
    if #args < 3 then
        TriggerClientEvent('ll-core:client:notify', source, 'Használat: /setstat [id] [stat] [value]', 'info')
        TriggerClientEvent('ll-core:client:notify', source, 'Stats: sanity, radiation, hunger, thirst, infection', 'info')
        return
    end
    
    local target = tonumber(args[1])
    local stat = args[2]
    local value = tonumber(args[3])
    
    if not PlayerApocalypseStats[target] then
        TriggerClientEvent('ll-core:client:notify', source, 'Játékos nem található!', 'error')
        return
    end
    
    if PlayerApocalypseStats[target][stat] ~= nil then
        PlayerApocalypseStats[target][stat] = value
        
        TriggerClientEvent('ll-core:client:notify', source, 'Stat módosítva: ' .. stat .. ' = ' .. value, 'success')
        TriggerClientEvent('ll-core:client:notify', target, 'Admin módosította a(z) ' .. stat .. ' értékedet', 'info')
    else
        TriggerClientEvent('ll-core:client:notify', source, 'Érvénytelen stat!', 'error')
    end
end)

-- Exports
exports('GetApocalypseStats', function(source)
    return LL.GetApocalypseStats(source)
end)