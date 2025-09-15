local PlayerData = {}
local currentVehicle = nil
local isOnMotorcycle = false
local trickActive = false
local currentTrick = nil
local trickStartTime = 0
local totalScore = 0
local sessionScore = 0
local comboCount = 0
local comboTimer = 0
local lastTrickTime = 0

-- Initialize
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle and vehicle ~= 0 then
            currentVehicle = vehicle
            isOnMotorcycle = IsMotorcycle(vehicle)
            
            if isOnMotorcycle and Config.EnableTricks then
                HandleTrickControls()
                UpdateTrickLogic()
            end
        else
            currentVehicle = nil
            isOnMotorcycle = false
            if trickActive then
                EndTrick()
            end
        end
        
        -- Update combo timer
        if comboTimer > 0 then
            comboTimer = comboTimer - 1
            if comboTimer <= 0 then
                comboCount = 0
            end
        end
    end
end)

-- Check if vehicle is a motorcycle
function IsMotorcycle(vehicle)
    local model = GetEntityModel(vehicle)
    for _, motorcycleModel in pairs(Config.MotorcycleModels) do
        if model == GetHashKey(motorcycleModel) then
            return true
        end
    end
    return GetVehicleClass(vehicle) == 8 -- Motorcycle class
end

-- Handle trick controls
function HandleTrickControls()
    local playerPed = PlayerPedId()
    
    -- Wheelie
    if IsControlPressed(Config.Keys.Wheelie[1], Config.Keys.Wheelie[2]) then
        if not trickActive and CanPerformTrick() then
            StartTrick('wheelie')
        end
    elseif trickActive and currentTrick == 'wheelie' then
        EndTrick()
    end
    
    -- Stoppie
    if IsControlPressed(Config.Keys.Stoppie[1], Config.Keys.Stoppie[2]) then
        if not trickActive and CanPerformTrick() then
            StartTrick('stoppie')
        end
    elseif trickActive and currentTrick == 'stoppie' then
        EndTrick()
    end
    
    -- Flip (one-time action)
    if IsControlJustPressed(Config.Keys.Flip[1], Config.Keys.Flip[2]) then
        if not trickActive and CanPerformTrick() then
            PerformFlip()
        end
    end
    
    -- Toggle UI
    if IsControlJustPressed(Config.Keys.ToggleUI[1], Config.Keys.ToggleUI[2]) then
        ToggleUI()
    end
end

-- Check if player can perform tricks
function CanPerformTrick()
    if not currentVehicle or not isOnMotorcycle then
        return false
    end
    
    local speed = GetEntitySpeed(currentVehicle) * 3.6 -- Convert to km/h
    local isOnGround = IsVehicleOnAllWheels(currentVehicle)
    
    return speed >= Config.TrickSettings.MinSpeed and 
           speed <= Config.TrickSettings.MaxSpeed and
           isOnGround
end

-- Start a trick
function StartTrick(trickType)
    trickActive = true
    currentTrick = trickType
    trickStartTime = GetGameTimer()
    
    if Config.Debug then
        print(string.format("Started trick: %s", trickType))
    end
    
    TriggerEvent('cs-tricks:trickStarted', trickType)
end

-- End current trick
function EndTrick()
    if not trickActive then return end
    
    local trickDuration = GetGameTimer() - trickStartTime
    local score = CalculateTrickScore(currentTrick, trickDuration)
    
    if trickDuration >= Config.TrickSettings.MinTrickTime then
        AddScore(score)
        TriggerEvent('cs-tricks:trickCompleted', currentTrick, score, trickDuration)
        
        -- Check for combo
        if GetGameTimer() - lastTrickTime <= Config.TrickSettings.ComboTimeout then
            comboCount = comboCount + 1
            comboTimer = Config.TrickSettings.ComboTimeout
            TriggerEvent('cs-tricks:comboUpdate', comboCount)
        else
            comboCount = 1
            comboTimer = Config.TrickSettings.ComboTimeout
        end
        
        lastTrickTime = GetGameTimer()
    end
    
    trickActive = false
    currentTrick = nil
    trickStartTime = 0
    
    if Config.Debug then
        print(string.format("Ended trick. Duration: %dms, Score: %d", trickDuration, score))
    end
