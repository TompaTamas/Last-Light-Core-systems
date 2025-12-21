-- Admin parancsok rendszere

-- Helper: Admin check parancsokhoz
local function IsAdmin(source)
    local player = LL.GetPlayer(source)
    if player then
        return player.hasPermission('admin')
    end
    return false
end

-- /save - Manuális mentés
RegisterCommand('save', function(source, args)
    local player = LL.GetPlayer(source)
    
    if player then
        player.save()
        TriggerClientEvent('ll-core:client:notify', source, _('data_saved'), 'success')
    end
end)

-- /heal [id] - Gyógyítás
RegisterCommand(Config.Commands.HealCommand, function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    local target = tonumber(args[1]) or source
    
    if GetPlayerPing(target) > 0 then
        TriggerEvent('ll-core:server:healPlayer', target)
        TriggerClientEvent('ll-core:client:notify', source, _('healed'), 'success')
    else
        TriggerClientEvent('ll-core:client:notify', source, _('player_not_online'), 'error')
    end
end)

-- /revive [id] - Újraélesztés
RegisterCommand(Config.Commands.ReviveCommand, function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    local target = tonumber(args[1]) or source
    
    if GetPlayerPing(target) > 0 then
        TriggerEvent('ll-core:server:revivePlayer', target)
    else
        TriggerClientEvent('ll-core:client:notify', source, _('player_not_online'), 'error')
    end
end)

-- /tp [id] [x] [y] [z] - Teleport
RegisterCommand(Config.Commands.TeleportCommand, function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args >= 3 then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        
        if x and y and z then
            local coords = vector3(x, y, z)
            TriggerClientEvent('ll-core:client:spawnPlayer', source, coords, 0.0)
            TriggerClientEvent('ll-core:client:notify', source, _('teleported'), 'success')
        else
            TriggerClientEvent('ll-core:client:notify', source, _('invalid_coords'), 'error')
        end
    elseif #args == 1 then
        -- Teleport másik játékoshoz
        local target = tonumber(args[1])
        
        if GetPlayerPing(target) > 0 then
            local targetPed = GetPlayerPed(target)
            local targetCoords = GetEntityCoords(targetPed)
            
            TriggerClientEvent('ll-core:client:spawnPlayer', source, targetCoords, 0.0)
            TriggerClientEvent('ll-core:client:notify', source, _('teleported'), 'success')
        else
            TriggerClientEvent('ll-core:client:notify', source, _('player_not_online'), 'error')
        end
    else
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/tp [id/x y z]'), 'info')
    end
end)

-- /bring [id] - Játékos magadhoz hozása
RegisterCommand('bring', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/bring [id]'), 'info')
        return
    end
    
    local target = tonumber(args[1])
    
    if GetPlayerPing(target) > 0 then
        local sourcePed = GetPlayerPed(source)
        local sourceCoords = GetEntityCoords(sourcePed)
        
        TriggerClientEvent('ll-core:client:spawnPlayer', target, sourceCoords, 0.0)
        TriggerClientEvent('ll-core:client:notify', source, 'Játékos hozzád hozva', 'success')
    else
        TriggerClientEvent('ll-core:client:notify', source, _('player_not_online'), 'error')
    end
end)

-- /goto [id] - Játékoshoz menés
RegisterCommand('goto', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/goto [id]'), 'info')
        return
    end
    
    local target = tonumber(args[1])
    
    if GetPlayerPing(target) > 0 then
        local targetPed = GetPlayerPed(target)
        local targetCoords = GetEntityCoords(targetPed)
        
        TriggerClientEvent('ll-core:client:spawnPlayer', source, targetCoords, 0.0)
        TriggerClientEvent('ll-core:client:notify', source, _('teleported'), 'success')
    else
        TriggerClientEvent('ll-core:client:notify', source, _('player_not_online'), 'error')
    end
end)

-- /givemoney [id] [account] [amount] - Pénz adás
RegisterCommand('givemoney', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 3 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/givemoney [id] [cash/bank] [amount]'), 'info')
        return
    end
    
    local target = tonumber(args[1])
    local account = args[2]
    local amount = tonumber(args[3])
    
    if not amount or amount <= 0 then
        TriggerClientEvent('ll-core:client:notify', source, 'Érvénytelen összeg!', 'error')
        return
    end
    
    TriggerEvent('ll-core:server:giveMoney', target, account, amount)
    TriggerClientEvent('ll-core:client:notify', source, 'Pénz átadva: $' .. amount, 'success')
end)

-- /setgroup [id] [group] - Csoport beállítás
RegisterCommand('setgroup', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/setgroup [id] [group]'), 'info')
        return
    end
    
    local target = tonumber(args[1])
    local group = args[2]
    
    TriggerEvent('ll-core:server:setGroup', target, group)
end)

-- /kick [id] [reason] - Játékos kirúgása
RegisterCommand('kick', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/kick [id] [reason]'), 'info')
        return
    end
    
    local target = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'Kirúgva'
    
    TriggerEvent('ll-core:server:kickPlayer', target, reason)
    TriggerClientEvent('ll-core:client:notify', source, 'Játékos kirúgva', 'success')
end)

-- /announce [message] - Bejelentés
RegisterCommand('announce', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/announce [message]'), 'info')
        return
    end
    
    local message = table.concat(args, ' ')
    TriggerEvent('ll-core:server:broadcast', message)
end)

-- /coords - Koordináták kiírása
RegisterCommand('coords', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local coordsText = string.format('vector4(%.2f, %.2f, %.2f, %.2f)', coords.x, coords.y, coords.z, heading)
    
    print('^2[COORDS]^7 ' .. GetPlayerName(source) .. ': ' .. coordsText)
    TriggerClientEvent('ll-core:client:notify', source, 'Koordináták kiírva console-ba', 'success')
end)

-- /car [model] - Jármű spawn
RegisterCommand('car', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('ll-core:client:notify', source, _('command_usage', '/car [model]'), 'info')
        return
    end
    
    local model = args[1]
    TriggerClientEvent('ll-core:client:spawnVehicle', source, model)
end)

-- /dv - Delete vehicle
RegisterCommand('dv', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('ll-core:client:notify', source, _('no_permission'), 'error')
        return
    end
    
    TriggerClientEvent('ll-core:client:deleteVehicle', source)
end)

print('^2[LL-CORE]^7 Commands loaded successfully!')