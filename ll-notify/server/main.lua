-- Debug print
local function Debug(msg)
    if Config.Debug then
        print('^3[LL-NOTIFY DEBUG]^7 ' .. msg)
    end
end

-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[LL-NOTIFY]^7 Last Light Notify started successfully!')
    end
end)

-- Notification küldése egy játékosnak
RegisterNetEvent('ll-notify:server:notify', function(target, message, type, duration, title)
    local source = source
    
    -- Ha nincs megadva target, a source-nak küldjük
    target = target or source
    
    TriggerClientEvent('ll-notify:client:notify', target, message, type, duration, title)
    
    Debug(string.format('Notification sent to %d: %s [%s]', target, message, type or 'info'))
end)

-- Success
RegisterNetEvent('ll-notify:server:success', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:success', target, message, duration, title)
end)

-- Error
RegisterNetEvent('ll-notify:server:error', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:error', target, message, duration, title)
end)

-- Warning
RegisterNetEvent('ll-notify:server:warning', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:warning', target, message, duration, title)
end)

-- Info
RegisterNetEvent('ll-notify:server:info', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:info', target, message, duration, title)
end)

-- Broadcast notification (mindenki kap)
RegisterNetEvent('ll-notify:server:broadcast', function(message, type, duration, title)
    TriggerClientEvent('ll-notify:client:notify', -1, message, type, duration, title)
    Debug('Broadcast notification: ' .. message)
end)

-- Apokalipszis specifikus
RegisterNetEvent('ll-notify:server:radiation', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:radiation', target, message, duration, title)
end)

RegisterNetEvent('ll-notify:server:sanity', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:sanity', target, message, duration, title)
end)

RegisterNetEvent('ll-notify:server:infection', function(target, message, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:infection', target, message, duration, title)
end)

-- Progressbar
RegisterNetEvent('ll-notify:server:progress', function(target, duration, label)
    target = target or source
    TriggerClientEvent('ll-notify:client:progress', target, duration, label)
end)

-- Custom notification
RegisterNetEvent('ll-notify:server:custom', function(target, message, icon, color, duration, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:custom', target, message, icon, color, duration, title)
end)

-- Persistent notification
RegisterNetEvent('ll-notify:server:persistent', function(target, message, type, id, title)
    target = target or source
    TriggerClientEvent('ll-notify:client:persistent', target, message, type, id, title)
end)

RegisterNetEvent('ll-notify:server:removePersistent', function(target, id)
    target = target or source
    TriggerClientEvent('ll-notify:client:removePersistent', target, id)
end)

-- Exports
exports('Notify', function(target, message, type, duration, title)
    TriggerClientEvent('ll-notify:client:notify', target, message, type, duration, title)
end)

exports('Success', function(target, message, duration, title)
    TriggerClientEvent('ll-notify:client:success', target, message, duration, title)
end)

exports('Error', function(target, message, duration, title)
    TriggerClientEvent('ll-notify:client:error', target, message, duration, title)
end)

exports('Warning', function(target, message, duration, title)
    TriggerClientEvent('ll-notify:client:warning', target, message, duration, title)
end)

exports('Info', function(target, message, duration, title)
    TriggerClientEvent('ll-notify:client:info', target, message, duration, title)
end)

exports('Broadcast', function(message, type, duration, title)
    TriggerClientEvent('ll-notify:client:notify', -1, message, type, duration, title)
end)