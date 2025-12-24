fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Skin - Teljes karakter megjelenés kezelő rendszer'
version '1.0.0'

-- Lua 5.4 használata
lua54 'yes'

-- Shared fájlok
shared_scripts {
    'config.lua',
    'locales/*.lua',
    'shared/data.lua'
}

-- Kliens oldali scriptek
client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/skin_menu.lua',
    'client/camera.lua',
    'client/preview.lua',
    'client/appearance.lua',
    'client/clothes.lua',
    'client/tattoos.lua',
    'client/outfits.lua'
}

-- Szerver oldali scriptek
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/skin_save.lua'
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/camera.js',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'html/assets/icons/*.svg',
    'html/assets/clothes/*.png',
    'html/assets/tattoos/*.png'
}

-- Dependencies
dependencies {
    'oxmysql',
    'll-core'
}