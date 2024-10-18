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
local aimLock = false
local smoothAiming = false
local aimSmoothness = 0.5
local aimFOV = 70
local playerSpeed = 16
local currentFOV = 70
local espBoxes = {}
local chamsHighlights = {}
local espThread, chamsThread
local noclipEnabled = false
local aimbotKey = Enum.KeyCode.E  -- Aimbot activation key
local holdingKey = false

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
    local targetPosition = PredictPosition(target)

    if targetPosition then
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

-- RunService for continuous aiming
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        currentTarget = GetNearestEnemy()
        if currentTarget then
            AimAt(currentTarget)
        end
    end
end)


local function ToggleAimbot()
    isAimbotActive = not isAimbotActive
    fovCircle.Visible = isAimbotActive  -- Show/Hide FOV circle

    local notificationMessage = isAimbotActive and "Aimbot Activated!" or "Aimbot Deactivated!"
    OrionLib:MakeNotification({
        Name = "Aimbot Status",
        Content = notificationMessage,
        Duration = 3,
        Image = "rbxassetid://10472045394"
    })
end

-- RunService for continuous aiming
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        currentTarget = GetNearestEnemy()
        if currentTarget then
            AimAt(currentTarget)
        end
    end
end)

-- Aimbot toggle using key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == aimKey then
        isAimbotActive = not isAimbotActive
        fovCircle.Visible = isAimbotActive  -- Show/Hide FOV circle
    end
end)

-- Update FOV Circle based on aimFOV
RunService.RenderStepped:Connect(function()
    if fovCircleVisible then
        fovCircle.Size = UDim2.new(0, aimFOV * 2, 0, aimFOV * 2)
    end
end)

-- Aimbot activation using key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == aimbotKey then
        isAimbotActive = true
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == aimKey then
        ToggleAimbot()
    end
end)

-- Update FOV Circle based on aimFOV
RunService.RenderStepped:Connect(function()
    if fovCircleVisible then
        fovCircle.Size = UDim2.new(0, aimFOV * 2, 0, aimFOV * 2)
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

-- Visuals Tab Options
VisualsTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        StartESPThread()
    end,
})

VisualsTab:AddToggle({
    Name = "Enable Chams",
    Default = false,
    Callback = function(value)
        ChamsEnabled = value
        StartChamsThread()
    end,
})

AimTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(value)
        isAimbotActive = value
        fovCircle.Visible = value
        local notificationMessage = value and "Aimbot Activated!" or "Aimbot Deactivated!"
        OrionLib:MakeNotification({
            Name = "Aimbot Status",
            Content = notificationMessage,
            Duration = 3,
            Image = "rbxassetid://10472045394"
        })
    end,
})

AimTab:AddSlider({
    Name = "Aim FOV",
    Min = 0,
    Max = 200,
    Default = 70,
    Increment = 5,
    Callback = function(value)
        aimFOV = value
    end,
})

AimTab:AddToggle({
    Name = "Smooth Aiming",
    Default = true,
    Callback = function(value)
        smoothAiming = value
    end,
})

AimTab:AddSlider({
    Name = "Aim Smoothness",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Increment = 0.01,
    Callback = function(value)
        aimSmoothness = value
    end,
})

AimTab:AddSlider({
    Name = "Aim Prediction Factor",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.01,
    Callback = function(value)
        aimPredictionFactor = value
    end,
})

AimTab:AddDropdown({
    Name = "Aimbot Key",
    Default = aimKey.Name,
    Options = {"E", "Q", "F", "G", "H", "J", "K"},
    Callback = function(value)
        aimKey = Enum.KeyCode[value]
    end,
})

-- Misc Tab Options
MiscTab:AddButton({
    Name = "Enable No-Clip",
    Callback = function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end,
})

-- Teleport Tab Options
TeleportTab:AddDropdown({
    Name = "Select Player to Teleport To",
    Options = {},  -- Options will be populated dynamically
    Callback = function(selectedPlayer)
        local playerToTeleport = Players:FindFirstChild(selectedPlayer)
        if playerToTeleport and playerToTeleport.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = playerToTeleport.Character.HumanoidRootPart.CFrame
        end
    end,
})

-- Update the dropdown on script start
UpdateTeleportDropdown()

-- Exit the script cleanly
OrionLib:MakeNotification({
    Name = "Krt Hub Loaded",
    Content = "Welcome to Krt Hub!",
    Duration = 5,
    Image = "rbxassetid://10472045394"
})

