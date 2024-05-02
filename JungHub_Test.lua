local Luminosity = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/UserInterface/Luminosity.lua", true))()
local Window = Luminosity.new("JungHub-AF Test", "v1.0.0", 4370345701)

-- Hàm để lấy danh sách tên của các unit từ dịch vụ ReplicatedStorage
local function getUnitNames()
    local unitNames = {}
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local createUnitsRemote = remotes:WaitForChild("CreateUnits")
    for _, child in ipairs(createUnitsRemote:GetChildren()) do
        table.insert(unitNames, child.Name)
    end
    return unitNames
end

local isUIVisible = true

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

-- Hàm để nhập code
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

-- Tạo danh sách tên các unit
local unitNames = getUnitNames()

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Frame.Size = UDim2.new(0.2, 0, 0.2, 0)      -- Thu nhỏ kích thước giao diện


local Frame = Window.Container("JungHub-AF Test")
local gameButton = Frame.Button("Game")
local miscButton = Frame.Button("Misc")
local settingButton = Frame.Button("Settings")

local toggleUIIcon = Instance.new("ImageButton")
toggleUIIcon.Name = "ToggleUIIcon"
toggleUIIcon.Parent = ScreenGui
toggleUIIcon.Position = UDim2.new(0.5, -15, 0.1, 0)  -- Vị trí của icon
toggleUIIcon.Size = UDim2.new(0, 30, 0, 30)          -- Kích thước của icon
toggleUIIcon.Image = "http://www.roblox.com/asset/?id=7161646433"  -- Icon màu đen có chữ J màu trắng
toggleUIIcon.BackgroundTransparency = 1
toggleUIIcon.Visible = true

local gameFrame = Frame.Page("Game")
local miscFrame = Frame.Page("Misc")
local settingFrame = Frame.Page("Settings")

local autoPlaceButton = gameFrame.Toggle("Auto Place Units: OFF")
local autoPlaceVipButton = gameFrame.Toggle("Auto Place Vip: OFF")
local autoUpgradeButton = gameFrame.Toggle("Auto Upgrade Units: OFF")
local autoReadyButton = gameFrame.Toggle("Auto Ready: OFF")
local autoReplayButton = gameFrame.Toggle("Auto Replay: OFF")

local autoInputCodeButton = miscFrame.Toggle("Auto Input Code: OFF")
local autoSummonButton = miscFrame.Toggle("Auto Summon: OFF")

local position1Button = settingFrame.Button("Position 1")
local position2Button = settingFrame.Button("Position 2")
local position3Button = settingFrame.Button("Position 3")
local position4Button = settingFrame.Button("Position 4")
local position5Button = settingFrame.Button("Position 5")
local position6Button = settingFrame.Button("Position 6")

toggleUIIcon.MouseButton1Click:Connect(function()
    if isUIVisible then
        Frame.Visible = false
        isUIVisible = false
    else
        Frame.Visible = true
        isUIVisible = true
    end
end)
-- Kết nối các nút với hàm xử lý tương ứng
position1Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 1 vào vị trí đã chọn
    createUnit(unitNames[1], CFrame.new(position), position, "Tag1")
end)

position2Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 2 vào vị trí đã chọn
    createUnit(unitNames[2], CFrame.new(position), position, "Tag2")
end)

position3Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 3 vào vị trí đã chọn
    createUnit(unitNames[3], CFrame.new(position), position, "Tag3")
end)

position4Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 4 vào vị trí đã chọn
    createUnit(unitNames[4], CFrame.new(position), position, "Tag4")
end)

position5Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 5 vào vị trí đã chọn
    createUnit(unitNames[5], CFrame.new(position), position, "Tag5")
end)

position6Button.MouseButton1Click:Connect(function()
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot 6 vào vị trí đã chọn
    createUnit(unitNames[6], CFrame.new(position), position, "Tag6")
end)

