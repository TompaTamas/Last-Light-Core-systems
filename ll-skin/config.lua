Config = {}

-- Alap beállítások
Config.Locale = 'hu'
Config.Debug = false

-- Menü megnyitás
Config.Menu = {
    Command = 'skin',           -- /skin parancs
    Key = 'F7',                 -- F7 billentyű
    KeyCode = 168,              -- F7 key code
    EnableCommand = true,       -- Parancs engedélyezése
    EnableKey = false,           -- Billentyű engedélyezése
    
    -- Hozzáférés
    AllowEverywhere = false,    -- Bárhol megnyitható
    RequireClothingShop = true, -- Csak ruhaboltban
    RequireBarberShop = true,   -- Csak fodrászatban (arc/haj)
    
    -- Ár
    EnablePrice = true,
    Price = 100,                -- Módosítás ára
    FreeForAdmins = true
}

-- Ruhaboltok
Config.ClothingShops = {
    {coords = vector3(72.3, -1399.1, 29.4), blip = true},
    {coords = vector3(-703.8, -152.3, 37.4), blip = true},
    {coords = vector3(-167.9, -299.0, 39.7), blip = true},
    {coords = vector3(428.7, -800.1, 29.5), blip = true},
    {coords = vector3(-829.4, -1073.7, 11.3), blip = true},
    {coords = vector3(-1447.8, -242.5, 49.8), blip = true},
    {coords = vector3(11.6, 6514.2, 31.9), blip = true},
    {coords = vector3(123.6, -219.4, 54.6), blip = true},
    {coords = vector3(1696.3, 4829.3, 42.1), blip = true},
    {coords = vector3(618.1, 2759.6, 42.1), blip = true},
    {coords = vector3(1190.6, 2713.4, 38.2), blip = true},
    {coords = vector3(-1193.4, -772.3, 17.3), blip = true},
    {coords = vector3(-3172.5, 1048.1, 20.9), blip = true},
    {coords = vector3(-1108.4, 2708.9, 19.1), blip = true}
}

-- Fodrászatok
Config.BarberShops = {
    {coords = vector3(-814.3, -183.8, 37.6), blip = true},
    {coords = vector3(136.8, -1708.4, 29.3), blip = true},
    {coords = vector3(-1282.6, -1116.8, 7.0), blip = true},
    {coords = vector3(1931.5, 3729.7, 32.8), blip = true},
    {coords = vector3(1212.8, -472.9, 66.2), blip = true},
    {coords = vector3(-32.9, -152.3, 57.1), blip = true},
    {coords = vector3(-278.1, 6228.5, 31.7), blip = true}
}

-- Blip beállítások
Config.Blips = {
    ClothingShop = {
        sprite = 73,
        color = 47,
        scale = 0.8,
        label = 'Ruhabolt'
    },
    BarberShop = {
        sprite = 71,
        color = 47,
        scale = 0.8,
        label = 'Fodrászat'
    }
}

-- Kamera beállítások
Config.Camera = {
    Enable = true,
    Positions = {
        head = {offset = vector3(0, 0.6, 0.65), fov = 40.0},
        body = {offset = vector3(0, 1.5, 0.2), fov = 50.0},
        legs = {offset = vector3(0, 1.5, -0.5), fov = 50.0},
        feet = {offset = vector3(0, 1.5, -1.0), fov = 50.0},
        full = {offset = vector3(0, 2.5, 0.0), fov = 60.0}
    },
    RotationSpeed = 5.0,        -- Forgatás sebessége
    AllowRotation = true        -- Egér forgatás
}

-- Megjelenés komponensek
Config.Components = {
    -- Arcvonások (Heritage)
    Heritage = {
        enable = true,
        mothers = 21,  -- Anyák száma (0-20)
        fathers = 23   -- Apák száma (0-22, 42-44 speciális)
    },
    
    -- Arc vonások (Face Features)
    FaceFeatures = {
        enable = true,
        features = {
            'nose_width', 'nose_peak_height', 'nose_peak_length',
            'nose_bone_height', 'nose_peak_lowering', 'nose_bone_twist',
            'eyebrows_height', 'eyebrows_width',
            'cheekbone_height', 'cheekbone_width',
            'cheeks_width', 'eyes_opening',
            'lips_thickness', 'jaw_bone_width',
            'jaw_bone_back_length', 'chin_bone_lowering',
            'chin_bone_length', 'chin_bone_width',
            'chin_hole', 'neck_thickness'
        }
    },
    
    -- Haj
    Hair = {
        enable = true,
        styles = true,      -- Hajstílusok
        colors = true,      -- Hajszín
        highlight = true    -- Melír
    },
    
    -- Arcszőrzet (férfiak)
    Beard = {
        enable = true,
        styles = true,
        colors = true
    },
    
    -- Szemöldök
    Eyebrows = {
        enable = true,
        styles = true,
        colors = true
    },
    
    -- Mellkas szőrzet (férfiak)
    ChestHair = {
        enable = true,
        styles = true,
        colors = true
    },
    
    -- Smink
    Makeup = {
        enable = true,
        styles = true,
        colors = true,
        opacity = true
    },
    
    -- Rúzs
    Lipstick = {
        enable = true,
        styles = true,
        colors = true,
        opacity = true
    },
    
    -- Szemszín
    EyeColor = {
        enable = true,
        colors = 32  -- 0-31
    },
    
    -- Ráncok/öregedés
    Ageing = {
        enable = true,
        styles = true,
        opacity = true
    },
    
    -- Bőrhibák
    Blemishes = {
        enable = true,
        styles = true,
        opacity = true
    },
    
    -- Napégés
    SunDamage = {
        enable = true,
        styles = true,
        opacity = true
    },
    
    -- Arcszínezés
    Complexion = {
        enable = true,
        styles = true,
        opacity = true
    },
    
    -- Anyajegyek
    Moles = {
        enable = true,
        styles = true,
        opacity = true
    }
}

