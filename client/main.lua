local RSGCore = exports['rsg-core']:GetCoreObject()
local playerBlip = nil
local wantedBlips = {}
local myWantedLevel = 0

local function removePlayerBlip()
    if playerBlip then
        RemoveBlip(playerBlip)
        playerBlip = nil
    end
end

local function isPolice()
    local Player = RSGCore.Functions.GetPlayerData()
    return Player.job.type == 'leo' 
end

local function createOrUpdateBlip(coords, isWanted)
    removePlayerBlip()
    
    if isWanted then
        playerBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
        Citizen.InvokeNative(0x74F74D3207ED525C, playerBlip, Config.WantedBlipSprite, 1)
        Citizen.InvokeNative(0x9CB1A1623062F402, playerBlip, "Wanted Player")
        Citizen.InvokeNative(0x662D364ABF16DE2F, playerBlip, Config.DefaultBlipScale)
    end
end

local function handlePlayerDeath()
    if myWantedLevel > 0 then
        TriggerServerEvent('wanted:server:PlayerDied')
        myWantedLevel = 0
        removePlayerBlip()
    end
end

AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        local isDead = args[4] == 1
        
        if victim == PlayerPedId() and isDead then
            handlePlayerDeath()
        end
    end
end)

local function updatePlayerBlip()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    createOrUpdateBlip(coords, myWantedLevel > 0)
    TriggerServerEvent('wanted:server:UpdatePlayerPosition', coords)
end

local function updateWantedBlips(wantedPlayers)
    
    for playerId, blip in pairs(wantedBlips) do
        RemoveBlip(blip)
    end
    wantedBlips = {}
    
    
    if not wantedPlayers then return end
    
    for playerId, wantedLevel in pairs(wantedPlayers) do
        if wantedLevel > 0 and tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(tonumber(playerId)))
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
                Citizen.InvokeNative(0x74F74D3207ED525C, blip, Config.WantedBlipSprite, 1)
                Citizen.InvokeNative(0x662D364ABF16DE2F, blip, Config.DefaultBlipScale)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Wanted Player")
                wantedBlips[playerId] = blip
            end
        end
    end
end

RegisterNetEvent('wanted:client:UpdateWantedLevel')
AddEventHandler('wanted:client:UpdateWantedLevel', function(level)
    local oldLevel = myWantedLevel
    myWantedLevel = level
    updatePlayerBlip()
    
    if myWantedLevel > 0 and oldLevel == 0 then
        TriggerEvent('rNotify:NotifyLeft', "YOU ARE A WANTED PERSON", "DAMN", "generic_textures", "tick", 4000)
    elseif myWantedLevel == 0 and oldLevel > 0 then
        TriggerEvent('rNotify:NotifyLeft', "YOU'RE NO LONGER WANTED", "PHEW", "generic_textures", "tick", 4000)
        removePlayerBlip()
    end
end)

RegisterNetEvent('wanted:client:SyncWantedPlayers')
AddEventHandler('wanted:client:SyncWantedPlayers', function(wantedPlayers)
    updateWantedBlips(wantedPlayers)
end)

RegisterNetEvent('wanted:client:NotifyWanted')
AddEventHandler('wanted:client:NotifyWanted', function(playerName, isWanted)
    if isWanted then
        TriggerEvent('rNotify:NotifyLeft', playerName .. " IS NOW WANTED", "HUNT THEM", "generic_textures", "tick", 4000)
    else
        TriggerEvent('rNotify:NotifyLeft', playerName .. " IS NO LONGER WANTED", "PHEW", "generic_textures", "tick", 4000)
    end
end)

RegisterCommand('setwanted', function(source, args)
    if isPolice() then
        local targetId = tonumber(args[1])
        local wantedLevel = tonumber(args[2])
        if targetId and wantedLevel ~= nil then
            TriggerServerEvent('wanted:server:SetWantedLevel', targetId, wantedLevel)
        else
            RSGCore.Functions.Notify("Usage: /setwanted [playerID] [wantedLevel]", "error")
        end
    else
        RSGCore.Functions.Notify("You are not authorized to use this command. Police only.", "error")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.BlipUpdateInterval)
        if myWantedLevel > 0 then
            updatePlayerBlip()
        end
    end
end)
