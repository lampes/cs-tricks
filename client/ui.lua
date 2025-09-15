local uiVisible = false

-- UI State management
RegisterNetEvent('cs-tricks:scoreUpdate')
AddEventHandler('cs-tricks:scoreUpdate', function(score, totalScore, sessionScore)
    if Config.UI.ShowScore then
        SendNUIMessage({
            type = 'updateScore',
            score = score,
            totalScore = totalScore,
            sessionScore = sessionScore
        })
    end
end)

RegisterNetEvent('cs-tricks:statsReset')
AddEventHandler('cs-tricks:statsReset', function()
    SendNUIMessage({
        type = 'resetStats'
    })
end)

-- Toggle UI visibility
function ToggleUI()
    uiVisible = not uiVisible
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = 'toggleUI',
        visible = uiVisible
    })
    
    local message = uiVisible and "UI Enabled" or "UI Disabled"
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        args = {"Tricks", message}
    })
end

-- Show stats command
RegisterCommand('trickstats', function()
    local stats = exports['cs-tricks']:GetTrickStats()
    local sessionStats = exports['cs-tricks']:GetSessionStats()
    
    local message = string.format(
        "Session: %d points | Total: %d points | Tricks: %d | Combo: x%d",
        stats.sessionScore,
        stats.totalScore,
        sessionStats.totalTricks,
        stats.comboCount
    )
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 255},
        args = {"Trick Stats", message}
    })
    
    -- Detailed breakdown
    if sessionStats.totalTricks > 0 then
        local breakdown = string.format(
            "Wheelies: %d | Stoppies: %d | Flips: %d | Avg Score: %.1f",
            sessionStats.wheelies,
            sessionStats.stoppies,
            sessionStats.flips,
            sessionStats.averageScore
        )
        
        TriggerEvent('chat:addMessage', {
            color = {200, 200, 200},
            args = {"Details", breakdown}
        })
    end
end, false)

-- Show leaderboard command
RegisterCommand('tricktop', function()
    -- This would typically fetch from server, but for now show local stats
    local sessionStats = exports['cs-tricks']:GetSessionStats()
    
    if sessionStats.bestTrick then
        local bestTrick = sessionStats.bestTrick
        local message = string.format(
            "Best Trick: %s (%d points)",
            string.upper(bestTrick.type),
            bestTrick.score
        )
        
        TriggerEvent('chat:addMessage', {
            color = {255, 215, 0},
            args = {"Best Trick", message}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            args = {"Tricks", "No tricks performed yet!"}
        })
    end
end, false)

-- Show help command
RegisterCommand('trickhelp', function()
    local helpMessages = {
        "=== CS-TRICKS HELP ===",
        "Left Shift: Hold for Wheelie",
        "Left Alt: Hold for Stoppie", 
        "Space: Perform Flip",
        "F5: Toggle UI",
        "",
        "Commands:",
        "/trickstats - Show statistics",
        "/tricktop - Show best trick",
        "/resetstats - Reset session stats",
        "/trickhelp - Show this help"
    }
    
    for _, message in pairs(helpMessages) do
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            args = {"", message}
        })
    end
end, false)

-- Initialize UI
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for game to load
    
    SendNUIMessage({
        type = 'init',
        config = {
            showScore = Config.UI.ShowScore,
            showCombo = Config.UI.ShowCombo,
            showTrickName = Config.UI.ShowTrickName,
            position = Config.UI.Position
        }
    })
end)

-- Handle UI callbacks
RegisterNUICallback('closeUI', function(data, cb)
    uiVisible = false
    SetNuiFocus(false, false)
    cb({})
end)