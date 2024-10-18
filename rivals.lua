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
local smoothAiming = false
local aimSmoothness = 0.5
local aimFOV = 70
local aimPredictionFactor = 0.5
local espBoxes = {}
local chamsHighlights = {}
local espThread, chamsThread
local noclipEnabled = false
local aimbotKey = Enum.KeyCode.E  -- Aimbot activation key

-- Function to create a highlight for a player (Chams)
local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Store the highlighter for later removal
    chamsHighlights[Player] = Highlighter

    -- Function to update highlight based on health
    local function OnHealthChanged()
        if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then
            Highlighter:Destroy()
            chamsHighlights[Player] = nil
        end
    end

    -- Connect health change
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)
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

    -- Clean up the box when the player dies
    Character.Humanoid.Died:Connect(function()
        if espBoxes[Player] then
            espBoxes[Player]:Destroy()
            espBoxes[Player] = nil
        end
    end)
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

-- Aimbot aiming function
local function AimAt(target)
    local camera = Workspace.CurrentCamera
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position + (target.Character.HumanoidRootPart.Velocity * aimPredictionFactor)
        local screenPosition = camera:WorldToScreenPoint(targetPosition)

        local mouseX, mouseY = UserInputService:GetMouseLocation()

        if smoothAiming then
            local newMouseX = mouseX + (screenPosition.X - mouseX) * aimSmoothness
            local newMouseY = mouseY + (screenPosition.Y - mouseY) * aimSmoothness
            UserInputService:SetMouseLocation(newMouseX, newMouseY)
        else
            UserInputService:SetMouseLocation(screenPosition.X, screenPosition.Y)
        end
    end
end

-- Function to find the nearest enemy within FOV
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

-- RunService for continuous aiming
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        local currentTarget = GetNearestEnemy()
        if currentTarget then
            AimAt(currentTarget)
        end
    end
end)

-- Aimbot toggle using key press
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

-- Function to enable No-Clip
local function EnableNoClip()
    noclipLoop = RunService.Stepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Function to disable No-Clip
local function DisableNoClip()
    if noclipLoop then
        noclipLoop:Disconnect()  -- Stop the No-clip loop
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Function to update the dropdown options with current players
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

-- Update dropdown when a player joins or leaves
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Wait()  -- Wait for their character to load
    UpdateTeleportDropdown()
end)

Players.PlayerRemoving:Connect(function(Player)
    UpdateTeleportDropdown()
end)

-- Correctly creating the Visuals, Aim, Misc, and Teleport tabs
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10472045394",
})

local AimTab = Window:MakeTab({
    Name = "Aim",
    Icon = "rbxassetid://10472045394",
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://10472045394",
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://10472045394",
})

-- Visuals section
VisualsTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if value then StartESPThread() else RemoveAllESPBoxes() end
    end,
})

VisualsTab:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(value)
        ChamsEnabled = value
        if value then StartChamsThread() else RemoveAllChams() end
    end,
})

-- Aim section
AimTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(value)
        isAimbotActive = value
    end,
})

AimTab:AddDropdown({
    Name = "Aimbot Key",
    Options = {
        "E",
        "LeftAlt",
        "Q",
        "R",
        "F",
        "G",
        "H",
        "T",
        "Y",
        "U",
        "I",
        "O",
        "P",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "0",
    },
    Default = "E",
    Callback = function(selectedKey)
        aimbotKey = Enum.KeyCode[selectedKey]  -- Update the aimbot key based on the selection
        OrionLib:MakeNotification({
            Name = "Aimbot Key Changed",
            Content = "Aimbot key set to: " .. selectedKey,
            Duration = 3,
            Image = "rbxassetid://10472045394"
        })
    end,
})

AimTab:AddSlider({
    Name = "Aim Smoothness",
    Min = 0,
    Max = 1,
    Default = aimSmoothness,
    Increment = 0.1,
    Callback = function(value)
        aimSmoothness = value
    end,
})

AimTab:AddSlider({
    Name = "Aim FOV",
    Min = 0,
    Max = 150,
    Default = aimFOV,
    Increment = 1,
    Callback = function(value)
        aimFOV = value
    end,
})

AimTab:AddToggle({
    Name = "Smooth Aiming",
    Default = false,
    Callback = function(value)
        smoothAiming = value
    end,
})

-- Misc section
MiscTab:AddToggle({
    Name = "No-Clip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        if value then EnableNoClip() else DisableNoClip() end
    end,
})

-- Teleport section
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

-- Initialize the teleport dropdown
UpdateTeleportDropdown()

-- Function to handle closing the script
Window:Destroy()
