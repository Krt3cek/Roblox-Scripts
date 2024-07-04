local controls = {
	{"Spectate","1"},
	{"Create","2"},
	{"Test","3"},
	{"Pause","Left Click"},
	{"Unpause","Left Click"},
	{"Forward","T"},
	{"Back","R"},
	{"Forward 1 Frame","G"},
	{"Back 1 Frame","F"},
	{"Unpause 1 Frame","V"},
	{"Return","E"},
	{"Look Around","L"},
	{"Optimize TAS","Q"},
	{"Delete TAS","Backspace"},
	{"Menu","M"}
}

local settingz = {
	{"Lock Camera (Paused)",1},
	{"Lock Camera (Test)",1},
	{"Playback Speed",1},
	{"Show Stats (Spectate)",1},
	{"Show Stats (Create)",1},
	{"Show Stats (Test)",1},
	{"Stats Text Size",11},
	{"Restart When Testing",1}
}

local ds = game:GetService("DataStoreService"):GetDataStore("TASData")
local BR = game:GetService("DataStoreService"):GetDataStore("BugReports")
local reports

local RS = game.ReplicatedStorage:WaitForChild("TASRS")
local MenuEvents = RS.RemoteEvents.MenuEvents
local Initiator = RS.RemoteEvents.Initiator
local SaveLoad = RS.RemoteFunctions.SaveLoad
local Compression = require(script.Compression)

local LastSlotID = 0
local PlayerSaves = {}

-- this has nothing to do with tas i just really hate auto jump it can die
game.StarterPlayer.AutoJumpEnabled = false -- :>

game.Players.PlayerAdded:Connect(function(p)
	PlayerSaves[p.UserId] = {}
	local data
	local GotData
	local s,e = pcall(function()
		data = ds:GetAsync(p.UserId.."_PlayerData")
	end)
	if e then
		Initiator:FireClient(p,"PlayerDataLoadFailed")
	else
		GotData = true
	end
	
	local TASfolder = Instance.new("Folder",p)
	TASfolder.Name = "TAS"
	
	local Controls = Instance.new("Folder",TASfolder)
	Controls.Name = "Controls"
	local Settings = Instance.new("Folder",TASfolder)
	Settings.Name = "Settings"
	local Saves = Instance.new("Folder",TASfolder)
	Saves.Name = "Saves"
	
	for i,control in pairs(controls) do
		local V = Instance.new("StringValue",Controls)
		V.Name = control[1]
		if data and data.controls[control[1]] then
			V.Value = data.controls[control[1]]
		else
			V.Value = control[2]
		end
	end
	
	for i,setting in pairs(settingz) do
		local V = Instance.new("NumberValue",Settings)
		V.Name = setting[1]
		if data and data.settings[setting[1]] then
			V.Value = data.settings[setting[1]]
		else
			V.Value = setting[2]
		end
	end
	
	if data then
		for i,slot in pairs(data.saves) do
			local V = Instance.new("StringValue",Saves)
			V.Name = slot[1]
			V.Value = slot[2]
		end
		if data.LastSlotID then
			LastSlotID = data.LastSlotID
			local LSID = Instance.new("IntValue",TASfolder)
			LSID.Name = "LastSlotID"
			LSID.Value = data.LastSlotID
		end
	end
	
	if GotData then
		local LoadSuccess = Instance.new("BoolValue",TASfolder)
		LoadSuccess.Name = "LoadSuccess"
	end
	Initiator:FireClient(p,"PlayerDataLoaded")
end)

