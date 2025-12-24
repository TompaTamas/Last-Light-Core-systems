Config = {}

-- Alap beállítások
Config.Locale = 'hu'
Config.Debug = true

-- Karakter beállítások
Config.Character = {
    MaxCharacters = 3,           -- Maximum karakterek száma
    EnableDelete = true,         -- Karakter törölhető
    DeleteConfirmation = true,   -- Megerősítés kérése törléskor
    
    -- Név validáció
    Name = {
        MinLength = 3,
        MaxLength = 20,
        AllowNumbers = false,
        AllowSpecialChars = false,
        Pattern = '^[a-zA-ZáéíóöőúüűÁÉÍÓÖŐÚÜŰ ]+$' -- Regex pattern
    },
    
    -- Születési dátum
    DateOfBirth = {
        MinAge = 18,             -- Minimum életkor
        MaxAge = 80,             -- Maximum életkor
        Format = 'YYYY-MM-DD'    -- Dátum formátum
    },
    
    -- Magasság
    Height = {
        Min = 150,               -- cm
        Max = 220                -- cm
    }
}

-- Spawn beállítások
Config.Spawn = {
    -- Új karakter spawn pontok (választható)
    NewCharacterSpawns = {
        {
            label = 'Los Santos Reptér',
            coords = vector4(-1037.97, -2738.61, 20.17, 329.39),
            image = 'airport.jpg'
        },
        {
            label = 'Paleto Bay',
            coords = vector4(-356.0, 6336.0, 29.0, 223.28),
            image = 'paleto.jpg'
        },
        {
            label = 'Sandy Shores',
            coords = vector4(1839.13, 3672.85, 34.28, 209.84),
            image = 'sandy.jpg'
        }
    },
    
    -- Létező karakter spawn
    UseLastPosition = true,      -- Utolsó pozíció használata
    DefaultSpawn = vector4(-1037.97, -2738.61, 20.17, 329.39), -- Ha nincs mentett pozíció
    
    -- Spawn kamera
    EnableSpawnCam = true,
    CameraPosition = vector3(-1040.0, -2740.0, 25.0),
    CameraRotation = vector3(-20.0, 0.0, 45.0),
    CameraFov = 50.0
}

-- Karakter kreátor beállítások
Config.Creator = {
    EnableAdvanced = true,       -- Részletes testreszabás (később ll-skin-nel)
    
    -- Alap megjelenés opciók
    Gender = {
        Male = 'mp_m_freemode_01',
        Female = 'mp_f_freemode_01'
    },
    
    -- Kezdő ruhák (alap)
    DefaultClothes = {
        Male = {
            tshirt = {1, 0},
            torso = {15, 0},
            legs = {21, 0},
            shoes = {34, 0}
        },
        Female = {
            tshirt = {1, 0},
            torso = {15, 0},
            legs = {21, 0},
            shoes = {35, 0}
        }
    }
}

-- NUI beállítások
Config.NUI = {
    -- Háttér
    EnableBackground = true,
    BackgroundImage = 'background.jpg',  -- html/assets/background.jpg
    BackgroundVideo = false,             -- Videó háttér (ha van)
    
    -- Apokalipszis téma
    Theme = 'apocalypse',                -- apocalypse, modern, dark, light
    
    -- Zene
    EnableMusic = true,
    MusicVolume = 0.2,
    MusicFile = 'menu_music.ogg',
    
    -- Effektek
    EnableParticles = true,              -- Porszem effektek
    EnableBlur = true,                   -- Háttér elmosás
    
    -- Animációk
    AnimationSpeed = 300                 -- ms
}

-- Biztonsági beállítások
Config.Security = {
    EnableAnticheat = true,              -- Alap anticheat
    MaxCharactersPerDay = 5,             -- Maximum karakterek létrehozása naponta
    CooldownBetweenCreations = 60,       -- Másodpercek karakterek létrehozása között
    
    -- Név blacklist
    BlacklistedNames = {
        'admin',
        'moderator',
        'helper',
        'support',
        'server',
        'fivem',
        'god',
        'test'
        -- Add hozzá többet...
    },
    
    -- Születési dátum validáció
    ValidateDateOfBirth = true
}

-- Karakterválasztó kamera
Config.SelectionCamera = {
    Enable = true,
    Distance = 2.0,                      -- Távolság a karaktertől
    Height = 0.5,                        -- Magasság offset
    RotationSpeed = 0.5,                 -- Kamera forgás sebesség
    Fov = 40.0
}

-- Intro/Outro animációk
Config.Animations = {
    CharacterIntro = {
        Enable = true,
        Duration = 2000,                 -- ms
        Type = 'fade'                    -- fade, slide, zoom
    },
    
    CharacterOutro = {
        Enable = true,
        Duration = 1000,
        Type = 'fade'
    }
}

-- Discord Rich Presence
Config.DiscordRichPresence = {
    Enable = true,
    ApplicationId = 'https://discord.gg/9Q2UVX3Nfb',
    LargeImage = 'logo',
    LargeText = 'Last Light RP',
    SmallImage = 'character',
    SmallText = 'Karakterválasztás'
}

-- Survival Starting Kit (apokalipszis kezdőcsomag)
Config.StartingKit = {
    Enable = true,
    
    -- Kezdő itemek (ll-inventory integration)
    Items = {
        {item = 'water_bottle', count = 2},
        {item = 'bread', count = 3},
        {item = 'flashlight', count = 1},
        {item = 'bandage', count = 2}
    },
    
    -- Kezdő pénz
    Money = {
        cash = 500,
        bank = 0
    },
    
    -- Kezdő státuszok (apokalipszis)
    ApocalypseStats = {
        sanity = 100,
        radiation = 0,
        hunger = 100,
        thirst = 100,
        infection = 0
    }
}

-- Tutorial (opcionális)
Config.Tutorial = {
    Enable = true,
    ShowForNewPlayers = true,
    
    Steps = {
        {
            title = 'Üdvözlünk!',
            description = 'Ez egy apokalipszis túlélő szerver. Figyelj a statisztikáidra!',
            duration = 5000
        },
        {
            title = 'Alapvető túlélés',
            description = 'Keress ételt, vizet és menedéket. Kerüld a radiációt!',
            duration = 5000
        },
        {
            title = 'Veszélyek',
            description = 'Zombik, radiáció és más játékosok is veszélyt jelentenek.',
            duration = 5000
        }
    }
}

-- Logging
Config.Logging = {
    EnableDiscordLog = false,
    WebhookURL = '',
    
    -- Mit logooljunk
    LogCharacterCreation = true,
    LogCharacterDeletion = true,
    LogCharacterSelection = true
}