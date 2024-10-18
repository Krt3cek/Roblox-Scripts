local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChildOfClass("Tool")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local pollenLimit = 100 -- Default, can be changed in menu
local autoFarmEnabled = false
local autoCollectTokensEnabled = false
local autoQuestEnabled = false
local autoBuyEnabled = false
local autoTeleportEnabled = false
local selectedFields = {"SunflowerField"} -- Default field
local bindKey = Enum.KeyCode.F -- Default bind

-- Create the GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Visible = false -- Start hidden
frame.Draggable = true -- Allow dragging the frame

local title = Instance.new("TextLabel", frame)
title.Text = "Bee Swarm Simulator"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple background
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

-- Function to create toggle buttons
local function createToggle(label, position, toggleVar)
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
        toggleVar = not toggleVar
        toggleSwitch.Text = toggleVar and "ON" or "OFF"
        toggleSwitch.BackgroundColor3 = toggleVar and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) -- Green for on
        return toggleVar
    end)

    return toggleVar
end

-- Create toggle buttons
local toggleFarm = createToggle("Auto Farm", UDim2.new(0, 0, 0, 60), autoFarmEnabled)
local toggleTokens = createToggle("Auto Collect Tokens", UDim2.new(0, 0, 0, 110), autoCollectTokensEnabled)
local toggleQuests = createToggle("Auto Quests", UDim2.new(0, 0, 0, 160), autoQuestEnabled)
local toggleBuy = createToggle("Auto Buy", UDim2.new(0, 0, 0, 210), autoBuyEnabled)
local toggleTeleport = createToggle("Auto Teleport", UDim2.new(0, 0, 0, 260), autoTeleportEnabled)

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
            autoTeleportEnabled = false
        end
    end
end)

-- Start auto farm, token collection, questing, and auto-buy in separate threads
coroutine.wrap(autoFarm)()
coroutine.wrap(collectTokens)()
coroutine.wrap(autoCompleteQuests)()
coroutine.wrap(autoBuy)()
coroutine.wrap(autoTeleport)()
