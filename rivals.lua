-- Load OrionLib
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "Krt Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Krt Hub",
    IntroEnabled = true,
    IntroText = "Krt Hub | Loader",
    IntroIcon = "rbxassetid://10472045394",
    Icon = "rbxassetid://10472045394"
})

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false
local ChamsEnabled = false
local highlightColor = Color3.fromRGB(255, 48, 51)
local isAimbotActive = false
local aimSmoothness = 0.1
local aimFOV = 70
local aimbotKey = Enum.KeyCode.E  -- Aimbot activation key
local espBoxes = {}
local chamsHighlights = {}
local espThread, chamsThread

-- Function to create a highlight for a player (Chams)
local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Store the highlighter for later removal
    chamsHighlights[Player] = Highlighter
end

-- Function to create ESP box for a player
local function CreateESPBox(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    -- Create a BoxHandleAdornment for ESP
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Character:GetExtentsSize()
    espBox.Adornee = Character
    espBox.Color3 = highlightColor
    espBox.Transparency = 0.5
    espBox.ZIndex = 10
    espBox.Parent = Character

    -- Store the ESP box for later removal
    espBoxes[Player] = espBox
end

-- Function to update Chams for all players
local function UpdateChams()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not chamsHighlights[Player] then
            ApplyChams(Player)
        end
    end
end

-- Function to update ESP for all players
local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not espBoxes[Player] then
            CreateESPBox(Player)
        end
    end
end

-- Function to remove all ESP boxes
local function RemoveAllESPBoxes()
    for _, espBox in pairs(espBoxes) do
        if espBox then
            espBox:Destroy()
        end
    end
    espBoxes = {}
end

-- Function to remove all Chams highlights
local function RemoveAllChams()
    for _, highlight in pairs(chamsHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    chamsHighlights = {}
end

-- Function to start Chams thread
local function StartChamsThread()
    if chamsThread then return end  -- Prevent multiple threads
    chamsThread = RunService.Heartbeat:Connect(function()
        if ChamsEnabled then
            UpdateChams()
        else
            RemoveAllChams()
        end
    end)
end

-- Function to start ESP thread
local function StartESPThread()
    if espThread then return end  -- Prevent multiple threads
    espThread = RunService.Heartbeat:Connect(function()
        if ESPEnabled then
            UpdateESP()
        else
            RemoveAllESPBoxes()
        end
    end)
end

-- Function to get the closest enemy player within FOV
local function GetNearestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).magnitude
                if distance <= aimFOV and distance < closestDistance then
                    closestDistance = distance
                    closestEnemy = player
                end
            end
        end
    end

    return closestEnemy
end

-- Function to aim at the target's head
local function AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local targetPosition = target.Character.Head.Position
        local camera = Workspace.CurrentCamera
        
        -- Calculate the angle between the camera's CFrame and the target position
        local direction = (targetPosition - camera.CFrame.Position).unit
        local targetCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        
        -- Smoothly interpolate the camera's CFrame towards the target
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimSmoothness)
    end
end

-- RunService for continuous aiming
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        local targetPlayer = GetNearestEnemy()
        if targetPlayer then
            AimAt(targetPlayer)  -- Aim specifically at the head
        end
    end
end)

-- Toggle Aimbot using key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == aimbotKey then
        isAimbotActive = not isAimbotActive
        local notificationMessage = isAimbotActive and "Aimbot Activated!" or "Aimbot Deactivated!"
        OrionLib:MakeNotification({
            Name = "Aimbot Status",
            Content = notificationMessage,
            Duration = 3,
            Image = "rbxassetid://10472045394"
        })
    end
end)

-- Create GUI for Teleportation
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://10472045394",
    PremiumOnly = false,
})

TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Options = {},  -- Will be updated dynamically
    Callback = function(selectedPlayer)
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if targetPlayer and targetPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
})

TeleportTab:AddButton({
    Name = "Refresh Players",
    Callback = function()
        UpdateTeleportDropdown()  -- Update the dropdown options
    end,
})

-- GUI for ESP
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://10472045394",
    PremiumOnly = false,
})

ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if value then
            StartESPThread()
        else
            RemoveAllESPBoxes()
        end
    end
})

-- GUI for Chams
local ChamsTab = Window:MakeTab({
    Name = "Chams",
    Icon = "rbxassetid://10472045394",
    PremiumOnly = false,
})

ChamsTab:AddToggle({
    Name = "Enable Chams",
    Default = false,
    Callback = function(value)
        ChamsEnabled = value
        if value then
            StartChamsThread()
        else
            RemoveAllChams()
        end
    end,
})

-- GUI for No-Clip
local NoClipTab = Window:MakeTab({
    Name = "No-Clip",
    Icon = "rbxassetid://10472045394",
    PremiumOnly = false,
})

NoClipTab:AddToggle({
    Name = "Enable No-Clip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        if value then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end,
})

-- Cleanup on exit
game.Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        RemoveAllESPBoxes()
        RemoveAllChams()
        DisableNoClip()
    end
end)

-- Update the dropdown options with current players for teleportation
local function UpdateTeleportDropdown()
    local playerNames = {}
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then  -- Exclude local player
            table.insert(playerNames, Player.Name)
        end
    end
    TeleportTab:UpdateDropdown({
        Name = "Select Player to Teleport To",
        Options = playerNames,
    })
end

-- Initial update for Teleport dropdown
UpdateTeleportDropdown()

-- Show the window
OrionLib:Init()
