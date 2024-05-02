
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)

if game.PlaceId == 16474126979 then
	
	repeat task.wait() until game.ReplicatedStorage.packages:FindFirstChild("assets")
	repeat task.wait() until game.ReplicatedStorage.packages:FindFirstChild("StarterGui")
end
if getgenv().JungHubExecuted then return end
getgenv().JungHubExecuted = true

-- SERVICES
local HttpService = game:GetService('HttpService')
local UIS = game:GetService('UserInputService')
local RunS = game:GetService('RunService')
local RS = game:GetService('ReplicatedStorage')
local TS = game:GetService('TweenService')
local PS = game:GetService('PhysicsService')

-- VARIABLES

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()


local Remotes = RS:WaitForChild('endpoints')
local Event = game:GetService("ReplicatedStorage").endpoints["client_to_server"]



-- SAVED STATS

local DifferentColorsPoints = {Color3.fromRGB(1, 81, 255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255)}
MacroUnitsTextBlocks = {}
local RecordingMacro = false
local FPS = 0
local StartTime = os.time()
local IsLobby = workspace:FindFirstChild('_MAP_CONFIG') if IsLobby and IsLobby:FindFirstChild('IsLobby') then IsLobby = IsLobby.IsLobby.Value end
local _DATA = workspace:FindFirstChild('_DATA')
local GameFinished
if _DATA then GameFinished = _DATA:FindFirstChild('GameFinished') end
local ResultUI = player.PlayerGui['ResultsUI']



--------------- Files
makefolder("Jung Hub")
makefolder('Jung Hub\\Anime Fantasy')


local DefaultFiles = {

	['Jung Hub\\Settings_' .. player.Name] = {

		['Ignored Capsules'] = {};
		['Delete Skins'] = {};

		['Selected Portal Difficulties Delete'] = {};
		['Selected Tiers Delete'] = {};
		['Selected Portals Delete'] = {};
		['Ignore Worlds Delete'] = {};
		['Ignore Bonus Delete'] = {};

		['PortalUSE Portals'] = {};
		['PortalUSE Tiers'] = {};
		['PortalUSE Difficulties Ignore'] = {};
		['PortalUSE Worlds Ignore'] = {};
		['PortalUSE Bonus Ignore'] = {};
		['PortalUSE Start After Time'] = 1;
		['PortalUSE Star After Players'] = 1;

		['Challenge_IgnoreWorlds'] = {};
		['Challenge_IgnoreDifficulties'] = {};
		['Challenge_IgnoreRewards'] = {};

		['AutoPlacePositions'] = {};
		['AutoPlacesCap'] = {['1'] = 4, ['2'] = 4, ['3'] = 4, ['4'] = 4, ['5'] = 4, ['6'] = 4};
		['AutoUpgradesCap'] = {['1'] = 10, ['2'] = 10, ['3'] = 10, ['4'] = 10, ['5'] = 10, ['6'] = 10};

		['Discord Url'] = '';
		['Discord UserID'] = '';

		['StoryInf_World'] = '';
		['StoryInf_Level'] = '';

		['AutoJoinCastleMaxRoom'] = 500;
		['AutoLeaveOnWave'] = 1;
		['AutoSkillWave'] = 1;
		['AutoSkillUnits'] = {};
		['AutoSellUnitsWave'] = 1;
		['FPS_LIMIT'] = 60;
		['AutoSellFarmsWave'] = 1;
		['AutoPlaceUnitsWave'] = 1;
		['AutoUpgradeWave'] = 1;
		['Selected Macro'] = '';
		['Step Delay'] = 0.4;
		['Hide Key'] = 'U';

		['Selected Macro Map'] = {Tower = {}, Main = {}, Raid = {}, Portal = {}, Other = {}}

	};




}

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

RunS.RenderStepped:Connect(function()
	FPS += 1
end)

for name, value in pairs(DefaultFiles) do -- SET DEFAULT VALUES
	if not pcall(function() readfile(name) end) then writefile(name, HttpService:JSONEncode(value)) end 
end

local Settings = HttpService:JSONDecode(readfile('Jung Hub\\Settings_' .. player.Name)) 

local function Save (valueName, newValue)
	Settings[valueName] = newValue
	writefile('Jung Hub\\Settings_' .. player.Name, HttpService:JSONEncode(Settings))
end

local function GetSave (valueName)
	local value = Settings[valueName]
	if value == nil then
		if DefaultFiles['Jung Hub\\Settings_' .. player.Name][valueName] ~= nil then
			Save(valueName, DefaultFiles['Jung Hub\\Settings_' .. player.Name][valueName])
		else
			Save(valueName, false)
		end

		value = Settings[valueName]
	end

	if type(value) == 'table' then value = deepcopy(value) end

	return value
end



---------------------------------------------------------

local RefreshedUniqueItems = {}
local RefreshedNormalItems = {}
local Loader = require(RS.src.Loader)
local ItemInventoryServiceClient = Loader.load_client_service(script, "ItemInventoryServiceClient")
local battlePassID = ""

function get_inventory_items_unique_items()
	return ItemInventoryServiceClient["session"]['inventory']['inventory_profile_data']['unique_items']
end

function get_inventory_items()
	return ItemInventoryServiceClient["session"]["inventory"]['inventory_profile_data']['normal_items']
end

function get_Units_Owner()
	return ItemInventoryServiceClient["session"]["collection"]["collection_profile_data"]['owned_units']
end

bpOpenTime = 0
for _, BattlePassModule in ipairs(RS.src.Data.BattlePass:GetChildren()) do
	if not BattlePassModule:IsA('ModuleScript') then continue end
	local bpModule = require(BattlePassModule)

	for bpID,aboutBP in pairs(bpModule) do
		if not aboutBP.tiers then continue end

		if not aboutBP.tiers['26'] or not aboutBP.tiers['26']._unlock_time then continue end
		if aboutBP.tiers['26']._unlock_time < bpOpenTime then continue end
		battlePassID = bpID
		bpOpenTime = aboutBP.tiers['26']._unlock_time
	end

end

task.spawn(function()

	while true do
		RefreshedUniqueItems = get_inventory_items_unique_items()
		RefreshedNormalItems = get_inventory_items()
		task.wait(0.1)
	end

end)

local function getEquippedUnits ()
	local newUnitsEquipped = {}
	for _, unitInfo in pairs(get_Units_Owner()) do
		if not unitInfo['equipped_slot'] then continue end
		newUnitsEquipped[unitInfo['uuid']] = {id = unitInfo['unit_id'], equipped_slot = unitInfo['equipped_slot'] }
	end

	return newUnitsEquipped
end
local EquippedUnits = getEquippedUnits()
local EquippedUnitsAbout = {}


for uuid, aboutSlot in pairs(EquippedUnits) do

	for _, moduleScript in ipairs(RS.src.Data.Units:GetDescendants()) do
		if not moduleScript:IsA('ModuleScript') then continue end

		for unitID, unitTable in pairs(require(moduleScript)) do
			if unitID ~= aboutSlot.id then continue end

			EquippedUnitsAbout[ tostring(aboutSlot.equipped_slot) ] = { 

				id = unitID,
				uuid = uuid,
				upgrades = unitTable['upgrade'],
				cost = unitTable['cost'],
				hill = unitTable['hill_unit'],
				spawn_cap = unitTable['spawn_cap'] or 5,
				unsellable = unitTable['unsellable'],
				global_spawn_cap = unitTable['global_spawn_cap']


			}

		end

	end

end



function getLevelData()

	return game.Workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer()

end

local LevelData = nil
if not game.Workspace._MAP_CONFIG:WaitForChild('IsLobby').Value then LevelData = getLevelData() end

function StringToCFrame(String)
	local Split = string.split(String, ",")
	return CFrame.new(Split[1],Split[2],Split[3],Split[4],Split[5],Split[6],Split[7],Split[8],Split[9],Split[10],Split[11],Split[12])
end

local function TPLobby ()
	game:GetService('TeleportService'):Teleport(16474126979, player)
end

function makeComma(p1)
	local value = p1;
	while true do
		local value2, value3 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2");
		value = value2;
		if value3 ~= 0 then else
			break;
		end;
	end;
	return value;
end

local function math_round( roundIn , roundDig )
	local mul = math.pow( 10, roundDig )
	return ( math.floor( ( roundIn * mul ) + 0.5 )/mul )
end

local vu = game:GetService("VirtualUser")
player.Idled:connect(function()
	vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	wait(1)
	vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local function getItemsData ()
	local newItemsData = {}
	local DataModules = RS.src.Data.Items:GetDescendants()
	table.insert(DataModules, RS.src.Data.Units)

	for _, itemDataModule in ipairs(DataModules) do
		if not itemDataModule:IsA('ModuleScript') then continue end

		for itemID, ItemTable in pairs( require(itemDataModule) ) do
			newItemsData[itemID] = {
				Rarity = ItemTable.rarity,
				Name = ItemTable.name,
				Amount = 0
			}
		end
	end


	for itemId, amount in pairs(get_inventory_items()) do
		newItemsData[itemId]['Amount'] = amount
	end

	for _, itemTable in pairs(get_inventory_items_unique_items()) do
		newItemsData[ itemTable.item_id ]['Amount'] = newItemsData[ itemTable.item_id ]['Amount'] + 1
	end

	for _, unitTable in pairs(get_Units_Owner()) do
		newItemsData[ unitTable.unit_id ]['Amount'] = newItemsData[ unitTable.unit_id ]['Amount'] + 1
	end


	return newItemsData
end
local oldItemsData = getItemsData()

local _Maps_DATA = {}

for _, mapData in ipairs(RS.src.Data.Maps:GetDescendants()) do
	if not mapData:IsA('ModuleScript') then continue end
	for mapId, mapTable in pairs( require(mapData) ) do
		_Maps_DATA[mapTable.id] = mapTable.name
	end
end


local macroMapList = {

	['Main'] = {
		'Fabled Kingdom',
		'Planet Namak',
		'Shiganshinu District',
		'Windhym',
		'Hollow World',
		'Clover Kingdom',
		'Magic Town',
		'Ant Kingdom',
		'Cursed Academy',
		'Cape Canaveral',
		"Marine's Ford",
		'Hero City',
		'Hidden Sand Village',
		'Alien Spaceship',
		'Snowy Town',
		'Virtual Dungeon',
		'Ghoul City',
		'Puppet Island',
		'Undead Tomb'
	};

	['Tower'] = {'Thriller Park', 'Entertainment District', 'Karakora Town', 'Storm Hideout', 'Infinity Train',};

	['Raid'] = {
		'Fabled Kingdom (Commandments)',
		'Karakora Town',
		'Entertainment District',
		'Clover Kingdom (Elf Invasion)',
		'Cape Canaveral',
		'Hero City (Midnight)',
		'Infinity Train',
		'Virtual Dungeon (Bosses)',
		'Storm Hideout',
		'Storm Hideout (Final)',
		'West City',
		'Bizzare Town',
		'Hidden Sand Village',
		'Shiganshinu District',
		'Undead Tomb'

	};

	['Portal'] = {
		'Puppet Island (Summer)',
		'Shiganshinu District (Summer)',
		'Fabled Kingdom (Summer)',
		'Alien Spaceship (Underwater)',
		'Planet Namak (Summer)',
		'Ant Kingdom (Summer)',
		'Cursed Academy (Summer)',
		'Fabled Kingdom (Cube)',
		'The Eclipse',
		'Alien Spaceship (Final)',
		'Puppet Island (Birdcage)'
	};

	['Other'] = {
		'Cursed Womb'
	}
}

for _, mapName in ipairs(macroMapList.Main) do
	table.insert(macroMapList.Tower, mapName)
end

---------------------------------------------------------
local function MakeUICorner (scale, newParent)

	local newCorner = Instance.new('UICorner')
	newCorner.CornerRadius = UDim.new(scale, 0)
	newCorner.Parent = newParent

end

local function MakeUIPadding (bottom, left, right, top, newParent)

	local newPadding = Instance.new('UIPadding')
	newPadding.PaddingBottom = UDim.new(bottom, 0)
	newPadding.PaddingLeft = UDim.new(left, 0)
	newPadding.PaddingRight = UDim.new(right, 0)
	newPadding.PaddingTop = UDim.new(top, 0)
	newPadding.Parent = newParent

end

local function makeUIList (padding, newParent, VA)
	local va = VA or Enum.VerticalAlignment.Top

	local newUIList = Instance.new('UIListLayout')
	newUIList.Padding = UDim.new(padding, 0)
	newUIList.FillDirection = Enum.FillDirection.Vertical
	newUIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	newUIList.VerticalAlignment = va
	newUIList.SortOrder = Enum.SortOrder.LayoutOrder
	newUIList.Parent = newParent

end

---------------------------------------------------------

PGUI = game.Players.LocalPlayer:WaitForChild('PlayerGui')

-- MAKING GUI
ScreenGui = Instance.new('ScreenGui', game.CoreGui)
ScreenGui.Name = 'Jung Hub'
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Enabled = true


MainFrame = Instance.new('Frame', ScreenGui)
MainFrame.BackgroundTransparency = 1
MainFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
MainFrame.Size = UDim2.new(0.525, 0, 0.525, 0)
MainFrame.Position = UDim2.new(0.614, 0, 0.284, 0)
MainFrame.Name = 'MainFrame'

MainContent = Instance.new('Frame', MainFrame)
MainContent.BackgroundColor3 = Color3.fromRGB(73, 73, 99)
MainContent.Size = UDim2.new(1, 0, 1, 0)
MakeUICorner(0.01, MainContent)

lowerTop = Instance.new('Frame', MainContent)
lowerTop.AnchorPoint = Vector2.new(0.5, 1)
lowerTop.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
lowerTop.Size = UDim2.new(1, 0, 0.019, 0)
lowerTop.Position = UDim2.new(0.5, 0, 0.038, 0)	
lowerTop.BorderSizePixel = 0

ShadowMainContent = Instance.new('Frame', MainContent)
ShadowMainContent.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
ShadowMainContent.AnchorPoint = Vector2.new(0.5, 0.5)
ShadowMainContent.Size = UDim2.new(1.02, 0, 1.02, 0)
ShadowMainContent.Position = UDim2.new(0.5, 0, 0.5, 0)
ShadowMainContent.ZIndex = -1
MakeUICorner(0.015, ShadowMainContent)

additionalFrame = Instance.new('Frame', ScreenGui) additionalFrame.Name = 'Additional'
additionalFrame.BackgroundColor3 = Color3.fromRGB(73,73,99) 
additionalFrame.Position = UDim2.new(0.15, 0, 0.005, 0)
additionalFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
additionalFrame.Size = UDim2.new(0.195, 0, 0.062, 0)
additionalFrame.ZIndex = 1000001
MakeUICorner(0.07, additionalFrame)

additionalFrameShadow = Instance.new('Frame', additionalFrame)
additionalFrameShadow.BackgroundColor3 = Color3.fromRGB(26,26,26)
additionalFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
additionalFrameShadow.Size = UDim2.new(1.05, 0, 1.1, 0)
additionalFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
additionalFrameShadow.ZIndex = 1000000
MakeUICorner(0.07, additionalFrameShadow)

additionalFrameInner = Instance.new('Frame', additionalFrame)
additionalFrameInner.BackgroundTransparency = 1
additionalFrameInner.Size = UDim2.new(1,0,1,0)
makeUIList(0.02, additionalFrameInner, Enum.VerticalAlignment.Center)

TimerLabel = Instance.new('TextLabel', additionalFrameInner)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Size = UDim2.new(0.95, 0, 0.3, 0)
TimerLabel.ZIndex = 1000002
TimerLabel.Font = Enum.Font.GothamBlack
TimerLabel.TextColor3 = Color3.fromRGB(255,255,255)
TimerLabel.TextScaled = true
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerLabel.Text = "Timer: 00:00:00"

FPSLabel = Instance.new('TextLabel', additionalFrameInner)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Size = UDim2.new(0.95, 0, 0.3, 0)
FPSLabel.ZIndex = 1000002
FPSLabel.Font = Enum.Font.GothamBlack
FPSLabel.TextColor3 = Color3.fromRGB(255,255,255)
FPSLabel.TextScaled = true
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Text = "FPS: 0"

DiscordLabel = Instance.new('TextLabel', additionalFrameInner)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Size = UDim2.new(0.95, 0, 0.3, 0)
DiscordLabel.ZIndex = 1000002
DiscordLabel.Font = Enum.Font.GothamBlack
DiscordLabel.TextColor3 = Color3.fromRGB(255,255,255)
DiscordLabel.TextScaled = true
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.Text = "Discord: zMc8bTmQXh"

task.spawn(function()
	while true do
		TimerLabel.Text = string.format("Timer: %02s:%02s:%02s", math.floor((os.time() - StartTime) / 3600), math.floor((os.time() - StartTime)%3600/60), (os.time() - StartTime) % 60 )
		FPSLabel.Text = string.format("FPS: %s", FPS) FPS = 0
		task.wait(1)
	end
end)

Top = Instance.new('Frame', MainFrame)
Top.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Top.AnchorPoint = Vector2.new(1, 0.5)
Top.Size = UDim2.new(1, 0, 0.048, 0)
Top.Position = UDim2.new(1, 0, 0.014, 0)
Top.ZIndex = 10000
MakeUICorner(0.2, Top)

CloseButton = Instance.new('TextButton', Top)
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.Size = UDim2.new(0.065, 0, 0.694, 0)
CloseButton.Position = UDim2.new(0.984, 0, 0.5, 0)
CloseButton.ZIndex = 10001
CloseButton.Font = Enum.Font.GothamBlack
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.TextScaled = true
CloseButton.Text = '-'
MakeUICorner(0.3, CloseButton)


HubTitle = Instance.new('TextLabel', Top)
HubTitle.BackgroundTransparency = 1
HubTitle.AnchorPoint = Vector2.new(0.5, 0.5)
HubTitle.Size = UDim2.new(0.85, 0, 0.8, 0)
HubTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
HubTitle.ZIndex = 10001
HubTitle.Font = Enum.Font.GothamBlack
HubTitle.TextColor3 = Color3.fromRGB(255,255,255)
HubTitle.TextScaled = true
HubTitle.Text = 'Jung Hub - BETA'


TopBarSizes = {
	[false] = UDim2.new(0.5, 0,0.048, 0),
	[true] = UDim2.new(1,0,0.048,0)
}
closeButtonSizes = {
	[false] = UDim2.new(0.13, 0, 0.694, 0),
	[true] = UDim2.new(0.065, 0, 0.694, 0)
}

HubTitlePoses = {
	[false] = UDim2.new(0.45, 0, 0.5, 0),
	[true] = UDim2.new(0.5, 0, 0.5, 0)
}


CloseButton.MouseButton1Click:Connect(function() 
	MainContent.Visible = not MainContent.Visible 

	HubTitle.Position = HubTitlePoses[MainContent.Visible]
	CloseButton.Size = closeButtonSizes[MainContent.Visible]
	Top.Size = TopBarSizes[MainContent.Visible]

end)


local function MakeDraggable (dragGui, dragwith)

	local dragging
	local dragInput
	local dragStart
	local startPos
	local function updateDrag(input)
		local delta = input.Position - dragStart
		local dragTime = 0.04
		local SmoothDrag = {}
		SmoothDrag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		local dragSmoothFunction = TS:Create(dragwith, TweenInfo.new(dragTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), SmoothDrag)
		dragSmoothFunction:Play()
	end

	dragGui.InputBegan:Connect(function(input)
		local usedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		local usedTouch = input.UserInputType == Enum.UserInputType.Touch

		if usedMouse or usedTouch then
			dragging = true
			dragStart = input.Position
			startPos = dragwith.Position
			local release

			release = UIS.InputEnded:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				dragging = false
				release:Disconnect()

			end)



		end
	end)
	dragGui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateDrag(input)
		end
	end)

end
MakeDraggable(additionalFrame, additionalFrame)
MakeDraggable(Top, MainFrame)

Pages = Instance.new('ScrollingFrame', MainContent)
Pages.BackgroundColor3 = Color3.fromRGB(94, 94, 127)
Pages.Size = UDim2.new(1, 0, 0.047, 0)
Pages.Position = UDim2.new(0, 0, 0.038, 0)
Pages.AutomaticCanvasSize = 'Y'
Pages.CanvasSize = UDim2.new(0, 0, 0, 0)
Pages.ScrollBarThickness = 0
Pages.ScrollingDirection = Enum.ScrollingDirection.X
Pages.BorderSizePixel = 0
Pages.ZIndex = 9500

ListPages = Instance.new('UIListLayout', Pages)
ListPages.FillDirection = Enum.FillDirection.Horizontal
ListPages.HorizontalAlignment = Enum.HorizontalAlignment.Left
ListPages.VerticalAlignment = Enum.VerticalAlignment.Center
ListPages.SortOrder = Enum.SortOrder.LayoutOrder

ScrollingContent = Instance.new('ScrollingFrame', MainContent)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.Size = UDim2.new(1, 0, 0.916, 0)
ScrollingContent.Position = UDim2.new(0, 0, 0.084, 0)
ScrollingContent.AutomaticCanvasSize = 'Y'
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContent.ScrollBarThickness = 4
ScrollingContent.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingContent.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollingContent.BorderSizePixel = 0

newPageButtonBCInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

pageOrder = 1
pageShown = nil
local function MakeNewPage (pageName, pageButtonX)

	local newPageButton = Instance.new('TextButton', Pages)
	newPageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	newPageButton.Name = pageName
	newPageButton.BackgroundTransparency = 1
	newPageButton.Size = UDim2.new(pageButtonX, 0, 1, 0)
	newPageButton.Text = ''
	newPageButton.LayoutOrder = pageOrder pageOrder+=1
	newPageButton.BorderSizePixel = 0
	newPageButton.ZIndex = 9850

	local newPageButtonTitle = Instance.new('TextLabel', newPageButton)
	newPageButtonTitle.AnchorPoint = Vector2.new(0.5, 0.5)
	newPageButtonTitle.BackgroundTransparency = 1
	newPageButtonTitle.Size = UDim2.new(1, 0, 0.8, 0)
	newPageButtonTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
	newPageButtonTitle.Font = Enum.Font.GothamBlack
	newPageButtonTitle.TextScaled = true
	newPageButtonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	newPageButtonTitle.Text = string.upper(pageName)
	newPageButtonTitle.ZIndex = 9875

	local newPageButtonBottomLine = Instance.new('Frame', newPageButton)
	newPageButtonBottomLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	newPageButtonBottomLine.Name = 'BottomLine'
	newPageButtonBottomLine.AnchorPoint = Vector2.new(0, 1)
	newPageButtonBottomLine.Size = UDim2.new(1, 0, 0.05, 0)
	newPageButtonBottomLine.Position = UDim2.new(0, 0, 1, 0)
	newPageButtonBottomLine.Visible = false
	newPageButtonBottomLine.BorderSizePixel = 0
	newPageButtonBottomLine.ZIndex = 9800

	local newPage = Instance.new('Frame', ScrollingContent)
	newPage.Name = pageName
	newPage.BackgroundTransparency = 1
	newPage.Size = UDim2.new(1, 0, 1, 0)
	newPage.Visible = false

	local LeftPage = Instance.new('Frame', newPage)
	LeftPage.Name = 'Left'
	LeftPage.BackgroundTransparency = 1
	LeftPage.Size = UDim2.new(0.5, 0, 1, 0)
	makeUIList(0.02, LeftPage)
	MakeUIPadding(0.01, 0, 0, 0.01, LeftPage)

	local RightPage = Instance.new('Frame', newPage)
	RightPage.Name = 'Right'
	RightPage.BackgroundTransparency = 1
	RightPage.AnchorPoint = Vector2.new(1, 0)
	RightPage.Position = UDim2.new(1, 0, 0, 0)
	RightPage.Size = UDim2.new(0.5, 0, 1, 0)
	makeUIList(0.02, RightPage)
	MakeUIPadding(0.01, 0, 0, 0.01, RightPage)

	local PlaceHolder = Instance.new('Frame', RightPage)
	PlaceHolder.BackgroundTransparency = 1
	PlaceHolder.Size = UDim2.new(0, 0, 0.4, 0)
	PlaceHolder.LayoutOrder = 999999

	local PlaceHolder = Instance.new('Frame', LeftPage)
	PlaceHolder.BackgroundTransparency = 1
	PlaceHolder.Size = UDim2.new(0, 0, 0.4, 0)
	PlaceHolder.LayoutOrder = 999999

	newPageButton.MouseEnter:Connect(function()
		local TweenButton = TS:Create(newPageButton, newPageButtonBCInfo, {BackgroundTransparency = 0.9})
		TweenButton:Play()
	end)

	newPageButton.MouseLeave:Connect(function()
		local TweenButton = TS:Create(newPageButton, newPageButtonBCInfo, {BackgroundTransparency = 1})
		TweenButton:Play()
	end)

	newPageButton.MouseButton1Click:Connect(function()
		if pageShown == newPage then return end
		pageShown.Visible = false
		Pages[pageShown.Name].BottomLine.Visible = false

		pageShown = newPage
		newPageButtonBottomLine.Visible = true
		newPage.Visible = true


	end)

	return newPage
