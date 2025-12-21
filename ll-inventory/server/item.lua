-- ITEM PÉLDÁK AZ APOKALIPSZIS RENDSZERHEZ
-- Ez a fájl NEM tartozik az ll-core-hoz, csak példa az ll-inventory számára

-- Ezeket az itemeket kell létrehozni az ll-inventory/server/item.lua fájlban

Items = {
    -- ÉTEL ITEMEK
    ['canned_beans'] = {
        label = 'Konzerv Bab',
        weight = 200,
        type = 'food',
        unique = false,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = 'Egy konzerv bab. Enyhíti az éhséget.',
        -- Használat
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Konzerv Bab', 25, 0)
            -- 25 éhség + 0 szomjúság
        end
    },
    
    ['canned_tuna'] = {
        label = 'Konzerv Tonhal',
        weight = 150,
        type = 'food',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Tonhal konzerv. Jó fehérje forrás.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Konzerv Tonhal', 30, 5)
            -- 30 éhség + 5 szomjúság
        end
    },
    
    ['bread'] = {
        label = 'Kenyér',
        weight = 100,
        type = 'food',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Egy szelet száraz kenyér.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Kenyér', 15, 0)
        end
    },
    
    ['mre'] = {
        label = 'MRE (Katonai Adag)',
        weight = 500,
        type = 'food',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Katonai túlélési adag. Nagyon tápláló.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'MRE', 50, 10)
            -- Bonus: +5 sanity
            local apocalypseData = exports['ll-core']:GetApocalypseStats(source)
            if apocalypseData then
                apocalypseData.sanity = math.min(100, apocalypseData.sanity + 5)
            end
        end
    },
    
    -- ITAL ITEMEK
    ['water_bottle'] = {
        label = 'Tiszta Víz',
        weight = 200,
        type = 'drink',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Egy palack tiszta ivóvíz.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Tiszta Víz', 0, 35)
            -- 0 éhség + 35 szomjúság
        end
    },
    
    ['dirty_water'] = {
        label = 'Szennyezett Víz',
        weight = 200,
        type = 'drink',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Vízforrásból merített víz. Veszélyes lehet!',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Szennyezett Víz', 0, 20)
            -- Van esély fertőzésre!
            if math.random(100) <= 30 then -- 30% esély
                TriggerClientEvent('ll-core:client:addInfection', source, 5)
            end
        end
    },
    
    ['soda'] = {
        label = 'Üdítő',
        weight = 150,
        type = 'drink',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Egy doboz üdítő. Nem túl egészséges, de jobb a semminél.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Üdítő', 5, 25)
        end
    },
    
    ['energy_drink'] = {
        label = 'Energiaital',
        weight = 150,
        type = 'drink',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Energiaital. Rövid időre erőt ad.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:consumeFood', source, 'Energiaital', 0, 30)
            -- Bonus: Speed boost 60 másodpercig
            -- TODO: Implement speed boost
        end
    },
    
    -- GYÓGYSZER ITEMEK
    ['antibiotics'] = {
        label = 'Antibiotikum',
        weight = 50,
        type = 'medical',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Antibiotikum. Csökkenti a fertőzést.',
        onUse = function(source, item)
            TriggerClientEvent('ll-core:client:useAntibiotics', source)
            -- -50% fertőzés (a client oldalon kezelve)
        end
    },
    
    ['radaway'] = {
        label = 'RadAway',
        weight = 100,
        type = 'medical',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Radiáció elleni gyógyszer. Csökkenti a sugárzást.',
        onUse = function(source, item)
            local apocalypseData = exports['ll-core']:GetApocalypseStats(source)
            if apocalypseData then
                apocalypseData.radiation = math.max(0, apocalypseData.radiation - 40)
                TriggerClientEvent('ll-core:client:notify', source, 'RadAway használva! Radiáció csökkent.', 'success')
            end
        end
    },
    
    ['bandage'] = {
        label = 'Kötszer',
        weight = 50,
        type = 'medical',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Első segély kötszer. Gyógyít egy keveset.',
        onUse = function(source, item)
            local ped = GetPlayerPed(source)
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped, math.min(200, health + 20))
            TriggerClientEvent('ll-core:client:notify', source, 'Kötszer használva! +20 HP', 'success')
        end
    },
    
    ['medkit'] = {
        label = 'Elsősegély Csomag',
        weight = 200,
        type = 'medical',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Teljes elsősegély készlet. Nagyobb gyógyulás.',
        onUse = function(source, item)
            local ped = GetPlayerPed(source)
            SetEntityHealth(ped, 200) -- Full HP
            TriggerClientEvent('ll-core:client:notify', source, 'Medkit használva! Teljes gyógyulás.', 'success')
        end
    },
    
    ['painkillers'] = {
        label = 'Fájdalomcsillapító',
        weight = 30,
        type = 'medical',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Fájdalomcsillapító. Növeli a sanity-t.',
        onUse = function(source, item)
            local apocalypseData = exports['ll-core']:GetApocalypseStats(source)
            if apocalypseData then
                apocalypseData.sanity = math.min(100, apocalypseData.sanity + 10)
                TriggerClientEvent('ll-core:client:notify', source, 'Fájdalomcsillapító használva! +10 Sanity', 'success')
            end
        end
    },
    
    -- VÉDŐFELSZERELÉS
    ['radsuit'] = {
        label = 'RadSuit',
        weight = 5000,
        type = 'armor',
        unique = true,
        useable = true,
        shouldClose = true,
        description = 'Teljes test radiáció védelem. 95% védelem.',
        onUse = function(source, item)
            -- TODO: Ruha felhelyezése (ll-skin integration)
            -- Radiáció védelem: 95%
            TriggerClientEvent('ll-core:client:notify', source, 'RadSuit felöltve!', 'success')
        end
    },
    
    ['gasmask'] = {
        label = 'Gázmaszk',
        weight = 500,
        type = 'armor',
        unique = true,
        useable = true,
        shouldClose = true,
        description = 'Gázmaszk. 30% radiáció védelem.',
        onUse = function(source, item)
            -- TODO: Prop felhelyezés
            TriggerClientEvent('ll-core:client:notify', source, 'Gázmaszk felvéve!', 'success')
        end
    },
    
    -- ESZKÖZÖK
    ['flashlight'] = {
        label = 'Zseblámpa',
        weight = 200,
        type = 'tool',
        unique = false,
        useable = true,
        shouldClose = false,
        description = 'Zseblámpa. Segít a sötétben.',
        onUse = function(source, item)
            -- TODO: Flashlight toggle
            TriggerClientEvent('ll-core:client:toggleFlashlight', source)
        end
    },
    
    ['map'] = {
        label = 'Térkép',
        weight = 100,
        type = 'tool',
        unique = false,
        useable = true,
        shouldClose = false,
        description = 'Egy régi térkép. Segít az eligazodásban.',
        onUse = function(source, item)
            -- TODO: Open map UI
            TriggerClientEvent('ll-core:client:openMap', source)
        end
    },
    
    ['geiger_counter'] = {
        label = 'Geiger Számláló',
        weight = 300,
        type = 'tool',
        unique = false,
        useable = true,
        shouldClose = false,
        description = 'Radiáció mérő. Megmutatja a környezeti sugárzást.',
        onUse = function(source, item)
            local apocalypseData = exports['ll-core']:GetApocalypseStats(source)
            if apocalypseData then
                local radLevel = apocalypseData.radiation
                local message = string.format('🔬 Radiáció szint: %.1f', radLevel)
                TriggerClientEvent('ll-core:client:notify', source, message, 'info', 10000)
            end
        end
    },
    
    -- CRAFTING ALAPANYAGOK
    ['scrap_metal'] = {
        label = 'Fémhulladék',
        weight = 500,
        type = 'material',
        unique = false,
        useable = false,
        shouldClose = false,
        description = 'Fémhulladék darabok. Craftinghoz használható.'
    },
    
    ['cloth'] = {
        label = 'Rongy',
        weight = 100,
        type = 'material',
        unique = false,
        useable = false,
        shouldClose = false,
        description = 'Rongy darabok. Craftinghoz használható.'
    },
    
    ['plastic'] = {
        label = 'Műanyag',
        weight = 50,
        type = 'material',
        unique = false,
        useable = false,
        shouldClose = false,
        description = 'Műanyag hulladék. Craftinghoz használható.'
    },
    
    ['electronics'] = {
        label = 'Elektronika',
        weight = 200,
        type = 'material',
        unique = false,
        useable = false,
        shouldClose = false,
        description = 'Elektronikai alkatrészek. Értékes anyag.'
    }
}

