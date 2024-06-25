

local RSGCore = exports['rsg-core']:GetCoreObject()
local playerBlip = nil
local wantedBlips = {}
local myWantedLevel = 0
local myName = ""

local WantedUI = {}

Citizen.CreateThread(function()
    WantedUI = {
        messages = {
            [1] = {},
            [2] = {},
            [3] = {}
        }
    }

    local wanted_label = "LAW_UI_WANTED_M" -- Potential hashes: [ LAW_UI_WANTED_M | LAW_UI_WANTED_F | LAW_UI_RESTRICTED_AREA | LAW_UI_WITNESS | LAW_UI_INVESTIGATING | LAW_UI_INTERROGATING | LAW_UI_LAW_SEARCHING | LAW_UI_CRIME_REPORTED | LAW_UI_UNKNOWN_SUSPECT | LAW_UI_MOVE_ALONG ]

    WantedUI.wanted = DatabindingAddDataContainerFromPath("", "wanted") 
    WantedUI.showBountyHunterMessage = DatabindingAddDataBool(WantedUI.wanted, "showBountyHunterMessage", false) 
    WantedUI.messages[1].container = DatabindingAddDataContainer(WantedUI.wanted, "firstMessage") 
    WantedUI.messages[2].container = DatabindingAddDataContainer(WantedUI.wanted, "secondMessage") 
    WantedUI.messages[3].container = DatabindingAddDataContainer(WantedUI.wanted, "thirdMessage") 
    for i, v in pairs(WantedUI.messages) do

        
        v.show = DatabindingAddDataBool(v.container, "showMessage", false) 

        v.upperLocText = DatabindingAddDataString(v.container, "upperLocText", wanted_label) 

        v.upperTextStyle = DatabindingAddDataInt(v.container, "upperTextStyle", 0) 

        v.lowerText0 = DatabindingAddDataString(v.container, "lowerText0", "") 
        v.lowerText1 = DatabindingAddDataString(v.container, "lowerText1", "") 
        v.lowerText2 = DatabindingAddDataString(v.container, "lowerText2", "") 
        v.lowerText3 = DatabindingAddDataString(v.container, "lowerText3", "") 

        v.lowerRawText0 = DatabindingAddDataString(v.container, "lowerRawText0", "") 
        v.lowerRawText1 = DatabindingAddDataString(v.container, "lowerRawText1", "") 
        v.lowerRawText2 = DatabindingAddDataString(v.container, "lowerRawText2", "") 
        v.lowerRawText3 = DatabindingAddDataString(v.container, "lowerRawText3", "") 

        v.switchLowerTextToIndex = DatabindingAddDataInt(v.container, "switchLowerTextToIndex", 0) 

        v.showKnownPulse = DatabindingAddDataBool(v.container, "showKnownPulse", false) 

        v.showUnknownPulse = DatabindingAddDataBool(v.container, "showUnknownPulse", false) 

        v.showShortWantedCooldown = DatabindingAddDataBool(v.container, "showShortWantedCooldown", false) 

        v.showLongWantedCooldown = DatabindingAddDataBool(v.container, "showLongWantedCooldown", false) 

        v.showWarningAnimation = DatabindingAddDataBool(v.container, "showWarningAnimation", false) 
    end

    function WantedUI:ShowMessage(index, bool)
        if index < 0 or index > 3 then return end
        if index == 0 or index == nil then
            for i, message in pairs(self.messages) do
                message.show = DatabindingAddDataBool(message.container, "showMessage", bool or false)
            end
        else
            for i, message in pairs(self.messages) do
                message.show = DatabindingAddDataBool(message.container, "showMessage", i == index and bool or false)
            end
        end
    end

    function WantedUI:SetMainTextLabel(index, label)
        if self.messages[index] == nil then return end
        self.messages[index].upperLocText = DatabindingAddDataString(self.messages[index].container, "upperLocText", label)
    end

    function WantedUI:SetMainTextStyle(index, int)
        if self.messages[index] == nil then return end
        self.messages[index].upperTextStyle = DatabindingAddDataInt(self.messages[index].container, "upperTextStyle", int or 0)
    end

    function WantedUI:SetLowerTextLabel(index, index_2, label)
        if self.messages[index] == nil then return end
        if index_2 < 0 or index_2 > 3 then return end
        if index_2 == 0 then
            self.messages[index].lowerText0 = DatabindingAddDataString(self.messages[index].container, "lowerText0", label)
        elseif index_2 == 1 then
            self.messages[index].lowerText1 = DatabindingAddDataString(self.messages[index].container, "lowerText1", label)
        elseif index_2 == 2 then
            self.messages[index].lowerText2 = DatabindingAddDataString(self.messages[index].container, "lowerText2", label)
        elseif index_2 == 3 then
            self.messages[index].lowerText3 = DatabindingAddDataString(self.messages[index].container, "lowerText3", label)
        end
    end

    function WantedUI:SetLowerTextRawText(index, index_2, string)
        if self.messages[index] == nil then return end
        if index_2 < 0 or index_2 > 3 then return end
        if index_2 == 0 then
            self.messages[index].lowerRawText0 = DatabindingAddDataString(self.messages[index].container, "lowerRawText0", string)
        elseif index_2 == 1 then
            self.messages[index].lowerRawText1 = DatabindingAddDataString(self.messages[index].container, "lowerRawText1", string)
        elseif index_2 == 2 then
            self.messages[index].lowerRawText2 = DatabindingAddDataString(self.messages[index].container, "lowerRawText2", string)
        elseif index_2 == 3 then
            self.messages[index].lowerRawText3 = DatabindingAddDataString(self.messages[index].container, "lowerRawText3", string)
        end
    end

    function WantedUI:SwapLowerTextIndex(index, index_2)
        if self.messages[index] == nil then return end
        if index_2 < 0 or index_2 > 3 then return end
        self.messages[index].switchLowerTextToIndex = DatabindingAddDataInt(self.messages[index].container, "switchLowerTextToIndex", index_2)
    end

    function WantedUI:ShowKnownPulse(index, bool)
        if self.messages[index] == nil then return end
        self.messages[index].showKnownPulse = DatabindingAddDataBool(self.messages[index].container, "showKnownPulse", bool)
    end

    function WantedUI:ShowUnknownPulse(index, bool)
        if self.messages[index] == nil then return end
        self.messages[index].showUnknownPulse = DatabindingAddDataBool(self.messages[index].container, "showUnknownPulse", bool)
    end

    function WantedUI:ShowShortWantedCooldown(index, bool)
        if self.messages[index] == nil then return end
        self.messages[index].showShortWantedCooldown = DatabindingAddDataBool(self.messages[index].container, "showShortWantedCooldown", bool)
    end

    function WantedUI:ShowLongWantedCooldown(index, bool)
        if self.messages[index] == nil then return end
        self.messages[index].showLongWantedCooldown = DatabindingAddDataBool(self.messages[index].container, "showLongWantedCooldown", bool)
    end

end)

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
        Citizen.InvokeNative(0x9CB1A1623062F402, playerBlip, "Wanted: " .. myName)
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
    
    local wantedCount = 0
    for playerId, wantedInfo in pairs(wantedPlayers) do
        if wantedInfo.level > 0 and tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
            wantedCount = wantedCount + 1
            local targetPed = GetPlayerPed(GetPlayerFromServerId(tonumber(playerId)))
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
                Citizen.InvokeNative(0x74F74D3207ED525C, blip, Config.WantedBlipSprite, 1)
                Citizen.InvokeNative(0x662D364ABF16DE2F, blip, Config.DefaultBlipScale)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Wanted: " .. wantedInfo.name)
                wantedBlips[playerId] = blip
            end
            
            
            WantedUI:SetLowerTextRawText(2, wantedCount - 1, "Wanted: " .. wantedInfo.name)
        end
    end
    
    
    WantedUI:ShowMessage(1, wantedCount > 0 or myWantedLevel > 0)
