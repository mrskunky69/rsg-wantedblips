

local RSGCore = exports['rsg-core']:GetCoreObject()
local playerPositions = {}
local playerWantedLevels = {}

RegisterNetEvent('wanted:server:UpdatePlayerPosition')
AddEventHandler('wanted:server:UpdatePlayerPosition', function(coords)
    local src = source
    playerPositions[src] = coords
end)

RegisterNetEvent('wanted:server:PlayerDied')
AddEventHandler('wanted:server:PlayerDied', function()
    local src = source
    playerPositions[src] = nil
    playerWantedLevels[src] = nil
    TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
end)


RegisterNetEvent('wanted:server:SetWantedLevel')
AddEventHandler('wanted:server:SetWantedLevel', function(targetId, level)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == 'police' else if Player.PlayerData.job.type == 'leo' then -- Ensure only law enforcement can set wanted levels
        playerWantedLevels[targetId] = level
        TriggerClientEvent('wanted:client:UpdateWantedLevel', targetId, level)
        TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) 
        TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
    end
end)


AddEventHandler('playerDropped', function(reason)
    local src = source
    playerPositions[src] = nil
    playerWantedLevels[src] = nil
    TriggerClientEvent('wanted:client:SyncWantedPlayers', -1, playerWantedLevels)
end)
