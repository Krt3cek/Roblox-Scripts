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

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false  -- Set to false initially
local ChamsEnabled = false  -- Set to false initially
local highlightColor = Color3.fromRGB(255, 48, 51)
local isAimbotActive = false  -- Set to false initially
local aimLock = false  -- Set to false initially
local smoothAiming = false  -- Set to false initially
local aimSmoothness = 0.5  -- Default smoothness
local aimFOV = 70  -- Default FOV for aiming
local playerSpeed = 16  -- Default player speed
local currentFOV = 70  -- Current Field of View

-- Function to create a highlight for a player
local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Function to update highlight based on health
    local function OnHealthChanged()
        if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then
            Highlighter:Destroy()
        end
    end

    -- Connect health change
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)

    return Highlighter
end

-- Function to toggle highlights for all players
local function ToggleChams()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local highlight = Player.Character:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight.Enabled = ChamsEnabled
            else
                ApplyChams(Player)
            end
        end
    end
end

-- Function to create a box around the player
local function CreateESPBox(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Head = Character:WaitForChild("Head")
    
    -- Create a box part for ESP
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Character:GetExtentsSize()
    espBox.Adornee = Character
    espBox.Color3 = highlightColor
    espBox.Transparency = 0.5
    espBox.ZIndex = 10
    espBox.Parent = Character

    -- Clean up the box when the player dies
    Character.Humanoid.Died:Connect(function()
        espBox:Destroy()
    end)

    return espBox
end

-- Function to toggle ESP boxes for all players
local function ToggleESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            CreateESPBox(Player)
        end
    end
end

-- Aimbot function to aim at the nearest enemy's head
local function AimAtNearestEnemy()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local head = Player.Character:FindFirstChild("Head")
            if head then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).magnitude
                if distance <= aimFOV and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = head
                end
            end
        end
    end

    if closestPlayer then
        -- Move the mouse to the closest enemy's head smoothly
        local targetPosition = workspace.CurrentCamera:WorldToScreenPoint(closestPlayer.Position)
        local newMousePosition = Vector2.new(targetPosition.X, targetPosition.Y)

        if smoothAiming then
            local mousePosition = Vector2.new(mouse.X, mouse.Y)
            local step = aimSmoothness
            mousePosition = mousePosition:Lerp(newMousePosition, step)  -- Smoothly interpolate
            UserInputService:SetMouseLocation(mousePosition.X, mousePosition.Y)
        else
            UserInputService:SetMouseLocation(newMousePosition.X, newMousePosition.Y)
        end
    end
end

-- Function to create a view line
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

-- Function to create skeleton visualization
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

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = skeletonPart
        weld.Part1 = part
        weld.Parent = skeletonPart

        return skeletonPart
    end

    local HeadSkeleton = CreateSkeletonPart(Character:WaitForChild("Head"))
    local TorsoSkeleton = CreateSkeletonPart(Character:WaitForChild("HumanoidRootPart"))

    -- Create skeleton parts for limbs
    local function CreateLimbSkeleton()
        for _, limbName in pairs({"Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
            local limb = Character:FindFirstChild(limbName)
            if limb then
                CreateSkeletonPart(limb)
            end
        end
    end

    CreateLimbSkeleton()

    -- Clean up skeleton parts when the player dies
    Humanoid.Died:Connect(function()
        HeadSkeleton:Destroy()
        TorsoSkeleton:Destroy()
        for _, part in pairs(Workspace:GetChildren()) do
            if part:IsA("Part") and part.Name == "SkeletonPart" then
                part:Destroy()
            end
        end
    end)
end

local MainTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10472045394",
    PremiumOnly = false
})

-- Visuals Tab: Toggle Chams button
MainTab:AddToggle({
    Name = "Toggle Chams",
    Default = false,
    Callback = function(Value)
        ChamsEnabled = Value
        ToggleChams()  -- Update Chams state
    end,
})

-- Visuals Tab: Toggle ESP button
MainTab:AddToggle({
    Name = "Toggle ESP Boxes",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            ToggleESP()  -- Apply ESP to players
        end
    end,
})

-- Visuals Tab: Change Highlight Color button with color picker
MainTab:AddColorPicker({
    Name = "Chams Highlight Color",
    Default = highlightColor,
    Callback = function(color)
        highlightColor = color
        ToggleChams()  -- Update Chams color
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

-- Visuals Tab: Toggle Skeleton button
MainTab:AddToggle({
    Name = "Toggle Skeleton",
    Default = false,
    Callback = function(Value)
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Value then
                ToggleSkeleton(Player)
            end
        end
    end,
})

-- Aimbot Tab: Toggle Aimbot
MainTab:AddToggle({
    Name = "Toggle Aimbot",
    Default = false,
    Callback = function(Value)
        isAimbotActive = Value
    end,
})

-- Aimbot Tab: Aim Lock Toggle
MainTab:AddToggle({
    Name = "Toggle Aim Lock",
    Default = false,
    Callback = function(Value)
        aimLock = Value
    end,
})

-- Aimbot Tab: Smooth Aiming Toggle
MainTab:AddToggle({
    Name = "Enable Smooth Aiming",
    Default = false,
    Callback = function(Value)
        smoothAiming = Value
    end,
})

-- Aimbot Tab: Aim Smoothness Slider
MainTab:AddSlider({
    Name = "Aim Smoothness",
    Min = 0,
    Max = 1,
    Default = aimSmoothness,
    Increment = 0.01,
    Callback = function(Value)
        aimSmoothness = Value
    end,
})

-- Aimbot Tab: Aim FOV Slider
MainTab:AddSlider({
    Name = "Aim FOV",
    Min = 0,
    Max = 200,
    Default = aimFOV,
    Increment = 1,
    Callback = function(Value)
        aimFOV = Value
    end,
})

-- Misc Tab: Speed Adjustment
MainTab:AddSlider({
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
MainTab:AddSlider({
    Name = "Adjust FOV",
    Min = 70,
    Max = 120,
    Default = currentFOV,
    Increment = 1,
    Callback = function(Value)
        currentFOV = Value
        workspace.CurrentCamera.FieldOfView = currentFOV  -- Update the camera FOV
    end,
})

-- Teleport Tab: Teleport to Player dropdown
local teleportDropdown = TeleportTab:AddDropdown({
    Name = "Select Player to Teleport To",
    Options = {},
    Callback = function(selectedPlayer)
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Name == selectedPlayer then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
                break
            end
        end
    end,
})

-- Populate the teleport dropdown with player names
Players.PlayerAdded:Connect(function(Player)
    teleportDropdown:Add(selectedPlayer.Name)
end)

for _, Player in pairs(Players:GetPlayers()) do
    teleportDropdown:Add(Player.Name)
end

-- Teleport Tab: Button to teleport to local player
TeleportTab:AddButton({
    Name = "Teleport to Me",
    Callback = function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Adjust as needed
    end,
})

-- Key bindings for menu toggling and ESP toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle the Orion window with 'F'
        if input.KeyCode == Enum.KeyCode.F then
            Window:Toggle()  -- Toggle Orion window
        end

        -- Activate aimbot when it's enabled
        if isAimbotActive and not aimLock then
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

-- Initial settings for players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        ApplyChams(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        ApplyChams(Player)
    end)
end)