end


local function updateWantedUI()
    if myWantedLevel > 0 then
        WantedUI:ShowMessage(1, true)
        WantedUI:SetMainTextLabel(1, "LAW_UI_WANTED_M")
        WantedUI:SetLowerTextRawText(1, 0, "WANTED: " .. myName)
    
    end
end


local lastWantedLevel = -1
local lastPoliceStatus = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second, but only update when necessary
        local currentWantedLevel = myWantedLevel
        local currentPoliceStatus = isPolice()

        if currentWantedLevel ~= lastWantedLevel or currentPoliceStatus ~= lastPoliceStatus then
            updateWantedUI()
            lastWantedLevel = currentWantedLevel
            lastPoliceStatus = currentPoliceStatus
        end
    end
end)

RegisterNetEvent('wanted:client:UpdateWantedLevel')
AddEventHandler('wanted:client:UpdateWantedLevel', function(level, playerName)
    local oldLevel = myWantedLevel
    myWantedLevel = level
    myName = playerName
    
    updateWantedUI()
    
    if myWantedLevel > 0 and oldLevel == 0 then
        TriggerEvent('rNotify:NotifyLeft', "YOU ARE A WANTED PERSON", "DAMN", "generic_textures", "temp_pedshot", 4000)
    elseif myWantedLevel == 0 and oldLevel > 0 then
        TriggerEvent('rNotify:NotifyLeft', "YOU'RE NO LONGER WANTED", "PHEW", "generic_textures", "temp_pedshot", 4000)
    end
    
    updatePlayerBlip()
end)

