-- LocalScript

local player = game.Players.LocalPlayer
local players = game:GetService("Players")
local RunService = game:GetService("RunService")

local espEnabled = true -- Set to true to enable ESP
local borderSize = 0.5 -- Size of the border
local borderColor = Color3.fromRGB(255, 0, 0) -- Color of the border
local borderTransparency = 0.5 -- Transparency of the border

-- Function to create a glowing border for a target player's character
local function createESP(targetPlayer)
    local character = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    local espPart = Instance.new("Part")
    
    espPart.Size = Vector3.new(4, 6, 4) -- Size of the border part
    espPart.Anchored = true
    espPart.CanCollide = false
    espPart.Material = Enum.Material.Neon
    espPart.Color = borderColor
    espPart.Transparency = borderTransparency
    espPart.Parent = workspace

    -- Function to update the position of the ESP part
    local function updateESP()
        if character and character:FindFirstChild("HumanoidRootPart") then
            espPart.Position = character.HumanoidRootPart.Position
        else
            espPart:Destroy() -- Destroy if the character is not found
        end
    end

    -- Connect the update function to the RenderStepped event
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if espEnabled then
            updateESP()
        else
            espPart:Destroy() -- Remove the ESP part if not enabled
            connection:Disconnect() -- Disconnect the event
        end
    end)

    -- Cleanup when the target player leaves
    targetPlayer.CharacterRemoving:Connect(function()
        espPart:Destroy()
        connection:Disconnect()
    end)
end

-- Function to enable ESP for all other players
local function enableESP()
    for _, targetPlayer in pairs(players:GetPlayers()) do
        if targetPlayer ~= player then
            targetPlayer.CharacterAdded:Connect(function()
                createESP(targetPlayer)
            end)

            -- Create ESP if the character already exists
            if targetPlayer.Character then
                createESP(targetPlayer)
            end
        end
    end
end

-- Connect to player added event
players.PlayerAdded:Connect(function(targetPlayer)
    targetPlayer.CharacterAdded:Wait()
    createESP(targetPlayer)
end)

-- Connect to player removing event
players.PlayerRemoving:Connect(function(targetPlayer)
    if targetPlayer ~= player then
        local espPart = workspace:FindFirstChild(targetPlayer.Name)
        if espPart then
            espPart:Destroy()
        end
    end
end)

-- Start by enabling ESP for existing players
enableESP()

-- Loop to continuously check the status of ESP
while true do
    wait(1) -- Update every second
end
