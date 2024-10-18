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
        -- TODO: Implement aimbot logic here
    end,
})

-- Initial settings for players
ToggleESP()  -- Apply initial highlights to all players

-- Key bindings for menu toggling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        Window:Toggle()  -- Toggle Orion window
    end
end)
