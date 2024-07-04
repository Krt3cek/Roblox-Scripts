local Running = false
local Frames = {}
local TimeStart = tick()
local CanFrame = false
local CurrentFrameIndex = 1
local Playing = false

local Player = game:GetService("Players").LocalPlayer
local getChar = function()
    local Character = Player.Character
    if Character then
        return Character
    else
        Player.CharacterAdded:Wait()
        return getChar()
    end
end

local StartRecord = function()
    Frames = {}
    Running = true
    TimeStart = tick()
    while Running do
        game:GetService("RunService").Heartbeat:Wait()
        local Character = getChar()
        table.insert(Frames, {
            Character.HumanoidRootPart.CFrame,
            Character.Humanoid:GetState().Value,
            tick() - TimeStart
        })
    end
end

local StopRecord = function()
    Running = false
    CanFrame = false
end

local PlayTAS = function()
    local Character = getChar()
    local TimePlay = tick()
    local FrameCount = #Frames
    local OldFrame = 1
    Playing = true
    local TASLoop
    TASLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if Playing then
            local CurrentTime = tick()
            if CurrentTime - TimePlay >= Frames[FrameCount][3] then
                Playing = false
                TASLoop:Disconnect()
                return
            end
            
            -- Move through frames based on CurrentFrameIndex
            local Frame = Frames[CurrentFrameIndex]
            if Frame and Frame[3] <= CurrentTime - TimePlay then
                Character.HumanoidRootPart.CFrame = Frame[1]
                Character.Humanoid:ChangeState(Frame[2])
                CurrentFrameIndex = CurrentFrameIndex + 1
            end
        end
    end)
end

local FrameFor = function()
    if Playing then
        return
    end
    
    CurrentFrameIndex = CurrentFrameIndex + 1
    if CurrentFrameIndex > #Frames then
        CurrentFrameIndex = #Frames
    end
    
    local Character = getChar()
    local Frame = Frames[CurrentFrameIndex]
    if Frame then
        Character.HumanoidRootPart.CFrame = Frame[1]
        Character.Humanoid:ChangeState(Frame[2])
    end
end

local FrameBack = function()
    if Playing then
        return
    end
    
    CurrentFrameIndex = CurrentFrameIndex - 1
    if CurrentFrameIndex < 1 then
        CurrentFrameIndex = 1
    end
    
    local Character = getChar()
    local Frame = Frames[CurrentFrameIndex]
    if Frame then
        Character.HumanoidRootPart.CFrame = Frame[1]
        Character.Humanoid:ChangeState(Frame[2])
    end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Jsem deny",LoadingTitle = "\"its not working pls fix\"",LoadingSubtitle = "by krtek.txt",
   ConfigurationSaving = {Enabled = true,FolderName="krtek.txt",FileName="TASRoblox by krtek.txt"},
   Discord = {Enabled = true,Invite="7XT74GwVnj",RememberJoins=true},KeySystem = false,KeySettings = {Title="",Subtitle="",Note="",FileName="",SaveKey=true,GrabKeyFromSite=false,Key={""}}
})
local Tab = Window:CreateTab("Control", 4483362458)
local Section = Tab:CreateSection("Save")
local Button = Tab:CreateButton({
   Name = "Start recording",
   Callback = StartRecord,
})
local Button = Tab:CreateButton({
   Name = "Stop recording.",
   Callback = StopRecord,
})

local Button = Tab:CreateButton({
   Name = "Play",
   Callback = PlayTAS,
})


local Keybind = Tab:CreateKeybind({
   Name = "Start Recording BIND",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "StartRecord",
   Callback = StartRecord,
})

local Keybind = Tab:CreateKeybind({
   Name = "Stop Recording BIND",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "StopRecord",
   Callback = StopRecord,
})

local Keybind = Tab:CreateKeybind({
   Name = "Play BIND",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "PlayTAS",
   Callback = PlayTAS,
})

local Keybind = Tab:CreateKeybind({
   Name = "1 Frame forward",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "FrameFor",
   Callback = FrameFor,
})

local Keybind = Tab:CreateKeybind({
   Name = "1 Frame backwards",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "FrameBack",
   Callback = FrameBack,
})
