-- LL-NOTIFY PÉLDÁK ÉS INTEGRÁCIÓK
-- Ez a fájl NEM része a resource-nak, csak példák!

-- ========================================
-- ALAP NOTIFICATION PÉLDÁK
-- ========================================

-- Egyszerű success
RegisterCommand('testsuccess', function()
    exports['ll-notify']:Success('Sikeresen elmentve!')
end)

-- Error címmel
RegisterCommand('testerror', function()
    exports['ll-notify']:Error('Nem sikerült betölteni az adatokat!', 5000, 'HIBA')
end)

-- Warning hosszabb idővel
RegisterCommand('testwarning', function()
    exports['ll-notify']:Warning('Alacsony a tárhelyed! Csak 10% maradt.', 7000)
end)

-- Info rövid idővel
RegisterCommand('testinfo', function()
    exports['ll-notify']:Info('Új üzeneted érkezett', 2000)
end)

-- ========================================
-- APOKALIPSZIS SPECIFIKUS
-- ========================================

-- Radiáció figyelmeztetés
RegisterNetEvent('apocalypse:enterRadZone', function(zoneName)
    exports['ll-notify']:Radiation('☢️ Radiációs zónába léptél: ' .. zoneName, 7000, 'VESZÉLY!')
end)

-- Zombie közelség
RegisterNetEvent('apocalypse:zombieDetected', function(distance)
    local message = string.format('🧟 Zombie %.1f méterre tőled!', distance)
    exports['ll-notify']:Zombie(message, 5000, 'FIGYELEM')
end)

-- Sanity csökkenés
RegisterNetEvent('apocalypse:sanityLow', function(sanityLevel)
    if sanityLevel <= 10 then
        exports['ll-notify']:Sanity('🧠 KRITIKUS ELMEÁLLAPOT!', 5000, 'VESZÉLY')
    elseif sanityLevel <= 30 then
        exports['ll-notify']:Sanity('Elméd gyengül...', 4000)
    end
end)

-- Fertőzés
RegisterNetEvent('apocalypse:infected', function(infectionLevel)
    exports['ll-notify']:Infection('🦠 Megfertőződtél! (' .. infectionLevel .. '%)', 6000, 'FERTŐZÉS')
end)

-- Éhség/Szomjúság
RegisterNetEvent('apocalypse:needsLow', function(type, level)
    if type == 'hunger' then
        exports['ll-notify']:Hunger('🍖 Éhség: ' .. level .. '%', 3000)
    elseif type == 'thirst' then
        exports['ll-notify']:Thirst('💧 Szomjúság: ' .. level .. '%', 3000)
    end
end)

-- ========================================
-- PROGRESSBAR PÉLDÁK
-- ========================================

-- Egyszerű progressbar
RegisterCommand('testprogress', function()
    exports['ll-notify']:Progress(5000, 'Betöltés...', function()
        exports['ll-notify']:Success('Kész!')
    end)
end)

-- Gyűjtés progressbar ESC-el megszakítható
RegisterCommand('gather', function()
    local ped = PlayerPedId()
    
    -- Animáció
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)
    
    exports['ll-notify']:Progress(10000, 'Gyűjtés folyamatban...', function()
        -- Sikeres befejezés
        ClearPedTasks(ped)
        exports['ll-notify']:Success('Sikeresen összegyűjtötted az itemeket!')
        
        -- TODO: Add items to inventory
    end, function()
        -- Megszakítva
        ClearPedTasks(ped)
        exports['ll-notify']:Warning('Megszakítottad a gyűjtést!')
    end)
end)

-- Crafting progressbar
RegisterCommand('craft', function(source, args)
    local itemName = args[1] or 'Bandage'
    
    exports['ll-notify']:Progress(8000, 'Crafting: ' .. itemName, function()
        exports['ll-notify']:Success('Sikeresen elkészítetted: ' .. itemName)
        -- TODO: Give item
    end, function()
        exports['ll-notify']:Error('Crafting megszakítva!')
    end)
end)

-- ========================================
-- PERSISTENT NOTIFICATION PÉLDÁK
-- ========================================

