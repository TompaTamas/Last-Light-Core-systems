Notify = {}

-- Lokalizáció
function _(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return str
    end
end

-- Debug print
function Notify.Debug(msg)
    if Config.Debug then
        print('^3[LL-NOTIFY DEBUG]^7 ' .. msg)
    end
end

-- Alap notification küldés
function Notify.Send(message, type, duration, title)
    -- Alapértelmezett értékek
    type = type or 'info'
    duration = duration or Config.Types[type].duration or 3000
    title = title or nil
    
    -- Config ellenőrzése
    if not Config.Types[type] then
        Notify.Debug('Invalid notification type: ' .. type)
        type = 'info'
    end
    
    -- NUI message
    SendNUIMessage({
        action = 'notify',
        data = {
            message = message,
            type = type,
            duration = duration,
            title = title,
            icon = Config.Icons[Config.Types[type].icon] or Config.Icons.info,
            color = Config.Types[type].color,
            sound = Config.Types[type].playSound and Config.Types[type].sound or nil,
            pulse = Config.Types[type].pulse or false,
            shake = Config.Types[type].shake or false
        }
    })
    
    Notify.Debug('Notification sent: ' .. message .. ' [' .. type .. ']')
end

-- Success notification
function Notify.Success(message, duration, title)
    Notify.Send(message, 'success', duration, title)
end

-- Error notification
function Notify.Error(message, duration, title)
    Notify.Send(message, 'error', duration, title)
end

-- Warning notification
function Notify.Warning(message, duration, title)
    Notify.Send(message, 'warning', duration, title)
end

-- Info notification
function Notify.Info(message, duration, title)
    Notify.Send(message, 'info', duration, title)
end

-- Apokalipszis specifikus notification-ök
function Notify.Radiation(message, duration, title)
    Notify.Send(message, 'radiation', duration, title or _('radiation_warning'))
end

function Notify.Sanity(message, duration, title)
    Notify.Send(message, 'sanity', duration, title or _('sanity_low'))
end

function Notify.Infection(message, duration, title)
    Notify.Send(message, 'infection', duration, title or _('infection_warning'))
end

function Notify.Hunger(message, duration, title)
    Notify.Send(message, 'hunger', duration, title or _('hunger_low'))
end

function Notify.Thirst(message, duration, title)
    Notify.Send(message, 'thirst', duration, title or _('thirst_low'))
end

-- Progressbar notification
function Notify.Progress(duration, label, onComplete, onCancel)
    label = label or _('progress_title')
    
    SendNUIMessage({
        action = 'progress',
        data = {
            duration = duration,
            label = label
        }
    })
    
    -- Progressbar timer
    local startTime = GetGameTimer()
    local cancelled = false
    
    Citizen.CreateThread(function()
        while GetGameTimer() - startTime < duration do
            Citizen.Wait(0)
            
            -- ESC gomb figyelése (cancel)
            if IsControlJustPressed(0, 322) then -- ESC
                cancelled = true
                
                SendNUIMessage({
                    action = 'cancelProgress'
                })
                
                if onCancel then
                    onCancel()
                end
                
                Notify.Warning(_('progress_cancelled'))
                break
            end
        end
        
        if not cancelled then
            SendNUIMessage({
                action = 'completeProgress'
            })
            
            if onComplete then
                onComplete()
            end
        end
    end)
end

-- Custom icon notification
function Notify.Custom(message, icon, color, duration, title)
    SendNUIMessage({
        action = 'notify',
        data = {
            message = message,
            type = 'custom',
            duration = duration or 3000,
            title = title,
            icon = icon or '📢',
            color = color or '#3b82f6',
            sound = nil
        }
    })
end

-- Persistent notification (nem tűnik el automatikusan)
function Notify.Persistent(message, type, id, title)
    type = type or 'info'
    id = id or ('persistent_' .. math.random(100000, 999999))
    
    SendNUIMessage({
        action = 'persistent',
        data = {
            id = id,
            message = message,
            type = type,
            title = title,
            icon = Config.Icons[Config.Types[type].icon] or Config.Icons.info,
            color = Config.Types[type].color
        }
    })
    
    return id
end

-- Persistent notification eltávolítása
function Notify.RemovePersistent(id)
    SendNUIMessage({
        action = 'removePersistent',
        data = {
            id = id
        }
    })
end

-- Összes notification törlése
function Notify.ClearAll()
    SendNUIMessage({
        action = 'clearAll'
    })
end

-- Hang lejátszása
function Notify.PlaySound(soundName)
    if Config.Sounds.enabled then
        SendNUIMessage({
            action = 'playSound',
            data = {
                sound = soundName,
                volume = Config.Sounds.volume
            }
        })
    end
end