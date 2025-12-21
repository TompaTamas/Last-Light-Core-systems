-- Pénz kezelés server-side
RegisterNetEvent('ll-core:server:giveMoney', function(target, account, amount)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    local targetPlayer = LL.GetPlayer(target)
    
    if targetPlayer then
        targetPlayer.addMoney(account, amount)
        
        -- Értesítés célpontnak
        TriggerClientEvent('ll-core:client:notify', target, _('received_money', amount), 'success')
    end
end)

-- Pénz elvétel
RegisterNetEvent('ll-core:server:removeMoney', function(target, account, amount)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    local targetPlayer = LL.GetPlayer(target)
    
    if targetPlayer then
        if targetPlayer.removeMoney(account, amount) then
            TriggerClientEvent('ll-core:client:notify', target, _('paid_amount', amount), 'error')
        else
            TriggerClientEvent('ll-core:client:notify', source, _('not_enough_money'), 'error')
        end
    end
end)

-- Pénz beállítása
RegisterNetEvent('ll-core:server:setMoney', function(target, account, amount)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    local targetPlayer = LL.GetPlayer(target)
    
    if targetPlayer then
        targetPlayer.setMoney(account, amount)
    end
end)

-- Group beállítása
RegisterNetEvent('ll-core:server:setGroup', function(target, group)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    local targetPlayer = LL.GetPlayer(target)
    
    if targetPlayer then
        targetPlayer.setGroup(group)
        
        TriggerClientEvent('ll-core:client:notify', source, 'Csoport módosítva: ' .. group, 'success')
        TriggerClientEvent('ll-core:client:notify', target, 'Csoportod megváltozott: ' .. group, 'info')
    end
end)

-- Teleportálás
RegisterNetEvent('ll-core:server:teleportPlayer', function(target, coords)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        TriggerClientEvent('ll-core:client:spawnPlayer', target, coords, 0.0)
        
        TriggerClientEvent('ll-core:client:notify', source, 'Játékos teleportálva', 'success')
    end
end)

-- Újraélesztés
RegisterNetEvent('ll-core:server:revivePlayer', function(target)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        TriggerClientEvent('ll-core:client:revive', target)
        
        local targetPlayer = LL.GetPlayer(target)
        if targetPlayer then
            TriggerClientEvent('ll-core:client:notify', source, _('revived_player', targetPlayer.name), 'success')
        end
    end
end)

-- Gyógyítás
RegisterNetEvent('ll-core:server:healPlayer', function(target)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        TriggerClientEvent('ll-core:client:heal', target)
    end
end)

-- Heal event kezelése kliensnek
RegisterNetEvent('ll-core:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)
end)

-- God mode toggle
RegisterNetEvent('ll-core:server:toggleGodMode', function(target, enabled)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        TriggerClientEvent('ll-core:client:setGodMode', target, enabled)
    end
end)

-- Láthatóság toggle
RegisterNetEvent('ll-core:server:toggleInvisible', function(target, enabled)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        TriggerClientEvent('ll-core:client:setInvisible', target, enabled)
    end
end)

-- Játékos kick
RegisterNetEvent('ll-core:server:kickPlayer', function(target, reason)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    if GetPlayerPing(target) > 0 then
        DropPlayer(target, reason or 'Kirúgva egy admin által')
    end
end)

-- Broadcast üzenet
RegisterNetEvent('ll-core:server:broadcast', function(message)
    local source = source
    
    if not LL.IsAdmin(source) then
        DropPlayer(source, 'Unauthorized command usage')
        return
    end
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 0, 0},
        multiline = true,
        args = {"[ANNOUNCEMENT]", message}
    })
end)