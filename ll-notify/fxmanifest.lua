fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Notify - Modern értesítési rendszer'
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
    'client/main.lua'
}

-- Szerver oldali scriptek
server_scripts {
    'server/main.lua'
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/sounds/*.ogg',
    'html/assets/icons/*.png',
    'html/assets/icons/*.svg'
}