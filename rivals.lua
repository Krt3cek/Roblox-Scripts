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
        -- TODO: Implement skeleton visualization logic here
    end,
})

-- Toggle View Line button
MainTab:AddToggle({
    Name = "Toggle View Line",
    Default = false,
    Callback = function(Value)
        viewLineEnabled = Value
        -- TODO: Implement view line logic here
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

        -- Toggle ESP with 'E'
        if input.KeyCode == Enum.KeyCode.E then
            ESPEnabled = not ESPEnabled
            ToggleESP()  -- Update ESP state
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
