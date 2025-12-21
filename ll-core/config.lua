Config = {}

-- Alap beállítások
Config.Locale = 'hu' -- Alapértelmezett nyelv
Config.Debug = false -- Debug mód

-- Spawn beállítások
Config.DefaultSpawn = vector4(-1037.97, -2738.61, 20.17, 329.39) -- Alap spawn pont
Config.SpawnProtection = 10 -- Spawn védelem (másodperc)

-- Halálkezelés
Config.Death = {
    RespawnTime = 300, -- Újraéledés ideje (másodperc)
    LoseInventory = false, -- Elveszíti-e az inventory-t halálkor
    RespawnAtHospital = true, -- Kórházban éled újra
    HospitalSpawns = {
        vector4(307.7, -1433.28, 29.89, 49.98), -- Pillbox Hill
        vector4(1839.13, 3672.85, 34.28, 209.84), -- Sandy Shores
        vector4(-247.76, 6331.23, 32.43, 223.28) -- Paleto Bay
    }
}

-- Játékos adatok
Config.Player = {
    DefaultMoney = 5000, -- Kezdő készpénz
    DefaultBank = 0, -- Kezdő bank egyenleg
    SaveInterval = 300000, -- Játékos adatok mentésének gyakorisága (ms) - 5 perc
}

-- Streaming beállítások
Config.Streaming = {
    EnableCustomClothes = true, -- Egyedi ruhák streamelése
    EnableCustomVehicles = true, -- Egyedi járművek streamelése
    EnableCustomWeapons = true, -- Egyedi fegyverek streamelése
    EnableDefaultAssets = true -- GTA alap assetek betöltése
}

-- Command beállítások
Config.Commands = {
    TeleportCommand = 'tp', -- Teleport parancs
    HealCommand = 'heal', -- Gyógyítás parancs
    ReviveCommand = 'revive', -- Újraélesztés parancs
    SaveCommand = 'save', -- Manuális mentés parancs
    AdminGroups = {'admin', 'superadmin', 'moderator'} -- Admin csoportok
}

-- Discord webhook (opcionális - csatlakozás/kilépés log)
Config.DiscordWebhook = {
    Enabled = false,
    WebhookURL = '',
    BotName = 'Last Light Logger',
    LogConnect = true,
    LogDisconnect = true
}

-- Karakter limitek
Config.Character = {
    MaxCharacters = 3, -- Maximum karakterek száma játékosonként
    NameMinLength = 3,
    NameMaxLength = 50
}

-- Performancia beállítások
Config.Performance = {
    DisableAmbientPeds = true, -- NPC-k kikapcsolása
    DisableAmbientVehicles = true, -- NPC autók kikapcsolása
    DisableAmbientProps = false, -- Környezeti objektumok
    DisableHealthRegen = true, -- Automatikus gyógyulás kikapcsolása
    DisableWeaponWheel = false -- Fegyver választó
}

