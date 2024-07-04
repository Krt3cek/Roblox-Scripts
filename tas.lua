local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "JSEM DENY",
    LoadingTitle = "nacitani...",
    LoadingSubtitle = "by krtek.txt",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "krtek.txt",
        FileName = "TASRoblox by krtek.txt"
    },
    Discord = {
        Enabled = true,
        Invite = "7XT74GwVnj",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "",
        Subtitle = "",
        Note = "",
        FileName = "",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

local controls = {
    {"Spectate", "1"},
    {"Create", "2"},
    {"Test", "3"},
    {"Pause", "Left Click"},
    {"Unpause", "Left Click"},
    {"Forward", "T"},
    {"Back", "R"},
    {"Forward 1 Frame", "G"},
    {"Back 1 Frame", "F"},
    {"Unpause 1 Frame", "V"},
    {"Return", "E"},
    {"Look Around", "L"},
    {"Optimize TAS", "Q"},
    {"Delete TAS", "Backspace"},
    {"Menu", "M"}
}

local settingz = {
    {"Lock Camera (Paused)", 1},
    {"Lock Camera (Test)", 1},
    {"Playback Speed", 1},
    {"Show Stats (Spectate)", 1},
    {"Show Stats (Create)", 1},
    {"Show Stats (Test)", 1},
    {"Stats Text Size", 11},
    {"Restart When Testing", 1}
}

local ds = game:GetService("DataStoreService"):GetDataStore("TASData")
local BR = game:GetService("DataStoreService"):GetDataStore("BugReports")
local reports

local RS = game.ReplicatedStorage:WaitForChild("TASRS")
local MenuEvents = RS.RemoteEvents.MenuEvents
local Initiator = RS.RemoteEvents.Initiator
local SaveLoad = RS.RemoteFunctions.SaveLoad
local Compression = require(script.Compression)

local LastSlotID = 0
local PlayerSaves = {}

game.StarterPlayer.AutoJumpEnabled = false -- Disable auto jump

game.Players.PlayerAdded:Connect(function(player)
    PlayerSaves[player.UserId] = {}
    local data, gotData = nil, false
    local success, error = pcall(function()
        data = ds:GetAsync(player.UserId .. "_PlayerData")
    end)
    
    if not success then
        Initiator:FireClient(player, "PlayerDataLoadFailed")
    else
        gotData = true
    end

    local tasFolder = Instance.new("Folder", player)
    tasFolder.Name = "TAS"

    local controlsFolder = Instance.new("Folder", tasFolder)
    controlsFolder.Name = "Controls"
    local settingsFolder = Instance.new("Folder", tasFolder)
    settingsFolder.Name = "Settings"
    local savesFolder = Instance.new("Folder", tasFolder)
    savesFolder.Name = "Saves"

    -- Initialize controls
    for _, control in ipairs(controls) do
        local stringValue = Instance.new("StringValue", controlsFolder)
        stringValue.Name = control[1]
        stringValue.Value = data and data.controls[control[1]] or control[2]
    end

    -- Initialize settings
    for _, setting in ipairs(settingz) do
        local numberValue = Instance.new("NumberValue", settingsFolder)
        numberValue.Name = setting[1]
        numberValue.Value = data and data.settings[setting[1]] or setting[2]
    end

    -- Load existing saves
    if data then
        for _, slot in ipairs(data.saves or {}) do
            local stringValue = Instance.new("StringValue", savesFolder)
            stringValue.Name = slot[1]
            stringValue.Value = slot[2]
        end

        if data.LastSlotID then
            LastSlotID = data.LastSlotID
            local lastSlotIDValue = Instance.new("IntValue", tasFolder)
            lastSlotIDValue.Name = "LastSlotID"
            lastSlotIDValue.Value = data.LastSlotID
        end
    end

    -- Notify client about data load
    if gotData then
        local loadSuccess = Instance.new("BoolValue", tasFolder)
        loadSuccess.Name = "LoadSuccess"
    end

    Initiator:FireClient(player, "PlayerDataLoaded")
end)

-- Function to save player data on leave
function savePlayerData(player)
    PlayerSaves[player.UserId] = nil
    if player.TAS:FindFirstChild("SaveRepeatPreventer") then
        return
    end

    if player.TAS:FindFirstChild("LoadSuccess") then
        local saveRepeatPreventer = Instance.new("BoolValue", player.TAS)
        saveRepeatPreventer.Name = "SaveRepeatPreventer"

        local data = {
            LastSlotID = LastSlotID,
            controls = {},
            settings = {},
            saves = {}
        }

        -- Save controls
        for _, control in ipairs(player.TAS.Controls:GetChildren()) do
            data.controls[control.Name] = control.Value
        end

        -- Save settings
        for _, setting in ipairs(player.TAS.Settings:GetChildren()) do
            data.settings[setting.Name] = setting.Value
        end

        -- Save saves
        for _, save in ipairs(player.TAS.Saves:GetChildren()) do
            table.insert(data.saves, {save.Name, save.Value})
        end

        ds:SetAsync(player.UserId .. "_PlayerData", data)
    end
end

-- Connect save function to PlayerRemoving and game close events
game.Players.PlayerRemoving:Connect(savePlayerData)
game:BindToClose(function()
    for _, player in ipairs(game.Players:GetChildren()) do
        savePlayerData(player)
    end
end)

-- Handle menu events from client
MenuEvents.OnServerEvent:Connect(function(player, action, v1, v2)
    if action == "SetControl" then
        player.TAS.Controls[v1].Value = v2
    elseif action == "SetSetting" then
        player.TAS.Settings[v1].Value = v2
    elseif action == "AddSlot" then
        local newSlot = Instance.new("StringValue", player.TAS.Saves)
        newSlot.Name = v1
        LastSlotID = v1
    elseif action == "RenameSlot" then
        player.TAS.Saves[v1].Value = v2
    elseif action == "DeleteSlot" then
        player.TAS.Saves[v1]:Destroy()
    elseif action == "PromptModelPurchase" then
        game.MarketplaceService:PromptPurchase(player, 10211275704)
    end
end)

-- Function to split large tables for saving/loading
local function splitTable(t)
    local result = {}
    for i = 1, #t, 1000 do
        local section = {}
        table.move(t, i, i + 999, 1, section)
        table.insert(result, section)
    end
    return result
end

-- Handle save/load requests
SaveLoad.OnServerInvoke = function(player, action, id, TAS)
    if action == "AddToSave" then
        if #PlayerSaves[player.UserId] > 0 then
            table.move(TAS, 1, #TAS, #PlayerSaves[player.UserId] + 1, PlayerSaves[player.UserId])
        else
            PlayerSaves[player.UserId] = TAS
        end
        return true
    elseif action == "Save" then
        local compressed, errorCount, err = Compression:Compress(PlayerSaves[player.UserId])
        if errorCount > 0 then
            MenuEvents:FireClient("Issue with compressing data, " .. errorCount .. " frames removed.")
            reports = reports .. "," .. err
            BR:SetAsync("1", reports)
            wait(5)
        end

        local splits = {}
        for i = 1, math.ceil(#compressed / 4000000) do
            table.insert(splits, string.sub(compressed, 4000000 * (i - 1) + 1, 4000000 * i))
        end

        PlayerSaves[player.UserId] = {}
        for i, v in pairs(splits) do
            MenuEvents:FireClient(player, 'Saving ' .. i .. '/' .. #splits)
            local success, error = pcall(function()
                local slotn = i > 1 and "-" .. i or ""
                ds:SetAsync(player.UserId .. "-" .. id .. slotn, v)
            end)
            if not success then
                return false
            end
            if i == #splits then
                break
            end
            MenuEvents:FireClient(player, 'Waiting For Datastore')
            wait(15)
        end

        return true
    elseif action == "Load" then
        local loaded = ""
        local i = 1
        while true do
            MenuEvents:FireClient(player, 'Loading ' .. i .. '/' .. '?')
            local success, error = pcall(function()
                local slotn = i > 1 and "-" .. i or ""
                loaded = loaded .. (ds:GetAsync(player.UserId .. "-" .. id .. slotn) or "")
            end)
            if not success or loaded == nil then
                return {}
            end
            if #loaded == 4000000 then
                i = i + 1
            else
                break
            end
            MenuEvents:FireClient(player, 'Waiting For Datastore')
            wait(15)
        end

        if type(loaded) == 'string' then
            loaded = Compression:Decompress(loaded)
        end

        local splits = splitTable(loaded)
        for i, v in pairs(splits) do
            MenuEvents:FireClient(player, "Sending To Client " .. i .. '/' .. #splits)
            SaveLoad:InvokeClient(player, v)
        end

        return true
    end
end

reports = BR:GetAsync("1") or ""

