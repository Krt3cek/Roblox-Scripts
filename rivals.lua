local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

ESP.Enabled = false;
ESP.ShowBox = false;
ESP.ShowName = false;
ESP.ShowHealth = false;
ESP.ShowTracer = false;
ESP.ShowDistance = false;
ESP.ShowSkeletons = false;

local ESP_SETTINGS = {
    BoxOutlineColor = Color3.new(1, 1, 1),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    CharSize = Vector2.new(4, 6),
    Teamcheck = false,
    WallCheck = false,
    Enabled = false,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowSkeletons = false,
    ShowTracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    SkeletonsColor = Color3.new(1, 1, 1),
    TracerPosition = "Bottom",
}

loadstring(game:HttpGet(("https://raw.githubusercontent.com/REDzHUB/LibraryV2/main/redzLib")))()
MakeWindow({
    Hub = {
        Title = "Krt Hub",
        Animation = "by Krtecek"
    },
    Key = {
        KeySystem = false,
        Title = "Key System",
        Description = "",
        KeyLink = "",
        Keys = {"1234"},
        Notifi = {
            Notifications = true,
            CorrectKey = "Running the Script...",
            Incorrectkey = "The key is incorrect",
            CopyKeyLink = "Copied to Clipboard"
        }
    }
})

MinimizeButton({
    Image = "",
    Size = {40, 40},
    Color = Color3.fromRGB(10, 10, 10),
    Corner = true,
    Stroke = false,
    StrokeColor = Color3.fromRGB(255, 0, 0)
})

local Main = MakeTab({Name = "Main"})

-- ESP Toggles
local Toggle = AddToggle(Main, {
    Name = "Enabled",
    Default = false,
    Callback = function(Value)
        ESP.Enabled = Value;
    end
})

-- Add Aimbot Toggles
local ToggleAimbot = AddToggle(Main, {
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        Aimbot.Enabled = Value
    end
})

-- FOV Setting
local SliderFOV = AddSlider(Main, {
    Name = "Aimbot FOV",
    Min = 10,
    Max = 300,
    Default = 100,
    Callback = function(Value)
        Aimbot.FOV = Value
    end
})

-- Smoothness Setting
local SliderSmooth = AddSlider(Main, {
    Name = "Aimbot Smoothness",
    Min = 1,
    Max = 100,
    Default = 10,
    Callback = function(Value)
        Aimbot.Smoothness = Value
    end
})

-- Triggerbot Toggle
local ToggleTriggerbot = AddToggle(Main, {
    Name = "Triggerbot",
    Default = false,
    Callback = function(Value)
        Triggerbot.Enabled = Value
    end
})

-- Define Aimbot and Triggerbot functionality
local Aimbot = {
    Enabled = false,
    FOV = 100,
    Smoothness = 10,
}

local Triggerbot = {
    Enabled = false,
}

-- Main loop
game:GetService("RunService").RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local closestPlayer = nil
        local closestDistance = Aimbot.FOV
        
        -- Loop through players to find closest target
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenPos = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)).magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        
        -- Aim at the closest player
        if closestPlayer then
            local targetPos = closestPlayer.Character.HumanoidRootPart.Position
            local mouse = game.Players.LocalPlayer:GetMouse()
            local angle = (targetPos - workspace.CurrentCamera.CFrame.Position).unit
            local newCFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)

            -- Smooth aiming
            local currentCFrame = workspace.CurrentCamera.CFrame
            workspace.CurrentCamera.CFrame = CFrame.new(currentCFrame.Position, newCFrame.Position) * CFrame.Angles(0, math.rad(Aimbot.Smoothness), 0)
            mouse1click()  -- Simulate mouse click if triggerbot is enabled
        end
    end

    if Triggerbot.Enabled then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local target = mouse.Target
        
        -- Check if target is a player and fire
        if target and target:IsA("Model") and game.Players:GetPlayerFromCharacter(target) then
            mouse1click()
        end
    end
end)

-- Additional ESP Toggles
local ToggleName = AddToggle(Main, {
    Name = "Name",
    Default = false,
    Callback = function(Value)
        ESP.ShowName = Value;
    end
})

local ToggleBox = AddToggle(Main, {
    Name = "Box",
    Default = false,
    Callback = function(Value)
        ESP.ShowBox = Value;
    end
})

local ToggleTracer = AddToggle(Main, {
    Name = "Tracer",
    Default = false,
    Callback = function(Value)
        ESP.ShowTracer = Value;
    end
})

local ToggleHealth = AddToggle(Main, {
    Name = "Health",
    Default = false,
    Callback = function(Value)
        ESP.ShowHealth = Value;
    end
})

local ToggleSkeletons = AddToggle(Main, {
    Name = "Skeletons",
    Default = false,
    Callback = function(Value)
        ESP.ShowSkeletons = Value;
    end
})

local ToggleDistance = AddToggle(Main, {
    Name = "Distance",
    Default = false,
    Callback = function(Value)
        ESP.ShowDistance = Value;
    end
})

local ToggleTeamCheck = AddToggle(Main, {
    Name = "Team check",
    Default = false,
    Callback = function(Value)
        ESP.Teamcheck = Value;    
    end
})

local ToggleWallCheck = AddToggle(Main, {
    Name = "Wall check",
    Default = false,
    Callback = function(Value)
        ESP.WallCheck = Value;
    end
})

local DropdownTracer = AddDropdown(Main, {
    Name = "Tracer",
    Options = {"Bottom", "Top", "Middle"},
    Default = "Top",
    Callback = function(Value)
        ESP.TracerPosition = Value;
    end
})

local DropdownBox = AddDropdown(Main, {
    Name = "Box",
    Options = {"2D", "Corner Box Esp"},
    Default = "2D",
    Callback = function(Value)
        ESP.BoxType = Value
    end
})
