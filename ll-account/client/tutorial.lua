-- Tutorial rendszer új játékosoknak

local tutorialActive = false
local currentStep = 0

-- Tutorial indítása
function Account.ShowTutorial()
    if not Config.Tutorial or not Config.Tutorial.Enable then
        return
    end
    
    if not Config.Tutorial.Steps or #Config.Tutorial.Steps == 0 then
        return
    end
    
    tutorialActive = true
    currentStep = 0
    
    Account.Debug('Starting tutorial')
    
    -- Első lépés
    Citizen.Wait(1000)
    Account.ShowNextTutorialStep()
end

-- Következő lépés megjelenítése
function Account.ShowNextTutorialStep()
    if not tutorialActive then
        return
    end
    
    currentStep = currentStep + 1
    
    if currentStep > #Config.Tutorial.Steps then
        -- Tutorial vége
        Account.EndTutorial()
        return
    end
    
    local step = Config.Tutorial.Steps[currentStep]
    
    if not step then
        Account.EndTutorial()
        return
    end
    
    -- Notify megjelenítése
    Account.Notify(step.description, 'info', step.duration or 5000)
    
    Account.Debug('Tutorial step ' .. currentStep .. ': ' .. step.title)
    
    -- Következő lépés időzítése
    Citizen.SetTimeout(step.duration or 5000, function()
        Account.ShowNextTutorialStep()
    end)
end

-- Tutorial befejezése
function Account.EndTutorial()
    tutorialActive = false
    currentStep = 0
    
    Account.Debug('Tutorial ended')
    
    -- Notify a végén
    Account.Notify(_('tutorial_complete'), 'success', 5000)
end

-- Tutorial kihagyása (opcionális parancs)
RegisterCommand('skiptutorial', function()
    if tutorialActive then
        Account.EndTutorial()
        Account.Notify('Tutorial skipped', 'info', 3000)
    end
end, false)

-- Export
exports('ShowTutorial', Account.ShowTutorial)