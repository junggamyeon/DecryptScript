-- Hàm để thực hiện tạo đơn vị
local function createUnit(unitName, cframe, position, tag)
    local args = {
        [1] = unitName,
        [2] = cframe,
        [3] = position,
        [4] = tag
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CreateUnits"):FireServer(unpack(args))
end

-- Hàm để thực hiện nâng cấp
local function upgradeUnit(unit)
    local args = {
        [1] = unit
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Upgrades"):FireServer(unpack(args))
end

-- Hàm để auto nhập code
local codes = {
    "Visit150k",
    "Visit250k",
    "SorryForTimeChamber",
    "Sub2Watchpixel",
    "Sub2Jetoza",
    "AnimeFantasy",
    "ShadowMonarch",
    "Release",
    "Sub2AekZaJunior",
    "Tkz",
    "Likes1500",
}

local function inputCode(index)
    local args = {
        [1] = codes[index],
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseCode"):FireServer(unpack(args))
end

-- Hàm để auto summon
local function autoSummon()
    for i = 1, 10 do
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SpecialSummonTenRoll"):FireServer()
        wait(1)
    end
end

-- Thực hiện hành động khi vào trận
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Ready"):FireServer()

-- Hàm để xử lý khi nhấn nút Position
local function placeUnit(positionIndex)
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot tương ứng vào vị trí đã chọn
    createUnit("Unit"..positionIndex, CFrame.new(position), position, "Tag"..positionIndex)
end

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Position = UDim2.new(0.5, -150, 0.5, -150)
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Style = Enum.FrameStyle.RobloxRound
Frame.Parent = ScreenGui

local gameButton = Instance.new("TextButton")
gameButton.Text = "Game"
gameButton.Position = UDim2.new(0, 0, 0, 0)
gameButton.Size = UDim2.new(0, 100, 0, 50)
gameButton.Parent = Frame

local miscButton = Instance.new("TextButton")
miscButton.Text = "Misc"
miscButton.Position = UDim2.new(0, 100, 0, 0)
miscButton.Size = UDim2.new(0, 100, 0, 50)
miscButton.Parent = Frame

local settingButton = Instance.new("TextButton")
settingButton.Text = "Settings"
settingButton.Position = UDim2.new(0, 200, 0, 0)
settingButton.Size = UDim2.new(0, 100, 0, 50)
settingButton.Parent = Frame

local gameFrame = Instance.new("Frame")
gameFrame.Position = UDim2.new(0, 0, 0, 50)
gameFrame.Size = UDim2.new(0, 300, 0, 250)
gameFrame.Visible = false
gameFrame.Parent = Frame

local autoPlaceButton = Instance.new("TextButton")
autoPlaceButton.Text = "Auto Place Units: OFF"
autoPlaceButton.Position = UDim2.new(0, 0, 0, 0)
autoPlaceButton.Size = UDim2.new(0, 300, 0, 50)
autoPlaceButton.Parent = gameFrame

local autoPlaceVipButton = Instance.new("TextButton")
autoPlaceVipButton.Text = "Auto Place Vip: OFF"
autoPlaceVipButton.Position = UDim2.new(0, 0, 0, 50)
autoPlaceVipButton.Size = UDim2.new(0, 300, 0, 50)
autoPlaceVipButton.Parent = gameFrame

local settingFrame = Instance.new("Frame")
settingFrame.Position = UDim2.new(0, 0, 0, 50)
settingFrame.Size = UDim2.new(0, 300, 0, 250)
settingFrame.Visible = false
settingFrame.Parent = Frame

local positionButtons = {}

for i = 1, 6 do
    local positionButton = Instance.new("TextButton")
    positionButton.Text = "Position " .. i
    positionButton.Position = UDim2.new(0, 0, 0, (i - 1) * 40)
    positionButton.Size = UDim2.new(0, 100, 0, 40)
    positionButton.Parent = settingFrame
    
    positionButton.MouseButton1Click:Connect(function()
        placeUnit(i)
    end)
    
    table.insert(positionButtons, positionButton)
end

-- Kết nối các nút với hàm xử lý tương ứng
autoPlaceButton.MouseButton1Click:Connect(toggleAutoPlace)
autoPlaceVipButton.MouseButton1Click:Connect(toggleAutoPlaceVip)
gameButton.MouseButton1Click:Connect(function()
    gameFrame.Visible = true
    miscFrame.Visible = false
    settingFrame.Visible = false
end)
miscButton.MouseButton1Click:Connect(function()
    gameFrame.Visible = false
    miscFrame.Visible = true
    settingFrame.Visible = false
end)
settingButton.MouseButton1Click:Connect(function()
    gameFrame.Visible = false
    miscFrame.Visible = false
    settingFrame.Visible = true
end)