-- Kết nối các nút auto với hàm xử lý tương ứng
autoUpgradeButton.Callback = function(status)
    if autoUpgradeButton.Text == "Auto Upgrade Units: OFF" then
        autoUpgradeButton.Text = "Auto Upgrade Units: ON"
        -- Bật chức năng auto upgrade
        autoUpgradeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi màu nút khi bật
        while autoUpgradeButton.Text == "Auto Upgrade Units: ON" do
            -- Tự động nâng cấp đơn vị
            upgradeUnit(unitNames[1]) -- Thay "unitName" bằng tên đơn vị muốn nâng cấp
            wait(1) -- Chờ 1 giây trước khi nâng cấp đơn vị tiếp theo
        end
    else
        autoUpgradeButton.Text = "Auto Upgrade Units: OFF"
        -- Tắt chức năng auto upgrade
        autoUpgradeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi màu nút khi tắt
    end
end

autoReadyButton.Callback = function(status)
    if autoReadyButton.Text == "Auto Ready: OFF" then
        autoReadyButton.Text = "Auto Ready: ON"
        -- Bật chức năng auto ready
        autoReadyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi màu nút khi bật
        while autoReadyButton.Text == "Auto Ready: ON" do
            -- Tự động ready khi vào trận
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Ready"):FireServer()
            wait(1) -- Chờ 1 giây trước khi ready lần tiếp theo
        end
    else
        autoReadyButton.Text = "Auto Ready: OFF"
        -- Tắt chức năng auto ready
        autoReadyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi màu nút khi tắt
    end
end

autoReplayButton.Callback = function(status)
    if autoReplayButton.Text == "Auto Replay: OFF" then
        autoReplayButton.Text = "Auto Replay: ON"
        -- Bật chức năng auto replay
        autoReplayButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi màu nút khi bật
        while autoReplayButton.Text == "Auto Replay: ON" do
            -- Tự động replay khi kết thúc trận đấu
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Replay"):FireServer()
            wait(1) -- Chờ 1 giây trước khi replay lần tiếp theo
        end
    else
        autoReplayButton.Text = "Auto Replay: OFF"
        -- Tắt chức năng auto replay
        autoReplayButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi màu nút khi tắt
    end
end

autoInputCodeButton.Callback = function(status)
    if autoInputCodeButton.Text == "Auto Input Code: OFF" then
        autoInputCodeButton.Text = "Auto Input Code: ON"
        -- Bật chức năng auto input code
        autoInputCodeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi màu nút khi bật
        while autoInputCodeButton.Text == "Auto Input Code: ON" do
            -- Tự động nhập code
            for index, code in ipairs(codes) do
                inputCode(index)
                wait(1) -- Chờ 1 giây trước khi nhập code tiếp theo
            end
        end
    else
        autoInputCodeButton.Text = "Auto Input Code: OFF"
        -- Tắt chức năng auto input code
        autoInputCodeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi màu nút khi tắt
    end
end

autoSummonButton.Callback = function(status)
    if autoSummonButton.Text == "Auto Summon: OFF" then
        autoSummonButton.Text = "Auto Summon: ON"
        -- Bật chức năng auto summon
        autoSummonButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi màu nút khi bật
        while autoSummonButton.Text == "Auto Summon: ON" do
            -- Tự động triệu hồi đơn vị
            autoSummon()
            wait(1) -- Chờ 1 giây trước khi triệu hồi tiếp theo
        end
    else
        autoSummonButton.Text = "Auto Summon: OFF"
        -- Tắt chức năng auto summon
        autoSummonButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi màu nút khi tắt
    end
end

gameButton.MouseButton1Click:Connect(function()
    gameFrame:Show()
    miscFrame:Hide()
    settingFrame:Hide()
end)

miscButton.MouseButton1Click:Connect(function()
    gameFrame:Hide()
    miscFrame:Show()
    settingFrame:Hide()
end)

settingButton.MouseButton1Click:Connect(function()
    gameFrame:Hide()
    miscFrame:Hide()
    settingFrame:Show()
end)

-- Đã thêm các chức năng vào giao diện và kết nối nút với hàm xử lý tương ứng
