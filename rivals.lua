-- LocalScript

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local highlightColor = Color3.fromRGB(255, 48, 51)
local skeletonColor = Color3.fromRGB(0, 255, 0)
local viewLineColor = Color3.fromRGB(0, 0, 255)
local toggleKey = Enum.KeyCode.M  -- Key for toggling the menu
local aimKey = Enum.KeyCode.E      -- Key for aimbot
local isAimbotActive = false
local aimTarget = nil
local skeletonEnabled = false
local viewLineEnabled = false

-- Function to create a highlight for a player
local function ApplyHighlight(Player)
    local Connections = {}

    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local Highlighter = Instance.new("Highlight", Character)

    local function UpdateFillColor()
        Highlighter.FillColor = highlightColor
    end

    local function Disconnect()
        Highlighter:Destroy()
        for _, Connection in next, Connections do
            Connection:Disconnect()
        end
    end

    table.insert(Connections, Player:GetPropertyChangedSignal("TeamColor"):Connect(UpdateFillColor))
    table.insert(Connections, Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if Humanoid.Health <= 0 then
            Disconnect()
        end
    end))

    return Disconnect
end

-- Function to highlight a player
local function HighlightPlayer(Player)
    if Player.Character then
        return ApplyHighlight(Player)
    end

    return Player.CharacterAdded:Connect(function()
        return ApplyHighlight(Player)
    end)
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

    local TitleLabel = Instance.new("TextLabel", Frame)
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TitleLabel.Text = "ESP & Aimbot Menu"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.BorderSizePixel = 0
    TitleLabel.TextStrokeTransparency = 0.5

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

        button.MouseButton1Click:Connect(toggleFunction)
        return button
    end

    -- Toggle buttons
    createToggleButton(ContentFrame, "Toggle ESP", UDim2.new(0, 0, 0, 0), function()
        ESPEnabled = not ESPEnabled
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local highlight = Player.Character:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight.Enabled = ESPEnabled
                end
            end
        end
    end)

    createToggleButton(ContentFrame, "Change Color", UDim2.new(0, 0, 0, 50), function()
        highlightColor = Color3.new(math.random(), math.random(), math.random())
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local highlight = Player.Character:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight.FillColor = highlightColor
                end
            end
        end
    end)

    createToggleButton(ContentFrame, "Toggle Skeleton", UDim2.new(0, 0, 0, 100), function()
        skeletonEnabled = not skeletonEnabled
        if skeletonEnabled then
            -- Implement skeleton visualization logic here
        else
            -- Remove skeletons logic here
        end
    end)

    createToggleButton(ContentFrame, "Toggle Aimbot", UDim2.new(0, 0, 0, 150), function()
        isAimbotActive = not isAimbotActive
        -- Implement aimbot logic here
    end)

    createToggleButton(ContentFrame, "Toggle View Line", UDim2.new(0, 0, 0, 200), function()
        viewLineEnabled = not viewLineEnabled
        -- Implement view line logic here
    end)

    -- Tab switching
    VisualsTab.MouseButton1Click:Connect(function()
        ContentFrame.Visible = true
    end)

    AimbotTab.MouseButton1Click:Connect(function()
        ContentFrame.Visible = false
    end)
end

-- Aimbot and ESP logic here (implementation omitted for brevity)

-- Create the toggle GUI
createToggleGUI()

-- Initial settings for players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer and Player.Character then
        local highlight = Player.Character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight.Enabled = ESPEnabled
            highlight.FillColor = highlightColor
        end
    end
end

-- Key bindings for menu toggling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then  -- Only process if the game is not handling the input
        if input.KeyCode == toggleKey then
            Frame.Visible = not Frame.Visible
        end
    end
end)
