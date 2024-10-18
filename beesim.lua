-- Advanced Bee Swarm Simulator with GUI and Keybinds

local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChildOfClass("Tool")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local pollenLimit = 100 -- Default, can be changed in menu
local autoFarmEnabled = false
local autoCollectTokensEnabled = false -- New variable for token collection
local autoQuestEnabled = false -- New variable for auto quests
local autoBuyEnabled = false -- New variable for auto-buy
local autoTeleportEnabled = false -- New variable for auto-teleport
local selectedFields = {"SunflowerField"} -- Default field
local bindKey = Enum.KeyCode.F -- Key for toggling the menu

-- Create the GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 600) -- Increased height for additional buttons
frame.Position = UDim2.new(0.5, -150, 0.5, -300)
frame.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple background
frame.BorderSizePixel = 0
frame.Visible = false -- Start hidden
frame.Active = true
frame.Draggable = true -- Make frame draggable

local title = Instance.new("TextLabel", frame)
title.Text = "Bee Swarm Simulator Script"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background for title
title.TextColor3 = Color3.fromRGB(128, 0, 128) -- Purple text
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeTransparency = 0.5

-- Toggle Auto Farm
local toggleFarm = Instance.new("TextButton", frame)
toggleFarm.Text = "Auto Farm: OFF"
toggleFarm.Size = UDim2.new(1, 0, 0, 50)
toggleFarm.Position = UDim2.new(0, 0, 0, 60)
toggleFarm.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleFarm.Font = Enum.Font.Gotham
toggleFarm.TextScaled = true
toggleFarm.TextStrokeTransparency = 0.5

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
toggleTokens.Font = Enum.Font.Gotham
toggleTokens.TextScaled = true
toggleTokens.TextStrokeTransparency = 0.5

toggleTokens.MouseButton1Click:Connect(function()
    autoCollectTokensEnabled = not autoCollectTokensEnabled
    toggleTokens.Text = "Auto Collect Tokens: " .. (autoCollectTokensEnabled and "ON" or "OFF")
end)

-- Toggle Auto Quests
local toggleQuests = Instance.new("TextButton", frame)
toggleQuests.Text = "Auto Quests: OFF"
toggleQuests.Size = UDim2.new(1, 0, 0, 50)
toggleQuests.Position = UDim2.new(0, 0, 0, 180)
toggleQuests.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleQuests.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleQuests.Font = Enum.Font.Gotham
toggleQuests.TextScaled = true
toggleQuests.TextStrokeTransparency = 0.5

toggleQuests.MouseButton1Click:Connect(function()
    autoQuestEnabled = not autoQuestEnabled
    toggleQuests.Text = "Auto Quests: " .. (autoQuestEnabled and "ON" or "OFF")
end)

-- Toggle Auto Buy
local toggleBuy = Instance.new("TextButton", frame)
toggleBuy.Text = "Auto Buy: OFF"
toggleBuy.Size = UDim2.new(1, 0, 0, 50)
toggleBuy.Position = UDim2.new(0, 0, 0, 240)
toggleBuy.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleBuy.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBuy.Font = Enum.Font.Gotham
toggleBuy.TextScaled = true
toggleBuy.TextStrokeTransparency = 0.5

toggleBuy.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    toggleBuy.Text = "Auto Buy: " .. (autoBuyEnabled and "ON" or "OFF")
end)

-- Toggle Auto Teleport to Base
local toggleTeleport = Instance.new("TextButton", frame)
toggleTeleport.Text = "Auto Teleport: OFF"
toggleTeleport.Size = UDim2.new(1, 0, 0, 50)
toggleTeleport.Position = UDim2.new(0, 0, 0, 300)
toggleTeleport.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
toggleTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleTeleport.Font = Enum.Font.Gotham
toggleTeleport.TextScaled = true
toggleTeleport.TextStrokeTransparency = 0.5

toggleTeleport.MouseButton1Click:Connect(function()
    autoTeleportEnabled = not autoTeleportEnabled
    toggleTeleport.Text = "Auto Teleport: " .. (autoTeleportEnabled and "ON" or "OFF")
end)

-- Select fields
local fieldLabel = Instance.new("TextLabel", frame)
fieldLabel.Text = "Select Field:"
fieldLabel.Size = UDim2.new(1, 0, 0, 40)
fieldLabel.Position = UDim2.new(0, 0, 0, 360)
fieldLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background for field label
fieldLabel.TextColor3 = Color3.fromRGB(128, 0, 128) -- Purple text
fieldLabel.Font = Enum.Font.Gotham
fieldLabel.TextScaled = true
fieldLabel.TextStrokeTransparency = 0.5