end

local Orders = {}
local function MakeNewSubPage (pageName, side, scaleY, cornerScale, UIPaddingTop, UIListLayout)

	local page = ScrollingContent[pageName][side]

	local newSubPage = Instance.new('Frame', page)
	newSubPage.BackgroundColor3 = Color3.fromRGB(48, 48, 69)
	newSubPage.BorderSizePixel = 0
	newSubPage.Size = UDim2.new(0.95, 0, scaleY, 0)
	MakeUICorner(cornerScale, newSubPage)
	makeUIList(UIListLayout, newSubPage)
	MakeUIPadding(0, 0.03, 0.03, UIPaddingTop, newSubPage)

	Orders[newSubPage] = 1
	return newSubPage
end

local function MakeTitle (subPage, TitleTXT, scaleY)

	local newTitle = Instance.new('TextLabel')
	newTitle.BackgroundTransparency = 1
	newTitle.Size = UDim2.new(1, 0, scaleY, 0)
	newTitle.Font = Enum.Font.GothamBlack
	newTitle.Text = TitleTXT
	newTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	newTitle.TextScaled = true
	newTitle.LayoutOrder = Orders[subPage]
	newTitle.Parent = subPage

	Orders[subPage] += 1

	return newTitle
end

local checkBoxColors = {
	[true] = Color3.fromRGB(175, 175, 255);
	[false] = Color3.fromRGB(37, 37, 54)
}

local function MakeCheckbox (subPage, checkBoxTXT, scaleY)

	local newCheckBoxFrame = Instance.new('Frame', subPage)
	newCheckBoxFrame.BackgroundTransparency = 1
	newCheckBoxFrame.Size = UDim2.new(1, 0, scaleY, 0)
	newCheckBoxFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local newCheckBox = Instance.new('Frame', newCheckBoxFrame)
	newCheckBox.AnchorPoint = Vector2.new(0, 0.5)
	newCheckBox.BackgroundColor3 = Color3.fromRGB(37, 37, 54)
	newCheckBox.Size = UDim2.new(0.049, 0, 0.73, 0)
	newCheckBox.Position = UDim2.new(0, 0, 0.5, 0)
	newCheckBox.BorderSizePixel = 0

	newCheckBox.BackgroundColor3 = checkBoxColors[GetSave(checkBoxTXT)]

	local UIStroke = Instance.new('UIStroke', newCheckBox)
	UIStroke.Color = Color3.fromRGB(255, 255, 255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local newCheckBoxButton = Instance.new('TextButton', newCheckBox)
	newCheckBoxButton.Name = checkBoxTXT
	newCheckBoxButton.BackgroundTransparency = 1
	newCheckBoxButton.Size = UDim2.new(1,0,1,0)
	newCheckBoxButton.ZIndex = 10
	newCheckBoxButton.Text = ''

	local newCheckBoxTXT = Instance.new('TextLabel', newCheckBoxFrame)
	newCheckBoxTXT.BackgroundTransparency = 1
	newCheckBoxTXT.Size = UDim2.new(0.835, 0, 1, 0)
	newCheckBoxTXT.Position = UDim2.new(0.08, 0, 0, 0)
	newCheckBoxTXT.Font = Enum.Font.GothamBold
	newCheckBoxTXT.TextColor3 = Color3.fromRGB(255, 255, 255)
	newCheckBoxTXT.TextScaled = true
	newCheckBoxTXT.TextXAlignment = Enum.TextXAlignment.Left
	newCheckBoxTXT.Text = checkBoxTXT

	return newCheckBoxButton
end

local function MakeLargeButton (subPage, buttonTXT, scaleY)

	local newLargeButtonFrame = Instance.new('Frame', subPage)
	newLargeButtonFrame.BackgroundTransparency = 1
	newLargeButtonFrame.Size = UDim2.new(1, 0, scaleY, 0)
	newLargeButtonFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local newLargeButton = Instance.new('TextButton', newLargeButtonFrame)
	newLargeButton.AnchorPoint = Vector2.new(0.5, 0.5)
	newLargeButton.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
	newLargeButton.BorderSizePixel = 0
	newLargeButton.Size = UDim2.new(1, 0, 0.67, 0)
	newLargeButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	newLargeButton.Text = ''
	newLargeButton.BorderSizePixel = 0


	local newLargeButtonLabel = Instance.new('TextLabel', newLargeButton)
	newLargeButtonLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	newLargeButtonLabel.BackgroundTransparency = 1
	newLargeButtonLabel.Size = UDim2.new(1, 0, 0.8, 0)
	newLargeButtonLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	newLargeButtonLabel.Font = Enum.Font.GothamBlack
	newLargeButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	newLargeButtonLabel.TextScaled = true
	newLargeButtonLabel.Text = buttonTXT
	MakeUICorner(0.15, newLargeButton)

	local UIStroke = Instance.new('UIStroke', newLargeButton)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1


	return newLargeButton
end

function getMacroUnits(macroName, textBlocks)
	local nameMacro = macroName
	local unitsFromMacro = {}

	local macroExist = isfile('Jung Hub\\Anime Adventures\\' .. nameMacro)
	local macroExistjson = isfile('Jung Hub\\Anime Adventures\\' .. nameMacro .. '.json')
	if macroExistjson then nameMacro = nameMacro .. '.json' end


	if macroExist or macroExistjson then

		local sucess, response = pcall(function()
			local MacroAbout = HttpService:JSONDecode( readfile( 'Jung Hub\\Anime Adventures\\' .. nameMacro) )

			for _, macroTabl in pairs(MacroAbout) do
				if not macroTabl['type'] or macroTabl['type'] ~= 'spawn_unit' then continue end
				if table.find(unitsFromMacro, macroTabl.unit) then continue end

				table.insert(unitsFromMacro, macroTabl.unit)
			end
		end)

		if not sucess then
			for i=1,6 do
				unitsFromMacro[i] = "error"
			end
		end

	end

	for textBlockNumb, TextBlock in ipairs(textBlocks) do
		local unitName = unitsFromMacro[textBlockNumb] if oldItemsData[unitsFromMacro[textBlockNumb]] then unitName = oldItemsData[unitsFromMacro[textBlockNumb]].Name end

		TextBlock.Text = string.format('Unit %s: %s', textBlockNumb, unitName or "")
	end

end 

local function MakeDDL (subPage, DDLTXT, scaleY)

	local newDDLFrame = Instance.new('Frame', subPage)
	newDDLFrame.BackgroundTransparency = 1
	newDDLFrame.Size = UDim2.new(1, 0, scaleY, 0)
	newDDLFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local newDDLLabel = Instance.new('TextLabel', newDDLFrame)
	newDDLLabel.BackgroundTransparency = 1
	newDDLLabel.Size = UDim2.new(1, 0, 0.3, 0)
	newDDLLabel.Position = UDim2.new(0, 0, 0.05, 0)
	newDDLLabel.Font = Enum.Font.GothamBlack
	newDDLLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	newDDLLabel.TextScaled = true
	newDDLLabel.TextXAlignment = Enum.TextXAlignment.Left
	newDDLLabel.Text = DDLTXT

	local newDDLButton = Instance.new('TextButton', newDDLFrame)
	newDDLButton.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
	newDDLButton.BorderSizePixel = 0
	newDDLButton.Size = UDim2.new(1, 0, 0.408, 0)
	newDDLButton.Position = UDim2.new(0, 0, 0.45, 0)
	newDDLButton.Text = ''
	MakeUICorner(0.15, newDDLButton)

	local UIStroke = Instance.new('UIStroke', newDDLButton)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local newDDLList = Instance.new('TextLabel', newDDLButton)
	newDDLList.BackgroundTransparency = 1
	newDDLList.AnchorPoint = Vector2.new(0.5, 0.5)
	newDDLList.Size = UDim2.new(0.95, 0, 0.8, 0)
	newDDLList.Position = UDim2.new(0.5, 0, 0.5, 0)
	newDDLList.Font = Enum.Font.GothamBlack
	newDDLList.TextScaled = true
	newDDLList.TextXAlignment = Enum.TextXAlignment.Left
	newDDLList.TextColor3 = Color3.fromRGB(255, 255, 255)
	newDDLList.RichText = true
	newDDLList.Text = 'None'


	return newDDLButton
end

local function DDLlabel (ddlButton, newValue)

	if type(newValue) == 'table' then
		local newTXT = "None"

		if #newValue >=1 then 
			newTXT = ""

			for _, addItem in ipairs(newValue) do
				newTXT = string.format(newTXT .. "%s, ", addItem)
			end

		end

		ddlButton.TextLabel.Text = newTXT

	else
		local newTXT = "None" if newValue ~= "" and newValue ~= nil then newTXT = newValue end
		ddlButton.TextLabel.Text = newTXT
	end
end

local DDLColors = {
	[true] = Color3.fromRGB(0, 176, 109);
	[false] = Color3.fromRGB(138, 138, 199)
}

local function GetDDL (ddlButton, items, multiple, keyName, secondKeyName, tabName)

	local DDL = ddlButton.Parent:FindFirstChild('List')

	if not DDL then
		DDL = Instance.new('Frame', MainContent) DDL.Name = 'List' DDL.Visible = false
		DDL.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
		DDL.BorderSizePixel = 0
		DDL.ZIndex = 555
		--DDL.Size = UDim2.new(0.448, 0, 0.388, 0)
		MakeUICorner(0.02, DDL)
		MakeUIPadding(0, 0.02, 0.02, 0, DDL)

		local UIStroke = Instance.new('UIStroke', DDL)
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		UIStroke.Color = Color3.fromRGB(189, 189, 255)
		UIStroke.LineJoinMode = Enum.LineJoinMode.Round
		UIStroke.Thickness = 1

		local ScrollingItems = Instance.new('ScrollingFrame', DDL) ScrollingItems.Name = 'ScrollingItems'
		ScrollingItems.BackgroundTransparency = 1
		ScrollingItems.Size = UDim2.new(1, 0, 0.97, 0)
		ScrollingItems.Position = UDim2.new(0, 0, 0.03, 0)
		ScrollingItems.ZIndex = 556
		ScrollingItems.AutomaticCanvasSize = 'Y'
		ScrollingItems.CanvasSize = UDim2.new(0,0,0,0)
		ScrollingItems.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
		ScrollingItems.ScrollBarThickness = 3
		ScrollingItems.BorderSizePixel = 0
		ScrollingItems.ScrollingDirection = Enum.ScrollingDirection.Y
		makeUIList(0.03, ScrollingItems)

		local TemplateButton = Instance.new('TextButton', ScrollingItems) TemplateButton.Name = 'Template' TemplateButton.Visible = false
		TemplateButton.BackgroundColor3 = Color3.fromRGB(138, 138, 199)
		TemplateButton.BorderSizePixel = 0
		TemplateButton.Size = UDim2.new(1, 0, 0.08, 0)
		TemplateButton.ZIndex = 556
		TemplateButton.RichText = true
		TemplateButton.Font = Enum.Font.GothamBlack
		TemplateButton.TextScaled = true
		TemplateButton.TextStrokeTransparency = 0.65
		TemplateButton.TextColor3 = Color3.fromRGB(255,255,255)

		--DDL.Size = UDim2.new(1, 0, 0, DDL.AbsoluteSize.Y)
		DDL.Position = UDim2.new(0, 0, 1, 0)
		DDL.Parent = ddlButton.Parent
	end

	DDL.Size = UDim2.new(1, 0, 0, MainContent.AbsoluteSize.Y * 0.388)
	DDL.Visible = not DDL.Visible

	for _, button in ipairs(DDL.ScrollingItems:GetChildren()) do
		if button.Name == 'item' then button:Destroy() end
	end

	if not DDL.Visible then return end

	for _, item in ipairs(items) do
		local newItem = DDL.ScrollingItems.Template:Clone() newItem.Name = 'item'
		newItem.Parent = DDL.ScrollingItems
		newItem.Text = item
		newItem.Visible = true

		local itemSelected = false

		if type(GetSave(keyName)) == 'table' then

			if secondKeyName then
				itemSelected = GetSave(keyName)[tabName][secondKeyName] == item
			else
				itemSelected = table.find(GetSave(keyName), item)
			end

		else itemSelected = GetSave(keyName) == item
		end

		if itemSelected then newItem.BackgroundColor3 = DDLColors[true] end

		newItem.MouseButton1Click:Connect(function()
			local isSelected = false

			if multiple then
				local itemInTable = table.find(GetSave(keyName), item)
				local newSave = table.clone(Settings[keyName])

				if itemInTable then 
					table.remove(newSave, itemInTable)
				else
					table.insert(newSave, item)
					isSelected = true
				end

				Save(keyName, newSave)

			else

				local oldKey = GetSave(keyName)

				for _, button in ipairs(DDL.ScrollingItems:GetChildren()) do
					if button.Name ~= 'item' then continue end
					if (not secondKeyName and button.Text == oldKey) or (secondKeyName and button.Text == oldKey[tabName][secondKeyName])  then button.BackgroundColor3 = DDLColors[false] break end
				end

				local toSave = "" if secondKeyName then toSave = deepcopy(oldKey) toSave[tabName][secondKeyName] = "" end

				if not secondKeyName and oldKey ~= item then toSave = item
				elseif secondKeyName and oldKey[tabName][secondKeyName] ~= item then toSave[tabName][secondKeyName] = item
				end



				Save(keyName, toSave)
				if keyName == "Selected Macro" then getMacroUnits(toSave, MacroUnitsTextBlocks) end

				local oldKey = GetSave(keyName)


				isSelected = (secondKeyName and toSave[tabName][secondKeyName] ~= "") or ( not secondKeyName and toSave ~= "")

			end

			local fillDDL = GetSave(keyName) if secondKeyName then fillDDL = fillDDL[tabName][secondKeyName] end



			DDLlabel(ddlButton, fillDDL)

			newItem.BackgroundColor3 = DDLColors[isSelected]

		end)
	end	

end

local function MakeTextBox (subPage, PlacehodlerTXT, TitleTXT, scaleY)

	local TextBoxFrame = Instance.new('Frame', subPage)
	TextBoxFrame.BackgroundTransparency = 1
	TextBoxFrame.Size = UDim2.new(1, 0, scaleY, 0)
	TextBoxFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local TextBoxTitle = Instance.new('TextLabel', TextBoxFrame)
	TextBoxTitle.BackgroundTransparency = 1
	TextBoxTitle.Size = UDim2.new(1, 0, 0.3, 0)
	TextBoxTitle.Position = UDim2.new(0, 0, 0.05, 0)
	TextBoxTitle.Font = Enum.Font.GothamBlack
	TextBoxTitle.TextScaled = true
	TextBoxTitle.TextColor3 = Color3.fromRGB(255,255,255)
	TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
	TextBoxTitle.Text = TitleTXT

	local TextBoxShadow = Instance.new('Frame', TextBoxFrame)
	TextBoxShadow.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
	TextBoxShadow.BorderSizePixel = 0
	TextBoxShadow.Size = UDim2.new(1, 0, 0.408, 0)
	TextBoxShadow.Position = UDim2.new(0, 0, 0.45, 0)
	MakeUICorner(0.15, TextBoxShadow)

	local TextBox = Instance.new('TextBox', TextBoxFrame)
	TextBox.BackgroundTransparency = 1
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.Size = UDim2.new(0.985, 0, 0.408, 0)
	TextBox.Position = UDim2.new(0.015, 0, 0.45, 0)
	TextBox.Font = Enum.Font.GothamBold
	TextBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	TextBox.PlaceholderText = PlacehodlerTXT
	TextBox.TextScaled = true
	TextBox.TextColor3 = Color3.fromRGB(255,255,255)
	TextBox.Text = ""

	local UIStroke = Instance.new('UIStroke', TextBoxShadow)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	return TextBox
end

local function MakeSlider (subPage, TitleTXT, scaleY)

	local slideFrame = Instance.new('Frame', subPage)
	slideFrame.BackgroundTransparency = 1
	slideFrame.Size = UDim2.new(1, 0, scaleY, 0)
	slideFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local slideTitle = Instance.new('TextLabel', slideFrame)
	slideTitle.BackgroundTransparency = 1
	slideTitle.Size = UDim2.new(0.532, 0, 0.3, 0)
	slideTitle.Position = UDim2.new(0, 0, 0.05, 0)
	slideTitle.Font = Enum.Font.GothamBlack
	slideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	slideTitle.TextScaled = true
	slideTitle.TextXAlignment = Enum.TextXAlignment.Left
	slideTitle.Text = TitleTXT

	local slideBox = Instance.new('TextBox', slideFrame)
	slideBox.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
	slideBox.BorderSizePixel = 0
	slideBox.Size = UDim2.new(0.468, 0, 0.312, 0)
	slideBox.Position = UDim2.new(0.532, 0, 0.038, 0)
	slideBox.Font = Enum.Font.GothamBold
	slideBox.TextScaled = true
	slideBox.PlaceholderText = ""
	slideBox.Text = ""
	slideBox.TextColor3 = Color3.fromRGB(255,255,255)
	MakeUICorner(0.15, slideBox)

	local UIStroke = Instance.new('UIStroke', slideBox)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local slider = Instance.new('Frame', slideFrame) slider.Name = "slider"
	slider.BackgroundColor3 = Color3.fromRGB(27, 27, 39)
	slider.BorderSizePixel = 0
	slider.Size = UDim2.new(1, 0, 0.35, 0)
	slider.Position = UDim2.new(0, 0, 0.508, 0)
	MakeUICorner(0.2, slider)

	local UIStroke = Instance.new('UIStroke', slider)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local sliderBar = Instance.new('Frame', slider)
	sliderBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderBar.BorderSizePixel = 0
	sliderBar.Size = UDim2.new(1,0,1,0)
	MakeUICorner(0.2, sliderBar)

	local UIGradient = Instance.new('UIGradient', sliderBar)

	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(176, 176, 239) ),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255) ),
	}

	local sliderButton = Instance.new('TextButton', slider) sliderButton.Name = "SliderButton"
	sliderButton.BackgroundTransparency = 1
	sliderButton.ZIndex = 10
	sliderButton.Size = UDim2.new(1,0,1,0)
	sliderButton.Text = ""

	return slideFrame
end

local function MakeSliderV2 (subPage, TitleTXT, scaleY)
	local slideFrame = Instance.new('Frame', subPage)
	slideFrame.BackgroundTransparency = 1
	slideFrame.Size = UDim2.new(1, 0, scaleY, 0)
	slideFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1

	local slideTitle = Instance.new('TextLabel', slideFrame)
	slideTitle.BackgroundTransparency = 1
	slideTitle.AnchorPoint = Vector2.new(0, 0.5)
	slideTitle.Size = UDim2.new(0.49, 0, 0.9, 0)
	slideTitle.Position = UDim2.new(0.02, 0, 0.5, 0)
	slideTitle.Font = Enum.Font.GothamBlack
	slideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	slideTitle.TextScaled = true
	slideTitle.TextXAlignment = Enum.TextXAlignment.Left
	slideTitle.Text = TitleTXT
	slideTitle.TextStrokeTransparency = 0
	slideTitle.TextStrokeColor3 = Color3.fromRGB(79,81,112)
	slideTitle.ZIndex = 3

	local slideAmount = Instance.new('TextLabel', slideFrame)
	slideAmount.BackgroundTransparency = 1
	slideAmount.AnchorPoint = Vector2.new(1, 0.5)
	slideAmount.Size = UDim2.new(0.49, 0, 0.9, 0)
	slideAmount.Position = UDim2.new(0.98, 0, 0.5, 0)
	slideAmount.Font = Enum.Font.GothamBlack
	slideAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
	slideAmount.TextScaled = true
	slideAmount.TextXAlignment = Enum.TextXAlignment.Right
	slideAmount.Text = "[0/0]"
	slideAmount.Name = "AmountLabel"
	slideAmount.TextStrokeTransparency = 0
	slideAmount.TextStrokeColor3 = Color3.fromRGB(79,81,112)
	slideAmount.ZIndex = 3

	local slider = Instance.new('Frame', slideFrame) slider.Name = "slider"
	slider.BackgroundColor3 = Color3.fromRGB(27, 27, 39)
	slider.BorderSizePixel = 0
	slider.Size = UDim2.new(1, 0, 1, 0)
	MakeUICorner(0.2, slider)

	local UIStroke = Instance.new('UIStroke', slider)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189, 189, 255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local sliderBar = Instance.new('Frame', slider)
	sliderBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderBar.BorderSizePixel = 0
	sliderBar.Size = UDim2.new(1,0,1,0)
	MakeUICorner(0.2, sliderBar)

	local UIGradient = Instance.new('UIGradient', sliderBar)

	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(176, 176, 239) ),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255) ),
	}

	local sliderButton = Instance.new('TextButton', slider) sliderButton.Name = "SliderButton"
	sliderButton.BackgroundTransparency = 1
	sliderButton.ZIndex = 10
	sliderButton.Size = UDim2.new(1,0,1,0)
	sliderButton.Text = ""

	return slideFrame
end

local function MakeTextBlock (subPage, DefaultTXT, ScaleY)

	local TxtBlockFrame = Instance.new('Frame', subPage)
	TxtBlockFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 44)
	TxtBlockFrame.BorderSizePixel = 0
	TxtBlockFrame.Size = UDim2.new(1, 0, ScaleY, 0)
	TxtBlockFrame.LayoutOrder = Orders[subPage]
	Orders[subPage] += 1
	MakeUICorner(0.2, TxtBlockFrame)

	local TxtLabel = Instance.new('TextLabel', TxtBlockFrame)
	TxtLabel.BackgroundTransparency = 1
	TxtLabel.AnchorPoint = Vector2.new(0, 0.5)
	TxtLabel.Size = UDim2.new(0.98, 0, 0.9, 0)
	TxtLabel.Position = UDim2.new(0.02, 0, 0.5, 0)
	TxtLabel.Font = Enum.Font.GothamBold
	TxtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TxtLabel.TextScaled = true
	TxtLabel.TextXAlignment = Enum.TextXAlignment.Left
	TxtLabel.Text = DefaultTXT

	return TxtLabel