-- Ruhák komponensek
Config.Clothes = {
    -- Fej (kalap, sisak)
    Head = {
        component = 0,
        enable = true,
        label = 'Fejfedő'
    },
    
    -- Maszk
    Mask = {
        component = 1,
        enable = true,
        label = 'Maszk'
    },
    
    -- Haj (ruhaként)
    HairStyle = {
        component = 2,
        enable = true,
        label = 'Frizura'
    },
    
    -- Felső (torso)
    Torso = {
        component = 3,
        enable = true,
        label = 'Kéz/Karizma'
    },
    
    -- Nadrág
    Legs = {
        component = 4,
        enable = true,
        label = 'Nadrág'
    },
    
    -- Táska/hátizsák
    Bag = {
        component = 5,
        enable = true,
        label = 'Táska'
    },
    
    -- Cipő
    Shoes = {
        component = 6,
        enable = true,
        label = 'Cipő'
    },
    
    -- Kiegészítők (nyaklánc)
    Accessories = {
        component = 7,
        enable = true,
        label = 'Nyaklánc'
    },
    
    -- Póló (undershirt)
    Undershirt = {
        component = 8,
        enable = true,
        label = 'Póló'
    },
    
    -- Mellény/páncél
    Armor = {
        component = 9,
        enable = true,
        label = 'Mellény'
    },
    
    -- Jelvény/dekoráció
    Decals = {
        component = 10,
        enable = true,
        label = 'Jelvény'
    },
    
    -- Kabát/jacket
    Jacket = {
        component = 11,
        enable = true,
        label = 'Kabát'
    }
}

-- Kiegészítők (Props)
Config.Props = {
    -- Kalap
    Hat = {
        prop = 0,
        enable = true,
        label = 'Kalap'
    },
    
    -- Szemüveg
    Glasses = {
        prop = 1,
        enable = true,
        label = 'Szemüveg'
    },
    
    -- Fülbevaló
    Ears = {
        prop = 2,
        enable = true,
        label = 'Fülbevaló'
    },
    
    -- Óra
    Watch = {
        prop = 6,
        enable = true,
        label = 'Óra'
    },
    
    -- Karkötő
    Bracelet = {
        prop = 7,
        enable = true,
        label = 'Karkötő'
    }
}

-- Tetoválások
Config.Tattoos = {
    Enable = true,
    MaxTattoos = 10,    -- Maximum tetoválások száma
    Categories = {
        'Multiplex',
        'Tribal',
        'Oriental',
        'Lettering',
        'Sacred Geometry',
        'Religious'
    },
    Price = 500,        -- Tetoválás ára
    RemovalPrice = 250  -- Eltávolítás ára
}

-- Outfitek (mentett szettek)
Config.Outfits = {
    Enable = true,
    MaxOutfits = 10,           -- Maximum mentett outfit
    AllowSharing = true,      -- Outfitek megosztása más játékosokkal
    Categories = {
        'Hétköznapi',
        'Munka',
        'Elegáns',
        'Sport',
        'Túlélő',
        'Egyéb'
    }
}

-- Apokalipszis témájú beállítások
Config.Apocalypse = {
    -- Túlélő ruhák (csökkentett ár vagy ingyenes)
    SurvivorClothes = {
        enable = true,
        discount = 50  -- 50% kedvezmény
    },
    
    -- Szennyezett ruházat
    DirtyClothes = {
        enable = true,
        effect = 'dirt_overlay'  -- Textúra overlay
    },
    
    -- Radiációs védőruha
    RadiationSuit = {
        enable = true,
        components = {
            {component = 11, drawable = 50, texture = 0}  -- Példa
        },
        protection = 95  -- 95% védelem
    }
}

-- Mentés
Config.Save = {
    AutoSave = true,
    AutoSaveInterval = 60000,  -- 1 perc (ms)
    SaveToDatabase = true
}

-- UI beállítások
Config.UI = {
    Theme = 'apocalypse',  -- apocalypse, modern, dark
    ShowPrices = true,
    ShowStats = true,      -- Apokalipszis státuszok megjelenítése
    AnimationSpeed = 200   -- ms
}