-- Raid indítása
RegisterCommand('startraid', function()
    local raidId = exports['ll-notify']:Persistent('⚔️ Raid folyamatban...', 'warning', 'raid_active', 'AKTÍV RAID')
    
    -- 2 perc múlva bezárjuk
    Citizen.SetTimeout(120000, function()
        exports['ll-notify']:RemovePersistent(raidId)
        exports['ll-notify']:Success('Raid befejezve!', 5000)
    end)
end)

-- Admin mód persistent
local adminNotifId = nil
RegisterCommand('adminmode', function()
    if adminNotifId then
        -- Kikapcsolás
        exports['ll-notify']:RemovePersistent(adminNotifId)
        adminNotifId = nil
        exports['ll-notify']:Info('Admin mód kikapcsolva')
    else
        -- Bekapcsolás
        adminNotifId = exports['ll-notify']:Persistent('👮 Admin mód aktív', 'info', 'admin_mode', 'ADMIN')
        exports['ll-notify']:Success('Admin mód bekapcsolva')
    end
end)

-- ========================================
-- CUSTOM NOTIFICATION PÉLDÁK
-- ========================================

-- Pénz kapás
RegisterNetEvent('banking:receiveMoney', function(amount)
    exports['ll-notify']:Custom(
        'Kaptál $' .. amount .. ' készpénzt',
        '💰',
        '#10b981',
        4000,
        'Pénzügy'
    )
end)

-- Telefonhívás
RegisterNetEvent('phone:incomingCall', function(caller)
    exports['ll-notify']:Custom(
        'Bejövő hívás: ' .. caller,
        '📱',
        '#3b82f6',
        10000,
        'Telefon'
    )
end)

-- Level up
RegisterNetEvent('character:levelUp', function(level)
    exports['ll-notify']:Custom(
        'Gratulálunk! Elértél ' .. level .. '. szintet!',
        '🎉',
        '#fbbf24',
        6000,
        'SZINT FEL'
    )
end)

-- ========================================
-- LL-CORE INTEGRÁCIÓ
-- ========================================

-- Halál
RegisterNetEvent('ll-core:onPlayerDeath', function()
    exports['ll-notify']:Error('💀 Meghaltál!', 5000, 'HALÁL')
end)

-- Újraéledés
RegisterNetEvent('ll-core:onPlayerRevive', function()
    exports['ll-notify']:Success('❤️ Újraéledtél!', 4000, 'ÉLET')
end)

-- Pénz kapás
RegisterNetEvent('ll-core:client:receiveMoney', function(account, amount)
    local accountName = account == 'cash' and 'Készpénz' or 'Bank'
    exports['ll-notify']:Success('Kaptál $' .. amount .. ' (' .. accountName .. ')', 3000, 'Pénzügy')
end)

-- Admin parancs használat
RegisterNetEvent('ll-core:admin:commandUsed', function(command)
    exports['ll-notify']:Info('Admin parancs végrehajtva: /' .. command, 2000)
end)

-- ========================================
-- LL-INVENTORY INTEGRÁCIÓ
-- ========================================

-- Item használat
RegisterNetEvent('ll-inventory:client:useItem', function(item)
    exports['ll-notify']:Success('Használtad: ' .. item.label, 2000)
end)

-- Item kapás
RegisterNetEvent('ll-inventory:client:addItem', function(item, count)
    exports['ll-notify']:Info('Kaptál: ' .. count .. 'x ' .. item.label, 3000)
end)

-- Item eltávolítás
RegisterNetEvent('ll-inventory:client:removeItem', function(item, count)
    exports['ll-notify']:Warning('Eltávolítva: ' .. count .. 'x ' .. item.label, 3000)
end)

-- Inventory teli
RegisterNetEvent('ll-inventory:client:full', function()
    exports['ll-notify']:Error('Az inventory tele van!', 4000, 'INVENTORY')
end)

-- ========================================
-- SZERVER OLDALI PÉLDÁK
-- ========================================

-- SERVER SIDE:


-- Játékos csatlakozás
AddEventHandler('playerConnecting', function(name)
    local source = source
    
    Citizen.SetTimeout(2000, function()
        exports['ll-notify']:Success(source, 'Üdvözlünk a szerveren, ' .. name .. '!', 5000, 'ÜDVÖZLET')
    end)
end)

