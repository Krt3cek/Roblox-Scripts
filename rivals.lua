-- LocalScript

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local playerBorderColor = Color3.new(1, 0, 0) -- Default Red
local borderVisible = false
local menuVisible = true

-- Create Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Visible = menuVisible
mainFrame.Parent = screenGui

-- Create Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Toggle Border"
toggleButton.Parent = mainFrame

-- Create Color Picker
local colorPicker = Instance.new("TextButton")
colorPicker.Size = UDim2.new(0, 180, 0, 50)
colorPicker.Position = UDim2.new(0, 10, 0, 70)
colorPicker.Text = "Pick Color"
colorPicker.Parent = mainFrame

-- Function to create the border effect
local function createBorderEffect()
    local border = Instance.new("Part")
    border.Size = Vector3.new(1.5, 1.5, 1.5) -- Adjust size as needed
    border.Anchored = true
    border.CanCollide = false
    border.Parent = workspace

    local playerChar = player.Character or player.CharacterAdded:Wait()
    local playerRoot = playerChar:WaitForChild("HumanoidRootPart")

    while borderVisible do
        border.Position = playerRoot.Position + Vector3.new(0, 3, 0) -- Adjust height as needed
        border.BrickColor = BrickColor.new(playerBorderColor)
        border.Material = Enum.Material.Neon
        border.Transparency = 0.5
        wait(0.1)
    end

    border:Destroy()
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    borderVisible = not borderVisible
    toggleButton.Text = borderVisible and "Hide Border" or "Show Border"
    if borderVisible then
        createBorderEffect()
    end
end)

-- Color picker functionality
colorPicker.MouseButton1Click:Connect(function()
    -- Open color picker (simple implementation)
    playerBorderColor = Color3.new(math.random(), math.random(), math.random()) -- Random color for example
end)

-- Keybind functionality to toggle the menu
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.M then -- Change 'M' to any key you want
            menuVisible = not menuVisible
            mainFrame.Visible = menuVisible
        end
    end
end)

-- Cleanup when player leaves
player.CharacterRemoving:Connect(function()
    borderVisible = false
end)