end

local function MakeDoubleButton (subPage, ButtonTXT, ScaleY)

	local DoubleButtonFrame = Instance.new('Frame', subPage)
	DoubleButtonFrame.BackgroundTransparency = 1
	DoubleButtonFrame.BorderSizePixel = 0
	DoubleButtonFrame.Size = UDim2.new(1, 0, ScaleY, 0)
	DoubleButtonFrame.LayoutOrder = Orders[subPage] Orders[subPage] +=1

	local BiggerButton = Instance.new('TextButton', DoubleButtonFrame) BiggerButton.Name = "_bigbutton"
	BiggerButton.BackgroundColor3 = Color3.fromRGB(75,75, 108)
	BiggerButton.Size = UDim2.new(0.69, 0, 1, 0)
	BiggerButton.Text = ""
	MakeUICorner(0.15, BiggerButton)

	local UIStroke = Instance.new('UIStroke', BiggerButton)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189,189,255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local BiggetButtonTXT = Instance.new('TextLabel', BiggerButton)
	BiggetButtonTXT.BackgroundTransparency = 1
	BiggetButtonTXT.AnchorPoint = Vector2.new(0, 0.5)
	BiggetButtonTXT.Position = UDim2.new(0,0,0.5,0)
	BiggetButtonTXT.Size = UDim2.new(1,0, 0.8, 0)
	BiggetButtonTXT.Font = Enum.Font.GothamBlack
	BiggetButtonTXT.TextColor3 = Color3.fromRGB(255,255,255)
	BiggetButtonTXT.TextScaled = true
	BiggetButtonTXT.Text = ButtonTXT

	local ResetButton = Instance.new('TextButton', DoubleButtonFrame) ResetButton.Name = '_resetbutton'
	ResetButton.AnchorPoint = Vector2.new(1, 0)
	ResetButton.BackgroundColor3 = Color3.fromRGB(75,75,108)
	ResetButton.Size = UDim2.new(0.279, 0, 1, 0)
	ResetButton.Position = UDim2.new(1,0,0,0)

	local UIStroke = Instance.new('UIStroke', ResetButton)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(189,189,255)
	UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	UIStroke.Thickness = 1

	local ResetButtonTXT = Instance.new('TextLabel', ResetButton)
	ResetButtonTXT.BackgroundTransparency = 1
	ResetButtonTXT.AnchorPoint = Vector2.new(0, 0.5)
	ResetButtonTXT.Position = UDim2.new(0,0,0.5,0)
	ResetButtonTXT.Size = UDim2.new(1,0, 0.8, 0)
	ResetButtonTXT.Font = Enum.Font.GothamBlack
	ResetButtonTXT.TextColor3 = Color3.fromRGB(255,255,255)
	ResetButtonTXT.TextScaled = true
	ResetButtonTXT.Text = "RESET"


	return DoubleButtonFrame
end

MakeNewPage('Main', 0.117)
MakeNewPage('Farm', 0.117)
MakeNewPage('AutoPlay+', 0.225)
MakeNewPage('Macro', 0.14)
MakeNewPage('Misc', 0.1)

-----------------------
pageShown = ScrollingContent['Main']
pageShown.Visible = true
Pages['Main'].BottomLine.Visible = true

---------------------------------------------------------------------

local Main_MainSubPage = MakeNewSubPage('Main', 'Right', 0.603, 0.03, 0.01, 0.02)
MakeTitle(Main_MainSubPage, 'Main', 0.07)
AutoLeaveLATE = MakeCheckbox(Main_MainSubPage, 'Auto Leave [LATE]', 0.056)
local AutoLeave = MakeCheckbox(Main_MainSubPage, 'Auto Leave', 0.056)
local AutoRetry = MakeCheckbox(Main_MainSubPage, 'Auto Retry', 0.056)
local AutoNextLevel = MakeCheckbox(Main_MainSubPage, 'Auto Next Level', 0.056)
local AutoNextPortal = MakeCheckbox(Main_MainSubPage, 'Auto Next Portal', 0.056)
local PlaceInRedZones = MakeCheckbox(Main_MainSubPage, 'Place In Red Zones', 0.056)
local HideMap = MakeCheckbox(Main_MainSubPage, 'Hide Map', 0.056)
local TPToLobby = MakeLargeButton(Main_MainSubPage, 'Teleport To Lobby', 0.103)

-----------------------

local Main_AutoOpenCapsules = MakeNewSubPage('Main', 'Right', 0.212, 0.05, 0.05, 0.02)
MakeTitle(Main_AutoOpenCapsules, 'Auto Open Capsules', 0.195)
local AutoOpenCapsules = MakeCheckbox(Main_AutoOpenCapsules, 'Auto Open Capsules', 0.162)
local selectedCapsulesDDL = MakeDDL(Main_AutoOpenCapsules, 'Select Ignore Capsules', 0.517)

-----------------------

local Main_SellSkinsSubPage = MakeNewSubPage('Main', 'Right', 0.212, 0.05, 0.05, 0.02)
MakeTitle(Main_SellSkinsSubPage, 'Auto Sell Skins', 0.195)
local AutoDeleteSkins = MakeCheckbox(Main_SellSkinsSubPage, 'Auto Delete Skins', 0.162)
local selectedSkinsDDL = MakeDDL(Main_SellSkinsSubPage, 'Select Skins', 0.517)

-----------------------

Main_HideYourself = MakeNewSubPage('Main', 'Left', 0.21, 0.05, 0.04, 0.07)
MakeTitle(Main_HideYourself, 'Hide Yourself', 0.21)
HideTab = MakeCheckbox(Main_HideYourself, 'Hide Tab', 0.17)
HideName = MakeCheckbox(Main_HideYourself, 'Hide Name', 0.17)
FakeOutfit = MakeCheckbox(Main_HideYourself, 'Fake Outfit', 0.17)

-----------------------

Main_DeletePortalsSubPage = MakeNewSubPage('Main', 'Left', 0.669, 0.03, 0.013, 0.025)
MakeTitle(Main_DeletePortalsSubPage, 'Auto Delete Portals', 0.063)
SelectedPortalsDelete = MakeDDL(Main_DeletePortalsSubPage, "Select Portals", 0.14)
SelectedDifficultiesDelete = MakeDDL(Main_DeletePortalsSubPage, "Select Difficulties", 0.14)
SelectedTiersDelete = MakeDDL(Main_DeletePortalsSubPage, "Select Tiers", 0.14)
SelectIgnoreBonusDelete = MakeDDL(Main_DeletePortalsSubPage, "Select Ignore DMG Bonus", 0.14)
SelectIgnoreWorldsDelete = MakeDDL(Main_DeletePortalsSubPage, "Select Ignore Worlds", 0.14)
AutoDeletePortals = MakeCheckbox(Main_DeletePortalsSubPage, "Auto Delete Portals", 0.05)

-----------------------

---------------------------------------------------------------------

Farm_AutoJoinInfStory = MakeNewSubPage('Farm', 'Left', 0.347, 0.03, 0.02, 0.02)
MakeTitle(Farm_AutoJoinInfStory, 'Auto Join Story / Infinite', 0.115)
StoryInf_SelectWorld = MakeDDL(Farm_AutoJoinInfStory, 'Selected World', 0.28)
StoryInf_SelectLevel = MakeDDL(Farm_AutoJoinInfStory, 'Selected Level', 0.28)
StoryInf_Hard = MakeCheckbox(Farm_AutoJoinInfStory, 'Hard Difficulty', 0.105)
StoryInf_AutoJoin = MakeCheckbox(Farm_AutoJoinInfStory, 'Auto Join Story/INF', 0.105)

-----------------------

Farm_SelectPortalsSubPage = MakeNewSubPage('Farm', 'Left', 0.977, 0.03, 0.01, 0.013)
MakeTitle(Farm_SelectPortalsSubPage, 'Auto Select Portals', 0.043)
SelectPortalName = MakeDDL(Farm_SelectPortalsSubPage, 'Select Portals', 0.097)
SelectIgnoreDifficulties = MakeDDL(Farm_SelectPortalsSubPage, 'Select Ignore Difficulties', 0.097)
SelectTiers = MakeDDL(Farm_SelectPortalsSubPage, 'Select Tiers', 0.097)
SelectIgnoreDMGBonus = MakeDDL(Farm_SelectPortalsSubPage, 'Select Ignore DMG Bonus', 0.097)
SelectIgnoreWorlds = MakeDDL(Farm_SelectPortalsSubPage, 'Select Ignore Worlds', 0.097)
StartAfterTimePortal = MakeSlider(Farm_SelectPortalsSubPage, 'Start After Time', 0.108)
StartAfterPlayersPortal = MakeSlider(Farm_SelectPortalsSubPage, 'Waiting For Players', 0.108)
OnlyFriendsPortal = MakeCheckbox(Farm_SelectPortalsSubPage, 'Only Friends', 0.034)
AutoStartPortal = MakeCheckbox(Farm_SelectPortalsSubPage, 'Auto Start', 0.034)
AutoUsePortal = MakeCheckbox(Farm_SelectPortalsSubPage, 'Auto Use', 0.034)

-----------------------

Farm_TakedownWorthinessSubPage = MakeNewSubPage('Farm', 'Right', 0.157, 0.1, 0.05, 0.08)
MakeTitle(Farm_TakedownWorthinessSubPage, 'Takedowns & Worthiness', 0.27)
ShowTakedowns = MakeCheckbox(Farm_TakedownWorthinessSubPage, 'Show Takedowns', 0.23)
ColoredTakedowns = MakeCheckbox(Farm_TakedownWorthinessSubPage, 'Colored Takedowns', 0.23)

-----------------------

Farm_InfCastleSubPage = MakeNewSubPage('Farm', 'Right', 0.252, 0.04, 0.04, 0.03)
MakeTitle(Farm_InfCastleSubPage, 'Auto Join Inf Castle', 0.162)
InfCastleMaxRoom = MakeTextBox(Farm_InfCastleSubPage, 'Room Number', 'Auto Join Until Room:', 0.42)
InfCastleHardDifficulty = MakeCheckbox(Farm_InfCastleSubPage, 'Hard Difficulty', 0.137)
InfCastleAutoJoin = MakeCheckbox(Farm_InfCastleSubPage, 'Auto Infinity Castle', 0.137)

-----------------------

Farm_ChallengeSubPage = MakeNewSubPage('Farm', 'Right', 0.429, 0.03, 0.02, 0.02)
MakeTitle(Farm_ChallengeSubPage, 'Auto Join Challenge', 0.1)
Challenge_IgnoreWorlds = MakeDDL(Farm_ChallengeSubPage, 'Select Ignore Worlds', 0.235)
Challenge_IgnoreDifficulty = MakeDDL(Farm_ChallengeSubPage, 'Select Ignore Difficulties', 0.235)
Challenge_IgnoreRewards = MakeDDL(Farm_ChallengeSubPage, 'Select Ignore Rewards', 0.235)
AutoChallenge = MakeCheckbox(Farm_ChallengeSubPage, 'Auto Challenge', 0.085)

-----------------------

Farm_AutoSkillSubPage = MakeNewSubPage('Farm', 'Right', 0.561, 0.03, 0.02, 0.02)
MakeTitle(Farm_AutoSkillSubPage, 'Auto Use Skill', 0.073)
AutoErwin = MakeCheckbox(Farm_AutoSkillSubPage, 'Auto Buff Erwin 100%', 0.06)
AutoWenda = MakeCheckbox(Farm_AutoSkillSubPage, 'Auto Buff Wenda 100%', 0.06)
AutoLeafy = MakeCheckbox(Farm_AutoSkillSubPage, 'Auto Buff Leafy 100%', 0.06)
AutoGriffin = MakeCheckbox(Farm_AutoSkillSubPage, 'Auto Sacrifice Griffin', 0.06)
AutoSkillSelectedUnits = MakeDDL(Farm_AutoSkillSubPage, 'Selected Units', 0.178)
AutoSkillWave = MakeTextBox(Farm_AutoSkillSubPage, 'Wave', 'Start Auto Skill On Wave:', 0.19)
AutoSkillOnBoss = MakeCheckbox(Farm_AutoSkillSubPage, 'Only Skill On Boss', 0.06)
AutoUseSkill = MakeCheckbox(Farm_AutoSkillSubPage, 'Auto Use Skill', 0.06)


-----------------------


local Farm_QuestsSubPage = MakeNewSubPage('Farm', 'Right', 0.215, 0.08, 0.03, 0.07)
MakeTitle(Farm_QuestsSubPage, 'Quests', 0.195)
local AutoClaimQuests = MakeCheckbox(Farm_QuestsSubPage, 'Auto Claim Quests', 0.165)
local AutoTakeDailyQuests = MakeCheckbox(Farm_QuestsSubPage, 'Auto Take Daily Quests', 0.165)
local AutoTakeNamiQuests = MakeCheckbox(Farm_QuestsSubPage, 'Auto Take Nami Quests', 0.165)

-----------------------



---------------------------------------------------------------------

AP_PositionSettings = MakeNewSubPage('AutoPlay+', 'Left', 0.489, 0.025, 0.02, 0.039)
MakeTitle(AP_PositionSettings, "AutoPlace Positions", 0.083)
AP_PositionButtons = {}
for unitOrder = 1, 6 do
	AP_PositionButtons[unitOrder] = MakeDoubleButton(AP_PositionSettings, string.format("Select Unit %s Position", unitOrder), 0.083)
end
ShowPoints = MakeLargeButton(AP_PositionSettings, 'Show Positions', 0.125)

-----------------------

AP_SettingsSubPage = MakeNewSubPage('AutoPlay+', 'Left', 0.221, 0.06, 0.05, 0.045)
MakeTitle(AP_SettingsSubPage, 'Auto Place Units', 0.193)
AutoPlaceWave = MakeTextBox(AP_SettingsSubPage, 'Wave', 'Start On Wave:', 0.48)
AutoPlaceTurnOn = MakeCheckbox(AP_SettingsSubPage, 'Auto Place Units', 0.16)

-----------------------

AP_AutoSellUnitsSubPage = MakeNewSubPage('AutoPlay+', 'Left', 0.221, 0.06, 0.05, 0.045)
MakeTitle(AP_AutoSellUnitsSubPage, 'Auto Sell Units', 0.193)
AutoSellUnitsWave = MakeTextBox(AP_AutoSellUnitsSubPage, 'Wave', 'Sell On Wave:', 0.48)
AutoSellUnits = MakeCheckbox(AP_AutoSellUnitsSubPage, 'Auto Sell Units', 0.16)


-----------------------

AP_AutoSellFarmsSubPage = MakeNewSubPage('AutoPlay+', 'Left', 0.221, 0.06, 0.05, 0.045)
MakeTitle(AP_AutoSellFarmsSubPage, 'Auto Sell Farms', 0.193)
AutoSellFarmsWave = MakeTextBox(AP_AutoSellFarmsSubPage, 'Wave', 'Sell On Wave:', 0.48)
AutoSellFarms = MakeCheckbox(AP_AutoSellFarmsSubPage, 'Auto Sell Farms', 0.16)

-----------------------

AP_LeaveOnWaveSubPage = MakeNewSubPage('AutoPlay+', 'Left', 0.221, 0.06, 0.05, 0.045)
MakeTitle(AP_LeaveOnWaveSubPage, 'Auto Leave', 0.193)
AutoLeaveWaveON = MakeTextBox(AP_LeaveOnWaveSubPage, 'Wave', 'Leave On Wave:', 0.48)
AutoLeaveWave = MakeCheckbox(AP_LeaveOnWaveSubPage, 'Auto Leave', 0.16)

-----------------------


AP_AutoUpgradeSubPage = MakeNewSubPage('AutoPlay+', 'Right', 0.281, 0.06, 0.03, 0.045)
MakeTitle(AP_AutoUpgradeSubPage, 'Auto Upgrade Units', 0.155)
AutoUpgradeStartWave = MakeTextBox(AP_AutoUpgradeSubPage, 'Wave', 'Start On Wave:', 0.38)
FocusOnFarmAutoPlace = MakeCheckbox(AP_AutoUpgradeSubPage, 'Focus On Farms', 0.125)
AutoUpgradeCheckBox = MakeCheckbox(AP_AutoUpgradeSubPage, 'Auto Upgrade', 0.125)

-----------------------

AP_PlaceCapSubPage = MakeNewSubPage('AutoPlay+', 'Right', 0.418, 0.03, 0.025, 0.047)
MakeTitle(AP_PlaceCapSubPage, 'AutoPlace Cap', 0.096)
AP_PlaceCapSliders = {}
for sliderNum = 1,6  do
	AP_PlaceCapSliders[sliderNum] = MakeSliderV2(AP_PlaceCapSubPage, 'Unit ' .. sliderNum,  0.095)
end

-----------------------

AP_UpgradeCapSubPage = MakeNewSubPage('AutoPlay+', 'Right', 0.418, 0.03, 0.03, 0.047)
MakeTitle(AP_UpgradeCapSubPage, 'AutoUpgrade Cap', 0.096)
AP_UpgradeCapSliders = {}
for sliderNum = 1,6  do
	AP_UpgradeCapSliders[sliderNum] = MakeSliderV2(AP_UpgradeCapSubPage, 'Unit ' .. sliderNum,  0.095)
end

---------------------------------------------------------------------

local Macro_ConfigSubPage = MakeNewSubPage('Macro', 'Left', 0.405, 0.03, 0.02, 0.01)
MakeTitle(Macro_ConfigSubPage, 'Config', 0.105)
local selectedMacroDDL = MakeDDL(Macro_ConfigSubPage, "Select Macro", 0.26)
local createMacroBox = MakeTextBox(Macro_ConfigSubPage, 'Macro Name', 'Create Macro', 0.26)
local deleteMacroButton = MakeLargeButton(Macro_ConfigSubPage, 'Delete Macro', 0.155)
local equipMacroUnitsButton = MakeLargeButton(Macro_ConfigSubPage, 'Equip Macro Units', 0.155)

-----------------------

Macro_MacroUnitsSubPage = MakeNewSubPage('Macro', 'Left', 0.361, 0.03, 0.02, 0.04)
MakeTitle(Macro_MacroUnitsSubPage, 'Macro Units', 0.115)
for unitOrder =1,6 do local macroUnitBlock = MakeTextBlock(Macro_MacroUnitsSubPage, string.format('Unit %s:', unitOrder), 0.1) MacroUnitsTextBlocks[unitOrder] = macroUnitBlock end
if not IsLobby then Macro_MacroUnitsSubPage.Visible = false end

-----------------------

local Macro_MacroSubPage = MakeNewSubPage('Macro', 'Left', 0.258, 0.06, 0.02, 0.05)
MakeTitle(Macro_MacroSubPage, 'Macro', 0.16)
local PlayMacro = MakeCheckbox(Macro_MacroSubPage, "Play Macro", 0.13)
local RecordMacro = MakeCheckbox(Macro_MacroSubPage, "Record Macro", 0.13)
local StepDelaySlider = MakeSlider(Macro_MacroSubPage, "Step Delay", 0.41)

-----------------------

local Macro_MacroStatusSubPage = MakeNewSubPage('Macro', 'Left', 0.258, 0.06, 0.02, 0.05)
local MacroStatusTitle = MakeTitle(Macro_MacroStatusSubPage, 'Macro Status: None', 0.16)
local Macro_ActionTXT = MakeTextBlock(Macro_MacroStatusSubPage, 'Action:', 0.14)
local Macro_TypeTXT = MakeTextBlock(Macro_MacroStatusSubPage, 'Type:', 0.14)
local Macro_UnitTXT = MakeTextBlock(Macro_MacroStatusSubPage, 'Unit:', 0.14)
local Macro_WaitTXT = MakeTextBlock(Macro_MacroStatusSubPage, 'Waiting for:', 0.14)


-----------------------

local Macro_MacroListSubPage = MakeNewSubPage('Macro', 'Right', 4.542, 0.03, 0, 0.002)

---------------------------------------------------------------------

local Misc_WebhookSubPage = MakeNewSubPage('Misc', 'Right', 0.532, 0.03, 0.02, 0.02)
MakeTitle(Misc_WebhookSubPage, 'Discord Webhook', 0.082)
local webhookUrlBox = MakeTextBox(Misc_WebhookSubPage, 'discord url', 'Webhook', 0.2)
local webhookPingBox = MakeTextBox(Misc_WebhookSubPage, 'userID', 'Ping User', 0.2)
local ResultWebhook = MakeCheckbox(Misc_WebhookSubPage, "Result Webhook", 0.063)
local PingUserCHB = MakeCheckbox(Misc_WebhookSubPage, "Ping User", 0.063)
local PingRareCHB = MakeCheckbox(Misc_WebhookSubPage, "Ping On Secret Drop", 0.063)
local PingDefeatCHB = MakeCheckbox(Misc_WebhookSubPage, "Ping On Defeat", 0.063)

local TestWebhook = MakeLargeButton(Misc_WebhookSubPage, "Test Webhook", 0.12)

local Misc_MiscSubPage = MakeNewSubPage('Misc', 'Right', 0.344, 0.03, 0.02, 0.02)
MakeTitle(Misc_MiscSubPage, 'Misc', 0.13)
makeUHBigger = MakeCheckbox(Misc_MiscSubPage, 'Large Window', 0.095)
local hideAdditionalFrame = MakeCheckbox(Misc_MiscSubPage, "Hide Additional Frame", 0.095)

---------------------------------------------------------------------



