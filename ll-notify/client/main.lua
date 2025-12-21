-- Resource indítása
Citizen.CreateThread(function()
    Notify.Debug('ll-notify started successfully')
    
    -- Pozíció és stílus küldése NUI-nak
    SendNUIMessage({
        action = 'setConfig',
        data = {
            position = Config.Position,
            style = Config.Style,
            sounds = Config.Sounds
        }
    })
end)

-- Szerver esemény figyelése
RegisterNetEvent('ll-notify:client:notify', function(message, type, duration, title)
    Notify.Send(message, type, duration, title)
end)

RegisterNetEvent('ll-notify:client:success', function(message, duration, title)
    Notify.Success(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:error', function(message, duration, title)
    Notify.Error(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:warning', function(message, duration, title)
    Notify.Warning(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:info', function(message, duration, title)
    Notify.Info(message, duration, title)
end)

-- Apokalipszis specifikus események
RegisterNetEvent('ll-notify:client:radiation', function(message, duration, title)
    Notify.Radiation(message, duration, title)
end)


RegisterNetEvent('ll-notify:client:sanity', function(message, duration, title)
    Notify.Sanity(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:infection', function(message, duration, title)
    Notify.Infection(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:hunger', function(message, duration, title)
    Notify.Hunger(message, duration, title)
end)

RegisterNetEvent('ll-notify:client:thirst', function(message, duration, title)
    Notify.Thirst(message, duration, title)
end)

-- Progressbar event
RegisterNetEvent('ll-notify:client:progress', function(duration, label)
    Notify.Progress(duration, label)
end)

-- Custom notification event
RegisterNetEvent('ll-notify:client:custom', function(message, icon, color, duration, title)
    Notify.Custom(message, icon, color, duration, title)
end)

-- Persistent notification events
RegisterNetEvent('ll-notify:client:persistent', function(message, type, id, title)
    Notify.Persistent(message, type, id, title)
end)

RegisterNetEvent('ll-notify:client:removePersistent', function(id)
    Notify.RemovePersistent(id)
end)

-- Clear all event
RegisterNetEvent('ll-notify:client:clearAll', function()
    Notify.ClearAll()
end)

-- NUI Callback-ek
RegisterNUICallback('notificationClosed', function(data, cb)
    Notify.Debug('Notification closed: ' .. (data.id or 'unknown'))
    cb('ok')
end)

-- ESX Kompatibilitás
if Config.Framework.ESX then
    function ESX.ShowNotification(msg, type, duration)
        Notify.Send(msg, type or 'info', duration)
    end
end

-- QBCore Kompatibilitás
if Config.Framework.QBCore then
    function QBCore:Notify(text, texttype, length)
        local notifyType = texttype or 'primary'
        
        -- QB típusok átalakítása
        if notifyType == 'primary' then notifyType = 'info' end
        if notifyType == 'success' then notifyType = 'success' end
        if notifyType == 'error' then notifyType = 'error' end
        
        Notify.Send(text, notifyType, length)
    end
end

-- Exports
exports('Notify', function(message, type, duration, title)
    Notify.Send(message, type, duration, title)
end)

exports('Success', function(message, duration, title)
    Notify.Success(message, duration, title)
end)

exports('Error', function(message, duration, title)
    Notify.Error(message, duration, title)
end)

exports('Warning', function(message, duration, title)
    Notify.Warning(message, duration, title)
end)

exports('Info', function(message, duration, title)
    Notify.Info(message, duration, title)
end)

exports('Radiation', function(message, duration, title)
    Notify.Radiation(message, duration, title)
end)

exports('Sanity', function(message, duration, title)
    Notify.Sanity(message, duration, title)
end)

exports('Infection', function(message, duration, title)
    Notify.Infection(message, duration, title)
end)

exports('Progress', function(duration, label, onComplete, onCancel)
    Notify.Progress(duration, label, onComplete, onCancel)
end)

exports('Custom', function(message, icon, color, duration, title)
    Notify.Custom(message, icon, color, duration, title)
end)

exports('Persistent', function(message, type, id, title)
    return Notify.Persistent(message, type, id, title)
end)

exports('RemovePersistent', function(id)
    Notify.RemovePersistent(id)
end)

exports('ClearAll', function()
    Notify.ClearAll()
end)

-- Command teszt (debug)
if Config.Debug then
    RegisterCommand('testnotify', function()
        Notify.Success('Ez egy success notification teszt!')
        Citizen.Wait(500)
        Notify.Error('Ez egy error notification teszt!')
        Citizen.Wait(500)
        Notify.Warning('Ez egy warning notification teszt!')
        Citizen.Wait(500)
        Notify.Info('Ez egy info notification teszt!')
        Citizen.Wait(500)
        Notify.Radiation('☢️ Radiációs zónába léptél!')
        Citizen.Wait(500)
        Notify.Zombie('🧟 Zombie közeledik!')
    end)
    
    RegisterCommand('testprogress', function()
        Notify.Progress(5000, 'Tesztelés folyamatban...', function()
            Notify.Success('Progressbar befejezve!')
        end, function()
            Notify.Warning('Progressbar megszakítva!')
        end)
    end)
end