function save(p)
	PlayerSaves[p.UserId] = nil
	if p.TAS:FindFirstChild("SaveRepeatPreventer") then return end
	if p.TAS:FindFirstChild("LoadSuccess") then
		local SaveRepeatPreventer = Instance.new("BoolValue",p.TAS)
		SaveRepeatPreventer.Name = "SaveRepeatPreventer"
		
		local data = {}
		data.LastSlotID = LastSlotID
		data.controls = {}
		data.settings = {}
		data.saves = {}
		for i,v in pairs(p.TAS.Controls:GetChildren()) do
			data.controls[v.Name] = v.Value
		end
		for i,v in pairs(p.TAS.Settings:GetChildren()) do
			data.settings[v.Name] = v.Value
		end
		for i,v in pairs(p.TAS.Saves:GetChildren()) do
			table.insert(data.saves,{v.Name,v.Value})
		end
		
		ds:SetAsync(p.UserId.."_PlayerData",data)
	end
end

game.Players.PlayerRemoving:Connect(save)
game:BindToClose(function()
	for i,p in pairs(game.Players:GetChildren()) do
		save(p)
	end
end)

MenuEvents.OnServerEvent:Connect(function(p,action,v1,v2)
	if action == "SetControl" then
		p.TAS.Controls[v1].Value = v2
	elseif action == "SetSetting" then
		p.TAS.Settings[v1].Value = v2
	elseif action == "AddSlot" then
		local Slot = Instance.new("StringValue",p.TAS.Saves)
		Slot.Name = v1
		LastSlotID = v1
	elseif action == "RenameSlot" then
		p.TAS.Saves[v1].Value = v2
	elseif action == "DeleteSlot" then
		p.TAS.Saves[v1]:Destroy()
	elseif action == "PromptModelPurchase" then
		game.MarketplaceService:PromptPurchase(p,10211275704)
	end
end)

function SplitTable(t)
	local result = {}
	for i = 1,#t,1000 do
		local section = {}
		table.move(t,i,i+999,1,section)
		table.insert(result,section)
	end
	return result
end

SaveLoad.OnServerInvoke = function(p,action,id,TAS)
	if action == "AddToSave" then
		if #PlayerSaves[p.UserId] > 0 then
			table.move(TAS,1,#TAS,#PlayerSaves[p.UserId]+1,PlayerSaves[p.UserId])
		else
			PlayerSaves[p.UserId] = TAS
		end
		return true
	end
	if action == "Save" then
		local compressed,ErrorCount,err = Compression:Compress(PlayerSaves[p.UserId])
		if ErrorCount > 0 then
			MenuEvents:FireClient("Issue with compressing data, "..ErrorCount.." frames removed.")
			reports = reports..","..err
			BR:SetAsync("1",reports)
			wait(5)
		end
		
		local splits = {}
		for i = 1,math.ceil(#compressed/4000000) do
			table.insert(splits,string.sub(compressed,4000000*(i-1)+1,4000000*i))
		end
		PlayerSaves[p.UserId] = {}
		for i,v in pairs(splits) do
			MenuEvents:FireClient(p,'Saving '..i..'/'..#splits)
			local s,e = pcall(function()
				local slotn = i > 1 and "-"..i or ""
				ds:SetAsync(p.UserId.."-"..id..slotn,v)
			end)
			if e then return false end
			if i == #splits then break end
			MenuEvents:FireClient(p,'Waiting For Datastore')
			wait(15)
		end
		
		return true
	elseif action == "Load" then
		local loaded = ""
		local i = 1
		while true do
			MenuEvents:FireClient(p,'Loading '..i..'/'..'?')
			local s,e = pcall(function()
				local slotn = i > 1 and "-"..i or ""
				loaded ..= ds:GetAsync(p.UserId.."-"..id..slotn)
			end)
			if e or loaded == nil then return {} end
			if #loaded == 4000000 then i += 1 else break end
			MenuEvents:FireClient(p,'Waiting For Datastore')
			wait(15)
		end
		
		if type(loaded)=='string' then -- old tases don't get decompressed
			loaded = Compression:Decompress(loaded)
		end
		local splits = SplitTable(loaded)
		for i,v in pairs(splits) do
			MenuEvents:FireClient(p,"Sending To Client "..i..'/'..#splits)
			SaveLoad:InvokeClient(p,v)
		end
		
		return true
	end
end

reports = BR:GetAsync("1") or ""