local lookingForANewPosition = false
for unitOrder, doubleButtonFrame in ipairs(AP_PositionButtons) do


	local spawnCap = 6 
	local distanceBetweenUnits = 1.9

	if EquippedUnitsAbout[ tostring(unitOrder) ] then 
		spawnCap = EquippedUnitsAbout[ tostring(unitOrder) ].spawn_cap

		if EquippedUnitsAbout[ tostring(unitOrder) ].id == 'speedwagon' then distanceBetweenUnits = 4 end
	end

	doubleButtonFrame._resetbutton.MouseButton1Click:Connect(function()
		if IsLobby then return end
		local oldSave = GetSave('AutoPlacePositions')
		if not oldSave[LevelData.map] then oldSave[LevelData.map] = {} end

		oldSave[LevelData.map][ 'Unit' .. unitOrder ] = nil

		Save("AutoPlacePositions", oldSave)
	end)

	if IsLobby then continue end

	doubleButtonFrame._bigbutton.MouseButton1Click:Connect(function()
		if IsLobby or lookingForANewPosition then return end lookingForANewPosition = true

		local placeCapSaved = GetSave('AutoPlacesCap')[tostring(unitOrder)] 

		if EquippedUnitsAbout[ tostring(unitOrder) ] and EquippedUnitsAbout[ tostring(unitOrder) ].spawn_cap < placeCapSaved then
			spawnCap = EquippedUnitsAbout[ tostring(unitOrder) ].spawn_cap	
		else
			spawnCap = placeCapSaved
		end

		local objects = {}
		for objectNumber = 0, spawnCap-1 do
			local newObject = Instance.new('Part')
			newObject.Anchored = true
			newObject.CanCollide = false
			newObject.Color = Color3.fromRGB(255,255,255)
			newObject.Material = Enum.Material.Neon
			newObject.Size = Vector3.new(1,1,1)
			newObject.Transparency = 0.3
			newObject.Parent = workspace

			objects[tostring(objectNumber)] = newObject
		end

		local positionSaved
		local mouseMoveConnection
		local releasedConnection

		mouseMoveConnection = RunS.RenderStepped:Connect(function(input)
			local mouseRay = mouse.UnitRay
			local RayParams = RaycastParams.new()
			RayParams.FilterDescendantsInstances = {workspace._terrain}
			RayParams.FilterType = Enum.RaycastFilterType.Include
			RayParams.IgnoreWater = true

			local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 100, RayParams)
			if not result then return end
			positionSaved = result.Position

			for objectNumb, Object in pairs(objects) do
				Object.Position = result.Position + Vector3.new( ( tonumber(objectNumb)  % (spawnCap/2) ) * distanceBetweenUnits , 0, math.floor( tonumber(objectNumb) / spawnCap + 0.5) * distanceBetweenUnits ) 
			end

		end)

		releasedConnection = UIS.InputBegan:Connect(function(input)
			local usedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
			local usedTouch = input.UserInputType == Enum.UserInputType.Touch

			if usedMouse or usedTouch then

				releasedConnection:Disconnect()
				mouseMoveConnection:Disconnect()

				local mouseRay = mouse.UnitRay
				local RayParams = RaycastParams.new()
				RayParams.FilterDescendantsInstances = {workspace._terrain}
				RayParams.FilterType = Enum.RaycastFilterType.Include
				RayParams.IgnoreWater = true

				local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 100, RayParams)
				positionSaved = nil if result and result.Position then positionSaved = result.Position end

				for objectNumb, object in pairs(objects) do
					local Fading = TS:Create(object, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {Transparency = 1})
					Fading:Play()
					game.Debris:AddItem(object, 1.2)
					if not result then continue end
					object.Position = result.Position + Vector3.new( ( tonumber(objectNumb)  % (spawnCap/2) ) * distanceBetweenUnits , 0, math.floor( tonumber(objectNumb) / spawnCap + 0.5) * distanceBetweenUnits )

				end

				lookingForANewPosition = false
				if not positionSaved then return end

				local oldSave = GetSave('AutoPlacePositions')
				if not oldSave[LevelData.map] then oldSave[LevelData.map] = {} end

				oldSave[LevelData.map][ 'Unit' .. unitOrder] = tostring(CFrame.new(positionSaved))

				Save("AutoPlacePositions", oldSave)

			end
		end)

	end)


end


SelectTiers.MouseButton1Click:Connect(function()
	local items = {}
	for number = 1, 15 do
		table.insert(items, number)
	end

	GetDDL(SelectTiers, items, true, 'PortalUSE Tiers')

end)
DDLlabel(SelectTiers, GetSave('PortalUSE Tiers'))

SelectPortalName.MouseButton1Click:Connect(function()
	local items = table.clone(PortalsList)

	GetDDL(SelectPortalName, items, true, 'PortalUSE Portals')

end)
DDLlabel(SelectPortalName, GetSave('PortalUSE Portals'))

SelectIgnoreDifficulties.MouseButton1Click:Connect(function()
	local items = {}

	for _, difficultyName in pairs(DifficultiesName) do
		table.insert(items, difficultyName)
	end

	GetDDL(SelectIgnoreDifficulties, items, true, 'PortalUSE Difficulties Ignore')

end)
DDLlabel(SelectIgnoreDifficulties, GetSave('PortalUSE Difficulties Ignore'))

SelectIgnoreDMGBonus.MouseButton1Click:Connect(function()
	local items = {}

	for _, bonusName in pairs(Bonuses) do
		table.insert(items, bonusName)
	end

	GetDDL(SelectIgnoreDMGBonus, items, true, 'PortalUSE Bonus Ignore')

end)
DDLlabel(SelectIgnoreDMGBonus, GetSave('PortalUSE Bonus Ignore'))

SelectIgnoreWorlds.MouseButton1Click:Connect(function()
	local items = {}

	for _, worldName in pairs(portalWorlds) do
		table.insert(items, worldName)
	end

	GetDDL(SelectIgnoreWorlds, items, true, 'PortalUSE Worlds Ignore')

end)
DDLlabel(SelectIgnoreWorlds, GetSave('PortalUSE Worlds Ignore'))


StoryInf_SelectWorld.MouseButton1Click:Connect(function()
	local items = {}

	for _, worldModule in ipairs(RS.src.Data.Worlds:GetChildren()) do
		if not worldModule:IsA('ModuleScript') then continue end

		for _,worldAbout in pairs(require(worldModule)) do
			if not worldAbout.infinite and not worldAbout.legend_stage then continue end

			local worldName = worldAbout.name

			if worldAbout.legend_stage  then
				worldName = string.format('<font color="#ffa61f">%s</font>', worldName)
			end

			table.insert(items, worldName)
		end

	end

	GetDDL(StoryInf_SelectWorld, items, false, 'StoryInf_World')

	Save('StoryInf_Level', '')
	DDLlabel(StoryInf_SelectLevel, '')
end)
DDLlabel(StoryInf_SelectWorld, GetSave('StoryInf_World'))

StoryInf_SelectLevel.MouseButton1Click:Connect(function()
	local items = {}
	local selectedWorld = GetSave('StoryInf_World')
	local legendStage = string.match(selectedWorld, ">(.+)<") if legendStage then selectedWorld = legendStage end
	if selectedWorld == '' then return end

	local levelsInWorld = {}
	for _, worldModule in ipairs(RS.src.Data.Worlds:GetChildren()) do
		if not worldModule:IsA('ModuleScript') or #levelsInWorld > 0 then continue end

		for _,worldAbout in pairs(require(worldModule)) do
			if not worldAbout.levels or (not legendStage and not worldAbout.infinite) then continue end
			if legendStage and not worldAbout.legend_stage then continue end

			if selectedWorld == worldAbout.name then
				if not legendStage then levelsInWorld[1] = worldAbout.infinite.id end
				local amountOfLevels = 0
				for _,_ in pairs(worldAbout.levels) do amountOfLevels+=1 end

				for levelOrder = 1,amountOfLevels do
					levelsInWorld[#levelsInWorld+1] = worldAbout.levels[tostring(levelOrder)].id
				end

				break 
			end
		end

	end

	for _, levelModule in ipairs(RS.src.Data.Levels:GetDescendants()) do
		if not levelModule:IsA('ModuleScript') then continue end

		local levelsModule = require(levelModule)

		if not levelsModule[levelsInWorld[1]] then continue end

		for _, levelId in ipairs(levelsInWorld) do
			table.insert(items, levelsModule[levelId].name)
		end

	end



	GetDDL(StoryInf_SelectLevel, items, false, 'StoryInf_Level')

end)
DDLlabel(StoryInf_SelectLevel, GetSave('StoryInf_Level'))


local function getPortalUSE ()

	local IgnoreBonus = {}
	local IgnoreWorlds = {}
	local IgnoreDifficulties = {}

	for diffucltID, difficultName in pairs(DifficultiesName) do
		if not table.find(GetSave('PortalUSE Difficulties Ignore'), difficultName) then continue end
		table.insert(IgnoreDifficulties, diffucltID)
	end

	for bonusId, bonusName in pairs(Bonuses) do
		if not table.find(GetSave('PortalUSE Bonus Ignore'), bonusName) then continue end
		table.insert(IgnoreBonus, bonusId)
	end

	for worldID, worldName in pairs(portalWorlds) do
		if not table.find( GetSave('PortalUSE Worlds Ignore'), worldName) then continue end
		table.insert(IgnoreWorlds, worldID)
	end

	local PortalChosen = nil

	for _, itemData in pairs(RefreshedUniqueItems) do
		if not itemData['item_id'] or not string.find(oldItemsData[itemData.item_id].Name, 'Portal') then continue end
		if not table.find(GetSave('PortalUSE Portals'), oldItemsData[itemData.item_id].Name) then continue end
		local portalTier = itemData['_unique_item_data']['_unique_portal_data'].portal_depth
		local portalDifficulty = itemData['_unique_item_data']['_unique_portal_data'].challenge
		local portalBonus = itemData['_unique_item_data']['_unique_portal_data']['_weak_against'][1].damage_type
		local portalWorld = itemData['_unique_item_data']['_unique_portal_data']['level_id']

		if portalWorld and table.find(IgnoreWorlds, portalWorld) then continue end
		if portalBonus and table.find(IgnoreBonus, portalBonus) then continue end
		if portalDifficulty and table.find(IgnoreDifficulties, portalDifficulty) then continue end
		if portalTier and portalTier >=1 and not table.find(GetSave('PortalUSE Tiers'), portalTier) then continue end 

		PortalChosen = itemData.uuid
		break
	end

	return PortalChosen
end



SelectedTiersDelete.MouseButton1Click:Connect(function()
	local items = {}
	for number = 1, 15 do
		table.insert(items, number)
	end

	GetDDL(SelectedTiersDelete, items, true, 'Selected Tiers Delete')

end)

DDLlabel(SelectedTiersDelete, GetSave('Selected Tiers Delete'))

SelectedPortalsDelete.MouseButton1Click:Connect(function()
	local items = table.clone(PortalsList)

	GetDDL(SelectedPortalsDelete, items, true, 'Selected Portals Delete')

end)
DDLlabel(SelectedPortalsDelete, GetSave('Selected Portals Delete'))


SelectedDifficultiesDelete.MouseButton1Click:Connect(function()
	local items = {}

	for _, difficultyName in pairs(DifficultiesName) do
		table.insert(items, difficultyName)
	end

	GetDDL(SelectedDifficultiesDelete, items, true, 'Selected Portal Difficulties Delete')

end)
DDLlabel(SelectedDifficultiesDelete, GetSave('Selected Portal Difficulties Delete'))

SelectIgnoreBonusDelete.MouseButton1Click:Connect(function()
	local items = {}

	for _, bonusName in pairs(Bonuses) do
		table.insert(items, bonusName)
	end

	GetDDL(SelectIgnoreBonusDelete, items, true, 'Ignore Bonus Delete')

end)
DDLlabel(SelectIgnoreBonusDelete, GetSave('Ignore Bonus Delete'))


SelectIgnoreWorldsDelete.MouseButton1Click:Connect(function()
	local items = {}

	for _, worldName in pairs(portalWorlds) do
		table.insert(items, worldName)
	end

	GetDDL(SelectIgnoreWorldsDelete, items, true, 'Ignore Worlds Delete')

end)
DDLlabel(SelectIgnoreWorldsDelete, GetSave('Ignore Worlds Delete'))

Challenge_IgnoreWorlds.MouseButton1Click:Connect(function()
	local items = {}

	for _, worldName in pairs(macroMapList.Main) do
		table.insert(items, worldName)
	end

	GetDDL(Challenge_IgnoreWorlds, items, true, 'Challenge_IgnoreWorlds')

end)
DDLlabel(Challenge_IgnoreWorlds, GetSave('Challenge_IgnoreWorlds'))

Challenge_IgnoreDifficulty.MouseButton1Click:Connect(function()
	local items = {}

	for _, difficultyName in pairs(DifficultiesName) do
		table.insert(items, difficultyName)
	end

	GetDDL(Challenge_IgnoreDifficulty, items, true, 'Challenge_IgnoreDifficulties')

end)
DDLlabel(Challenge_IgnoreDifficulty, GetSave('Challenge_IgnoreDifficulties'))

Challenge_IgnoreRewards.MouseButton1Click:Connect(function()
	local items = {}

	for _, reward in pairs(require(RS.src.Data.ChallengeAndRewards).rewards) do
		table.insert(items, reward.name)
	end

	GetDDL(Challenge_IgnoreRewards, items, true, 'Challenge_IgnoreRewards')

end)
DDLlabel(Challenge_IgnoreRewards, GetSave('Challenge_IgnoreRewards'))

local function DeletePortalsFunc ()
	if not IsLobby then return end

	while GetSave(AutoDeletePortals.Name) do

		local IgnoreBonus = {}
		local IgnoreWorlds = {}
		local DeleteDifficulties = {}
		for diffucltID, difficultName in pairs(DifficultiesName) do
			if not table.find(GetSave('Selected Portal Difficulties Delete'), difficultName) then continue end
			table.insert(DeleteDifficulties, diffucltID)
		end

		for bonusId, bonusName in pairs(Bonuses) do
			if not table.find(GetSave('Ignore Bonus Delete'), bonusName) then continue end
			table.insert(IgnoreBonus, bonusId)
		end

		for worldID, worldName in pairs(portalWorlds) do
			if not table.find( GetSave('Ignore Worlds Delete'), worldName) then continue end
			table.insert(IgnoreWorlds, worldID)
		end


		local willBeDeleted = {}
		for _, itemData in pairs(RefreshedUniqueItems) do
			if not itemData['item_id'] or not string.find(oldItemsData[itemData.item_id].Name, 'Portal') then continue end
			if not table.find(GetSave('Selected Portals Delete'), oldItemsData[itemData.item_id].Name) then continue end
			local portalTier = itemData['_unique_item_data']['_unique_portal_data'].portal_depth
			local portalDifficulty = itemData['_unique_item_data']['_unique_portal_data'].challenge
			local portalBonus = itemData['_unique_item_data']['_unique_portal_data']['_weak_against'][1].damage_type
			local portalWorld = itemData['_unique_item_data']['_unique_portal_data']['level_id']

			if portalWorld and table.find(IgnoreWorlds, portalWorld) then continue end
			if portalBonus and table.find(IgnoreBonus, portalBonus) then continue end
			if portalDifficulty and not table.find(DeleteDifficulties, portalDifficulty) then continue end
			if portalTier and portalTier >=1 and not table.find(GetSave('Selected Tiers Delete'), portalTier) then continue end 

			table.insert(willBeDeleted, itemData.uuid)

		end

		if #willBeDeleted >=1 then Event['delete_unique_items']:InvokeServer(willBeDeleted) end

		task.wait(0.05)
	end

end

local HideUHFrame = Instance.new('Frame', Misc_MiscSubPage)
HideUHFrame.BackgroundTransparency = 1
HideUHFrame.LayoutOrder = Orders[Misc_MiscSubPage]
HideUHFrame.Size = UDim2.new(1, 0, 0.144, 0)
Orders[Misc_MiscSubPage] += 1

FPSMax_Misc = MakeTextBox(Misc_MiscSubPage, 'Frames Per Second', 'FPS Limit', 0.31)

local HideUHLabel = Instance.new('TextLabel', HideUHFrame)
HideUHLabel.TextColor3 = Color3.fromRGB(255,255,255)
HideUHLabel.BackgroundTransparency = 1
HideUHLabel.Size = UDim2.new(0.796, 0, 0.8, 0)
HideUHLabel.Font = Enum.Font.GothamBold
HideUHLabel.TextScaled = true
HideUHLabel.Text = 'Hide Jung Hub'
HideUHLabel.Position = UDim2.new(0, 0, 0.5, 0)
HideUHLabel.AnchorPoint = Vector2.new(0, 0.5)
HideUHLabel.TextXAlignment = Enum.TextXAlignment.Left

local HideUHButton = Instance.new('TextButton', HideUHFrame)
HideUHButton.BackgroundColor3 = Color3.fromRGB(75, 75, 108)
HideUHButton.TextColor3 = Color3.fromRGB(255,255,255)
HideUHButton.BorderSizePixel = 0
HideUHButton.AnchorPoint = Vector2.new(0, 0.5)
HideUHButton.Size = UDim2.new(0.2, 0, 0.8, 0)
HideUHButton.Position = UDim2.new(0.8, 0, 0.5, 0)
HideUHButton.Font = Enum.Font.GothamBlack
HideUHButton.TextScaled = true
HideUHButton.Text = 'U'
MakeUICorner(0.15, HideUHButton)

local HideUHStroke = Instance.new('UIStroke', HideUHButton)
HideUHStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HideUHStroke.Color = Color3.fromRGB(189, 189, 255)
HideUHStroke.LineJoinMode = Enum.LineJoinMode.Round
HideUHStroke.Thickness = 1

local chosing = false
HideUHButton.MouseButton1Click:Connect(function()
	if chosing then return end
	chosing = true
	HideUHButton.Text = "..."


	local chosenButton
	chosenButton = UIS.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		chosenButton:Disconnect()
		chosing = false
		Save('Hide Key', input.KeyCode.Name)

		HideUHButton.Text = input.KeyCode.Name

	end)


end)
HideUHButton.Text = UIS:GetStringForKeyCode( GetSave('Hide Key') )

UIS.InputBegan:Connect(function(input, gameprocess)
	if input.KeyCode.Name ~= GetSave('Hide Key') or gameprocess then return end 
	MainFrame.Visible = not MainFrame.Visible
end)

hideAdditionalFrame.MouseButton1Click:Connect(function()
	local enabled = not GetSave(hideAdditionalFrame.Name)
	Save(hideAdditionalFrame.Name, enabled)

	hideAdditionalFrame.Parent.BackgroundColor3 = checkBoxColors[enabled]

	additionalFrame.Visible = not enabled
end)
if GetSave(hideAdditionalFrame.Name) then additionalFrame.Visible = false hideAdditionalFrame.Parent.BackgroundColor3 = checkBoxColors[true] end


webhookUrlBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed or webhookUrlBox.Text == '' then webhookUrlBox.Text = GetSave('Discord Url') return end

	Save("Discord Url", webhookUrlBox.Text)

end)
webhookUrlBox.TextSize = 20
webhookUrlBox.TextScaled = false
webhookUrlBox.Text = GetSave("Discord Url")

webhookPingBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed or webhookPingBox.Text == '' or not tonumber(webhookPingBox.Text) then webhookPingBox.Text = GetSave('Discord UserID') return end

	Save("Discord UserID", webhookPingBox.Text)

end)
webhookPingBox.Text = GetSave("Discord UserID")

AutoUpgradeStartWave.FocusLost:Connect(function()
	if AutoUpgradeStartWave.Text == '' or not tonumber(AutoUpgradeStartWave.Text) then AutoUpgradeStartWave.Text = GetSave('AutoUpgradeWave') return end

	Save("AutoUpgradeWave", tonumber(AutoUpgradeStartWave.Text) )
end)
AutoUpgradeStartWave.Text = GetSave("AutoUpgradeWave")

AutoSellFarmsWave.FocusLost:Connect(function()
	if AutoSellFarmsWave.Text == '' or not tonumber(AutoSellFarmsWave.Text) then AutoSellFarmsWave.Text = GetSave('AutoSellFarmsWave') return end

	Save("AutoSellFarmsWave", tonumber(AutoSellFarmsWave.Text) )
end)
AutoSellFarmsWave.Text = GetSave("AutoSellFarmsWave")


AutoLeaveWaveON.FocusLost:Connect(function()
	if AutoLeaveWaveON.Text == '' or not tonumber(AutoLeaveWaveON.Text) then AutoLeaveWaveON.Text = GetSave('AutoLeaveOnWave') return end

	Save("AutoLeaveOnWave", tonumber(AutoLeaveWaveON.Text) )
end)
AutoLeaveWaveON.Text = GetSave("AutoLeaveOnWave")

InfCastleMaxRoom.FocusLost:Connect(function()
	if InfCastleMaxRoom.Text == '' or not tonumber(InfCastleMaxRoom.Text) then InfCastleMaxRoom.Text = GetSave('AutoJoinCastleMaxRoom') return end

	Save("AutoJoinCastleMaxRoom", tonumber(InfCastleMaxRoom.Text) )
end)
InfCastleMaxRoom.Text = GetSave("AutoJoinCastleMaxRoom")

AutoSkillWave.FocusLost:Connect(function()
	if AutoSkillWave.Text == '' or not tonumber(AutoSkillWave.Text) then AutoSkillWave.Text = GetSave('AutoSkillWave') return end

	Save("AutoSkillWave", tonumber(AutoSkillWave.Text) )
end)
AutoSkillWave.Text = GetSave("AutoSkillWave")


FPSMax_Misc.FocusLost:Connect(function()
	if FPSMax_Misc.Text == '' or not tonumber(FPSMax_Misc.Text) or tonumber(FPSMax_Misc.Text) < 1 then FPSMax_Misc.Text = GetSave('FPS_LIMIT') return end
	pcall(function() 

		if setfpsmax then
			setfpsmax( tonumber(FPSMax_Misc.Text) ) 
		else

			local maxFPS = math.clamp(tonumber(FPSMax_Misc.Text), 0, 60)
			local notChangedfps

			notChangedfps = FPSMax_Misc.FocusLost:Connect(function()
				if FPSMax_Misc.Text == '' or not tonumber(FPSMax_Misc.Text) or tonumber(FPSMax_Misc.Text) < 1 then return end
				notChangedfps:Disconnect()
				notChangedfps = nil
			end)

			while notChangedfps do
				local t0 = tick()
				RunS.Heartbeat:Wait()
				repeat until (t0 + 1/maxFPS) < tick()
			end
		end

	end)
	Save("FPS_LIMIT", tonumber(FPSMax_Misc.Text) )
end)
FPSMax_Misc.Text = GetSave("FPS_LIMIT")
pcall(function() setfpsmax( GetSave("FPS_LIMIT") ) end)

AutoSellUnitsWave.FocusLost:Connect(function()
	if AutoSellUnitsWave.Text == '' or not tonumber(AutoSellUnitsWave.Text) then AutoSellUnitsWave.Text = GetSave('AutoSellUnitsWave') return end

	Save("AutoSellUnitsWave", tonumber(AutoSellUnitsWave.Text) )
end)
AutoSellUnitsWave.Text = GetSave("AutoSellUnitsWave")

AutoPlaceWave.FocusLost:Connect(function()
	if AutoPlaceWave.Text == '' or not tonumber(AutoPlaceWave.Text) then AutoPlaceWave.Text = GetSave('AutoPlaceUnitsWave') return end

	Save("AutoPlaceUnitsWave", tonumber(AutoPlaceWave.Text) )
end)
AutoPlaceWave.Text = GetSave("AutoPlaceUnitsWave")


TestWebhook.MouseButton1Click:Connect(function()
	local Time = os.date("%X")
	local willBePinged = GetSave(PingDefeatCHB.Name) or GetSave(PingRareCHB.Name) or GetSave(PingUserCHB.Name)
	local userID = "" if GetSave("Discord UserID") ~= "" and willBePinged then userID = string.format("<@%s>", GetSave("Discord UserID")) end
	local discordUrl = GetSave("Discord Url")

	local data = {
		["content"] = userID,
		["embeds"] = {

			{
				["title"] = 'Anime Adventures',
				['color'] = 11513855,
				['footer'] = {
					['text'] = string.format("// Made by Jung Ganmyeon (%s)", Time), 
				},
				['fields'] = {
					{
						['name'] = 'Test Webhook',
						['value'] = 'Sao lại không nhỉ'
					}
				}

			}



		}
	}

	data = HttpService:JSONEncode(data)
	local headers = {["content-type"] = "application/json"}
	local request = http_request or request or HttpPost or syn.request or http.request
	local dataSend = {Url = discordUrl, Body = data, Method = "POST", Headers = headers}
	warn("Sending test webhook...")

	pcall(function() request(dataSend) end)

end)