end

-- Perform flip trick
function PerformFlip()
    local vehicle = currentVehicle
    local velocity = GetEntityVelocity(vehicle)
    local speed = GetEntitySpeed(vehicle)
    
    -- Determine flip type based on player input and vehicle state
    local flipType = 'backflip' -- Default
    local forceMultiplier = math.min(speed * 0.1, 2.0)
    
    -- Apply flip force
    ApplyForceToEntity(vehicle, 1, 0.0, 0.0, forceMultiplier, 0.0, forceMultiplier, 0.0, false, true, true, true, false, true)
    
    -- Calculate score based on successful rotation
    Citizen.CreateThread(function()
        Citizen.Wait(1000) -- Wait for flip to complete
        local score = Config.Scores.Flip[flipType] or Config.Scores.Flip.base
        AddScore(score)
        TriggerEvent('cs-tricks:flipCompleted', flipType, score)
    end)
end

-- Calculate trick score
function CalculateTrickScore(trickType, duration)
    local baseScore = 0
    local durationBonus = 0
    
    if trickType == 'wheelie' then
        baseScore = Config.Scores.Wheelie.base
        durationBonus = math.floor(duration / 1000) * Config.Scores.Wheelie.perSecond
    elseif trickType == 'stoppie' then
        baseScore = Config.Scores.Stoppie.base
        durationBonus = math.floor(duration / 1000) * Config.Scores.Stoppie.perSecond
    end
    
    local totalScore = baseScore + durationBonus
    
    -- Speed bonus
    local speed = GetEntitySpeed(currentVehicle) * 3.6
    if speed >= Config.Scores.Speed.bonusThreshold then
        totalScore = math.floor(totalScore * Config.Scores.Speed.bonusMultiplier)
    end
    
    -- Combo multiplier
    if comboCount > 1 then
        local multiplier = math.min(
            1 + (comboCount - 1) * (Config.Scores.Combo.multiplier - 1),
            Config.Scores.Combo.maxMultiplier
        )
        totalScore = math.floor(totalScore * multiplier)
    end
    
    return totalScore
end

-- Add score to player
function AddScore(score)
    totalScore = totalScore + score
    sessionScore = sessionScore + score
    TriggerEvent('cs-tricks:scoreUpdate', score, totalScore, sessionScore)
end

-- Update trick logic
function UpdateTrickLogic()
    if not trickActive then return end
    
    local vehicle = currentVehicle
    local trickDuration = GetGameTimer() - trickStartTime
    
    -- Check if trick should end due to conditions
    if not IsVehicleOnAllWheels(vehicle) and currentTrick ~= 'flip' then
        -- Continue trick while airborne
    elseif currentTrick == 'wheelie' then
        -- Check wheelie angle
        local rotation = GetEntityRotation(vehicle, 2)
        if math.abs(rotation.x) < 10.0 then -- Not wheelie-ing enough
            EndTrick()
        end
    elseif currentTrick == 'stoppie' then
        -- Check stoppie angle  
        local rotation = GetEntityRotation(vehicle, 2)
        if math.abs(rotation.x) > -10.0 then -- Not stoppie-ing enough
            EndTrick()
        end
    end
    
    -- Auto-end trick if too long (prevent infinite scores)
    if trickDuration > 30000 then -- 30 seconds max
        EndTrick()
    end
end

-- Get current stats
function GetTrickStats()
    return {
        totalScore = totalScore,
        sessionScore = sessionScore,
        comboCount = comboCount,
        currentTrick = currentTrick,
        trickActive = trickActive
    }
end

-- Reset session stats
RegisterCommand('resetstats', function()
    sessionScore = 0
    comboCount = 0
    TriggerEvent('cs-tricks:statsReset')
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        args = {"Tricks", "Session stats reset!"}
    })
end, false)

-- Export functions
exports('GetTrickStats', GetTrickStats)
exports('AddScore', AddScore)