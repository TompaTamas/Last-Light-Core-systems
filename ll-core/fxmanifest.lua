fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Core - Framework alaprendszer'
version '1.0.0'

-- Lua 5.4 használata
lua54 'yes'

-- Shared fájlok (mind kliens, mind szerver)
shared_scripts {
    'config.lua',
    'locales/*.lua'
}

-- Kliens oldali scriptek
client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/player.lua',
    'client/death.lua',
    'client/streaming.lua',
    'client/apocalypse.lua',  -- Apokalipszis rendszer
    'client/zombies.lua',      -- Zombie/Mutáns rendszer
    'client/weather.lua'       -- Időjárás rendszer
}

-- Szerver oldali scriptek
server_scripts {
    '@oxmysql/lib/MySQL.lua', -- MySQL wrapper
    'server/functions.lua',
    'server/main.lua',
    'server/player.lua',
    'server/commands.lua',
    'server/apocalypse.lua',   -- Apokalipszis rendszer
    'server/weather.lua'       -- Időjárás rendszer
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png'
}

-- Dependency
dependencies {
    'oxmysql'
}