local MacroTabs = Instance.new('Frame', Macro_MacroListSubPage)
MacroTabs.BackgroundTransparency = 1
MacroTabs.LayoutOrder = -999
MacroTabs.Size = UDim2.new(1, 0, 0.0092, 0)
MacroTabs.Name = 'Macro Tabs'

local MacroTabsListLayout = Instance.new('UIListLayout', MacroTabs)
MacroTabsListLayout.Padding = UDim.new(0,0)
MacroTabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MacroTabsListLayout.FillDirection = Enum.FillDirection.Horizontal
MacroTabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MacroTabsListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local RightOrders = {Main = 1, Tower = 2, Raid = 3, Portal = 4, Other = 5}
local viewingTab = nil
for tabName, mapsList in pairs(macroMapList) do

	local MacroList = Instance.new('Frame', Macro_MacroListSubPage)
	MacroList.BackgroundTransparency = 1
	MacroList.Size = UDim2.new(1, 0, 0.984, 0)
	MacroList.Name = tabName
	MacroList.Visible = false
	makeUIList(0, MacroList)

	Orders[MacroList] = 0

	local newTab = Instance.new('TextButton', MacroTabs)
	newTab.BackgroundTransparency = 1
	newTab.BackgroundColor3 = Color3.fromRGB(255,255,255)
	newTab.BorderSizePixel = 0
	newTab.Size = UDim2.new(0.206, 0, 1, 0)
	newTab.Text = ""
	newTab.Name = tabName
	newTab.LayoutOrder = RightOrders[tabName]
	newTab.ZIndex = 5

	newTab.MouseEnter:Connect(function()
		local TweenButton = TS:Create(newTab, newPageButtonBCInfo, {BackgroundTransparency = 0.9})
		TweenButton:Play()
	end)

	newTab.MouseLeave:Connect(function()
		local TweenButton = TS:Create(newTab, newPageButtonBCInfo, {BackgroundTransparency = 1})
		TweenButton:Play()
	end)

	newTab.MouseButton1Click:Connect(function()
		if viewingTab == newTab then return end

		Macro_MacroListSubPage[viewingTab.Name].Visible = false
		MacroList.Visible = true

		viewingTab.bottomLine.Visible = false
		newTab.bottomLine.Visible = true

		viewingTab = newTab

	end)

	local bottomLine = Instance.new('Frame', newTab) bottomLine.Name = 'bottomLine'
	bottomLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bottomLine.BorderSizePixel = 0
	bottomLine.Size = UDim2.new(1, 0, 0.05, 0)
	bottomLine.AnchorPoint = Vector2.new(0, 1)
	bottomLine.Position = UDim2.new(0, 0, 1, 0)
	bottomLine.Visible = false

	local tabTxtLabel = Instance.new('TextLabel', newTab)
	tabTxtLabel.BackgroundTransparency = 1
	tabTxtLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	tabTxtLabel.Size = UDim2.new(1, 0, 0.8, 0)
	tabTxtLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	tabTxtLabel.Font = Enum.Font.GothamBlack
	tabTxtLabel.TextScaled = true
	tabTxtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabTxtLabel.Text = tabName

	for _, mapName in ipairs(mapsList) do

		local newDDLMacroMap = MakeDDL(MacroList, mapName, 0.023)

		newDDLMacroMap.MouseButton1Click:Connect(function()

			local MacrosList = listfiles('Jung Hub\\Anime Adventures')

			local items = {}

			for _, macro in ipairs(MacrosList) do
				local macroName = string.match(string.sub(macro, 28), "[^.]+")

				table.insert(items, macroName)

			end

			GetDDL(newDDLMacroMap, items, false, 'Selected Macro Map', mapName, tabName)

		end)

		local fillDDL = GetSave('Selected Macro Map')

		DDLlabel(newDDLMacroMap, fillDDL[tabName][mapName])


	end

end

viewingTab = Macro_MacroListSubPage['Macro Tabs']['Main']
viewingTab.bottomLine.Visible = true
Macro_MacroListSubPage['Main'].Visible = true

local TypesAndMeaning = {
	['cycle_priority'] = "Changing Priority",
	['spawn_unit'] = "Spawning Unit",
	['sell_unit_ingame'] = "Selling Unit",
	['upgrade_unit_ingame'] = "Upgrading Unit"
}
local LastMacroStartedAt = nil


local function RecordMacroFunc ()
	if not LevelData then return end

	local MacroFile = GetSave('Selected Macro')

	local macroExist = isfile('Jung Hub\\Anime Adventures\\' .. MacroFile )
	local macroExistJson = isfile('Jung Hub\\Anime Adventures\\' .. MacroFile .. '.json')

	if macroExistJson then MacroFile = 'Jung Hub\\Anime Adventures\\' .. MacroFile .. '.json'
	elseif macroExist then MacroFile = 'Jung Hub\\Anime Adventures\\' .. MacroFile
	else RecordingMacro = false RecordMacro.Parent.BackgroundColor3 = checkBoxColors[false] return
	end

	MacroStatusTitle.Text = 'Macro Status: Recording'
	Macro_ActionTXT.Text = "Action:"

	local connections = {}
	local Steps = {}
	local Step = 1


	connections[1] = workspace._UNITS.ChildAdded:Connect(function(child)
		if child:WaitForChild('_stats'):WaitForChild('player').Value ~= player or not child._stats:WaitForChild('uuid') or not child._stats:WaitForChild('id') then return end
		local unitName = nil

		for equippedUnitUUID, equippedUnitAbout in pairs(EquippedUnits) do
			if equippedUnitUUID ~= child._stats.uuid.Value or equippedUnitAbout.id ~= child._stats.id.Value then continue end
			unitName = equippedUnitAbout.id
		end

		if not unitName then return end

		local unitParams = RaycastParams.new()
		unitParams.FilterDescendantsInstances = {workspace._terrain.ground, workspace._terrain.hill}
		unitParams.FilterType = Enum.RaycastFilterType.Include
		unitParams.IgnoreWater = true

		local pos = workspace:Raycast(child:WaitForChild('_shadow').Position, Vector3.new(0,-10,0), unitParams) 

		Steps[tostring(Step)] = {
			['money'] = child._stats.total_spent.Value;
			['type'] = 'spawn_unit';
			['cframe'] = tostring(CFrame.new(pos.Position));
			['unit'] = unitName
		}

		Macro_ActionTXT.Text = string.format('Action: %s', Step)
		Macro_TypeTXT.Text = string.format("Type: %s", TypesAndMeaning['spawn_unit'])
		Macro_UnitTXT.Text = string.format("Unit: %s", unitName)
		Macro_WaitTXT.Text = string.format("Waiting for: %s$", child._stats.total_spent.Value)

		Step +=1

		local lastSpent = child._stats.total_spent.Value
		local upgradeConnection
		local priorityConnection

		priorityConnection = child._stats.priority.Changed:Connect(function()

			Steps[tostring(Step)] = {
				['money'] = 0;
				['type'] = 'cycle_priority';
				['pos'] = tostring(child._shadow.CFrame);
				['unit'] = unitName
			}

			Macro_ActionTXT.Text = string.format('Action: %s', Step)
			Macro_TypeTXT.Text = string.format("Type: %s", TypesAndMeaning['cycle_priority'])
			Macro_UnitTXT.Text = string.format("Unit: %s", unitName)
			Macro_WaitTXT.Text = "Waiting for: 0$"

			Step +=1

		end)

		upgradeConnection = child._stats.total_spent.Changed:Connect(function(value)

			Steps[tostring(Step)] = {
				['money'] = value - lastSpent;
				['type'] = 'upgrade_unit_ingame';
				['pos'] = tostring(child._shadow.CFrame);
			}

			Macro_ActionTXT.Text = string.format('Action: %s', Step)
			Macro_TypeTXT.Text = string.format("Type: %s", TypesAndMeaning['upgrade_unit_ingame'])
			Macro_UnitTXT.Text = string.format("Unit: %s", unitName)
			Macro_WaitTXT.Text = string.format("Waiting for: %s$", value - lastSpent)

			Step +=1
			lastSpent = value

		end)
		table.insert(connections, upgradeConnection)



	end)

	connections[2] = workspace._UNITS.ChildRemoved:Connect(function(child)
		if child:WaitForChild('_stats').player.Value ~= player or not child._stats:FindFirstChild('uuid') then return end
		if not child:FindFirstChild('_shadow') then return end

		local unitName = nil

		for equippedUnitUUID, equippedUnitAbout in pairs(EquippedUnits) do
			if equippedUnitUUID ~= child._stats.uuid.Value or equippedUnitAbout.id ~= child._stats.id.Value then continue end
			unitName = equippedUnitAbout.id
		end

		if not unitName then return end

		Steps[tostring(Step)] = {
			['money'] = player._stats.resource.Value;
			['type'] = 'sell_unit_ingame';
			['pos'] = tostring(child._shadow.CFrame);
		}

		Macro_ActionTXT.Text = string.format('Action: %s', Step)
		Macro_TypeTXT.Text = string.format("Type: %s", TypesAndMeaning['sell_unit_ingame'])
		Macro_UnitTXT.Text = string.format("Unit: %s", unitName)
		Macro_WaitTXT.Text = string.format("Waiting for: %s$", math.ceil(player._stats.resource.Value) )


		Step+=1

	end)


	repeat task.wait() until not RecordingMacro

	MacroStatusTitle.Text = 'Macro Status: Recorded'
	Macro_ActionTXT.Text = 'Action:'
	Macro_TypeTXT.Text = 'Type:'
	Macro_UnitTXT.Text = "Unit:"
	Macro_WaitTXT.Text = "Waiting for:"

	for _, connection in ipairs(connections) do
		if connection then connection:Disconnect() end
	end

	writefile(MacroFile, HttpService:JSONEncode(Steps))

end

local TabsAndValues

local function PlayMacroFunc ()
	if RecordingMacro or not LevelData then return end
	local MacroFile = GetSave('Selected Macro')

	if LevelData.floor_num then
		MacroFile = GetSave('Selected Macro Map')['Tower'][LevelData._location_name]
	elseif LevelData._is_map_or_portal_level then
		MacroFile = GetSave('Selected Macro Map')['Portal'][LevelData._location_name]
	else
		MacroFile = GetSave('Selected Macro Map')['Raid'][LevelData._location_name]

		if not MacroFile then MacroFile = GetSave('Selected Macro Map')['Other'][LevelData._location_name] or GetSave('Selected Macro Map')['Other'][LevelData.name] end
		if not MacroFile and LevelData._gamemode ~= 'raid' then MacroFile = GetSave('Selected Macro Map')['Main'][LevelData._location_name] end
	end
	if not MacroFile then MacroFile = GetSave('Selected Macro') end

	if not MacroFile then return end


	local macroExist = isfile('Jung Hub\\Anime Adventures\\' .. MacroFile )
	local macroExistJson = isfile('Jung Hub\\Anime Adventures\\' .. MacroFile .. '.json')

	if macroExistJson then MacroFile = 'Jung Hub\\Anime Adventures\\' .. MacroFile .. '.json'
	elseif macroExist then MacroFile = 'Jung Hub\\Anime Adventures\\' .. MacroFile
	else return
	end

	MacroFile = HttpService:JSONDecode( readfile(MacroFile) )
	local TotalActions = 0
	local VisibleActions = 0
	local currentAction = 1

	for actionOrder, AboutAction in pairs(MacroFile) do
		if type(AboutAction) ~= 'table' then continue end

		if tonumber(actionOrder) and tonumber(actionOrder) > TotalActions then 
			TotalActions = tonumber(actionOrder)
		end 

		if not AboutAction['type'] or not TypesAndMeaning[ AboutAction['type'] ] then continue end
		if not AboutAction['money'] then AboutAction.unit = nil AboutAction.pos = nil AboutAction.cframe = nil AboutAction['type'] = nil continue end
		VisibleActions += 1


	end

	LastMacroStartedAt = tick()
	local CurrentMacroStartedAt = LastMacroStartedAt
	local MacroEnded = false
	MacroStatusTitle.Text = 'Macro Status: Playing'

	task.spawn(function()

		for actionNumb = 1, TotalActions do
			if LastMacroStartedAt ~= CurrentMacroStartedAt then break end

			local AboutAction = MacroFile[ tostring(actionNumb) ] if not AboutAction then continue end
			local unitName = AboutAction['unit']
			local unit = nil
			local unitUUID
			if not TypesAndMeaning[ AboutAction['type'] ] then continue end

			if AboutAction['type'] ~= 'spawn_unit' then 
				local distance = 10 --if AboutAction['type'] == 'sell_unit_ingame' then distance = 0.3 end

				for _, unitInWorkspace in ipairs(workspace._UNITS:GetChildren()) do
					if not unitInWorkspace:FindFirstChild('_shadow') then continue end
					local newDistance = ( unitInWorkspace._shadow.Position - StringToCFrame(AboutAction.pos).Position ).Magnitude 
					if unitInWorkspace:WaitForChild('_stats'):WaitForChild('player').Value ~= player or distance < newDistance then continue end

					local cappedUpgrade = false

					if AboutAction['type'] == 'upgrade_unit_ingame' then


						for equippedslot, unitAbout in pairs(EquippedUnitsAbout) do
							if unitAbout.id ~= unitInWorkspace._stats.id.Value then continue end
							if unitAbout.uuid ~= unitInWorkspace._stats.uuid.Value then continue end							
							if #unitAbout.upgrades <= unitInWorkspace._stats.upgrade.Value then cappedUpgrade = true break end
						end

					end

					if cappedUpgrade then continue end

					distance = newDistance
					unit = unitInWorkspace
					unitName = unitInWorkspace.Name

				end
			else
				for uuid, aboutUnit in pairs(EquippedUnits) do
					if aboutUnit.id ~= unitName then continue end
					unitName = aboutUnit.id
					unitUUID = uuid
					break
				end
			end

			if not unitName then continue end

			Macro_ActionTXT.Text = string.format('Action: %s/%s', currentAction, VisibleActions)
			Macro_TypeTXT.Text = string.format("Type: %s", TypesAndMeaning[ AboutAction['type'] ])
			Macro_UnitTXT.Text = string.format("Unit: %s", unitName)
			Macro_WaitTXT.Text = string.format("Waiting for: %s$", math.ceil(AboutAction['money']) )
			currentAction += 1

			repeat task.wait()
			until player._stats.resource.Value >= AboutAction.money or LastMacroStartedAt ~= CurrentMacroStartedAt task.wait(0.1)
			if LastMacroStartedAt ~= CurrentMacroStartedAt then break end

			if AboutAction['type'] == 'spawn_unit' then
				local unitsBefore = 0
				for _, unitInWorkspace in ipairs(workspace._UNITS:GetChildren()) do
					if not unitInWorkspace:FindFirstChild('_shadow') then continue end
					if not unitInWorkspace:FindFirstChild("_stats"):FindFirstChild('id') or unitInWorkspace._stats.id.Value ~= unitName then continue end
					if unitInWorkspace._stats:WaitForChild('player').Value ~= player or unitInWorkspace._stats:WaitForChild('uuid').Value ~= unitUUID then continue end
					unitsBefore += 1
				end

				task.spawn(function() Event['spawn_unit']:InvokeServer( unitUUID, StringToCFrame( AboutAction['cframe'] ) ) end)

				local tries = 0
				repeat
					task.wait(0.1)
					tries += 1
					local unitsCounted = 0

					for _, unitInWorkspace in ipairs(workspace._UNITS:GetChildren()) do
						if not unitInWorkspace:FindFirstChild('_shadow') then continue end
						if not unitInWorkspace:FindFirstChild("_stats"):FindFirstChild('id') or unitInWorkspace._stats.id.Value ~= unitName then continue end
						if unitInWorkspace._stats:WaitForChild('player').Value ~= player or unitInWorkspace._stats:WaitForChild('uuid').Value ~= unitUUID then continue end
						unitsCounted += 1
					end

					if unitsCounted ~= unitsBefore then unitsBefore = -1 end
				until unitsBefore == -1 or tries >= 25

			else
				task.spawn(function() Event[ AboutAction['type'] ]:InvokeServer(unit) end)
			end

			task.wait( math.clamp( tonumber(GetSave('Step Delay')), 0.2, 10) )
		end

		MacroEnded = true

	end)


	repeat task.wait() until MacroEnded or LastMacroStartedAt ~= CurrentMacroStartedAt

	Macro_TypeTXT.Text = "Type:"
	Macro_UnitTXT.Text = "Unit:"
	Macro_WaitTXT.Text = "Waiting for:"

	if LastMacroStartedAt == CurrentMacroStartedAt then 
		MacroStatusTitle.Text = 'Macro Status: Ended'
		Macro_ActionTXT.Text = string.format('Action: %s/%s', TotalActions, TotalActions)
	else
		MacroStatusTitle.Text = 'Macro Status: None'
		Macro_ActionTXT.Text = 'Action:'
	end

end


RecordMacro.MouseButton1Click:Connect(function()
	if LastMacroStartedAt ~= nil then return end

	RecordingMacro = not RecordingMacro
	RecordMacro.Parent.BackgroundColor3 = checkBoxColors[RecordingMacro]
	if not RecordingMacro then return end

	RecordMacroFunc()

end)

PlayMacro.MouseButton1Click:Connect(function()
	if RecordingMacro then return end

	local enabled = not GetSave(PlayMacro.Name)
	Save(PlayMacro.Name, enabled)

	PlayMacro.Parent.BackgroundColor3 = checkBoxColors[enabled]

	if not enabled then LastMacroStartedAt = nil return end

	PlayMacroFunc()
end)

if GetSave(PlayMacro.Name) then PlayMacro.Parent.BackgroundColor3 = checkBoxColors[true] spawn(function() PlayMacroFunc() end) end

local function MoveSlider(slider, min, max, step, abbr)

	local xOffset = math.floor((mouse.X - slider.AbsolutePosition.X) + 0.5) 
	local xOffsetClamped = math.clamp(xOffset, 0, slider.AbsoluteSize.X )

	local roundedAbsSize = math.floor(slider.AbsoluteSize.X + 0.5) 
	local RoundedOffsetClamped = math.floor(xOffsetClamped + 0.5)

	local sliderValue =  RoundedOffsetClamped / roundedAbsSize
	local newValue = sliderValue * max

	local resultValue = math.clamp( newValue - newValue % step, min, max)
	local intervalValue = math.clamp( newValue, min, max)
	if intervalValue-resultValue >= step/2 and resultValue >0 then resultValue += step end

	if resultValue <1 then resultValue = math.floor( ((resultValue*100)+0.5) )/100 else resultValue = math.floor(resultValue) end



	slider.Frame.Size = UDim2.new(math.clamp(resultValue/max, 0, 1), 0, 1, 0)

	if not slider.Parent:FindFirstChild('TextBox') then 
		slider.Parent.AmountLabel.Text = string.format("[%s/%s]", resultValue, max)
	else
		slider.Parent.TextBox.Text = string.format("%s %s", resultValue, abbr)
	end


	return resultValue

end

local function SliderBoxFunc (sliderFrame, keyName, abbr, max)
	local newStepDelay = tonumber(sliderFrame.TextBox.Text)
	if not newStepDelay or newStepDelay <=0 then return end 
	sliderFrame.TextBox.Text = sliderFrame.TextBox.Text .. ' ' .. abbr

	Save(keyName, newStepDelay)

	sliderFrame.slider.Frame.Size = UDim2.new(math.clamp(newStepDelay /max, 0, 1), 0, 1, 0)
end

StepDelaySlider.TextBox.FocusLost:Connect(function()
	SliderBoxFunc(StepDelaySlider, "Step Delay", 'seconds', 1)
end)
StepDelaySlider.TextBox.Text = string.format("%s seconds", GetSave("Step Delay"))
StepDelaySlider.slider.Frame.Size = UDim2.new(math.clamp(GetSave("Step Delay"), 0, 1), 0, 1, 0)


local function sliderFunc (slideFrame, keyName, min, max, step, abbr)
	local connections = {}

	local resultValue = 0

	connections[1] = mouse.Move:Connect(function()
		resultValue = MoveSlider(slideFrame.slider, min, max, step, abbr)
	end)

	connections[2] = mouse.Button1Up:Connect(function()
		for _,connection in ipairs(connections) do if connection then connection:Disconnect() end end

		if not tonumber(abbr) then
			Save(keyName, resultValue)
		else
			local oldSave = GetSave(keyName)
			oldSave[tostring(abbr)] = resultValue

			Save(keyName, oldSave)
		end
	end)

	connections[3] = slideFrame.slider.SliderButton.MouseButton1Up:Connect(function()
		for _,connection in ipairs(connections) do if connection then connection:Disconnect() end end

		if not tonumber(abbr) then
			Save(keyName, resultValue)
		else
			local oldSave = GetSave(keyName)
			oldSave[tostring(abbr)] = resultValue

			Save(keyName, oldSave)
		end
	end)
end

for unitNumb, sliderFrame in ipairs(AP_PlaceCapSliders) do
	sliderFrame.slider.SliderButton.MouseButton1Down:Connect(function()
		sliderFunc(sliderFrame, "AutoPlacesCap", 0, 6, 1, unitNumb)
	end)

	sliderFrame.AmountLabel.Text = string.format("[%s/%s]", GetSave('AutoPlacesCap')[tostring(unitNumb)] , "6")
	sliderFrame.slider.Frame.Size = UDim2.new(math.clamp(GetSave("AutoPlacesCap")[tostring(unitNumb)]/6, 0, 1), 0, 1, 0)

end

for unitNumb, sliderFrame in ipairs(AP_UpgradeCapSliders) do
	sliderFrame.slider.SliderButton.MouseButton1Down:Connect(function()
		sliderFunc(sliderFrame, "AutoUpgradesCap", 0, 15, 1, unitNumb)
	end)

	sliderFrame.AmountLabel.Text = string.format("[%s/%s]", GetSave('AutoUpgradesCap')[tostring(unitNumb)], "15")
	sliderFrame.slider.Frame.Size = UDim2.new(math.clamp(GetSave("AutoUpgradesCap")[tostring(unitNumb)]/15, 0, 1), 0, 1, 0)

end

StartAfterTimePortal.slider.SliderButton.MouseButton1Down:Connect(function()
	sliderFunc(StartAfterTimePortal, "PortalUSE Start After Time", 0, 60, 1, 'seconds')
end)

StartAfterTimePortal.TextBox.FocusLost:Connect(function()
	SliderBoxFunc(StartAfterTimePortal, "PortalUSE Start After Time", 'seconds', 60)
end)
StartAfterTimePortal.TextBox.Text = string.format("%s seconds", GetSave("PortalUSE Start After Time"))
StartAfterTimePortal.slider.Frame.Size = UDim2.new(math.clamp(GetSave("PortalUSE Start After Time")/60, 0, 1), 0, 1, 0)

StartAfterPlayersPortal.slider.SliderButton.MouseButton1Down:Connect(function()
	sliderFunc(StartAfterPlayersPortal, "PortalUSE Star After Players", 0, 6, 1, 'players')
end)

