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
local ESPEnabled = true
local highlightColor = Color3.fromRGB(255, 48, 51)
local isAimbotActive = false
local skeletonEnabled = false
local viewLineEnabled = false

-- Function to create a highlight for a player
local function ApplyHighlight(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Function to update highlight based on health
    local function OnHealthChanged()
        if Humanoid.Health <= 0 then
            Highlighter:Destroy()
        end
    end

    -- Connect health change
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)

    return Highlighter
end

-- Function to toggle highlights for all players
local function ToggleESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local highlight = Player.Character:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight.Enabled = ESPEnabled
            else
                ApplyHighlight(Player)
            end
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

-- Function to toggle skeleton visualization
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

-- Create Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10472045394",
})

-- Toggle ESP button
MainTab:AddButton({
    Name = "Toggle ESP",
    Callback = function()
        ESPEnabled = not ESPEnabled
        ToggleESP()  -- Update ESP state
    end,
})

-- Change Highlight Color button
MainTab:AddButton({
    Name = "Change Highlight Color",
    Callback = function()
        highlightColor = Color3.new(math.random(), math.random(), math.random())
        ToggleESP()  -- Update highlight color
    end,
})

-- Toggle Skeleton button
MainTab:AddToggle({
    Name = "Toggle Skeleton",
    Default = false,
    Callback = function(Value)
        skeletonEnabled = Value
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                if skeletonEnabled then
                    ToggleSkeleton(Player)
                end
            end
        end
    end,
})

-- Toggle View Line button
MainTab:AddToggle({
    Name = "Toggle View Line",
    Default = false,
    Callback = function(Value)
        viewLineEnabled = Value
        if viewLineEnabled then
            DrawViewLine()
        end
    end,
})

-- Toggle Aimbot button
MainTab:AddToggle({
    Name = "Toggle Aimbot",
    Default = false,
    Callback = function(Value)
        isAimbotActive = Value
    end,
})

-- Initial settings for players
ToggleESP()  -- Apply initial highlights to all players

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
