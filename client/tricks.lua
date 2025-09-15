-- Advanced trick detection and mechanics
local trickHistory = {}
local perfectTrickBonus = {}

-- Register trick events
RegisterNetEvent('cs-tricks:trickStarted')
AddEventHandler('cs-tricks:trickStarted', function(trickType)
    -- Visual effects for trick start
    if Config.UI.ShowTrickName then
        ShowTrickNotification(trickType, 'started')
    end
    
    -- Add to history
    table.insert(trickHistory, {
        type = trickType,
        startTime = GetGameTimer(),
        endTime = nil,
        score = 0
    })
end)

RegisterNetEvent('cs-tricks:trickCompleted')
AddEventHandler('cs-tricks:trickCompleted', function(trickType, score, duration)
    -- Update history
    if #trickHistory > 0 then
        local lastTrick = trickHistory[#trickHistory]
        if lastTrick.type == trickType and not lastTrick.endTime then
            lastTrick.endTime = GetGameTimer()
            lastTrick.score = score
            lastTrick.duration = duration
        end
    end
    
    -- Show completion notification
    ShowTrickNotification(trickType, 'completed', score, duration)
    
    -- Check for perfect trick
    CheckPerfectTrick(trickType, duration)
end)

RegisterNetEvent('cs-tricks:flipCompleted')
AddEventHandler('cs-tricks:flipCompleted', function(flipType, score)
    ShowTrickNotification(flipType, 'completed', score)
    
    -- Add to history
    table.insert(trickHistory, {
        type = flipType,
        startTime = GetGameTimer(),
        endTime = GetGameTimer(),
        score = score,
        duration = 0
    })
end)

RegisterNetEvent('cs-tricks:comboUpdate')
AddEventHandler('cs-tricks:comboUpdate', function(comboCount)
    if Config.UI.ShowCombo and comboCount > 1 then
        ShowComboNotification(comboCount)
    end
end)

-- Show trick notification
function ShowTrickNotification(trickType, status, score, duration)
    local message = ""
    local color = {255, 255, 255}
    
    if status == 'started' then
        message = string.format("Started %s!", string.upper(trickType))
        color = {0, 255, 255}
    elseif status == 'completed' then
        if duration then
            local durationSec = duration / 1000
            message = string.format("%s completed! +%d points (%.1fs)", 
                string.upper(trickType), score, durationSec)
        else
            message = string.format("%s completed! +%d points", 
                string.upper(trickType), score)
        end
        color = {0, 255, 0}
    end
    
    -- Send to chat
    TriggerEvent('chat:addMessage', {
        color = color,
        args = {"Tricks", message}
    })
    
    -- Send to UI
    if Config.UI.ShowTrickName then
        SendNUIMessage({
            type = 'showTrick',
            trickType = trickType,
            status = status,
            score = score,
            duration = duration
        })
    end
end

-- Show combo notification
function ShowComboNotification(comboCount)
    local message = string.format("COMBO x%d!", comboCount)
    local color = {255, 165, 0} -- Orange
    
    TriggerEvent('chat:addMessage', {
        color = color,
        args = {"Tricks", message}
    })
    
    SendNUIMessage({
        type = 'showCombo',
        comboCount = comboCount
    })
end

-- Check for perfect trick (long duration)
function CheckPerfectTrick(trickType, duration)
    local perfectThreshold = 0
    local perfectBonus = 0
    
    if trickType == 'wheelie' then
        perfectThreshold = 5000 -- 5 seconds
        perfectBonus = Config.Scores.Wheelie.perfect
    elseif trickType == 'stoppie' then
        perfectThreshold = 4000 -- 4 seconds
        perfectBonus = Config.Scores.Stoppie.perfect
    end
    
    if duration >= perfectThreshold then
        -- Award perfect bonus
        exports['cs-tricks']:AddScore(perfectBonus)
        
        TriggerEvent('chat:addMessage', {
            color = {255, 215, 0}, -- Gold
            args = {"Tricks", string.format("PERFECT %s! Bonus: +%d points", 
                string.upper(trickType), perfectBonus)}
        })
        
        SendNUIMessage({
            type = 'showPerfect',
            trickType = trickType,
            bonus = perfectBonus
        })
    end
end

-- Advanced wheelie detection
function IsPerformingWheelie(vehicle)
    local rotation = GetEntityRotation(vehicle, 2)
    local velocity = GetEntityVelocity(vehicle)
    local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
    
    -- Check if front wheel is significantly higher than rear
    return rotation.x > 15.0 and speed > 5.0
end

-- Advanced stoppie detection
function IsPerformingStoppie(vehicle)
    local rotation = GetEntityRotation(vehicle, 2)
    local velocity = GetEntityVelocity(vehicle)
    local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
    
    -- Check if rear wheel is significantly higher than front
    return rotation.x < -15.0 and speed > 5.0
end

-- Detect natural tricks (not key-initiated)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle and vehicle ~= 0 and exports['cs-tricks']:GetTrickStats().currentTrick == nil then
            local vehicleClass = GetVehicleClass(vehicle)
            
            if vehicleClass == 8 then -- Motorcycle
                -- Natural wheelie detection
                if IsPerformingWheelie(vehicle) then
                    TriggerEvent('cs-tricks:naturalTrickDetected', 'wheelie')
                end
                
                -- Natural stoppie detection
                if IsPerformingStoppie(vehicle) then
                    TriggerEvent('cs-tricks:naturalTrickDetected', 'stoppie')
                end
            end
        end
    end
end)

-- Handle natural trick detection
RegisterNetEvent('cs-tricks:naturalTrickDetected')
AddEventHandler('cs-tricks:naturalTrickDetected', function(trickType)
    -- Only trigger if no active trick and conditions are met
    local stats = exports['cs-tricks']:GetTrickStats()
    if not stats.trickActive then
        -- Auto-start natural trick
        TriggerEvent('cs-tricks:trickStarted', trickType)
    end
end)

-- Get trick history
function GetTrickHistory()
    return trickHistory
end

-- Clear trick history
function ClearTrickHistory()
    trickHistory = {}
end

-- Get session statistics
function GetSessionStats()
    local stats = {
        totalTricks = #trickHistory,
        wheelies = 0,
        stoppies = 0,
        flips = 0,
        totalDuration = 0,
        averageScore = 0,
        bestTrick = nil
    }
    
    local totalScore = 0
    
    for _, trick in pairs(trickHistory) do
        if trick.type == 'wheelie' then
            stats.wheelies = stats.wheelies + 1
        elseif trick.type == 'stoppie' then
            stats.stoppies = stats.stoppies + 1
        elseif string.find(trick.type, 'flip') then
            stats.flips = stats.flips + 1
        end
        
        if trick.duration then
            stats.totalDuration = stats.totalDuration + trick.duration
        end
        
        totalScore = totalScore + trick.score
        
        if not stats.bestTrick or trick.score > stats.bestTrick.score then
            stats.bestTrick = trick
        end
    end
    
    if stats.totalTricks > 0 then
        stats.averageScore = totalScore / stats.totalTricks
    end
    
    return stats
end

-- Export functions
exports('GetTrickHistory', GetTrickHistory)
exports('ClearTrickHistory', ClearTrickHistory)
exports('GetSessionStats', GetSessionStats)