-- CRAFTING RECEPTEK (példa)
CraftingRecipes = {
    -- Kötszer készítés
    {
        result = 'bandage',
        resultCount = 1,
        ingredients = {
            {item = 'cloth', count = 2}
        },
        craftTime = 5000 -- 5 másodperc
    },
    
    -- RadAway készítés (advanced)
    {
        result = 'radaway',
        resultCount = 1,
        ingredients = {
            {item = 'electronics', count = 1},
            {item = 'plastic', count = 2},
            {item = 'water_bottle', count = 1}
        },
        craftTime = 15000 -- 15 másodperc
    },
    
    -- Gázmaszk javítás
    {
        result = 'gasmask',
        resultCount = 1,
        ingredients = {
            {item = 'gasmask', count = 1}, -- Törött
            {item = 'plastic', count = 3},
            {item = 'cloth', count = 2}
        },
        craftTime = 20000
    }
}

-- LOOT TÁBLÁK (példa zombie-kra)
ZombieLoot = {
    -- Walker
    ['walker'] = {
        {item = 'cloth', count = {1, 3}, chance = 60},
        {item = 'scrap_metal', count = {1, 2}, chance = 30},
        {item = 'canned_beans', count = 1, chance = 20},
        {item = 'dirty_water', count = 1, chance = 15}
    },
    
    -- Runner
    ['runner'] = {
        {item = 'cloth', count = {2, 4}, chance = 50},
        {item = 'bandage', count = 1, chance = 25},
        {item = 'painkillers', count = 1, chance = 20}
    },
    
    -- Tank
    ['tank'] = {
        {item = 'scrap_metal', count = {3, 5}, chance = 80},
        {item = 'electronics', count = {1, 2}, chance = 40},
        {item = 'medkit', count = 1, chance = 30},
        {item = 'antibiotics', count = 1, chance = 25}
    }
}