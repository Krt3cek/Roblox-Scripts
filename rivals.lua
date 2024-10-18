-- LocalScript

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")

local espEnabled = false -- Track ESP state
local bindKey = Enum.KeyCode.F -- Key to toggle the menu
local espBoxSize = Vector3.new(4, 6, 4) -- Size of the ESP box

-- Create the GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Visible = false -- Start hidden
frame.Draggable = true -- Allow dragging the frame

local title = Instance.new("TextLabel", frame)
title.Text = "ESP Toggle"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple background
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

-- Function to create the toggle button
local function createToggle(label, position)
    local toggleFrame = Instance.new("Frame", frame)
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.Position = position
    toggleFrame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)

    local toggleLabel = Instance.new("TextLabel", toggleFrame)
    toggleLabel.Text = label
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextScaled = true

    local toggleSwitch = Instance.new("TextButton", toggleFrame)
    toggleSwitch.Size = UDim2.new(0.3, 0, 1, 0)
    toggleSwitch.Position = UDim2.new(0.7, 0, 0, 0)
    toggleSwitch.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red for off
    toggleSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleSwitch.Text = "OFF"

    toggleSwitch.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        toggleSwitch.Text = espEnabled and "ON" or "OFF"
        toggleSwitch.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) -- Green for on

        if espEnabled then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player then
                    local espBox = Instance.new("BoxHandleAdornment")
                    espBox.Size = espBoxSize
                    espBox.Adornee = p.Character:WaitForChild("HumanoidRootPart")
                    espBox.ZIndex = 0
                    espBox.Color3 = Color3.fromRGB(255, 0, 0) -- Red color
                    espBox.Transparency = 0.5
                    espBox.Parent = p.Character.HumanoidRootPart
                end
            end
        else
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player and p.Character then
                    local espBox = p.Character.HumanoidRootPart:FindFirstChildOfClass("BoxHandleAdornment")
                    if espBox then
                        espBox:Destroy()
                    end
                end
            end
        end
    end)
end

-- Create toggle button for ESP
createToggle("Toggle ESP", UDim2.new(0, 0, 0, 60))

-- Keybind functionality to toggle the menu
uis.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == bindKey then
        frame.Visible = not frame.Visible -- Toggle GUI visibility
    end
end)
