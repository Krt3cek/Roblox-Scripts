-- LocalScript

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local highlightColor = Color3.fromRGB(255, 48, 51)
local skeletonColor = Color3.fromRGB(0, 255, 0)
local viewLineColor = Color3.fromRGB(0, 0, 255)
local toggleKey = Enum.KeyCode.M  -- Key for toggling the menu
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

-- Function to create the GUI
local function createToggleGUI()
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 0.5
    Frame.Active = true
    Frame.Draggable = true
    Frame.Visible = false  -- Start with the menu hidden

    -- Title Label
    local TitleLabel = Instance.new("TextLabel", Frame)
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TitleLabel.Text = "ESP & Aimbot Menu"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.BorderSizePixel = 0
    TitleLabel.TextStrokeTransparency = 0.5

    -- Create Tabs
    local VisualsTab = Instance.new("TextButton", Frame)
    VisualsTab.Size = UDim2.new(0.5, 0, 0, 50)
    VisualsTab.Position = UDim2.new(0, 0, 0.2, 0)
    VisualsTab.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    VisualsTab.Text = "Visuals"
    VisualsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualsTab.TextScaled = true

    local AimbotTab = Instance.new("TextButton", Frame)
    AimbotTab.Size = UDim2.new(0.5, 0, 0, 50)
    AimbotTab.Position = UDim2.new(0.5, 0, 0.2, 0)
    AimbotTab.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    AimbotTab.Text = "Aimbot"
    AimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotTab.TextScaled = true

    -- Create content frame for toggles
    local ContentFrame = Instance.new("Frame", Frame)
    ContentFrame.Size = UDim2.new(1, 0, 0, 300)
    ContentFrame.Position = UDim2.new(0, 0, 0.3, 0)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local function createToggleButton(parent, text, position, toggleFunction)
        local button = Instance.new("TextButton", parent)
        button.Size = UDim2.new(1, 0, 0, 50)
        button.Position = position
        button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.BorderSizePixel = 0

        button.MouseButton1Click:Connect(toggleFunction)
        return button
    end

    -- Toggle buttons for visuals
    createToggleButton(ContentFrame, "Toggle ESP", UDim2.new(0, 0, 0, 0), function()
        ESPEnabled = not ESPEnabled
        ToggleESP()  -- Update ESP state
    end)

    createToggleButton(ContentFrame, "Change Color", UDim2.new(0, 0, 0, 50), function()
        highlightColor = Color3.new(math.random(), math.random(), math.random())
        ToggleESP()  -- Update highlight color
    end)

    createToggleButton(ContentFrame, "Toggle Skeleton", UDim2.new(0, 0, 0, 100), function()
        skeletonEnabled = not skeletonEnabled
        -- TODO: Implement skeleton visualization logic here
    end)

    createToggleButton(ContentFrame, "Toggle View Line", UDim2.new(0, 0, 0, 150), function()
        viewLineEnabled = not viewLineEnabled
        -- TODO: Implement view line logic here
    end)

    -- Toggle buttons for aimbot
    createToggleButton(ContentFrame, "Toggle Aimbot", UDim2.new(0, 0, 0, 200), function()
        isAimbotActive = not isAimbotActive
        -- TODO: Implement aimbot logic here
    end)

    -- Manage tab visibility
    VisualsTab.MouseButton1Click:Connect(function()
        ContentFrame.Visible = true
    end)

    AimbotTab.MouseButton1Click:Connect(function()
        ContentFrame.Visible = false
    end)
end

-- Create the toggle GUI
createToggleGUI()

-- Key bindings for menu toggling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then  -- Only process if the game is not handling the input
        if input.KeyCode == toggleKey then
            Frame.Visible = not Frame.Visible
        end
    end
end)

-- Initial settings for players
ToggleESP()  -- Apply initial highlights to all players