-- APOKALIPSZIS BEÁLLÍTÁSOK
Config.Apocalypse = {
    Enabled = true, -- Apokalipszis rendszer engedélyezése
    
    -- Mentális állapot (Sanity)
    Sanity = {
        Enabled = true,
        MaxSanity = 100,
        StartingSanity = 100,
        DecreaseRate = 0.1, -- Csökkenés percenként
        LowSanityThreshold = 30, -- Alacsony elme állapot
        CriticalSanityThreshold = 10, -- Kritikus elme állapot
        
        -- Elme állapot csökkenés
        DecreaseFactors = {
            InDark = 0.2, -- Sötétben
            NearDead = 0.5, -- Halott közelében
            LowHealth = 0.3, -- Alacsony életerő
            Alone = 0.1, -- Egyedül (messze másoktól)
            InRadiation = 0.4 -- Radiációs zónában
        },
        
        -- Elme állapot növelés
        IncreaseFactors = {
            NearFire = 0.3, -- Tűz közelében
            NearPlayers = 0.2, -- Játékosok közelében
            InSafeZone = 0.5, -- Biztonságos zónában
            Eating = 2.0, -- Étkezés
            Sleeping = 3.0 -- Alvás
        },
        
        -- Hatások alacsony elme állapotnál
        Effects = {
            Hallucinations = true, -- Hallucinációk
            ReducedAccuracy = true, -- Csökkent pontosság
            Paranoia = true, -- Paranoia (NPC-k látszanak)
            ReducedSpeed = true -- Csökkent sebesség
        }
    },
    
    -- Radioaktivitás
    Radiation = {
        Enabled = true,
        MaxRadiation = 100,
        StartingRadiation = 0,
        DecayRate = 0.5, -- Csökkenés percenként (természetes bomlás)
        DamageThreshold = 50, -- Ettől kezd sebzést okozni
        DamagePerTick = 2, -- HP csökkenés tickenként (5 másodperc)
        
        -- Radiációs zónák (automatikus detektálás)
        Zones = {
            {
                name = "Katonai Bázis",
                coords = vector3(-2355.0, 3249.0, 32.0),
                radius = 500.0,
                radiationLevel = 5.0, -- Radáció növekedés másodpercenként
                warning = true
            },
            {
                name = "Kraftmű",
                coords = vector3(2776.0, 1533.0, 24.5),
                radius = 300.0,
                radiationLevel = 8.0,
                warning = true
            },
            {
                name = "Sandy Shores Airfield",
                coords = vector3(1747.0, 3273.0, 41.0),
                radius = 400.0,
                radiationLevel = 3.0,
                warning = true
            }
        },
        
        -- Védelem
        Protection = {
            RadSuit = 95, -- 95% védelem (item: radsuit)
            GasMask = 30, -- 30% védelem (item: gasmask)
            Bunker = 100 -- 100% védelem (interior)
        }
    },
    
    -- Éhség és Szomjúság
    Needs = {
        Enabled = true,
        
        Hunger = {
            Max = 100,
            Starting = 100,
            DecreaseRate = 0.15, -- Csökkenés percenként
            CriticalThreshold = 20,
            DamageWhenCritical = 1 -- HP csökkenés tickenként
        },
        
        Thirst = {
            Max = 100,
            Starting = 100,
            DecreaseRate = 0.25, -- Gyorsabban csökken mint éhség
            CriticalThreshold = 15,
            DamageWhenCritical = 2 -- Több HP csökkenés
        },
        
        -- Hőmérséklet hatása
        Temperature = {
            Hot = 1.5, -- Szomjúság gyorsabb csökkenés melegben
            Cold = 1.3 -- Éhség gyorsabb csökkenés hidegben
        }
    },
    
    -- Fertőzés rendszer
    Infection = {
        Enabled = true,
        SpreadChance = 25, -- % esély zombi támadáskor
        ProgressionRate = 0.5, -- Fertőzés terjedési sebessége percenként
        MaxInfection = 100,
        DeathAtMax = true, -- Halál 100%-nál
        
        Stages = {
            {level = 25, effects = {'cough', 'fatigue'}},
            {level = 50, effects = {'fever', 'reduced_speed'}},
            {level = 75, effects = {'hallucinations', 'reduced_health'}},
            {level = 100, effects = {'death'}}
        },
        
        Cure = {
            Item = 'antibiotics',
            ReduceAmount = 50 -- Mennyit csökkent
        }
    },
    
    -- Környezeti veszélyek
    Environment = {
        -- Dinamikus időjárás
        DynamicWeather = true,
        RadiationStorms = true, -- Radiációs viharok
        StormInterval = {min = 1800, max = 3600}, -- 30-60 perc között
        StormDuration = 300, -- 5 perc
        
        -- Éjszakai veszélyek
        DangerousNights = true,
        NightDamageMultiplier = 1.5, -- Több sebzés éjjel
        NightSanityDecrease = 2.0 -- Gyorsabb elme csökkenés
    },
    
    -- Túlélési zónák
    SafeZones = {
        {
            name = "Bunker Alpha",
            coords = vector3(-1082.0, -2742.0, -7.0),
            radius = 50.0,
            benefits = {
                noRadiation = true,
                sanityRegen = true,
                noInfection = true
            }
        },
        {
            name = "Paleto Bay Menedék",
            coords = vector3(-356.0, 6336.0, 29.0),
            radius = 100.0,
            benefits = {
                noRadiation = true,
                sanityRegen = true
            }
        }
    },
    
    -- Zombik / Mutánsok (NPC)
    Zombies = {
        Enabled = true,
        SpawnRadius = 200.0, -- Játékostól való távolság
        MaxZombies = 10, -- Maximum zombie egyszerre
        SpawnInterval = 30, -- Másodpercek spawn között
        
        Types = {
            {
                name = "Walker",
                model = "a_m_y_downtown_01",
                health = 150,
                damage = 10,
                speed = 0.7,
                spawnChance = 60
            },
            {
                name = "Runner",
                model = "a_m_y_runner_01",
                health = 100,
                damage = 15,
                speed = 1.5,
                spawnChance = 30
            },
            {
                name = "Tank",
                model = "s_m_m_bouncer_01",
                health = 400,
                damage = 30,
                speed = 0.5,
                spawnChance = 10
            }
        },
        
        -- Zombik csak éjjel
        NightOnly = false,
        MoreAtNight = true, -- Több spawn éjjel
        
        -- Infection esély támadáskor
        InfectionChance = 25
    },
    
    -- Crafting (túlélési eszközök)
    Crafting = {
        Enabled = true,
        RequireWorkbench = false -- Kell-e workbench
    },
    
    -- Loot rendszer
    Loot = {
        Enabled = true,
        RespawnTime = 1800, -- 30 perc
        RandomizeQuantity = true
    }
}

-- Időjárás beállítások (apokaliptikus)
Config.Weather = {
    Types = {
        'EXTRASUNNY',
        'CLOUDS',
        'OVERCAST',
        'RAIN',
        'THUNDER',
        'SMOG', -- Apokaliptikus
        'FOGGY' -- Apokaliptikus
    },
    
    -- Radiációs vihar
    RadStorm = {
        Weather = 'THUNDER',
        RadiationIncrease = 10.0, -- Radáció növekedés másodpercenként
        WarningTime = 60 -- 1 perc figyelmeztetés
    }
}