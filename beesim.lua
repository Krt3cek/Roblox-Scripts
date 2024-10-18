-- Advanced Bee Swarm Simulator with GUI and Keybinds

local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChildOfClass("Tool")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local pollenLimit = 100 -- Default, can be changed in menu
local autoFarmEnabled = false
local autoCollectTokensEnabled = false -- New variable for token collection
local selectedFields = {"SunflowerField"} -- Default field
local bindKey = Enum.KeyCode.F -- Default bind

-- Create the GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Visible = false -- Start hidden

local title = Instance.new("TextLabel", frame)
title.Text = "Bee Swarm Simulator Script"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

-- Toggle Auto Farm
local toggleFarm = Instance.new("TextButton", frame)
toggleFarm.Text = "Auto Farm: OFF"
toggleFarm.Size = UDim2.new(1, 0, 0, 50)
toggleFarm.Position = UDim2.new(0, 0, 0, 60)
toggleFarm.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleFarm.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleFarm.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    toggleFarm.Text = "Auto Farm: " .. (autoFarmEnabled and "ON" or "OFF")
end)

-- Toggle Auto Collect Tokens
local toggleTokens = Instance.new("TextButton", frame)
toggleTokens.Text = "Auto Collect Tokens: OFF"
toggleTokens.Size = UDim2.new(1, 0, 0, 50)
toggleTokens.Position = UDim2.new(0, 0, 0, 120)
toggleTokens.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleTokens.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleTokens.MouseButton1Click:Connect(function()
    autoCollectTokensEnabled = not autoCollectTokensEnabled
    toggleTokens.Text = "Auto Collect Tokens: " .. (autoCollectTokensEnabled and "ON" or "OFF")
end)

-- Select fields
local fieldLabel = Instance.new("TextLabel", frame)
fieldLabel.Text = "Select Field:"
fieldLabel.Size = UDim2.new(1, 0, 0, 40)
fieldLabel.Position = UDim2.new(0, 0, 0, 180)
fieldLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fieldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local dropdown = Instance.new("TextButton", frame)
dropdown.Text = "SunflowerField"
dropdown.Size = UDim2.new(1, 0, 0, 40)
dropdown.Position = UDim2.new(0, 0, 0, 220)
dropdown.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)

dropdown.MouseButton1Click:Connect(function()
    if dropdown.Text == "SunflowerField" then
        dropdown.Text = "DandelionField"
        selectedFields = {"DandelionField"}
    elseif dropdown.Text == "DandelionField" then
        dropdown.Text = "MushroomField"
        selectedFields = {"MushroomField"}
    else
        dropdown.Text = "SunflowerField"
        selectedFields = {"SunflowerField"}
    end
end)

-- Set bind key
local keyLabel = Instance.new("TextLabel", frame)
keyLabel.Text = "Press a key to bind:"
keyLabel.Size = UDim2.new(1, 0, 0, 40)
keyLabel.Position = UDim2.new(0, 0, 0, 280)
keyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local bindButton = Instance.new("TextButton", frame)
bindButton.Text = "Current: F"
bindButton.Size = UDim2.new(1, 0, 0, 40)
bindButton.Position = UDim2.new(0, 0, 0, 320)
bindButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
bindButton.TextColor3 = Color3.fromRGB(255, 255, 255)

bindButton.MouseButton1Click:Connect(function()
    bindButton.Text = "Press any key..."
    local connection
    connection = uis.InputBegan:Connect(function(input)
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            bindKey = input.KeyCode
            bindButton.Text = "Current: " .. input.KeyCode.Name
            connection:Disconnect()
        end
    end)
end)

-- Anti-AFK
local virtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end)

-- Function to collect pollen from fields
local function collectPollen(fieldName)
    local field = workspace.FlowerZones:FindFirstChild(fieldName)
    if field and tool and tool:FindFirstChild("ClickEvent") then
        -- Teleport player to the field
        player.Character.HumanoidRootPart.CFrame = field.CFrame * CFrame.new(0, 3, 0) -- Adjust height as needed
        repeat
            tool.ClickEvent:FireServer() -- Simulate tool collection
            wait(math.random(0.3, 0.7)) -- Random delay between actions
        until player.Data.Pollen.Value >= pollenLimit -- Stop when full
    end
end

-- Function to make honey at the hive
local function makeHoney()
    local hive = workspace.HoneyHives:FindFirstChild(player.Name)
    if hive then
        local honeyButton = hive:FindFirstChild("MakeHoneyButton")
        if honeyButton then
            repeat
                fireclickdetector(honeyButton.ClickDetector)
                wait(math.random(0.5, 1.5)) -- Random delay to mimic human behavior
            until player.Data.Pollen.Value == 0 -- Stop when honey is made
        end
    end
end

-- Function to auto-collect tokens
local function collectTokens()
    while autoCollectTokensEnabled do
        for _, token in pairs(workspace:GetChildren()) do
            if token:IsA("Part") and token.Name:match("Token") then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport to token
                    character.HumanoidRootPart.CFrame = token.CFrame * CFrame.new(0, 3, 0) -- Adjust height as needed
                    wait(0.1) -- Give time for teleportation
                    fireclickdetector(token:FindFirstChild("ClickDetector"))
                    wait(math.random(0.5, 1.5)) -- Random delay to mimic human behavior
                end
            end
        end
        wait(1) -- Delay before searching for tokens again
    end
end

-- Function to auto farm selected fields
local function autoFarm()
    while autoFarmEnabled do
        for _, field in pairs(selectedFields) do
            collectPollen(field)
            makeHoney()
            wait(math.random(5, 10)) -- Random delay for safety
        end
    end
end

-- Bind the farming process to the selected key
uis.InputBegan:Connect(function(input)
    if input.KeyCode == bindKey then
        frame.Visible = not frame.Visible -- Toggle GUI visibility
        if autoFarmEnabled then
            autoFarm()
        end
        if autoCollectTokensEnabled then
            collectTokens()
        end
    end
end)