-- Minden játékosnak broadcast
RegisterCommand('announce', function(source, args)
    if not IsPlayerAceAllowed(source, 'admin') then return end
    
    local message = table.concat(args, ' ')
    exports['ll-notify']:Broadcast(message, 'info', 10000, 'BEJELENTÉS')
end)

-- Játékos büntetés
RegisterNetEvent('admin:warnPlayer', function(target, reason)
    local source = source
    
    if not IsPlayerAceAllowed(source, 'admin') then return end
    
    exports['ll-notify']:Error(target, '⚠️ Figyelmeztetés: ' .. reason, 10000, 'ADMIN')
    exports['ll-notify']:Success(source, 'Játékos figyelmeztetve', 3000)
end)

-- Restart figyelmeztetés
RegisterCommand('restartwarn', function(source, args)
    if not IsPlayerAceAllowed(source, 'admin') then return end
    
    local minutes = tonumber(args[1]) or 5
    
    exports['ll-notify']:Broadcast(
        'A szerver újraindul ' .. minutes .. ' perc múlva!',
        'warning',
        15000,
        '⚠️ RESTART'
    )
end)

-- Radiációs vihar (server broadcast)
function StartRadiationStorm()
    -- Figyelmeztetés
    exports['ll-notify']:Broadcast(
        '☢️ RADIÁCIÓS VIHAR KÖZELEDIK! Keress menedéket!',
        'radiation',
        10000,
        'VESZÉLY'
    )
    
    -- Vihar indítás
    Citizen.SetTimeout(60000, function()
        TriggerClientEvent('apocalypse:radStormStart', -1)
    end)
end


-- ========================================
-- EVENT CHAIN PÉLDA
-- ========================================

-- Komplex eseménylánc notification-ökkel
RegisterCommand('complexevent', function()
    -- 1. Kezdés
    exports['ll-notify']:Info('Esemény indítása...', 2000)
    
    Citizen.SetTimeout(2000, function()
        -- 2. Progressbar
        exports['ll-notify']:Progress(5000, 'Előkészítés...', function()
            -- 3. Sikeres előkészítés
            exports['ll-notify']:Success('Előkészítés kész!', 2000)
            
            Citizen.SetTimeout(2000, function()
                -- 4. Második progressbar
                exports['ll-notify']:Progress(8000, 'Végrehajtás...', function()
                    -- 5. Befejezés
                    exports['ll-notify']:Custom(
                        'Esemény sikeresen befejezve!',
                        '🎉',
                        '#10b981',
                        5000,
                        'SIKER'
                    )
                end, function()
                    -- Megszakítva
                    exports['ll-notify']:Error('Esemény megszakítva!', 4000)
                end)
            end)
        end, function()
            -- Előkészítés megszakítva
            exports['ll-notify']:Warning('Előkészítés megszakítva', 3000)
        end)
    end)
end)

-- ========================================
-- APOKALIPSZIS FULL INTEGRÁCIÓ
-- ========================================

-- Stat változások figyelése
Citizen.CreateThread(function()
    local lastRadiation = 0
    local lastSanity = 100
    
    while true do
        Citizen.Wait(5000) -- 5 másodpercenként check
        
        local apocalypseData = exports['ll-core']:GetApocalypseData()
        
        if apocalypseData then
            -- Radiáció threshold check
            if apocalypseData.radiation >= 50 and lastRadiation < 50 then
                exports['ll-notify']:Radiation('☢️ MAGAS SUGÁRZÁS!', 7000, 'VESZÉLY')
            elseif apocalypseData.radiation >= 75 and lastRadiation < 75 then
                exports['ll-notify']:Radiation('☢️ KRITIKUS SUGÁRZÁS!', 10000, '💀 ÉLETVESZÉLY')
            end
            
            -- Sanity threshold check
            if apocalypseData.sanity <= 30 and lastSanity > 30 then
                exports['ll-notify']:Sanity('🧠 Elméd gyengül...', 5000)
            elseif apocalypseData.sanity <= 10 and lastSanity > 10 then
                exports['ll-notify']:Sanity('🧠 KRITIKUS ELMEÁLLAPOT!', 8000, '💀 VESZÉLY')
            end
            
            lastRadiation = apocalypseData.radiation
            lastSanity = apocalypseData.sanity
        end
    end
end)