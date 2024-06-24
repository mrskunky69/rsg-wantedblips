local RSGCore = exports['rsg-core']:GetCoreObject()
local playerPositions = {}
local playerWantedLevels = {}

RegisterNetEvent('wanted:server:UpdatePlayerPosition')
AddEventHandler('wanted:server:UpdatePlayerPosition', function(coords)
    local src = source
    playerPositions[src] = coords
end)

RegisterNetEvent('wanted:server:SetWantedLevel')
AddEventHandler('wanted:server:SetWantedLevel', function(targetId, level)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' then
        targetId = tonumber(targetId)
        level = tonumber(level)
        
        local oldLevel = playerWantedLevels[targetId] or 0
        
        local targetPlayer = RSGCore.Functions.GetPlayer(targetId)
        if targetPlayer then
            local playerName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
            
            if level == 0 then
                playerWantedLevels[targetId] = nil
            else
                playerWantedLevels[targetId] = {level = level, name = playerName}
            end
            
            TriggerClientEvent('wanted:client:UpdateWantedLevel', targetId, level, playerName)
            TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
            
            if level > 0 and oldLevel == 0 then
                TriggerClientEvent('wanted:client:NotifyWanted', -1, playerName, true)
            elseif level == 0 and oldLevel > 0 then
                TriggerClientEvent('wanted:client:NotifyWanted', -1, playerName, false)
            end
        end
    end
end)

RegisterNetEvent('wanted:server:PlayerDied')
AddEventHandler('wanted:server:PlayerDied', function()
    local src = source
    if playerWantedLevels[src] and playerWantedLevels[src] > 0 then
        playerWantedLevels[src] = nil
        TriggerClientEvent('wanted:client:UpdateWantedLevel', src, 0)
        TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
        
        local Player = RSGCore.Functions.GetPlayer(src)
        if Player then
            local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
            TriggerClientEvent('wanted:client:NotifyWanted', -1, playerName, false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels or {})
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    playerPositions[src] = nil
    playerWantedLevels[src] = nil
    TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels or {})
end)
