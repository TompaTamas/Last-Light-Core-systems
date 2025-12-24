fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Account System - Login, Registration, Character Management'
version '1.0.0'

lua54 'yes'

-- Shared
shared_scripts {
    'config.lua',
    'locales/*.lua'
}

-- Client
client_scripts {
    'client/init.lua',
    'client/functions.lua',
    'client/main.lua',
    'client/creator.lua',
    'client/spawn.lua',
    'client/tutorial.lua',
    'client/debug.lua'
}

-- Server
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/character.lua',
    'server/spawn_events.lua'
}

-- NUI
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