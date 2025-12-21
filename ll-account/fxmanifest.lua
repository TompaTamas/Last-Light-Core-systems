fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Account - Fiókkezelő és karakterválasztó rendszer'
version '1.0.0'

-- Lua 5.4 használata
lua54 'yes'

-- Shared fájlok
shared_scripts {
    'config.lua',
    'locales/*.lua'
}

-- Kliens oldali scriptek
client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/character.lua',
    'client/spawn.lua'
}

-- Szerver oldali scriptek
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/character.lua'
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'html/assets/fonts/*.ttf',
    'html/assets/sounds/*.ogg'
}

-- Dependencies
dependencies {
    'oxmysql',
    'll-core'
}