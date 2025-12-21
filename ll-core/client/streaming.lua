-- Streaming rendszer - Egyedi ruhák, autók, fegyverek + alap GTA assetek

-- Request model helper
function RequestModelSync(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if not IsModelValid(hash) then
        LL.Debug('Invalid model: ' .. tostring(model))
        return false
    end
    
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 5000 do
            Citizen.Wait(10)
            timeout = timeout + 10
        end
        
        if not HasModelLoaded(hash) then
            LL.Debug('Model loading timeout: ' .. tostring(model))
            return false
        end
    end
    
    return true
end

-- Request anim dict helper
function RequestAnimDictSync(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        
        local timeout = 0
        while not HasAnimDictLoaded(dict) and timeout < 5000 do
            Citizen.Wait(10)
            timeout = timeout + 10
        end
        
        if not HasAnimDictLoaded(dict) then
            LL.Debug('Anim dict loading timeout: ' .. dict)
            return false
        end
    end
    
    return true
end

-- Request weapon asset helper
function RequestWeaponAssetSync(weaponHash, timeout)
    timeout = timeout or 5000
    
    if not HasWeaponAssetLoaded(weaponHash) then
        RequestWeaponAsset(weaponHash, 31, 0)
        
        local timer = 0
        while not HasWeaponAssetLoaded(weaponHash) and timer < timeout do
            Citizen.Wait(10)
            timer = timer + 10
        end
        
        if not HasWeaponAssetLoaded(weaponHash) then
            LL.Debug('Weapon asset loading timeout: ' .. tostring(weaponHash))
            return false
        end
    end
    
    return true
end

-- Alap GTA assetek betöltése
Citizen.CreateThread(function()
    if Config.Streaming.EnableDefaultAssets then
        LL.Debug('Loading default GTA assets...')
        
        -- Gyakran használt modellek előtöltése
        local commonModels = {
            -- Ped modellek
            'mp_m_freemode_01', -- Férfi alap modell
            'mp_f_freemode_01', -- Női alap modell
            
            -- Járművek
            'adder',
            'zentorno',
            'insurgent',
            'police',
            'police2',
            'ambulance',
            'firetruk',
            
            -- Objektumok
            'prop_box_wood01a',
            'prop_chair_01a',
            'prop_table_01'
        }
        
        for _, model in pairs(commonModels) do
            RequestModelSync(model)
        end
        
        LL.Debug('Default GTA assets loaded')
    end
end)

-- Egyedi ruhák streamelése
if Config.Streaming.EnableCustomClothes then
    -- TODO: Itt kell implementálni az egyedi ruhák betöltését
    -- Példa: stream mappa beolvasása és modellek regisztrálása
    Citizen.CreateThread(function()
        LL.Debug('Custom clothes streaming enabled')
        
        -- Egyedi ruha streamek betöltése
        -- Az ll-skin resource fogja használni később
    end)
end

-- Egyedi járművek streamelése
if Config.Streaming.EnableCustomVehicles then
    Citizen.CreateThread(function()
        LL.Debug('Custom vehicles streaming enabled')
        
        -- Egyedi jármű streamek betöltése
        -- DLC pack-ek automatikus detektálása és betöltése
    end)
end

-- Egyedi fegyverek streamelése
if Config.Streaming.EnableCustomWeapons then
    Citizen.CreateThread(function()
        LL.Debug('Custom weapons streaming enabled')
        
        -- Egyedi fegyver streamek betöltése
    end)
end

-- IPL-ek betöltése (interiorok)
Citizen.CreateThread(function()
    -- Alap interiorok aktiválása
    local ipls = {
        -- Pillbox Hill Medical Center
        'RC12B_Default',
        'RC12B_Fixed',
        
        -- Vanilla Unicorn
        'v_vanilla',
        
        -- Bahama Mamas
        'hei_sm_16_interior_v_bahama_mamas_milo_',
        
        -- North Yankton (ha kell)
        -- 'prologue01',
        -- 'prologue01c',
        -- 'prologue01d',
        -- 'prologue01e',
    }
    
    for _, ipl in pairs(ipls) do
        RequestIpl(ipl)
        LL.Debug('IPL loaded: ' .. ipl)
    end
end)

-- Model cleanup (memória optimalizáció)
function CleanupUnusedModels()
    -- Nem használt modellek eltávolítása
    local models = {
        'mp_m_freemode_01',
        'mp_f_freemode_01',
        'adder',
        'zentorno'
    }
    
    for _, model in pairs(models) do
        local hash = GetHashKey(model)
        if HasModelLoaded(hash) then
            SetModelAsNoLongerNeeded(hash)
        end
    end
end

-- Periodikus cleanup
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- 5 percenként
        
        if Config.Debug then
            CleanupUnusedModels()
            LL.Debug('Model cleanup executed')
        end
    end
end)

-- Exports
exports('RequestModel', function(model)
    return RequestModelSync(model)
end)

exports('RequestAnimDict', function(dict)
    return RequestAnimDictSync(dict)
end)

exports('RequestWeaponAsset', function(weapon)
    return RequestWeaponAssetSync(weapon)
end)