StartAfterPlayersPortal.TextBox.FocusLost:Connect(function()
	SliderBoxFunc(StartAfterPlayersPortal, "PortalUSE Star After Players", 'players', 6)
end)
StartAfterPlayersPortal.TextBox.Text = string.format("%s players", GetSave("PortalUSE Star After Players"))
StartAfterPlayersPortal.slider.Frame.Size = UDim2.new(math.clamp(GetSave("PortalUSE Star After Players")/6, 0, 1), 0, 1, 0)


StepDelaySlider.slider.SliderButton.MouseButton1Down:Connect(function()
	sliderFunc(StepDelaySlider, "Step Delay", 0, 1, 0.01, 'seconds')

end)

selectedMacroDDL.MouseButton1Click:Connect(function()
	local MacrosList = listfiles('Jung Hub\\Anime Adventures')

	local items = {}

	for _, macro in ipairs(MacrosList) do
		local macroName = string.match(string.sub(macro, 28), "[^.]+")

		table.insert(items, macroName)

	end

	GetDDL(selectedMacroDDL, items, false, 'Selected Macro')
end)

DDLlabel(selectedMacroDDL, GetSave('Selected Macro'))
if IsLobby then getMacroUnits(GetSave('Selected Macro'), MacroUnitsTextBlocks) end


createMacroBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed and createMacroBox.Text ~= '' then return end

	writefile('Jung Hub\\Anime Adventures\\' .. createMacroBox.Text .. '.json', HttpService:JSONEncode({}))
end)

deleteMacroButton.MouseButton1Click:Connect(function()

	local item = selectedMacroDDL.TextLabel.Text
	if item == "" or item == "None" then return end

	local macroExist = isfile('Jung Hub\\Anime Adventures\\' .. item)
	local macroExistjson = isfile('Jung Hub\\Anime Adventures\\' .. item .. '.json')
	if macroExistjson then item = item .. '.json' end

	if not macroExist and not macroExistjson then return end

	delfile('Jung Hub\\Anime Adventures\\' .. item)

	Save("Selected Macro", "")
	DDLlabel(selectedMacroDDL, GetSave('Selected Macro'))

end)

equippingMacroUnits = false
equipMacroUnitsButton.MouseButton1Click:Connect(function()
	if equippingMacroUnits or GetSave('Selected Macro') == "" then return end
	equippingMacroUnits = true

	local macroSelected = GetSave('Selected Macro')

	local macroExist = isfile('Jung Hub\\Anime Adventures\\' .. macroSelected)
	local macroExistjson = isfile('Jung Hub\\Anime Adventures\\' .. macroSelected .. '.json')
	if macroExistjson then macroSelected = macroSelected .. '.json' end

	if not macroExist and not macroExistjson then equippingMacroUnits = false return end

	local MacroAbout = HttpService:JSONDecode( readfile( 'Jung Hub\\Anime Adventures\\' .. macroSelected) )
	Event['unequip_all']:InvokeServer()

	local alrEquipped = {}
	local unitsFromMacro = {}
	for _, macroTabl in pairs(MacroAbout) do
		if not macroTabl['type'] or macroTabl['type'] ~= 'spawn_unit' then continue end
		table.insert(unitsFromMacro, macroTabl.unit)
	end

	for _, unitName in ipairs(unitsFromMacro) do

		for _, unitInfo in pairs(get_Units_Owner()) do
			if unitInfo['unit_id'] ~= unitName or table.find(alrEquipped, unitName) then continue end

			Event['equip_unit']:InvokeServer(unitInfo['uuid']) table.insert(alrEquipped, unitName)
			task.wait(0.5)
		end

	end

	equippingMacroUnits = false
end)

selectedCapsulesDDL.MouseButton1Click:Connect(function()

	local items = GetSave('Ignored Capsules')

	for itemKey, itemData in pairs(get_inventory_items()) do
		if not string.find(itemKey, 'capsule') then continue end
		local itemName = oldItemsData[itemKey].Name

		if table.find(items, itemName) then continue end

		table.insert(items, itemName)

	end

	GetDDL(selectedCapsulesDDL, items, true, 'Ignored Capsules')

end)

DDLlabel(selectedCapsulesDDL, GetSave('Ignored Capsules'))

local function AutoOpenCapsulesFunc ()
	if not IsLobby then return end

	while GetSave(AutoOpenCapsules.Name) do

		local IgnoreCapsules = GetSave('Ignored Capsules')

		for itemKey, itemData in pairs(RefreshedNormalItems) do
			if not string.find(itemKey, 'capsule') then continue end
			local itemName = oldItemsData[itemKey].Name

			if table.find(IgnoreCapsules, itemName) then continue end
			local moreThanTen = itemData >=10

			Event['use_item']:InvokeServer(itemKey, {['use10'] = moreThanTen})
			task.wait(0.1)

		end


		task.wait(0.05)

	end

end


skinsRarityColors = {
	Rare = '<font color="#0787ff">[Rare]</font> %s',
	Epic = '<font color="#cc00ff">[Epic]</font> %s',
	Legendary = '<font color="#ffff00">[Legendary]</font> %s',
	Mythic = '<font color="#f475ff">[Mythic]</font> %s',
	--[nil] = '<font color="#ffffff">%s</font>'
}

selectedSkinsDDL.MouseButton1Click:Connect(function()
	local items = GetSave('Delete Skins')

	for _, itemData in pairs(get_inventory_items_unique_items()) do
		if not itemData['item_id'] or not string.find(itemData['item_id'], 'skin') then continue end
		local itemName = oldItemsData[itemData['item_id']].Name
		itemName = string.sub(itemName, 37)
		itemName = string.format(skinsRarityColors[oldItemsData[itemData['item_id']].Rarity], itemName )

		if table.find(items, itemName) then continue end

		table.insert(items, itemName)

	end


	GetDDL(selectedSkinsDDL, items, true, 'Delete Skins')

end)

DDLlabel(selectedSkinsDDL, GetSave('Delete Skins'))

local function AutoDeleteSkinsFunc ()
	if not IsLobby then return end

	while GetSave(AutoDeleteSkins.Name) do
		local DeleteSkins = GetSave('Delete Skins')
		local willBeDeleted = {}

		for _, itemData in pairs(RefreshedUniqueItems) do
			if not itemData['item_id'] or not string.find(itemData['item_id'], 'skin') then continue end
			local itemName = oldItemsData[itemData['item_id']].Name
			itemName = string.sub(itemName, 37)
			itemName = string.format(skinsRarityColors[oldItemsData[itemData['item_id']].Rarity], itemName )

			if not table.find(DeleteSkins, itemName) then continue end
			table.insert(willBeDeleted, itemData['uuid'])

		end

		if #willBeDeleted >= 1 then Event['delete_unique_items']:InvokeServer(willBeDeleted) end

		task.wait(0.05)
	end
end

---------------------------------------------------------------------

local map

if not workspace:FindFirstChild('_npcs') then
	map = {
		{oldParent = workspace:WaitForChild('_map'), childs = workspace:WaitForChild('_map'):GetChildren() };
		{oldParent = workspace._terrain.terrain, childs = workspace:WaitForChild('_terrain'):WaitForChild('terrain'):GetChildren()  }

	}
end


local function endGameFunc ()
	if not GameFinished or not GameFinished.Value then return end

	task.spawn(function()

		while true do

			if GetSave(AutoLeave.Name) then TPLobby()
			elseif GetSave(AutoNextPortal.Name) and LevelData._is_map_or_portal_level then
				local Portal = getPortalUSE() if not Portal then wait(2) continue end
				Event['set_game_finished_vote']:InvokeServer('replay', {item_uuid = Portal})
			elseif  GetSave(AutoRetry.Name) and ResultUI.Holder.Title.Text == 'DEFEAT' then
				if LevelData.floor_num then
					Event['request_start_infinite_tower_from_game']:InvokeServer()
				else
					Event['set_game_finished_vote']:InvokeServer('replay')

				end


			elseif GetSave(AutoNextLevel.Name) and ResultUI.Holder.Title.Text ~= 'DEFEAT' then
				if LevelData.floor_num then Event['request_start_infinite_tower_from_game']:InvokeServer('NextRetry')
				else Event['set_game_finished_vote']:InvokeServer('next_story')
				end
			elseif GetSave(AutoRetry.Name) then
				Event['set_game_finished_vote']:InvokeServer('replay')
			end

			task.wait(5)
		end
	end)

end

local function TurnOFFRedZones ()
	if IsLobby then return end

	while GetSave(PlaceInRedZones.Name) do

		local _bounds = workspace.ignore:FindFirstChild('_bounds')

		if _bounds then

			for _, item in ipairs(_bounds:GetDescendants()) do
				if not item:IsA('Part') and not item:IsA('MeshPart') and not item:IsA('UnionOperation') then continue end
				--item.CollisionGroup = "PartNotCollide"
				item:Destroy()
			end

		end

		task.wait()
	end

end

autoBuffActivatedTime = {}
autoBuffOrder = {"1", "3", "2", "4"}
local function AutoBuffFunc (unitID, keySave)
	if IsLobby then return end

	local activatedAutoBuff = tick()
	autoBuffActivatedTime[unitID] = activatedAutoBuff

	while GetSave(keySave) and activatedAutoBuff == autoBuffActivatedTime[unitID] do
		local unitsFolder = {}

		for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
			if not unitWorkspace:FindFirstChild('_stats') or not unitWorkspace._stats:FindFirstChild('player') or unitWorkspace._stats.player.Value ~= player then continue end
			if unitWorkspace._stats.id.Value ~= unitID then continue end
			table.insert(unitsFolder, unitWorkspace)
		end

		if #unitsFolder >=4 then
			local allFourOnMap = true

			task.wait(1)
			while GetSave(keySave) and activatedAutoBuff == autoBuffActivatedTime[unitID] and allFourOnMap do

				for int=1,4 do
					if not GetSave(keySave) or activatedAutoBuff ~= autoBuffActivatedTime[unitID] or not allFourOnMap then continue end
					for _, unitWorkspace in ipairs(unitsFolder) do if not unitWorkspace or not unitWorkspace.Parent or unitWorkspace.Parent ~= workspace._UNITS then allFourOnMap = false continue end end

					Event['use_active_attack']:InvokeServer(  unitsFolder[ tonumber(autoBuffOrder[int]) ]  )
					local AbilityCooldown = unitsFolder[ tonumber(autoBuffOrder[int]) ]._stats.active_attack_cooldown if AbilityCooldown then AbilityCooldown = AbilityCooldown.Value/4 + 0.1 else AbilityCooldown = 15.4 end
					task.wait( math.clamp(AbilityCooldown, 15.4, 60) )
				end

				task.wait()
			end


		end



		task.wait(0.1)
	end

end

autoUseAbilityActivatedTime = {}
local function AutoUseAbilityFunc (unitID, keySave)
	if IsLobby then return end

	local activatedAutoUseAbility = tick()
	autoUseAbilityActivatedTime[unitID] = activatedAutoUseAbility

	local function useAbility (unitWorkspace)
		if not unitWorkspace:WaitForChild('_stats') or not unitWorkspace._stats:WaitForChild('player') or unitWorkspace._stats.player.Value ~= player then return end
		if unitWorkspace._stats.id.Value ~= unitID then return end

		task.wait(1)
		while GetSave(keySave) and activatedAutoUseAbility == autoUseAbilityActivatedTime[unitID] and unitWorkspace and unitWorkspace.Parent and unitWorkspace.Parent == workspace._UNITS do

			Event['use_active_attack']:InvokeServer( unitWorkspace )
			task.wait(unitWorkspace._stats.active_attack_cooldown.Value)
		end
	end

	for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
		task.spawn(function() useAbility(unitWorkspace) end)
	end

	local newUnitsUseAbility
	newUnitsUseAbility = workspace._UNITS.ChildAdded:Connect(useAbility)

	repeat task.wait(0.1)
	until not GetSave(keySave) or activatedAutoUseAbility ~= autoUseAbilityActivatedTime[unitID]

	newUnitsUseAbility:Disconnect()

end

local function checkBoxFunc (checkBox, checkBoxF, checkBoxFuncValue, CustomKey)
	local keySave = CustomKey or checkBox.Name

	checkBox.MouseButton1Click:Connect(function()
		local enabled = not GetSave(keySave)
		Save(keySave, enabled)

		checkBox.Parent.BackgroundColor3 = checkBoxColors[enabled]
		if not enabled then return end

		if checkBoxF then checkBoxF(checkBoxFuncValue, checkBox.Name) end
	end)

	if GetSave(keySave) then 
		checkBox.Parent.BackgroundColor3 = checkBoxColors[true]
		if checkBoxF then task.spawn(function() checkBoxF(checkBoxFuncValue, checkBox.Name) end) end
	end


end

local function ClaimQuestsFunc()
	if not IsLobby then return end

	while GetSave(AutoClaimQuests.Name) do
		local Quests = ItemInventoryServiceClient["session"]['quest_handler']['quest_profile_data']['quests']
		local dailyQuests = {}
		local dailyMain

		for questId, questTable in pairs(Quests) do
			if questTable.quest_type and questTable.quest_type == 'daily' then table.insert(dailyQuests, questId) if not questTable.quest_progress then dailyMain = questId end end
			if not questTable['quest_progress'] then Event['redeem_quest']:InvokeServer(questId) task.wait(0.15) continue end
			if not questTable['quest_info'] or not questTable['quest_info']['quest_class'] then continue end
			if not questTable['quest_progress'].amount or not questTable['quest_info']['quest_class'].amount then continue end
			if questTable['quest_progress'].amount < questTable['quest_info']['quest_class'].amount then continue end
			local expiry_time = questTable['quest_info']['expiry_time']
			local creation_time = questTable['creation_time']
			if not expiry_time or not creation_time or expiry_time <= os.time() then continue end

			Event['redeem_quest']:InvokeServer(questId)
			task.wait(0.15)

		end

		if #dailyQuests == 1 and dailyMain then Event['redeem_quest']:InvokeServer(dailyMain) end



		task.wait(0.1)
	end

end

local function AutoTakeDailyQuestFunc ()
	if not IsLobby then return end

	while GetSave(AutoTakeDailyQuests.Name) do
		local Quests = ItemInventoryServiceClient["session"]['quest_handler']['quest_profile_data']['quests']

		for _, module in pairs(RS.src.Data	.QuestsEvent:GetDescendants()) do
			if not module:IsA('ModuleScript') then continue end
			local AboutQuest = require(module)

			for questID, questTable in pairs(AboutQuest) do
				if questTable['_EVENT_EXPIRED'] == nil or questTable['_EVENT_EXPIRED'] or not questTable['_AVAILABLE_NPC_QUEST'] then continue end
				local lastAccept = ItemInventoryServiceClient['session']['quest_handler']['quest_profile_data']['quests_cooldown_last_accept'][questTable.id]
				local acceptedDayAgo = lastAccept and os.time() - lastAccept >=86400

				if acceptedDayAgo  then Event['accept_npc_quest']:InvokeServer(questTable.id) end

				task.wait(0.5)
			end

		end



		task.wait(1)
	end
end

local function AutoTakeNamiQuestsFunc ()
	if not IsLobby then return end

	Event['request_claim_dailymission']:InvokeServer("mha 12.0.0_dailymission_opm_daily")

	while GetSave(AutoTakeNamiQuests.Name) do
		local ClaimedDailyQuests = ItemInventoryServiceClient["session"]['profile_data']['dailymissions_data']['claimed_missions']


		for _,QuestEventModule in ipairs(game.ReplicatedStorage.src.Data.QuestsEvent:GetDescendants()) do
			if not QuestEventModule:IsA('ModuleScript') then continue end

			for questID, aboutQuest in pairs( require(QuestEventModule) ) do
				if not aboutQuest._event_repeatable_quest or aboutQuest._AVAILABLE_NPC_QUEST ~= false then continue end
				local eventrepQuestID = string.format('mha 12.0.0_dailymission_%s', questID)

				if not ClaimedDailyQuests[ eventrepQuestID ] then

					Event['request_claim_dailymission']:InvokeServer(eventrepQuestID) task.wait(0.1)
				end


			end

		end

		task.wait(1)
	end
end

--- AUTOPLACE AVAILABLE HILL POINTS
hillPoints = {}
if not IsLobby then
	local amountGroundPoints = 0 for _,lane in ipairs(workspace._BASES.pve.LANES['1']:GetChildren()) do if not tonumber(lane.Name) then continue end amountGroundPoints += 1 end

	for groundPoint = 1, math.clamp(amountGroundPoints, 1, 6) do
		if groundPoint >= #workspace._terrain.hill:GetChildren() then break end
		local groundPart = workspace._BASES.pve.LANES['1'][tostring(groundPoint)]
		local chosenHill
		local chosenPoint
		local distance = 99999

		for _, hillPart in ipairs(workspace._terrain.hill:GetDescendants()) do
			if not hillPart:IsA('Part') and not hillPart:IsA('MeshPart') and not hillPart:IsA('UnionOperation') then continue end
			local hillused = false

			for _, hillpos in pairs(hillPoints) do if (hillpos.pos - (hillPart.Position + Vector3.new(0, hillPart.Size.Y/2 + 0.5,0) ) ).Magnitude <= 5 then hillused = true break end end
			if hillused then continue end
			local newdistance = (hillPart.Position - groundPart.Position).Magnitude
			local hillpartCanBeUsed = {['0'] = true, ['1'] = true}			

			for yOffest = 0, 1 do
				for unitOrder=0,3 do
					local xAxis = (unitOrder % 2 ) * 1.9
					local zAxis = math.floor(unitOrder / 4 + 0.5) * 1.9

					local possiblePosition = hillPart.Position + Vector3.new(0, hillPart.Size.Y/2, 0) + Vector3.new( xAxis , 1 + 10 * yOffest, zAxis ) 

					local possiblePositionRaycast = RaycastParams.new()
					possiblePositionRaycast.FilterDescendantsInstances = {workspace._terrain.hill, workspace._terrain.terrain}
					possiblePositionRaycast.FilterType = Enum.RaycastFilterType.Include
					possiblePositionRaycast.IgnoreWater = true

					local possiblePositionResult = workspace:Raycast(possiblePosition, Vector3.new(0,-2 + -15 * yOffest,0), possiblePositionRaycast)

					if not possiblePositionResult or possiblePositionResult.Instance.Parent.Name ~= 'hill' then hillpartCanBeUsed[tostring(yOffest)] = false break end

				end
			end



			if newdistance < distance and (hillpartCanBeUsed['0'] or hillpartCanBeUsed['1']) then 
				distance = newdistance chosenHill = hillPart
				chosenPoint = 1 if hillpartCanBeUsed['0'] then chosenPoint = 0 end
			end

		end

		if not chosenHill then continue end
		newHillPos = chosenHill.Position + Vector3.new(0, chosenHill.Size.Y/2 + 0.5, 0)
		hillPoints[groundPoint] = {pos = newHillPos, inst = chosenHill, yOfsset = chosenPoint, used = false}
	end

end

groundPoints = {}
if not IsLobby then
	local totalPoints = 0 for _,point in ipairs(workspace._BASES.pve.LANES['1']:GetChildren()) do if tonumber(point.Name) then totalPoints += 1 end end
	local chosenPoints = 0

	for point = 1, totalPoints do
		if chosenPoints >=6 then break end


		local groundPoint = workspace._BASES.pve.LANES['1'][tostring(point)]
		local Available = true

		for _, otherPoint in pairs(groundPoints) do
			if (otherPoint - groundPoint.Position).Magnitude > 10 then continue end
			Available = false break
		end

		if not Available then continue end

		for onMap = 0,5 do

			local possiblePosition = groundPoint.Position + Vector3.new( (onMap % 3 ) * 4 , 0, math.floor(onMap / 6 + 0.5) * 4 ) + Vector3.new(0,10,0)

			local possiblePositionRaycast = RaycastParams.new()
			possiblePositionRaycast.FilterDescendantsInstances = {workspace._terrain.ground}
			possiblePositionRaycast.FilterType = Enum.RaycastFilterType.Include
			possiblePositionRaycast.IgnoreWater = true

			local possiblePositionResult = workspace:Raycast(possiblePosition, Vector3.new(0,-15,0), possiblePositionRaycast)

			if not possiblePositionResult then Available = false break end
		end

		if not Available then continue end

		chosenPoints += 1
		groundPoints[tostring(chosenPoints)] = groundPoint.Position

	end
end