RegisterNetEvent('wanted:client:SyncWantedPlayers')
AddEventHandler('wanted:client:SyncWantedPlayers', function(wantedPlayers)
    updateWantedBlips(wantedPlayers)
end)

RegisterNetEvent('wanted:client:NotifyWanted')
AddEventHandler('wanted:client:NotifyWanted', function(playerName, isWanted)
    if isWanted then
        WantedUI:SetMainTextLabel(3, "LAW_UI_WANTED_M")
        WantedUI:SetLowerTextRawText(3, 0, playerName .. " is now wanted")
		WantedUI:SetLowerTextRawText(1, 0, "WANTED: " .. playerName )
        WantedUI:ShowMessage(3, true)
        
        TriggerEvent('rNotify:NotifyLeft', playerName .. " IS NOW WANTED", "HUNT THEM", "generic_textures", "temp_pedshot", 4000)
        
        
        Citizen.SetTimeout(5000, function()
        
        end)
    else
        WantedUI:ShowShortWantedCooldown(3, true)
        WantedUI:SetMainTextLabel(3, "LAW_UI_WANTED_M")
        WantedUI:SetLowerTextRawText(3, 0, playerName .. " is no longer wanted")
        WantedUI:ShowMessage(3, true)
        
        TriggerEvent('rNotify:NotifyLeft', playerName .. " IS NO LONGER WANTED", "PHEW", "generic_textures", "temp_pedshot", 4000)
        
        
        Citizen.SetTimeout(5000, function()
            WantedUI:ShowShortWantedCooldown(3, false)
            WantedUI:ShowMessage(3, false)
        end)
    end
end)

RegisterNetEvent('wanted:client:NotifyArrested')
AddEventHandler('wanted:client:NotifyArrested', function(playerName)
    WantedUI:ShowLongWantedCooldown(3, true)
    WantedUI:SetMainTextLabel(3, "LAW_UI_WANTED_M")
    WantedUI:SetLowerTextRawText(3, 0, playerName .. " has been arrested")
    WantedUI:ShowMessage(3, true)
    
    TriggerEvent('rNotify:NotifyLeft', playerName .. " HAS BEEN ARRESTED", "JUSTICE SERVED", "generic_textures", "temp_pedshot", 4000)
    
    
    Citizen.SetTimeout(5000, function()
        WantedUI:ShowLongWantedCooldown(3, false)
        WantedUI:ShowMessage(3, false)
    end)
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
