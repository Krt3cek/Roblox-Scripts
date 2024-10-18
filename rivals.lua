-- Load OrionLib
OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
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
local LocalPlayer = Players.LocalPlayer

-- Variables
local ESPEnabled = false  -- Set to false initially
local ChamsEnabled = false  -- Set to false initially
local highlightColor = Color3.fromRGB(255, 48, 51)
local isAimbotActive = false  -- Set to false initially
local skeletonEnabled = false  -- Set to false initially
local viewLineEnabled = false  -- Set to false initially
local healthBarVisible = true  -- Player health display
local distanceIndicatorVisible = true  -- Player distance indicator
local espBoxSize = Vector3.new(2, 2, 2)  -- Size for ESP boxes
local espBoxTransparency = 0.5  -- Transparency for ESP boxes
local playerSpeed = 16  -- Default player speed
local defaultFOV = 70  -- Default Field of View
local currentFOV = defaultFOV  -- Current Field of View

-- Functions for ESP, Chams, and other functionalities
local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Function to update highlight based on health
    local function OnHealthChanged()
        if Character and Humanoid.Health <= 0 then
            Highlighter:Destroy()
        end
    end

    -- Connect health change
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)

    return Highlighter
end

local function CreateHealthBar(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    local healthBar = Instance.new("BillboardGui")
    healthBar.Size = UDim2.new(0, 100, 0, 10)
    healthBar.StudsOffset = Vector3.new(0, 3, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = Character:FindFirstChild("Head")

    local healthBarFrame = Instance.new("Frame")
    healthBarFrame.Size = UDim2.new(1, 0, 1, 0)
    healthBarFrame.BackgroundColor3 = Color3.new(0, 1, 0)
    healthBarFrame.Parent = healthBar

    -- Update health bar as health changes
    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local healthRatio = Humanoid.Health / Humanoid.MaxHealth
        healthBarFrame.Size = UDim2.new(healthRatio, 0, 1, 0)
        healthBarFrame.BackgroundColor3 = healthRatio > 0.5 and Color3.new(0, 1, 0) or healthRatio > 0.25 and Color3.new(1, 1, 0) or Color3.new(1, 0, 0)
    end)

    return healthBar
end

local function CreateDistanceIndicator(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    local distanceLabel = Instance.new("BillboardGui")
    distanceLabel.Size = UDim2.new(0, 100, 0, 50)
    distanceLabel.StudsOffset = Vector3.new(0, 3, 0)
    distanceLabel.AlwaysOnTop = true
    distanceLabel.Parent = Character:FindFirstChild("Head")

    local distanceText = Instance.new("TextLabel")
    distanceText.Size = UDim2.new(1, 0, 1, 0)
    distanceText.BackgroundTransparency = 1
    distanceText.TextColor3 = Color3.new(1, 1, 1)
    distanceText.Parent = distanceLabel

    return distanceText
end

local function UpdateDistanceIndicator(distanceText, Player)
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).magnitude
    distanceText.Text = math.floor(distance) .. " studs"
end

local function CreateESPBox(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Head = Character:WaitForChild("Head")
    
    -- Create a box part for ESP
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = espBoxSize
    espBox.Adornee = Character
    espBox.Color3 = highlightColor
    espBox.Transparency = espBoxTransparency
    espBox.ZIndex = 10
    espBox.Parent = Character

    -- Clean up the box when the player dies
    Character.Humanoid.Died:Connect(function()
        espBox:Destroy()
    end)

    return espBox
end

local function ToggleESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            CreateESPBox(Player)

            -- Create health bar and distance indicator if enabled
            if healthBarVisible then
                CreateHealthBar(Player)
            end
            if distanceIndicatorVisible then
                local distanceText = CreateDistanceIndicator(Player)
                -- Update the distance every frame
                RunService.RenderStepped:Connect(function()
                    UpdateDistanceIndicator(distanceText, Player)
                end)
            end
        end
    end
end

local function AimAtNearestEnemy()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local head = Player.Character:FindFirstChild("Head")
            if head then
                local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
                local mouseDistance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude

                if mouseDistance < closestDistance then
                    closestDistance = mouseDistance
                    closestPlayer = head
                end
            end
        end
    end

    if closestPlayer then
        -- Move the mouse to the closest enemy's head
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter  -- Lock mouse to center
        local targetPosition = workspace.CurrentCamera:WorldToScreenPoint(closestPlayer.Position)
        local newMousePosition = Vector2.new(targetPosition.X, targetPosition.Y)
        UserInputService:SetMouseLocation(newMousePosition.X, newMousePosition.Y)
    end
end

local function DrawViewLine()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
            local line = Instance.new("LineHandleAdornment")
            line.Adornee = Player.Character.Head
            line.Length = 100
            line.Color3 = Color3.new(0, 0, 255) -- Blue color
            line.Thickness = 0.1
            line.Parent = Player.Character.Head

            -- Clean up the line when the player is no longer alive
            Player.Character.Humanoid.Died:Connect(function()
                line:Destroy()
            end)
        end
    end
end

local function ToggleSkeleton(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    -- Create parts for skeleton visualization
    local function CreateSkeletonPart(part)
        local skeletonPart = Instance.new("Part")
        skeletonPart.Size = Vector3.new(0.2, 0.2, 0.2)
        skeletonPart.Color = Color3.fromRGB(0, 255, 0) -- Green color
        skeletonPart.Anchored = true
        skeletonPart.CanCollide = false
        skeletonPart.Parent = Workspace

        -- Attach skeleton part to the original part
        skeletonPart.CFrame = part.CFrame
        part:GetPropertyChangedSignal("CFrame"):Connect(function()
            skeletonPart.CFrame = part.CFrame
        end)

        return skeletonPart
    end

    -- Create skeleton parts for body parts
    local function CreateSkeletonBody()
        local bodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
        for _, partName in pairs(bodyParts) do
            local part = Character:FindFirstChild(partName)
            if part then
                CreateSkeletonPart(part)
            end
        end
    end

    CreateSkeletonBody()

    -- Clean up skeleton parts when the player dies
    Humanoid.Died:Connect(function()
        for _, part in pairs(Workspace:GetChildren()) do
            if part:IsA("Part") and part.Name == "SkeletonPart" then
                part:Destroy()
            end
        end
    end)
end

-- Create Main Tabs
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

-- Toggle ESP Boxes button
VisualsTab:AddToggle({
    Name = "Toggle ESP Boxes",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            ToggleESP()  -- Apply ESP to players
        end
    end,
})

-- Toggle Health Bar button
VisualsTab:AddToggle({
    Name = "Toggle Health Bar",
    Default = true,
    Callback = function(Value)
        healthBarVisible = Value
        ToggleESP()  -- Reapply ESP to update health bar visibility
    end,
})

-- Toggle Distance Indicator button
VisualsTab:AddToggle({
    Name = "Toggle Distance Indicator",
    Default = true,
    Callback = function(Value)
        distanceIndicatorVisible = Value
        ToggleESP()  -- Reapply ESP to update distance indicator visibility
    end,
})

-- Change Highlight Color button with color picker
VisualsTab:AddColorPicker({
    Name = "Chams Highlight Color",
    Default = highlightColor,
    Callback = function(color)
        highlightColor = color
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local highlight = Player.Character:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight.FillColor = highlightColor
                end
            end
        end
    end,
})

-- Player Speed Adjustment slider
VisualsTab:AddSlider({
    Name = "Adjust Player Speed",
    Min = 16,
    Max = 100,
    Default = playerSpeed,
    Increment = 1,
    Callback = function(Value)
        playerSpeed = Value
        LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeed
    end,
})

-- Teleport to Selected Player button
AimTab:AddButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        local targetPlayer = Players:GetPlayers()[1]  -- Select the first player as an example
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
})

-- Aimbot button
AimTab:AddToggle({
    Name = "Toggle Aimbot",
    Default = false,
    Callback = function(Value)
        isAimbotActive = Value
    end,
})

-- Misc Tab: Speed Adjustment
MiscTab:AddSlider({
    Name = "Adjust Player Speed",
    Min = 16,
    Max = 100,
    Default = playerSpeed,
    Increment = 1,
    Callback = function(Value)
        playerSpeed = Value
        LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeed
    end,
})

-- Misc Tab: FOV Changer
MiscTab:AddSlider({
    Name = "Adjust FOV",
    Min = 70,
    Max = 120,
    Default = defaultFOV,
    Increment = 1,
    Callback = function(Value)
        currentFOV = Value
        workspace.CurrentCamera.FieldOfView = currentFOV  -- Update the camera FOV
    end,
})

-- Misc Tab: Teleport to Player
MiscTab:AddButton({
    Name = "Teleport to Nearest Player",
    Callback = function()
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = Player
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
})

-- Teleport Tab: Teleport to Specific Player
TeleportTab:AddDropdown({
    Name = "Select Player to Teleport To",
    Options = Players:GetPlayers(),
    Callback = function(selectedPlayer)
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Name == selectedPlayer then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
            end
        end
    end,
})

-- Teleport Tab: Teleport to Random Player
TeleportTab:AddButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local allPlayers = Players:GetPlayers()
        if #allPlayers > 1 then  -- Ensure there are other players to teleport to
            local randomIndex = math.random(1, #allPlayers)
            local targetPlayer = allPlayers[randomIndex]

            if targetPlayer and targetPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end,
})

-- Initial settings for players
ToggleESP()  -- Apply initial ESP to all players

-- Key bindings for menu toggling and ESP toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle the Orion window with 'F'
        if input.KeyCode == Enum.KeyCode.F then
            Window:Toggle()  -- Toggle Orion window
        end

        -- Activate aimbot when it's enabled
        if isAimbotActive then
            AimAtNearestEnemy()
        end
    end
end)

-- Aimbot loop to continuously aim at the nearest enemy
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        AimAtNearestEnemy()
    end
end)
