Config = {}

-- Alap beállítások
Config.Locale = 'hu' -- Alapértelmezett nyelv
Config.Debug = true -- Debug mód

-- Notification pozíció
Config.Position = {
    horizontal = 'right', -- left, center, right
    vertical = 'top'      -- top, center, bottom
}

-- Notification stílus
Config.Style = {
    theme = 'modern',     -- modern, classic, minimal, apocalypse
    borderRadius = 12,    -- px
    maxWidth = 400,       -- px
    minWidth = 300,       -- px
    spacing = 10,         -- Értesítések közötti távolság (px)
    maxStack = 5,         -- Maximum hány értesítés lehet egyszerre
    animationSpeed = 300  -- Animáció sebessége (ms)
}

-- Notification típusok beállításai
Config.Types = {
    success = {
        duration = 3000,    -- Megjelenési idő (ms)
        icon = 'check',     -- Icon név
        color = '#10b981',  -- Háttérszín
        sound = 'success',  -- Hang fájl neve (optional)
        playSound = true    -- Hang lejátszása
    },
    
    error = {
        duration = 5000,
        icon = 'error',
        color = '#ef4444',
        sound = 'error',
        playSound = true
    },
    
    warning = {
        duration = 4000,
        icon = 'warning',
        color = '#f59e0b',
        sound = 'warning',
        playSound = true
    },
    
    info = {
        duration = 3000,
        icon = 'info',
        color = '#3b82f6',
        sound = 'info',
        playSound = true
    },
    
    -- Apokalipszis specifikus típusok
    radiation = {
        duration = 5000,
        icon = 'radiation',
        color = '#84cc16',
        sound = 'warning',
        playSound = true,
        pulse = true -- Pulzáló animáció
    },
    
    zombie = {
        duration = 4000,
        icon = 'zombie',
        color = '#dc2626',
        sound = 'error',
        playSound = true,
        shake = true -- Rázós animáció
    },
    
    sanity = {
        duration = 4000,
        icon = 'brain',
        color = '#8b5cf6',
        sound = 'warning',
        playSound = true
    },
    
    infection = {
        duration = 5000,
        icon = 'virus',
        color = '#059669',
        sound = 'error',
        playSound = true
    },
    
    hunger = {
        duration = 3000,
        icon = 'food',
        color = '#f97316',
        sound = 'info',
        playSound = false
    },
    
    thirst = {
        duration = 3000,
        icon = 'water',
        color = '#0ea5e9',
        sound = 'info',
        playSound = false
    }
}

-- Hangok beállítása
Config.Sounds = {
    enabled = true,
    volume = 0.3, -- 0.0 - 1.0
    customSounds = {
        success = 'success.ogg',
        error = 'error.ogg',
        warning = 'warning.ogg',
        info = 'info.ogg'
    }
}

-- Progressbar notification (különleges típus)
Config.Progressbar = {
    enabled = true,
    showPercentage = true,
    showTimeLeft = true,
    color = '#3b82f6',
    backgroundColor = 'rgba(0, 0, 0, 0.3)'
}

-- Alapértelmezett ikonok
Config.Icons = {
    check = '✓',
    error = '✗',
    warning = '⚠',
    info = 'ℹ',
    radiation = '☢',
    zombie = '🧟',
    brain = '🧠',
    virus = '🦠',
    food = '🍖',
    water = '💧',
    money = '💰',
    phone = '📱',
    car = '🚗',
    house = '🏠',
    health = '❤',
    armor = '🛡'
}

-- ESX/QB-Core kompatibilitás
Config.Framework = {
    ESX = false, -- Ha true, ESX:ShowNotification wrapper
    QBCore = false -- Ha true, QBCore:Notify wrapper
}

-- Discord Rich Presence integration
Config.DiscordRichPresence = {
    enabled = false,
    showNotifications = false -- Notification-öket is megjelenít Discord-on
}