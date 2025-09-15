-- Server-side script for CS-Tricks
-- Handles leaderboards, statistics, and multiplayer features

local playerStats = {}
local leaderboard = {}

-- Player connected
RegisterNetEvent('playerConnecting')
AddEventHandler('playerConnecting', function()
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)
    
    -- Initialize player stats
    if not playerStats[playerId] then
        playerStats[playerId] = {
            totalScore = 0,
            sessionScore = 0,
            tricksPerformed = 0,
            bestTrick = nil,
            playTime = 0,
            achievements = {}
        }
    end
end)

-- Player disconnected
RegisterNetEvent('playerDropped')
AddEventHandler('playerDropped', function()
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)
    
    -- Save stats before player leaves
    if playerStats[playerId] then
        -- In a real implementation, you'd save to database here
        if Config.Debug then
            print(string.format("Player %s disconnected. Stats saved.", playerId))
        end
    end
end)

-- Update player score
RegisterNetEvent('cs-tricks:updateServerScore')
AddEventHandler('cs-tricks:updateServerScore', function(score, trickType, duration)
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)
    
    if not playerStats[playerId] then
        playerStats[playerId] = {
            totalScore = 0,
            sessionScore = 0,
            tricksPerformed = 0,
            bestTrick = nil,
            playTime = 0,
            achievements = {}
        }
    end
    
    local stats = playerStats[playerId]
    stats.totalScore = stats.totalScore + score
    stats.sessionScore = stats.sessionScore + score
    stats.tricksPerformed = stats.tricksPerformed + 1
    
    -- Update best trick
    if not stats.bestTrick or score > stats.bestTrick.score then
        stats.bestTrick = {
            type = trickType,
            score = score,
            duration = duration,
            timestamp = os.time()
        }
    end
    
    -- Update leaderboard
    UpdateLeaderboard(playerId, stats.totalScore)
    
    -- Check for achievements
    CheckAchievements(src, playerId, stats, trickType, score)
end)

-- Update leaderboard
function UpdateLeaderboard(playerId, totalScore)
    local playerName = GetPlayerName(playerId) or "Unknown"
    
    -- Update or add player to leaderboard
    local found = false
    for i, entry in ipairs(leaderboard) do
        if entry.playerId == playerId then
            entry.score = totalScore
            entry.name = playerName
            found = true
            break
        end
    end
    
    if not found then
        table.insert(leaderboard, {
            playerId = playerId,
            name = playerName,
            score = totalScore
        })
    end
    
    -- Sort leaderboard by score (descending)
    table.sort(leaderboard, function(a, b)
        return a.score > b.score
    end)
    
    -- Keep only top 100 players
    while #leaderboard > 100 do
        table.remove(leaderboard)
    end
end

-- Check for achievements
function CheckAchievements(src, playerId, stats, trickType, score)
    local achievements = stats.achievements
    
    -- First trick achievement
    if stats.tricksPerformed == 1 and not achievements.firstTrick then
        achievements.firstTrick = true
        TriggerClientEvent('cs-tricks:achievementUnlocked', src, 'First Trick', 'Performed your first trick!')
    end
    
    -- Score milestones
    local scoreMilestones = {1000, 5000, 10000, 25000, 50000, 100000}
    for _, milestone in ipairs(scoreMilestones) do
        local achievementKey = 'score_' .. milestone
        if stats.totalScore >= milestone and not achievements[achievementKey] then
            achievements[achievementKey] = true
            TriggerClientEvent('cs-tricks:achievementUnlocked', src, 
                string.format('%d Points', milestone), 
                string.format('Reached %d total points!', milestone))
        end
    end
    
    -- Trick count milestones
    local trickMilestones = {10, 50, 100, 500, 1000}
    for _, milestone in ipairs(trickMilestones) do
        local achievementKey = 'tricks_' .. milestone
        if stats.tricksPerformed >= milestone and not achievements[achievementKey] then
            achievements[achievementKey] = true
            TriggerClientEvent('cs-tricks:achievementUnlocked', src,
                string.format('%d Tricks', milestone),
                string.format('Performed %d tricks!', milestone))
        end
    end
    
    -- High score single trick
    if score >= 500 and not achievements.highScore then
        achievements.highScore = true
        TriggerClientEvent('cs-tricks:achievementUnlocked', src,
            'High Roller', 'Scored 500+ points in a single trick!')
    end
end

-- Get leaderboard
RegisterNetEvent('cs-tricks:getLeaderboard')
AddEventHandler('cs-tricks:getLeaderboard', function(limit)
    local src = source
    local topPlayers = {}
    
    limit = limit or 10
    for i = 1, math.min(limit, #leaderboard) do
        table.insert(topPlayers, leaderboard[i])
    end
    
    TriggerClientEvent('cs-tricks:receiveLeaderboard', src, topPlayers)
end)

-- Get player stats
RegisterNetEvent('cs-tricks:getPlayerStats')
AddEventHandler('cs-tricks:getPlayerStats', function()
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)
    
    local stats = playerStats[playerId] or {
        totalScore = 0,
        sessionScore = 0,
        tricksPerformed = 0,
        bestTrick = nil,
        playTime = 0,
        achievements = {}
    }
    
    TriggerClientEvent('cs-tricks:receivePlayerStats', src, stats)
end)

-- Reset session stats
RegisterNetEvent('cs-tricks:resetSessionStats')
AddEventHandler('cs-tricks:resetSessionStats', function()
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)
    
    if playerStats[playerId] then
        playerStats[playerId].sessionScore = 0
        TriggerClientEvent('cs-tricks:sessionReset', src)
    end
end)

-- Admin commands (if needed)
if Config.Debug then
    RegisterCommand('trickstats_admin', function(source, args, rawCommand)
        if source == 0 then -- Server console
            print("=== CS-TRICKS SERVER STATS ===")
            print(string.format("Total players tracked: %d", GetTableLength(playerStats)))
            print(string.format("Leaderboard entries: %d", #leaderboard))
            
            if #leaderboard > 0 then
                print("Top 5 players:")
                for i = 1, math.min(5, #leaderboard) do
                    local entry = leaderboard[i]
                    print(string.format("%d. %s - %d points", i, entry.name, entry.score))
                end
            end
        end
    end, true)
end

-- Utility function
function GetTableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Initialize
Citizen.CreateThread(function()
    if Config.Debug then
        print("CS-Tricks server initialized")
    end
end)