local cannotBePlacedAnywhere = {}
local farmUnits = {'speedwagon', 'bulma', 'nami_evolved'}
local function getNextMoveAUTOGAME ()
	local playerMoney = player._stats.resource.Value
	local focusFarm = GetSave(FocusOnFarmAutoPlace.Name)
	local returnUnitInfo = {}
	local returnMethod
	local unitPos
	local amountOnMap
	local sendTable = {}
	if GetSave(AutoPlaceTurnOn.Name) and not returnMethod and GetSave('AutoPlaceUnitsWave') <= workspace._wave_num.Value then
		local AutoSF = GetSave(AutoSellFarms.Name)
		local AutoSFWave = GetSave('AutoSellFarmsWave')

		for unitSlot = 1, 6 do
			local unitInfo = EquippedUnitsAbout[ tostring(unitSlot) ] if not unitInfo then continue end
			if playerMoney < unitInfo.cost * workspace._DATA.LevelModifiers.player_cost_scale.Value then continue end
			local globalcap =  unitInfo.global_spawn_cap
			local spawncap = unitInfo.spawn_cap

			if GetSave('AutoPlacesCap')[tostring(unitSlot)] <= spawncap then
				spawncap = GetSave('AutoPlacesCap')[tostring(unitSlot)]
			end
			if AutoSF and tonumber(AutoSFWave) <= workspace._wave_num.Value and table.find(farmUnits, unitInfo.id) then continue end

			if spawncap <=0 then continue end
			local onMap = {}
			local onMapGlobal = {}

			for _, unitOnMap in ipairs(workspace._UNITS:GetChildren()) do
				if not unitOnMap:FindFirstChild('_stats') or not unitOnMap._stats:FindFirstChild('uuid') or unitOnMap._stats.uuid.Value ~= unitInfo.uuid then continue end
				if unitOnMap._stats:WaitForChild('id').Value ~= unitInfo.id then continue end

				if unitOnMap._stats.player.Value == player then table.insert(onMap, unitOnMap)
				elseif globalcap then table.insert(onMapGlobal, unitOnMap)	
				end

			end

			if #onMap >= spawncap or #onMap >= unitInfo.spawn_cap or (globalcap and #onMapGlobal >= globalcap) then continue end

			returnUnitInfo = unitInfo
			returnUnitInfo.slot = unitSlot
			sendTable = {unitInfo.uuid}
			amountOnMap = #onMap
			unitPos = unitSlot
			returnMethod = 'spawn_unit'
			break
		end

		if unitPos then

			if returnUnitInfo.hill then

				local point

				local savedPosition = GetSave('AutoPlacePositions')
				if savedPosition[LevelData.map] and savedPosition[LevelData.map][ 'Unit' .. unitPos ] then point = StringToCFrame( savedPosition[LevelData.map][ 'Unit' .. unitPos ]).Position end

				local spawncap = returnUnitInfo.spawn_cap
				if GetSave('AutoPlacesCap')[tostring(returnUnitInfo.slot)] <= spawncap then spawncap = GetSave('AutoPlacesCap')[tostring(returnUnitInfo.slot)] end


				if not point and table.find(cannotBePlacedAnywhere, unitPos) then
					returnMethod = nil
					sendTable = {}
				end

				if point then
					local xAxis = (amountOnMap % ( spawncap/2 ) ) * 1.9
					local zAxis =  math.floor(amountOnMap / spawncap + 0.5) * 1.9

					unitPos = CFrame.new(point) + Vector3.new( xAxis , 0, zAxis )
				elseif not point and not table.find(cannotBePlacedAnywhere, unitPos) then
					for numberPlace, pointAbout in ipairs(hillPoints) do
						if pointAbout.used and pointAbout.used ~= unitPos then continue end
						point = pointAbout
						hillPoints[numberPlace].used = unitPos
						break
					end
					if not point then table.insert(cannotBePlacedAnywhere, unitPos) return {} end

					local xAxis = (amountOnMap % (spawncap/2 ) ) * 1.9
					local zAxis =  math.floor(amountOnMap / spawncap + 0.5) * 1.9

					unitPos = CFrame.new(point.pos) + Vector3.new( xAxis , 1 + 10 * point.yOfsset, zAxis )

					local unitPosParams = RaycastParams.new()
					unitPosParams.FilterDescendantsInstances = {workspace._terrain.hill}
					unitPosParams.FilterType = Enum.RaycastFilterType.Include
					unitPosParams.IgnoreWater = true

					unitPos = workspace:Raycast(unitPos.Position, Vector3.new(0,-2 + -15 * point.yOfsset,0), unitPosParams)
					local yPOS = unitPos.Position.Y				
					unitPos = CFrame.new( Vector3.new(unitPos.Position.X, yPOS, unitPos.Position.Z) )

				end


			else
				local savedPosition = GetSave('AutoPlacePositions') 
				local point = groundPoints[ tostring(unitPos) ]
				if savedPosition[LevelData.map] and savedPosition[LevelData.map][ 'Unit' .. unitPos ] then point = StringToCFrame( savedPosition[LevelData.map][ 'Unit' .. unitPos ] ).Position end
				local spawncap = returnUnitInfo.spawn_cap

				if GetSave('AutoPlacesCap')[tostring(returnUnitInfo.slot)] <= spawncap then spawncap = GetSave('AutoPlacesCap')[tostring(returnUnitInfo.slot)] end

				local distanceBetweenUnits = 2 if returnUnitInfo.id == 'speedwagon' then distanceBetweenUnits = 4 end

				unitPos = CFrame.new( point + Vector3.new( (amountOnMap % (spawncap/2) ) * distanceBetweenUnits , 0, math.floor(amountOnMap / spawncap + 0.5) * distanceBetweenUnits ) )
			end

			if returnMethod then table.insert(sendTable, unitPos) end
		end
	end

	if GetSave(AutoUpgradeCheckBox.Name) and tonumber(GetSave('AutoUpgradeWave')) <= workspace._wave_num.Value and not returnMethod then

		local possibleUpgradeUnits = {}
		local possibleUpgradeFarmUnits = {}


		for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
			if not unitWorkspace:FindFirstChild('_stats') or not unitWorkspace._stats:FindFirstChild('player') or unitWorkspace._stats.player.Value ~= player then continue end
			if not unitWorkspace._stats:FindFirstChild('uuid') then continue end
			if not unitWorkspace._stats:FindFirstChild('upgrade') or not unitWorkspace._stats:FindFirstChild('upgrade_cost_multiplier') then continue end
			if not EquippedUnits[unitWorkspace._stats.uuid.Value] then continue end
			if EquippedUnits[unitWorkspace._stats.uuid.Value].id ~= unitWorkspace._stats.id.Value then continue end

			for equippedslot, unitAbout in pairs(EquippedUnitsAbout) do
				if unitAbout.id ~= unitWorkspace._stats.id.Value then continue end
				if unitWorkspace._stats.uuid.Value ~= unitAbout.uuid then continue end
				local upgradeCap = GetSave('AutoUpgradesCap')[tostring(equippedslot)]
				local upgradeAmount = #unitAbout.upgrades if unitWorkspace._stats.upgrade.Value >= upgradeAmount or unitWorkspace._stats.upgrade.Value >= upgradeCap then continue end
				local upgradecost = unitAbout.upgrades[ unitWorkspace._stats.upgrade.Value + 1 ].cost * unitWorkspace._stats.upgrade_cost_multiplier.Value * workspace._DATA.LevelModifiers.player_cost_scale.Value 
				if playerMoney < upgradecost then continue end

				if focusFarm and table.find(farmUnits, unitWorkspace._stats.id.Value) then possibleUpgradeFarmUnits[unitWorkspace] = upgradecost continue end

				possibleUpgradeUnits[unitWorkspace] = upgradecost

			end

		end

		if focusFarm then
			local possibleCost = 999999999

			for unitWorkspace, upgradecost in pairs(possibleUpgradeFarmUnits) do
				if upgradecost > possibleCost then continue end
				possibleCost = upgradecost
				sendTable = {unitWorkspace}
				returnMethod = 'upgrade_unit_ingame'
			end


		end

		if not returnMethod then
			local possibleCost = 999999999
			for unitWorkspace, upgradecost in pairs(possibleUpgradeUnits) do
				if upgradecost > possibleCost then continue end
				possibleCost = upgradecost
				sendTable = {unitWorkspace}
				returnMethod = 'upgrade_unit_ingame'
			end


		end

	end

	return {fireTable = sendTable, method = returnMethod}
end

local function AutoSellFunc (areFarms)

	for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
		if not unitWorkspace:FindFirstChild('_stats') or unitWorkspace._stats.player.Value ~= player then continue end
		if EquippedUnits[unitWorkspace._stats:WaitForChild('uuid').Value].id ~= unitWorkspace._stats:WaitForChild('id').Value then continue end
		if areFarms and not table.find(farmUnits, unitWorkspace._stats.id.Value) then continue end

		for _, unitAbout in pairs(EquippedUnitsAbout) do
			if unitAbout.id ~= unitWorkspace._stats.id.Value then continue end

			if not unitAbout.unsellable then task.spawn(function()  Event['sell_unit_ingame']:InvokeServer(unitWorkspace) task.wait(0.35) end) break end
		end


	end

end

autoUseAbilityUnitsTable = {'jotaro', 'eren_final', 'ainz_evolved', 'kisuke_evolved',
	'yamamoto_evolved', 'dio_heaven', 'aki_evolved', 'law_2_evolved', 'brook_evolved', 'gojo_evolved', 'pucci_heaven',
	'jotaro_p6_evolved', 'homura_evolved', 'diavolo', 'armin'

}
usedAutoSkillTime = nil

local function AutoUseSkillFunc ()

	local connections = {}
	local activatedTime = tick()
	usedAutoSkillTime = activatedTime

	local function MakeAutoUseSkill (unitWorkspace)
		if not unitWorkspace:WaitForChild('_stats') or not unitWorkspace._stats:WaitForChild('id') or not unitWorkspace._stats:WaitForChild('player') then return end
		if not oldItemsData[unitWorkspace._stats.id.Value] then return end
		if unitWorkspace._stats.player.Value ~= player or not table.find(GetSave('AutoSkillUnits'), oldItemsData[unitWorkspace._stats.id.Value].Name) then return end
		if not unitWorkspace._stats:WaitForChild('active_attack') or not unitWorkspace._stats:WaitForChild('active_attack_cooldown') then return end

		repeat task.wait(0.1) if not unitWorkspace or not unitWorkspace.Parent then return end until unitWorkspace._stats.active_attack.Value and unitWorkspace._stats.active_attack.Value ~= 'nil'

		while GetSave(AutoUseSkill.Name) and activatedTime == usedAutoSkillTime do
			local onBoss = GetSave(AutoSkillOnBoss.Name)

			if onBoss then
				local bossNear = false

				repeat
					if not unitWorkspace or not unitWorkspace.Parent then return end

					for _, unitInWorkspace in ipairs(workspace._UNITS:GetChildren()) do
						if not unitInWorkspace:FindFirstChild('bossIndicator') then continue end
						if (unitWorkspace._hitbox.Position - unitInWorkspace.PrimaryPart.Position).Magnitude < unitWorkspace._stats.range.Value then bossNear = true end
					end
					task.wait(0.1)
				until bossNear or not GetSave(AutoSkillOnBoss.Name)

			end

			task.spawn(function() Event['use_active_attack']:InvokeServer(unitWorkspace) end)
			task.wait(unitWorkspace._stats.active_attack_cooldown.Value)
			if not unitWorkspace or not unitWorkspace.Parent then return end
		end



	end

	for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
		task.spawn(function() MakeAutoUseSkill(unitWorkspace) end)
	end

	connections[1] = workspace._UNITS.ChildAdded:Connect(function(unitWorkspace)
		MakeAutoUseSkill(unitWorkspace)
	end)

	repeat task.wait() until not GetSave(AutoUseSkill.Name)

	for _, connection in ipairs(connections) do
		if connection then connection:Disconnect() end
	end

end

local function autoGamePLUS ()
	if IsLobby then return end

	while true do		
		local AutoPL = GetSave(AutoPlaceTurnOn.Name) -- AUTO PLACE
		local AutoUP = GetSave(AutoUpgradeCheckBox.Name) -- AUTO UPGRADE
		local AutoSU = GetSave(AutoSellUnits.Name) -- AUTO SELL UNITS
		local AutoSF = GetSave(AutoSellFarms.Name) -- AUTO SELL FARMS
		local AutoL = GetSave('AutoLeave_WAVE')

		local AutoSUWave = GetSave('AutoSellUnitsWave')
		local AutoSFWave = GetSave('AutoSellFarmsWave')
		local AutoLWave = GetSave('AutoLeaveOnWave')

		if AutoL and tonumber(AutoLWave) <= workspace._wave_num.Value then
			TPLobby()
		end

		if (AutoPL or AutoUP) and not (AutoSU and tonumber(AutoSUWave) <= workspace._wave_num.Value) then
			local nextMove = getNextMoveAUTOGAME()

			if nextMove.method then
				task.spawn(function()  Event[nextMove.method]:InvokeServer( table.unpack(nextMove.fireTable) ) end)
			end

		end

		if ( AutoSU and tonumber(AutoSUWave) <= workspace._wave_num.Value) or ( AutoSF and tonumber(AutoSFWave) <= workspace._wave_num.Value) then

			if AutoSU and tonumber(AutoSUWave) <= workspace._wave_num.Value then AutoSellFunc(false) end
			if AutoSF and tonumber(AutoSFWave) <= workspace._wave_num.Value then AutoSellFunc(true) end
		end

		task.wait(0.5)
	end


end

task.spawn(function() autoGamePLUS() end)

function HideNameFunc ()

	local playerModel = workspace:FindFirstChild(player.Name)
	repeat
		task.wait()
		playerModel = workspace:FindFirstChild(player.Name)
	until playerModel and playerModel:FindFirstChild('Head') and playerModel.Head:FindFirstChild('_overhead')

	playerModel.Head._overhead.Enabled = false
	player.PlayerGui.spawn_units.Lives.Main.Desc.Visible = false

	if not IsLobby then  
		local connections = {}

		connections[1] = workspace._UNITS.ChildAdded:Connect(function(unitWorkspace)
			if unitWorkspace:WaitForChild('_stats'):WaitForChild('player').Value ~= player then return end
			if not unitWorkspace.PrimaryPart:WaitForChild('_overhead', 1) then return end
			unitWorkspace.PrimaryPart._overhead.tds.Owner.Visible = false
		end)

		while GetSave(HideName.Name) do
			for _, ignorePart in ipairs(workspace.ignore:GetChildren()) do
				if not ignorePart:FindFirstChild('_overhead') or ignorePart._overhead.tds.Owner.Text ~= player.DisplayName then continue end
				ignorePart._overhead.tds.Owner.Text = ""
			end
			task.wait()
		end

		connections[1]:Disconnect()

	end

	repeat
		task.wait()
	until not GetSave(HideName.Name)

	playerModel.Head._overhead.Enabled = true
	player.PlayerGui.spawn_units.Lives.Main.Desc.Visible = true


end

function HideTabFunc (enabled)

	local userNameNew = 'Jung Hub'
	if not enabled then userNameNew = player.DisplayName end

	pcall(function()
		local PlayerNameTabFrame1 = game.CoreGui:WaitForChild('PlayerList'):WaitForChild('PlayerListMaster'):WaitForChild('OffsetFrame'):WaitForChild('PlayerScrollList'):WaitForChild('SizeOffsetFrame')
		local PlayerNameTabFrame2 = PlayerNameTabFrame1:WaitForChild('ScrollingFrameContainer'):WaitForChild('ScrollingFrameClippingFrame'):WaitForChild('ScollingFrame'):WaitForChild('OffsetUndoFrame'):WaitForChild('p_' .. player.UserId, 5)
		PlayerNameTabFrame2:WaitForChild('ChildrenFrame'):WaitForChild('NameFrame'):WaitForChild('BGFrame'):WaitForChild('OverlayFrame'):WaitForChild('PlayerName'):WaitForChild('PlayerName').Text = userNameNew
	end)

end

HideTab.MouseButton1Click:Connect(function()

	local enabled = not GetSave(HideTab.Name)
	Save(HideTab.Name, enabled)

	HideTab.Parent.BackgroundColor3 = checkBoxColors[enabled]

	pcall(function() HideTabFunc(enabled) end)

end)
if GetSave(HideTab.Name) then task.spawn(function() pcall(function() HideTabFunc(true) end) end) HideTab.Parent.BackgroundColor3 = checkBoxColors[true] end

bodyColorsNames = {'HeadColor3', 'LeftArmColor3', 'RightArmColor3', 'LeftLegColor3', 'RightLegColor3', 'TorsoColor3'}
oldBodyColors = {}
oldCosmetics = {}
function FakeOutfitFunc (enabled)

	if enabled then

		local bodyColors = player.Character:WaitForChild('Body Colors')

		for _, bodyColorName in ipairs(bodyColorsNames) do
			oldBodyColors[bodyColorName] = bodyColors[bodyColorName]
			bodyColors[bodyColorName] = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255))
		end

		task.spawn(function()

			while GetSave(FakeOutfit.Name) do
				player.Character:WaitForChild('Head'):WaitForChild('face').Transparency = 1
				for _, itemInCharacter in ipairs(player.Character:GetChildren()) do
					if not itemInCharacter:IsA('Accessory') and not itemInCharacter:IsA('Pants') and not itemInCharacter:IsA('Shirt') then continue end
					table.insert(oldCosmetics, itemInCharacter)
					itemInCharacter.Parent = RS
				end
				task.wait()
			end

		end)


	else
		player.Character:WaitForChild('Head'):WaitForChild('face').Transparency = 0

		local bodyColors = player.Character:WaitForChild('Body Colors')

		for bodyColorName, OLDclr in pairs(oldBodyColors) do
			bodyColors[bodyColorName] = OLDclr
		end

		for _, oldcosmetic in ipairs(oldCosmetics) do
			oldcosmetic.Parent = player.Character
		end
	end

end

FakeOutfit.MouseButton1Click:Connect(function()

	local enabled = not GetSave(FakeOutfit.Name)
	Save(FakeOutfit.Name, enabled)

	FakeOutfit.Parent.BackgroundColor3 = checkBoxColors[enabled]

	pcall(function() FakeOutfitFunc(enabled) end)

end)
if GetSave(FakeOutfit.Name) then repeat task.wait() until player.Character and player.Character:FindFirstChild('_pets_folder') pcall(function() FakeOutfitFunc(true) end) FakeOutfit.Parent.BackgroundColor3 = checkBoxColors[true] end


makeUHBigger.MouseButton1Click:Connect(function()

	local enabled = not GetSave(makeUHBigger.Name)
	Save(makeUHBigger.Name, enabled)

	makeUHBigger.Parent.BackgroundColor3 = checkBoxColors[enabled]

	if enabled then
		MainFrame.Size = UDim2.new(1,0,1,0)
		additionalFrame.Size = UDim2.new(0.390, 0, 0.124, 0)

	else
		MainFrame.Size = UDim2.new(0.525, 0, 0.525, 0)
		additionalFrame.Size = UDim2.new(0.195, 0, 0.062, 0)
	end

end)

if GetSave(makeUHBigger.Name) then MainFrame.Size = UDim2.new(1,0,1,0) MainFrame.Position = UDim2.new(0.614, 0, 0, 0) additionalFrame.Size = UDim2.new(0.390, 0, 0.124, 0) makeUHBigger.Parent.BackgroundColor3 = checkBoxColors[true] end

local function TakedownMark (newParent, clrID)
	local takedownColor = Color3.fromRGB(255,255,255)

	if GetSave(ColoredTakedowns.Name) then takedownColor = DifferentColorsPoints[clrID] end

	local bGui = Instance.new('BillboardGui', newParent) bGui.Name = 'Takedown Counter'
	bGui.AlwaysOnTop = true
	bGui.ResetOnSpawn = false
	bGui.Size = UDim2.new(4,0, 1.2, 0)
	bGui.StudsOffset = Vector3.new(0,3,0)

	local TakedownCounter = Instance.new('TextLabel', bGui) TakedownCounter.Name = 'T'
	TakedownCounter.BackgroundTransparency = 1
	TakedownCounter.Position = UDim2.new(0,0,0.5,0)
	TakedownCounter.Size = UDim2.new(1,0,0.5,0)
	TakedownCounter.Font = Enum.Font.GothamBold
	TakedownCounter.Text = ""
	TakedownCounter.TextColor3 = takedownColor
	TakedownCounter.TextScaled = true
	TakedownCounter.TextStrokeTransparency = 0.5
	TakedownCounter.Text = 'T:'

	local WorthinessCounter = Instance.new('TextLabel', bGui) WorthinessCounter.Name = 'W'
	WorthinessCounter.BackgroundTransparency = 1
	WorthinessCounter.Size = UDim2.new(1,0,.5,0)
	WorthinessCounter.Font = Enum.Font.GothamBold
	WorthinessCounter.Text = ""
	WorthinessCounter.TextColor3 = takedownColor
	WorthinessCounter.TextScaled = true
	WorthinessCounter.TextStrokeTransparency = 0.5
	WorthinessCounter.Text = 'W:'

	return TakedownCounter
end

takedownGroups = {}
STconnections = {}

if not IsLobby then
	workspace._UNITS.ChildAdded:Connect(function(unitWorkspace)
		if not unitWorkspace:WaitForChild('_stats') or unitWorkspace._stats:WaitForChild('player').Value ~= player or not unitWorkspace._stats:WaitForChild('takedown_count') then return end
		if EquippedUnits[unitWorkspace._stats:WaitForChild('uuid').Value].id ~= unitWorkspace._stats:WaitForChild('id').Value then return end
		local unitID = unitWorkspace._stats.uuid.Value

		if not takedownGroups[unitID] then
			local unitsInventory = get_Units_Owner()
			local TakedownsBase = 0
			local WB = 0

			for unitUUID, aboutUnit in pairs(unitsInventory) do
				if unitUUID ~= unitID then continue end

				WB = aboutUnit['stat_luck'] or 0
				TakedownsBase = aboutUnit['total_takedowns'] or 0
				break
			end


			takedownGroups[unitID] = {BaseTakedowns = TakedownsBase, BaseWorthiness = WB, Units = {}}
		end

		table.insert(takedownGroups[unitID].Units, unitWorkspace)

	end)


	workspace._UNITS.ChildRemoved:Connect(function(unitWorkspace)
		if unitWorkspace._stats.player.Value ~= player or EquippedUnits[unitWorkspace._stats.uuid.Value].id ~= unitWorkspace._stats.id.Value then return end

		local unitID = unitWorkspace._stats.uuid.Value
		local posInTable = table.find(takedownGroups[unitID].Units, unitWorkspace)
		if not posInTable then return end
		table.remove(takedownGroups[unitID].Units, posInTable)
		takedownGroups[unitID].BaseTakedowns = takedownGroups[unitID].BaseTakedowns + unitWorkspace._stats.takedown_count.Value
		takedownGroups[unitID].BaseWorthiness = takedownGroups[unitID].BaseWorthiness + unitWorkspace._stats.stat_luck.Value 

		if STconnections[unitWorkspace] then STconnections[unitWorkspace]:Disconnect() end
	end)
end

ColoredTakedowns.MouseButton1Click:Connect(function()

	local enabled = not GetSave(ColoredTakedowns.Name)
	Save(ColoredTakedowns.Name, enabled)

	ColoredTakedowns.Parent.BackgroundColor3 = checkBoxColors[enabled]

	if IsLobby then return end

	for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
		if not unitWorkspace:FindFirstChild('_hitbox') or not unitWorkspace._hitbox:FindFirstChild('Takedown Counter') then continue end
		local colorTakedown = Color3.fromRGB(255,255,255)

		local clrID = 0
		for unitSlot, unitAbout in pairs(EquippedUnitsAbout) do
			if unitWorkspace._stats.uuid.Value ~= unitAbout.uuid then continue end
			clrID = tonumber(unitSlot) break
		end

		if enabled then colorTakedown = DifferentColorsPoints[clrID] end

		unitWorkspace._hitbox['Takedown Counter'].W.TextColor3 = colorTakedown
		unitWorkspace._hitbox['Takedown Counter'].T.TextColor3 = colorTakedown
	end

end)

if GetSave(ColoredTakedowns.Name) then ColoredTakedowns.Parent.BackgroundColor3 = checkBoxColors[true] end

function ShowTakedownFunc ()
	if IsLobby then return end

	local function updateTakedown (unitID)
		local takedownGroup = takedownGroups[unitID]

		local takedownsDid = takedownGroup.BaseTakedowns
		local worthinessNew = takedownGroup.BaseWorthiness

		for _, unitWorkspace in ipairs(takedownGroup.Units) do
			takedownsDid += unitWorkspace._stats.takedown_count.Value
			worthinessNew += unitWorkspace._stats.stat_luck.Value
		end

		for _, unitWorkspace in ipairs(takedownGroup.Units) do
			local TakedownCounter = unitWorkspace._hitbox:FindFirstChild('Takedown Counter')
			if not TakedownCounter then return end

			TakedownCounter.W.Text = string.format("W: %s", math_round(math.clamp(worthinessNew,0,100 ), 2)) .. "%"
			TakedownCounter.T.Text = 'T: ' .. makeComma(takedownsDid)

		end

	end

	local function SetTakedownsFunc (unitWorkspace)
		if not unitWorkspace:WaitForChild('_stats') or unitWorkspace._stats:WaitForChild('player').Value ~= player or not unitWorkspace._stats:WaitForChild('takedown_count') then return end
		local unitID = unitWorkspace._stats.uuid.Value

		if not EquippedUnits[unitID] or unitWorkspace._stats.id.Value ~= EquippedUnits[unitID].id then return end

		local takedownGroup

		repeat takedownGroup = takedownGroups[unitID] task.wait() until takedownGroup and table.find(takedownGroups[unitID].Units, unitWorkspace)

		local clrID = 0
		for unitSlot, unitAbout in pairs(EquippedUnitsAbout) do 
			if unitWorkspace._stats.uuid.Value ~= unitAbout.uuid then continue end
			clrID = tonumber(unitSlot) break
		end


		TakedownMark( unitWorkspace._hitbox, clrID )

		updateTakedown(unitID)

		STconnections[unitWorkspace] = unitWorkspace._stats.stat_luck.Changed:Connect(function()
			updateTakedown(unitID)
		end)

	end

	for _, unitWorkspace in ipairs(workspace._UNITS:GetChildren()) do
		task.spawn(function() SetTakedownsFunc(unitWorkspace) end)
	end

	STconnections['CHILDADDED'] = workspace._UNITS.ChildAdded:Connect(SetTakedownsFunc)

	repeat task.wait(0.05) until not GetSave(ShowTakedowns.Name)

	for _, connection in pairs(STconnections) do if connection then connection:Disconnect() end end

	for _, aboutUnits in pairs(takedownGroups) do

		for _, unitWorkspace in ipairs(aboutUnits.Units) do
			local TakedownCounter = unitWorkspace._hitbox:FindFirstChild('Takedown Counter')
			if TakedownCounter then TakedownCounter:Destroy() end

		end

	end

