-- LocalScript

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true -- Start with ESP enabled
local highlightColor = Color3.fromRGB(255, 48, 51) -- Default highlight color
local toggleKey = Enum.KeyCode.M -- Key to toggle the menu

-- Function to create a highlight for a player
local function ApplyHighlight(Player)
    local Connections = {}

    -- Parts
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local Highlighter = Instance.new("Highlight", Character)

    local function UpdateFillColor()
        Highlighter.FillColor = highlightColor
    end

    local function Disconnect()
        Highlighter:Destroy() -- Use Destroy instead of Remove for better cleanup
        for _, Connection in next, Connections do
            Connection:Disconnect()
        end
    end

    -- Connect functions to events
    table.insert(Connections, Player:GetPropertyChangedSignal("TeamColor"):Connect(UpdateFillColor))
    table.insert(Connections, Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if Humanoid.Health <= 0 then
            Disconnect()
        end
    end))

    -- Return the Disconnect function for cleanup
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

-- GUI for toggling ESP
local function createToggleGUI()
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 200, 0, 150)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    Frame.BackgroundTransparency = 0.5
    Frame.Active = true
    Frame.Draggable = true

    local ToggleButton = Instance.new("TextButton", Frame)
    ToggleButton.Size = UDim2.new(1, 0, 0, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    ToggleButton.Text = "Toggle ESP"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true

    local ColorPicker = Instance.new("TextButton", Frame)
    ColorPicker.Size = UDim2.new(1, 0, 0, 50)
    ColorPicker.Position = UDim2.new(0, 0, 0, 50)
    ColorPicker.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    ColorPicker.Text = "Change Color"
    ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPicker.TextScaled = true

    ToggleButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled -- Toggle the ESP variable
        ToggleButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF" -- Update button text

        -- Enable or disable highlights based on the toggle state
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local character = Player.Character
                if character then
                    local highlight = character:FindFirstChildOfClass("Highlight")
                    if highlight then
                        highlight.Enabled = ESPEnabled
                    end
                end
            end
        end
    end)

    ColorPicker.MouseButton1Click:Connect(function()
        highlightColor = Color3.new(math.random(), math.random(), math.random()) -- Random color
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local character = Player.Character
                if character then
                    local highlight = character:FindFirstChildOfClass("Highlight")
                    if highlight then
                        highlight.FillColor = highlightColor -- Change existing highlight color
                    end
                end
            end
        end
    end)

    -- Keybinding for toggling the menu visibility
    local isMenuVisible = true
    local function toggleMenu()
        Frame.Visible = not Frame.Visible
        isMenuVisible = Frame.Visible
    end

    -- Bind the key to toggle the menu
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            toggleMenu()
        end
    end)

    -- Initially set highlight color
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local character = Player.Character
            if character then
                local highlight = character:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight.FillColor = highlightColor -- Set initial highlight color
                end
            end
        end
    end
end

-- Apply highlights to players
local highlightConnections = {}
for _, Player in next, Players:GetPlayers() do
    if Player ~= LocalPlayer then
        highlightConnections[Player] = HighlightPlayer(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    highlightConnections[Player] = HighlightPlayer(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    if highlightConnections[Player] then
        highlightConnections[Player]()
        highlightConnections[Player] = nil
    end
end)

-- Create the toggle GUI
createToggleGUI()

-- Enable or disable ESP on the current players based on the initial setting
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        local character = Player.Character
        if character then
            local highlight = character:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight.Enabled = ESPEnabled
                highlight.FillColor = highlightColor -- Set initial highlight color
            end
        end
    end
end
