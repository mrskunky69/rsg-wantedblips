

local RSGCore = exports['rsg-core']:GetCoreObject()
local playerBlip = nil
local wantedBlips = {}
local myWantedLevel = 0
local isDead = false

local function getBlipColorModifier(color)
    
end

local function createOrUpdateBlip(coords, blipColor, blipName, blipSprite)
    if not playerBlip then
        playerBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    end

    if playerBlip then
        Citizen.InvokeNative(0x2B6D467DAB714E8D, playerBlip, coords.x, coords.y, coords.z)
        Citizen.InvokeNative(0x74F74D3207ED525C, playerBlip, blipSprite or Config.DefaultBlipSprite, 1)
        
        
        for i = 1, 84 do
            Citizen.InvokeNative(0x662D364ABF16DE2F, playerBlip, i)
        end
        BlipAddModifier(playerBlip, joaat(getBlipColorModifier(blipColor)))
        
        Citizen.InvokeNative(0x9CB1A1623062F402, playerBlip, blipName)
    end
end

local function updatePlayerBlip()
    local player = RSGCore.Functions.GetPlayerData()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    if isDead then
        if playerBlip then
            RemoveBlip(playerBlip)
            playerBlip = nil
        end
        TriggerServerEvent('madv.gps:server:PlayerDied')
        return
    end
    
    local blipColor = Config.DefaultBlipColor
    local blipName = "Player"
    local blipSprite = Config.DefaultBlipSprite

    if myWantedLevel > 0 then
        blipColor = Config.WantedBlipColor or 1 -- Red by default
        blipName = "Wanted Player"
        blipSprite = Config.WantedBlipSprite or GetHashKey("blip_ambient_bounty_target")
    elseif Config.Jobs[player.job.name] then
        blipColor = Config.Jobs[player.job.name].blipColor
        blipName = player.job.name
    elseif Config.Gangs[player.gang.name] then
        blipColor = Config.Gangs[player.gang.name].blipColor
        blipName = player.gang.name
    end

    createOrUpdateBlip(coords, blipColor, blipName, blipSprite)
    TriggerServerEvent('wanted:server:UpdatePlayerPosition', coords)
end


local function updateWantedBlips(wantedPlayers)
    for k, v in pairs(wantedBlips) do
        RemoveBlip(v)
    end
    wantedBlips = {}

    for playerId, wantedLevel in pairs(wantedPlayers) do
        if wantedLevel > 0 and GetPlayerFromServerId(playerId) ~= PlayerId() then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
                Citizen.InvokeNative(0x74F74D3207ED525C, blip, Config.WantedBlipSprite or GetHashKey("blip_ambient_bounty_target"), 1)
                BlipAddModifier(blip, joaat(getBlipColorModifier(Config.WantedBlipColor or 1)))
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Wanted Player")
                wantedBlips[playerId] = blip
            end
        end
    end
end

RegisterNetEvent('wanted:client:UpdateWantedLevel')
AddEventHandler('wanted:client:UpdateWantedLevel', function(level)
    myWantedLevel = level
    updatePlayerBlip()
end)

RegisterNetEvent('wanted:client:SyncWantedPlayers')
AddEventHandler('wanted:client:SyncWantedPlayers', function(wantedPlayers)
    updateWantedBlips(wantedPlayers)
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local isDead = args[4] == 1
        
        if victim == PlayerPedId() and isDead then
            isDead = true
            updatePlayerBlip()
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    isDead = false
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    isDead = false
    updatePlayerBlip()
end)

-- Add this to handle respawn
RegisterNetEvent('RSGCore:Client:OnPlayerUnload')
AddEventHandler('RSGCore:Client:OnPlayerUnload', function()
    isDead = false
    if playerBlip then
        RemoveBlip(playerBlip)
        playerBlip = nil
    end
end)



-- Add a command for law enforcement to set wanted levels
RegisterCommand('setwanted', function(source, args)
    local targetId = tonumber(args[1])
    local wantedLevel = tonumber(args[2])
    if targetId and wantedLevel then
        TriggerServerEvent('wanted:server:SetWantedLevel', targetId, wantedLevel)
    else
        print("Usage: /setwanted [playerID] [wantedLevel]")
    end
end)