local dropdown = Instance.new("TextButton", frame)
dropdown.Text = "SunflowerField"
dropdown.Size = UDim2.new(1, 0, 0, 40)
dropdown.Position = UDim2.new(0, 0, 0, 400)
dropdown.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdown.Font = Enum.Font.Gotham
dropdown.TextScaled = true
dropdown.TextStrokeTransparency = 0.5

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

-- Function to collect tokens
local function collectTokens()
    while autoCollectTokensEnabled do
        for _, token in pairs(workspace.Tokens:GetChildren()) do
            if token:IsA("Part") and token.Name:match("Token") then
                -- Teleport player to the token
                player.Character.HumanoidRootPart.CFrame = token.CFrame * CFrame.new(0, 3, 0) -- Adjust height as needed
                wait(0.1) -- Small wait before collecting
                fireclickdetector(token.ClickDetector)
                wait(math.random(0.5, 1.5)) -- Random delay to mimic human behavior
            end
        end
        wait(5) -- Delay before checking for tokens again
    end
end

-- Function to auto-complete quests
local function autoCompleteQuests()
    while autoQuestEnabled do
        for _, quest in pairs(workspace.Quests:GetChildren()) do
            if quest:FindFirstChild("Complete") and quest.Complete.Value then
                fireclickdetector(quest.Complete.ClickDetector) -- Complete the quest
                wait(math.random(1, 2)) -- Wait for completion
            end
        end
        wait(5) -- Delay before checking quests again
    end
end

-- Function to auto-buy better equipment
local function autoBuy()
    while autoBuyEnabled do
        local playerMoney = player.Data.Money.Value -- Adjust based on your game's player money structure
        local shop = workspace.Shop -- Adjust based on the actual shop location in your game
        if shop then
            for _, item in pairs(shop:GetChildren()) do
                if item:IsA("Tool") and item.Price.Value <= playerMoney then -- Check if player can afford item
                    -- Teleport player to the shop
                    player.Character.HumanoidRootPart.CFrame = shop.CFrame * CFrame.new(0, 3, 0) -- Adjust height as needed
                    wait(0.5) -- Wait for teleportation
                    fireclickdetector(item.ClickDetector) -- Simulate buying the item
                    wait(math.random(1, 2)) -- Wait for purchase
                    break -- Exit loop after buying the first affordable item
                end
            end
        end
        wait(5) -- Delay before checking again
    end
end

-- Function to teleport back to the base
local function teleportToBase()
    local hive = workspace.HoneyHives:FindFirstChild(player.Name) -- Assuming player's hive is located here
    if hive and player.Data.Pollen.Value >= pollenLimit then
        player.Character.HumanoidRootPart.CFrame = hive.CFrame * CFrame.new(0, 3, 0) -- Adjust height as needed
        wait(1) -- Wait a bit after teleporting
        makeHoney() -- Make honey after teleporting
    end
end

-- Auto-farm function with teleportation when backpack is full
local function autoFarm()
    while autoFarmEnabled do
        for _, field in pairs(selectedFields) do
            collectPollen(field)
            if autoTeleportEnabled then
                teleportToBase() -- Check for teleportation to base after collecting
            end
            wait(math.random(5, 10)) -- Random delay for safety
        end
    end
end

-- Bind the farming and quest process to the key for toggling the menu
uis.InputBegan:Connect(function(input)
    if input.KeyCode == bindKey then
        frame.Visible = not frame.Visible -- Toggle GUI visibility
        -- If the GUI is open, stop auto farming, collecting tokens, and auto questing
        if not frame.Visible then
            autoFarmEnabled = false
            autoCollectTokensEnabled = false
            autoQuestEnabled = false
            autoBuyEnabled = false
            toggleFarm.Text = "Auto Farm: OFF"
            toggleTokens.Text = "Auto Collect Tokens: OFF"
            toggleQuests.Text = "Auto Quests: OFF"
            toggleBuy.Text = "Auto Buy: OFF"
            toggleTeleport.Text = "Auto Teleport: OFF"
        end
    end
end)

-- Start auto farm, token collection, questing, and auto-buy in separate threads
coroutine.wrap(autoFarm)()
coroutine.wrap(collectTokens)()
coroutine.wrap(autoCompleteQuests)()
coroutine.wrap(autoBuy)()
coroutine.wrap(autoTeleport)()