end


function ShowPointsFunc ()
	if IsLobby then return end

	for _, workspaceItem in ipairs(workspace:GetChildren()) do
		if workspaceItem.Name ~= 'UnitPoint' then continue end
		workspaceItem:Destroy()
	end

	for unitSlot = 1, 6 do
		local unitInfo = EquippedUnitsAbout[ tostring(unitSlot) ]
		if table.find(cannotBePlacedAnywhere, unitSlot) then continue end
		if not unitInfo then unitInfo = {hill = false, spawn_cap = 6} end

		local spawncap = unitInfo.spawn_cap

		if spawncap >= GetSave('AutoPlacesCap')[tostring(unitSlot)] then
			spawncap = GetSave('AutoPlacesCap')[tostring(unitSlot)]
		end

		if spawncap <= 0 then continue end		

		for amountOnMap = 0, spawncap-1 do
			local unitPos = unitSlot

			if unitInfo.hill then

				local point

				local savedPosition = GetSave('AutoPlacePositions')
				if savedPosition[LevelData.map] and savedPosition[LevelData.map][ 'Unit' .. unitPos ] then point = StringToCFrame( savedPosition[LevelData.map][ 'Unit' .. unitPos ]).Position end

				if point then
					local xAxis = (amountOnMap % (spawncap/2 ) ) * 1.9
					local zAxis =  math.floor(amountOnMap / spawncap + 0.5) * 1.9

					unitPos = CFrame.new(point) + Vector3.new( xAxis , 0, zAxis )
				else
					for numberPlace, pointAbout in ipairs(hillPoints) do
						if pointAbout.used and pointAbout.used ~= unitPos then continue end
						point = pointAbout
						hillPoints[numberPlace].used = unitPos
						break
					end
					if not point then table.insert(cannotBePlacedAnywhere, unitPos) return {} end

					local xAxis = (amountOnMap % (spawncap/2 ) ) * 1.9
					local zAxis =  math.floor(amountOnMap / spawncap + 0.5) * 1.9

					unitPos = CFrame.new(point.pos) + Vector3.new( xAxis , 1 + 10 * point.yOfsset, zAxis )

					local unitPosParams = RaycastParams.new()
					unitPosParams.FilterDescendantsInstances = {workspace._terrain.hill}
					unitPosParams.FilterType = Enum.RaycastFilterType.Include
					unitPosParams.IgnoreWater = true

					unitPos = workspace:Raycast(unitPos.Position, Vector3.new(0,-2 + -15 * point.yOfsset,0), unitPosParams)
					local yPOS = unitPos.Position.Y				
					unitPos = CFrame.new( Vector3.new(unitPos.Position.X, yPOS, unitPos.Position.Z) )

				end


			else
				local savedPosition = GetSave('AutoPlacePositions') 
				local point = groundPoints[ tostring(unitSlot) ]
				if savedPosition[LevelData.map] and savedPosition[LevelData.map][ 'Unit' .. unitPos ] then point = StringToCFrame( savedPosition[LevelData.map][ 'Unit' .. unitPos ] ).Position end

				local distanceBetweenUnits = 2 if unitInfo.id == 'speedwagon' then distanceBetweenUnits = 4 end

				unitPos = CFrame.new( point + Vector3.new( (amountOnMap % (spawncap/2) ) * distanceBetweenUnits , 0, math.floor(amountOnMap / spawncap + 0.5) * distanceBetweenUnits ) )
			end

			local newPoint = Instance.new('Part', workspace) newPoint.Name = 'UnitPoint'
			newPoint.Anchored = true
			newPoint.Color = DifferentColorsPoints[unitSlot]
			newPoint.Size = Vector3.new(0.3,3.75,0.3)
			newPoint.Position = unitPos.Position + Vector3.new(0, newPoint.Size.Y/2, 0)
			newPoint.Material = Enum.Material.Neon
			newPoint.CanCollide = false
			newPoint.Transparency = 0.3

			local bguiAttachment = Instance.new('Attachment', newPoint)
			bguiAttachment.Position = Vector3.new(0,2.2,0)

			local bGui = Instance.new('BillboardGui', bguiAttachment)
			bGui.AlwaysOnTop = true
			bGui.Size = UDim2.new(8,0,0.5,0)

			local unitLabel = Instance.new('TextLabel', bGui)
			unitLabel.BackgroundTransparency = 1
			unitLabel.Size = UDim2.new(1,0,1,0)
			unitLabel.Font = Enum.Font.GothamBlack
			unitLabel.TextScaled = true
			unitLabel.TextColor3 = DifferentColorsPoints[unitSlot]
			unitLabel.TextStrokeTransparency = 0.5
			local unitName = "Unit " .. unitSlot if oldItemsData[unitInfo.id] then unitName = string.format("%s: %s", unitSlot, oldItemsData[unitInfo.id].Name) end 

			unitLabel.Text = unitName

			local TweenPartFading = TS:Create(newPoint, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 8.5), {Transparency = 1})
			local TweenTextFading = TS:Create(unitLabel, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 8.5), {TextTransparency = 1, TextStrokeTransparency = 1})
			TweenPartFading:Play()
			TweenTextFading:Play()

			game.Debris:AddItem(newPoint, 10)

		end



	end

end

ShowPoints.MouseButton1Click:Connect(ShowPointsFunc)

AutoSkillSelectedUnits.MouseButton1Click:Connect(function()
	local items = {}

	for _, unitID in pairs(autoUseAbilityUnitsTable) do
		local unitName = oldItemsData[unitID] if not unitName then continue end
		table.insert(items, unitName.Name)

	end

	GetDDL(AutoSkillSelectedUnits, items, true, 'AutoSkillUnits')

end)
DDLlabel(AutoSkillSelectedUnits, GetSave('AutoSkillUnits'))

checkBoxFunc(StoryInf_AutoJoin)
checkBoxFunc(StoryInf_Hard, false, false, 'Hard_StoryInf')
checkBoxFunc(InfCastleAutoJoin)
checkBoxFunc(InfCastleHardDifficulty)
checkBoxFunc(AutoChallenge)
checkBoxFunc(HideName, HideNameFunc)
checkBoxFunc(AutoSkillOnBoss)
checkBoxFunc(AutoUseSkill, AutoUseSkillFunc)
checkBoxFunc(AutoSellFarms)
checkBoxFunc(AutoLeaveWave, false, false, "AutoLeave_WAVE")
checkBoxFunc(AutoSellUnits)
checkBoxFunc(ShowTakedowns, ShowTakedownFunc)
checkBoxFunc(PingUserCHB)
checkBoxFunc(PingRareCHB)
checkBoxFunc(PingDefeatCHB)
checkBoxFunc(ResultWebhook)
checkBoxFunc(PlaceInRedZones, TurnOFFRedZones)
checkBoxFunc(AutoOpenCapsules, AutoOpenCapsulesFunc)
checkBoxFunc(AutoNextPortal)
checkBoxFunc(AutoNextLevel)
checkBoxFunc(AutoRetry)
checkBoxFunc(AutoLeave)
checkBoxFunc(AutoLeaveLATE)
checkBoxFunc(OnlyFriendsPortal)
checkBoxFunc(AutoStartPortal)
checkBoxFunc(AutoUsePortal)
checkBoxFunc(AutoDeleteSkins, AutoDeleteSkinsFunc)
checkBoxFunc(AutoClaimQuests, ClaimQuestsFunc)
checkBoxFunc(AutoTakeNamiQuests, AutoTakeNamiQuestsFunc)
checkBoxFunc(AutoTakeDailyQuests, AutoTakeDailyQuestFunc)
checkBoxFunc(AutoDeletePortals, DeletePortalsFunc)
checkBoxFunc(AutoErwin, AutoBuffFunc, 'erwin')
checkBoxFunc(AutoWenda, AutoBuffFunc, 'wendy')
checkBoxFunc(AutoLeafy, AutoBuffFunc, 'leafa_evolved')
checkBoxFunc(AutoGriffin, AutoUseAbilityFunc, 'femto_egg')
checkBoxFunc(FocusOnFarmAutoPlace)
checkBoxFunc(AutoPlaceTurnOn)
checkBoxFunc(AutoUpgradeCheckBox)

TPToLobby.MouseButton1Click:Connect(function()
	TPLobby()
end)

local function getMapName (result)
	local mapName = result

	if LevelData._gamemode == 'infinite' then mapName = "Infinite Mode - " .. LevelData._location_name end

	if LevelData._is_map_or_portal_level then
		mapName = 'Portal - ' .. mapName .. '\n' .. LevelData._location_name

		if LevelData._challengename then mapName = mapName .. string.format(' - %s', LevelData._challengename ) end
		if LevelData._portal_depth then mapName = mapName .. string.format('\nTier : %s', LevelData._portal_depth) end

	elseif LevelData.floor_num then
		mapName = "Infinity Tower Mode - " .. mapName .. string.format("\n(%s - Room %s)", LevelData._location_name, LevelData.floor_num)

	elseif LevelData._gamemode ~= 'infinite' then
		mapName = LevelData.name .. ' - ' .. mapName
	end

	local minutes = math.floor( (os.time() - StartTime) / 60 )
	local seconds = (os.time() - StartTime) % 60

	mapName = mapName .. '\n**Waves Completed : **' .. workspace._wave_num.Value .. string.format(' (Time: %02s:%02s)', minutes, seconds	)

	return mapName
end


local function Hide_Map (enabled)
	if IsLobby then return end

	if workspace:FindFirstChild('_npcs') then return end

	if enabled then

		for _, tableMap in ipairs(map) do
			for _, childMap in ipairs(tableMap.childs) do if childMap.Name == 'Union' then continue end childMap.Parent = nil end
		end

	else

		for _, tableMap in ipairs(map) do
			for _, childMap in ipairs(tableMap.childs) do childMap.Parent = tableMap.oldParent end
		end

	end
end


HideMap.MouseButton1Click:Connect(function()

	local enabled = not GetSave(HideMap.Name)
	Save(HideMap.Name, enabled)

	HideMap.Parent.BackgroundColor3 = checkBoxColors[enabled]

	Hide_Map(enabled)

end)

if GetSave('Hide Map') then Hide_Map(true) HideMap.Parent.BackgroundColor3 = checkBoxColors[true] end

local RareDrop = {"Sea God's Portal"}

local oldPlayerStats = {
	Gems = player._stats.gem_amount.Value,
	Gold = player._stats.gold_amount.Value,
	Pearls = player._stats._resourceSummerPearls.Value,
	PlayerXP = player._stats.player_xp.Value,
}

local contentNewSecretItem = ""

local function newSecretItemFunc (itemName, Amount)
	if contentNewSecretItem == "" then
		contentNewSecretItem = string.format("You have got %s (%s)", itemName, Amount)
	else
		contentNewSecretItem = contentNewSecretItem .. string.format(", %s (%s)", itemName, Amount)

	end
end

local function webhook ()
	local ping = GetSave(PingUserCHB.Name)
	local userID = string.format("<@%s>", GetSave("Discord UserID") )
	local webhookUrl = GetSave("Discord Url")

	local newResources = {
		{name = 'XP', amount = player._stats.player_xp.Value - oldPlayerStats.PlayerXP},
		{name = 'Gems', amount = player._stats.gem_amount.Value - oldPlayerStats.Gems},
		{name = 'Candies', amount = player._stats.candies_amount.Value - oldPlayerStats.candies},
		{name = 'Gold', amount = player._stats.gold_amount.Value - oldPlayerStats.Gold},
		{name = 'Summer Pearls', amount = player._stats._resourceSummerPearls.Value - oldPlayerStats.Pearls},

	}

	local newItemsData = getItemsData()
	local newItemsCount = 0
	local newItemsTable = {}

	for itemId, itemData in pairs(newItemsData) do
		if not oldItemsData[itemId] then 
			if itemData['Rarity'] and itemData.Rarity == 'Secret' and GetSave(PingRareCHB.Name) then ping = true newSecretItemFunc(itemData.Name, itemData.Amount) end
			newItemsTable[itemData.Name] = itemData.Amount continue

		elseif itemData.Amount <= oldItemsData[itemId].Amount then continue end

		if itemData['Rarity'] and itemData.Rarity == 'Secret' and GetSave(PingRareCHB.Name) then 
			ping = true 
			newSecretItemFunc(itemData.Name, itemData.Amount - oldItemsData[itemId].Amount)
		end

		newItemsTable[itemData.Name] = itemData.Amount - oldItemsData[itemId].Amount
		newItemsCount += 1
	end


	local result = getMapName(ResultUI.Holder.Title.Text) if string.find(result, 'DEFEAT') and GetSave(PingDefeatCHB.Name) and LevelData._gamemode ~= 'infinite' then ping = true end
	local newGems = ""
	local TotalGems = makeComma(player._stats.gem_amount.Value)
	local TotalGold = makeComma(player._stats.gold_amount.Value)
	local TotalCandies = makeComma(player._stats.candies_amount.Value)
	local TotalPearl = makeComma(player._stats._resourceSummerPearls.Value)
	local BattlePass = ''
	local reachedTier = 0
	local reachedTierExp = 0
	local nextTierExp = "0/50"
	local myBPexp = 0

	for _, bpModule in ipairs(RS.src.Data.BattlePass:GetChildren()) do
		if not bpModule:IsA('ModuleScript') then continue end
		local bpModulereq = require(bpModule)

		if not bpModulereq[battlePassID] then continue end

		myBPexp = ItemInventoryServiceClient['session']['profile_data']['battlepass_data']
		if myBPexp and myBPexp[battlePassID] and myBPexp[battlePassID].xp then myBPexp = myBPexp[battlePassID].xp else myBPexp = 0 end


		for tierNumb, aboutTier in pairs(bpModulereq[battlePassID].tiers) do
			if aboutTier.xp_required > myBPexp or reachedTierExp > aboutTier.xp_required then continue end
			reachedTierExp = aboutTier.xp_required
			reachedTier = tierNumb
		end

		if bpModulereq[battlePassID].tiers[tostring( tonumber(reachedTier) + 1 )] then
			nextTierExp = string.format('%s/%s',myBPexp - reachedTierExp, bpModulereq[battlePassID].tiers[tostring( tonumber(reachedTier) + 1 )].xp_required - reachedTierExp)
		else
			nextTierExp = 'MAX'
		end

		BattlePass = string.format('%s [%s]', reachedTier, nextTierExp)

		break
	end

	local levelAndUser = string.format("**User :** ||%s (@%s)||", player.Name, player.DisplayName)
	levelAndUser = levelAndUser .. string.format("\n**Level :** %s", string.match(player.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text, "%d+") ) .. string.format(" ||%s||", string.match(player.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text, "[\[].+") )
	local newItems = ""

	for _, newResourcesTable in ipairs(newResources) do
		if newResourcesTable.amount <=0 then continue end
		newItems = newItems .. string.format("+%s %s\n", math.floor(newResourcesTable.amount), newResourcesTable.name)
	end

	local currentItemCount = 0
	for itemName, itemAmount in pairs(newItemsTable) do
		currentItemCount += 1 local comma = "" if currentItemCount ~= newItemsCount then comma = "\n" end

		newItems = newItems .. string.format('+%s (%s)', itemName, itemAmount) .. comma

	end

	if not ping then userID = "" end

	local data = {

		["content"] = contentNewSecretItem .. " " .. userID,
		["embeds"] = {

			{
				["title"] = 'Anime Adventures',
				['color'] = 11513855,
				["description"] = levelAndUser,
				['footer'] = {
					['text'] = string.format("// Made by Jung Ganmyeon (%s)", os.date("%X")), 
				},
				['fields'] = {
					{
						['name'] = "Player Stats",
						['value'] = string.format( "<:Gems:1148368507029950515> %s\n<:Gold:1148368511463338074> %s\n<:Candies:1179742900368707735> %s\n:tickets: BattlePass: %s", TotalGems, TotalGold, TotalCandies, BattlePass),
						['inline'] = true
					},

					{
						['name'] = "Rewards",
						['value'] = newItems,
						['inline'] = true
					},

					{
						['name'] = "Result",
						['value'] = result
					}
				}

			}



		}
	}

	data = HttpService:JSONEncode(data)
	local headers = {["content-type"] = "application/json"}
	local request = http_request or request or HttpPost or syn.request or http.request
	local dataSend = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
	warn("Sending Result Webhook...")

	pcall(function() request(dataSend) end)

end
task.spawn(function() 
	pcall(function()

		if queue_on_teleport then
			local JungHubSCRIPT = 'loadstring(game:HttpGet("https://github.com/junggamyeon/MyScript/blob/main/junghub.lua"))()'
			queue_on_teleport(JungHubSCRIPT)
		end

	end)	
end)


if GameFinished and not IsLobby then
	game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()

	repeat task.wait() until GameFinished.Value and ResultUI.Enabled

	if GetSave(ResultWebhook.Name) then
		webhook()
	end

	endGameFunc()

	delay(180, function()

		if GetSave(AutoLeaveLATE.Name) then

			while true  do
				TPLobby()
				task.wait(5)
			end

		end

	end)

end



if IsLobby then

	local aboutChallenge = 	workspace:WaitForChild('_LOBBIES'):WaitForChild('_DATA'):WaitForChild('_CHALLENGE')

	while true  do

		local challengeNeed = false

		if GetSave(AutoChallenge.Name) then
			challengeNeed = true

			local lastCompletedChallenge = ItemInventoryServiceClient['session']['profile_data']['last_completed_challenge_uuid']
			if lastCompletedChallenge and lastCompletedChallenge == aboutChallenge.current_challenge_uuid.Value then challengeNeed = false end

			local Challenge_IgnoreRewards = GetSave('Challenge_IgnoreRewards')
			local Challenge_IgnoreDifficulties = GetSave('Challenge_IgnoreDifficulties')
			local Challenge_IgnoreWorlds = GetSave('Challenge_IgnoreWorlds')

			for difID, difName in pairs(DifficultiesName) do
				if table.find(Challenge_IgnoreDifficulties, difName) and difID == aboutChallenge.current_challenge.Value then challengeNeed = false break end
			end

			for rewId,rewAbout in pairs(require(RS.src.Data.ChallengeAndRewards).rewards) do
				if table.find(Challenge_IgnoreRewards, rewAbout.name) and rewId == aboutChallenge.current_reward.Value then challengeNeed = false break end
			end

			local worldIsIgnored = false
			for _,worldModule in ipairs(game.ReplicatedStorage.src.Data.Worlds:GetDescendants()) do
				if not worldModule:IsA('ModuleScript') then continue end
				for worldId, worldAbout in pairs(require(worldModule)) do
					for _,aboutLevel in pairs(worldAbout.levels) do
						if aboutLevel == aboutChallenge.current_level_id.Value and table.find(Challenge_IgnoreWorlds, worldAbout.name) then worldIsIgnored = true challengeNeed = false break end
					end
					if worldIsIgnored then break end
				end
			end

			if challengeNeed then

				for _, challengeRoom in ipairs(workspace._CHALLENGES.Challenges:GetChildren()) do
					if #challengeRoom.Players:GetChildren() >0 or challengeRoom.Active.Value then continue end
					Event['request_join_lobby']:InvokeServer(challengeRoom.Name)
					player.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(255.16964721679688, 196.8419189453125, -820.8120727539062)))

					while #challengeRoom.Players:GetChildren() == 1 and challengeRoom.Timer.Value >0 do

						task.wait(0.05)
					end

					if #challengeRoom.Players:GetChildren() ~=1 then Event['request_leave_lobby']:InvokeServer(challengeRoom.Name) player.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(255.16964721679688, 196.8419189453125, -820.8120727539062))) end
					break
				end

			end

		end

		local storyInfNeed = false

		if GetSave(StoryInf_AutoJoin.Name) and not challengeNeed then

			local StoryInf_World = GetSave('StoryInf_World')
			local StoryInf_Level = GetSave('StoryInf_Level')
			local HardDifficulty = GetSave('Hard_StoryInf')


			local legendStage = string.match(StoryInf_World, ">(.+)<") if legendStage then StoryInf_World = legendStage end

			if HardDifficulty or legendStage or StoryInf_Level == 'Infinite Mode' then HardDifficulty = 'Hard' else HardDifficulty = 'Normal' end

			if StoryInf_Level == 'Infinite Mode' then

				for _, worldModule in ipairs(RS.src.Data.Worlds:GetChildren()) do
					if not worldModule:IsA('ModuleScript') or storyInfNeed then continue end

					for _, worldAbout in pairs(require(worldModule)) do
						if not worldAbout.name or worldAbout.name ~= StoryInf_World or not worldAbout.infinite then continue end
						StoryInf_Level = worldAbout.infinite.id
						storyInfNeed = true
						break
					end	
				end
			else
				for _, levelModule in ipairs(RS.src.Data.Levels:GetDescendants()) do
					if not levelModule:IsA('ModuleScript') or storyInfNeed then continue end


					for levelId, levelAbout in pairs(require(levelModule)) do

						if levelAbout.name == StoryInf_Level then
							StoryInf_Level = levelId
							storyInfNeed = true
							break
						end

					end
				end
			end

			if storyInfNeed and StoryInf_Level ~= '' then

				for _, StoryRoom in ipairs(workspace._LOBBIES.Story:GetChildren()) do
					if #StoryRoom.Players:GetChildren() >0 or StoryRoom.Active.Value then continue end
					Event['request_join_lobby']:InvokeServer(StoryRoom.Name)
					player.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(255.16964721679688, 196.8419189453125, -820.8120727539062)))

					task.wait(1)
					Event['request_lock_level']:InvokeServer(StoryRoom.Name, StoryInf_Level, true, HardDifficulty)

					task.wait(1)
					Event['request_start_game']:InvokeServer(StoryRoom.Name)

					task.wait(10)
					break
				end

			end


		end


		local CastleJoined = false

		if GetSave(InfCastleAutoJoin.Name) and not storyInfNeed then
			CastleJoined = true

			local maxRoomChosen = GetSave('AutoJoinCastleMaxRoom')
			local reachedRoom = ItemInventoryServiceClient['session']['profile_data']['level_data']
			if reachedRoom['infinite_tower'] and reachedRoom['infinite_tower']['floor_reached'] then reachedRoom = reachedRoom['infinite_tower']['floor_reached'] else reachedRoom = 1 end

			if maxRoomChosen <= reachedRoom then CastleJoined = false end

			if CastleJoined then
				local DifficultyTower = GetSave(InfCastleHardDifficulty.Name)
				if DifficultyTower or reachedRoom > 100 then DifficultyTower = 'Hard' else DifficultyTower = 'Normal' end

				Event['request_start_infinite_tower']:InvokeServer(reachedRoom, DifficultyTower)
				task.wait(5)

			end

		end
		
	end

end
