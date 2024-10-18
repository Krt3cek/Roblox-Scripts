-- Load OrionLib
OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Krt Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Krt Hub",
    IntroEnabled = false,
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

    return Highlighter
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

    return espBox
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

-- Correctly creating the Visual, Aim, Misc, and Teleport tabs
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


-- Ensure we add Chams toggle under the correct 'VisualsTab'
VisualsTab:AddToggle({
    Name = "Toggle Chams",
    Default = false,
    Callback = function(Value)
        ChamsEnabled = Value
        if ChamsEnabled then
            StartChamsThread()  -- Start the thread to continuously update Chams
        else
            RemoveAllChams()  -- Clean up Chams when disabled
        end
    end,
})

-- Ensure ESP is under 'VisualsTab'
VisualsTab:AddToggle({
    Name = "Toggle ESP Boxes",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            StartESPThread()  -- Start the thread to continuously update ESP
        else
            RemoveAllESPBoxes()  -- Clean up ESP when disabled
        end
    end,
})

-- Ensure Chams highlight color picker is under 'VisualsTab'
VisualsTab:AddColorPicker({
    Name = "Chams Highlight Color",
    Default = highlightColor,
    Callback = function(color)
        highlightColor = color
        UpdateChams()  -- Update Chams color immediately
    end,
})

-- Aimbot toggles and settings are under 'AimTab'
AimTab:AddToggle({
    Name = "Toggle Aimbot",
    Default = false,
    Callback = function(Value)
        isAimbotActive = Value
    end,
})

AimTab:AddToggle({
    Name = "Toggle Aim Lock",
    Default = false,
    Callback = function(Value)
        aimLock = Value
    end,
})

AimTab:AddToggle({
    Name = "Enable Smooth Aiming",
    Default = false,
    Callback = function(Value)
        smoothAiming = Value
    end,
})

AimTab:AddSlider({
    Name = "Aim Smoothness",
    Min = 0,
    Max = 1,
    Default = aimSmoothness,
    Increment = 0.01,
    Callback = function(Value)
        aimSmoothness = Value
    end,
})

AimTab:AddSlider({
    Name = "Aim FOV",
    Min = 0,
    Max = 200,
    Default = aimFOV,
    Increment = 1,
    Callback = function(Value)
        aimFOV = Value
    end,
})

-- Miscellaneous settings under 'MiscTab'
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

MiscTab:AddSlider({
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
TeleportTab:AddDropdown({
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


-- Initialize the library
OrionLib:Init()
