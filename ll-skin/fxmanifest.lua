fx_version 'ceruleon'
game 'gta5'

author 'Last Light Development'
description 'Last Light Skin - Teljes karakter megjelenés kezelő (Illenium-Appearance alapú)'
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
    'client/camera.lua',
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
    'server/save.lua'
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'html/assets/icons/*.svg',
    
    -- Illenium-Appearance streaming (helyezd ide az illenium stream mappából)
    'stream/mp_m_freemode_01_*.ymt',
    'stream/mp_f_freemode_01_*.ymt',
    'stream/tattoos/*.ytd'
}

-- Streaming data files (Illenium format)
data_file 'SHOP_PED_APPAREL_META_FILE' 'stream/mp_m_freemode_01_*.ymt'
data_file 'SHOP_PED_APPAREL_META_FILE' 'stream/mp_f_freemode_01_*.ymt'
data_file 'PED_OVERLAY_FILE' 'stream/tattoos/*.ytd'

-- Dependencies
dependencies {
    'oxmysql',
    'll-core'
}fx_version 'cerulean'
game 'gta5'

author 'Last Light Development'
description 'Last Light Skin - Teljes karakter megjelenés kezelő (Illenium-Appearance integration)'
version '1.0.0'

-- Lua 5.4 használata
lua54 'yes'

-- Shared fájlok
shared_scripts {
    'config.lua',
    'locales/*.lua',
    'shared/data.lua',
    'shared/illenium/*.lua'  -- Illenium shared adatok
}

-- Kliens oldali scriptek
client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/menu.lua',
    'client/camera.lua',
    'client/appearance.lua',
    'client/clothes.lua',
    'client/tattoos.lua',
    'client/outfits.lua',
    'client/illenium.lua'  -- Illenium integration
}

-- Szerver oldali scriptek
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/save.lua',
    'server/illenium.lua'  -- Illenium integration
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'html/assets/icons/*.svg',
    'html/assets/clothes/*.png',
    'html/assets/tattoos/*.png',
    
    -- Illenium streaming files
    'stream/mp_m_freemode_01_*.ymt',
    'stream/mp_f_freemode_01_*.ymt',
    'stream/tattoo_*.ytd'
}

-- Dependencies
dependencies {
    'oxmysql',
    'll-core'
}

-- Data files for streaming (Illenium clothes/tattoos)
data_file 'SHOP_PED_APPAREL_META_FILE' 'stream/mp_m_freemode_01_mp_m_*.ymt'
data_file 'SHOP_PED_APPAREL_META_FILE' 'stream/mp_f_freemode_01_mp_f_*.ymt'
data_file 'PED_OVERLAY_FILE' 'stream/tattoo_*.ytd'fx_version 'cerulean'
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
    'shared/data.lua'  -- Komponens adatok
}

-- Kliens oldali scriptek
client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/menu.lua',
    'client/camera.lua',
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
    'server/save.lua'
}

-- NUI fájlok
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
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