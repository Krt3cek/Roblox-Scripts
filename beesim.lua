-- Advanced Bee Swarm Simulator with GUI and Keybinds

local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChildOfClass("Tool")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local pollenLimit = 100 -- Default, can be changed in menu
local autoFarmEnabled = false
local autoCollectTokensEnabled = false -- New variable for token collection
local autoQuestEnabled = false -- New variable for auto quests
local selectedFields = {"SunflowerField"} -- Default field
local bindKey = Enum.KeyCode.F -- Key for toggling the menu

-- Create the GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 500) -- Increased height for quests
frame.Position = UDim2.new(0.5, -150, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = false -- Start hidden
frame.Active = true
frame.Draggable = true -- Make frame draggable

local title = Instance.new("TextLabel", frame)
title.Text = "Bee Swarm Simulator Script"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
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

-- Select fields
local fieldLabel = Instance.new("TextLabel", frame)
fieldLabel.Text = "Select Field:"
fieldLabel.Size = UDim2.new(1, 0, 0, 40)
fieldLabel.Position = UDim2.new(0, 0, 0, 240)
fieldLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fieldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fieldLabel.Font = Enum.Font.Gotham
fieldLabel.TextScaled = true
fieldLabel.TextStrokeTransparency = 0.5

local dropdown = Instance.new("TextButton", frame)
dropdown.Text = "SunflowerField"
dropdown.Size = UDim2.new(1, 0, 0, 40)
dropdown.Position = UDim2.new(0, 0, 0, 280)
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

-- Function to auto complete quests
local function autoCompleteQuests()
    while autoQuestEnabled do
        for _, quest in pairs(workspace.Quests:GetChildren()) do
            if quest:IsA("Quest") and quest:FindFirstChild("QuestGiver") then
                local questGiver = quest.QuestGiver
                if questGiver:FindFirstChild("Talk") then
                    fireclickdetector(questGiver.Talk.ClickDetector) -- Simulate talking to the quest giver
                    wait(math.random(1, 2)) -- Wait for interaction
                end
                if quest:FindFirstChild("Complete") and quest.Complete.Value then
                    fireclickdetector(quest.Complete.ClickDetector) -- Complete the quest
                    wait(math.random(1, 2)) -- Wait for completion
                end
            end
        end
        wait(5) -- Delay before checking quests again
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
            toggleFarm.Text = "Auto Farm: OFF"
            toggleTokens.Text = "Auto Collect Tokens: OFF"
            toggleQuests.Text = "Auto Quests: OFF"
        end
    end
end)

-- Start auto farm and questing in separate threads
coroutine.wrap(autoFarm)()
coroutine.wrap(collectTokens)()
coroutine.wrap(autoCompleteQuests)()
