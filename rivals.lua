-- LocalScript

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true -- Start with ESP enabled
local highlightColor = Color3.fromRGB(255, 48, 51) -- Default highlight color
local toggleKey = Enum.KeyCode.M -- Key to toggle the menu
local aimKey = Enum.KeyCode.E -- Key to activate aimbot
local isAimbotActive = false -- Aimbot toggle state
local aimTarget = nil -- The current target for aimbot

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

-- GUI for toggling ESP and Aimbot
local function createToggleGUI()
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 250)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -125)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    Frame.BackgroundTransparency = 0.5
    Frame.Active = true
    Frame.Draggable = true

    local TabButtons = Instance.new("Frame", Frame)
    TabButtons.Size = UDim2.new(1, 0, 0, 50)
    TabButtons.BackgroundColor3 = Color3.fromRGB(75, 75, 75)

    local VisualsTab = Instance.new("TextButton", TabButtons)
    VisualsTab.Size = UDim2.new(0.5, 0, 1, 0)
    VisualsTab.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    VisualsTab.Text = "Visuals"
    VisualsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualsTab.TextScaled = true

    local AimbotTab = Instance.new("TextButton", TabButtons)
    AimbotTab.Size = UDim2.new(0.5, 0, 1, 0)
    AimbotTab.Position = UDim2.new(0.5, 0, 0, 0)
    AimbotTab.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    AimbotTab.Text = "Aimbot"
    AimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotTab.TextScaled = true

    local ContentFrame = Instance.new("Frame", Frame)
    ContentFrame.Size = UDim2.new(1, 0, 0, 200)
    ContentFrame.Position = UDim2.new(0, 0, 0.2, 0)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local ToggleButton = Instance.new("TextButton", ContentFrame)
    ToggleButton.Size = UDim2.new(1, 0, 0, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    ToggleButton.Text = "Toggle ESP"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true

    local ColorPicker = Instance.new("TextButton", ContentFrame)
    ColorPicker.Size = UDim2.new(1, 0, 0, 50)
    ColorPicker.Position = UDim2.new(0, 0, 0, 50)
    ColorPicker.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    ColorPicker.Text = "Change Color"
    ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPicker.TextScaled = true

    local AimbotToggle = Instance.new("TextButton", ContentFrame)
    AimbotToggle.Size = UDim2.new(1, 0, 0, 50)
    AimbotToggle.Position = UDim2.new(0, 0, 0, 100)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    AimbotToggle.Text = "Toggle Aimbot"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextScaled = true

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

    -- Aimbot functionality
    AimbotToggle.MouseButton1Click:Connect(function()
        isAimbotActive = not isAimbotActive -- Toggle aimbot state
        AimbotToggle.Text = isAimbotActive and "Aimbot: ON" or "Aimbot: OFF" -- Update button text
    end)

    -- Keybinding for toggling the menu visibility
    local isMenuVisible = true
    local function toggleMenu()
        Frame.Visible = not Frame.Visible
        isMenuVisible = Frame.Visible
    end

    -- Bind the key to toggle the menu
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            toggleMenu()
        end
    end)

    -- Aimbot functionality while holding the aim key
    RunService.RenderStepped:Connect(function()
        if isAimbotActive then
            aimTarget = nil
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local head = Player.Character:FindFirstChild("Head")
                    if head and head:IsA("Part") then
                        local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
                        if (Vector2.new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude < 200 then
                            aimTarget = head
                            break -- Lock onto the closest target
                        end
                    end
                end
            end
            
            -- If we have a target, aim at it
            if aimTarget then
                LocalPlayer.Character.HumanoidRootPart.CFrame = aimTarget.CFrame * CFrame.new(0, 0, 5) -- Aim at the target
            end
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
