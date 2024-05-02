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
autoPlaceButton.Text = "Auto Place: OFF"
autoPlaceButton.Position = UDim2.new(0, 0, 0, 0)
autoPlaceButton.Size = UDim2.new(0, 300, 0, 50)
autoPlaceButton.Parent = gameFrame

local autoPlaceVipButton = Instance.new("TextButton")
autoPlaceVipButton.Text = "Auto Place Vip: OFF"
autoPlaceVipButton.Position = UDim2.new(0, 0, 0, 50)
autoPlaceVipButton.Size = UDim2.new(0, 300, 0, 50)
autoPlaceVipButton.Parent = gameFrame

local autoReadyButton = Instance.new("TextButton")
autoReadyButton.Text = "Auto Ready: OFF"
autoReadyButton.Position = UDim2.new(0, 0, 0, 100)
autoReadyButton.Size = UDim2.new(0, 300, 0, 50)
autoReadyButton.Parent = gameFrame

local autoReplayButton = Instance.new("TextButton")
autoReplayButton.Text = "Auto Replay: OFF"
autoReplayButton.Position = UDim2.new(0, 0, 0, 150)
autoReplayButton.Size = UDim2.new(0, 300, 0, 50)
autoReplayButton.Parent = gameFrame

local miscFrame = Instance.new("Frame")
miscFrame.Position = UDim2.new(0, 0, 0, 50)
miscFrame.Size = UDim2.new(0, 300, 0, 250)
miscFrame.Visible = false
miscFrame.Parent = Frame

local autoInputCodeButton = Instance.new("TextButton")
autoInputCodeButton.Text = "Auto Input Code: OFF"
autoInputCodeButton.Position = UDim2.new(0, 0, 0, 0)
autoInputCodeButton.Size = UDim2.new(0, 300, 0, 50)
autoInputCodeButton.Parent = miscFrame

local autoSummonButton = Instance.new("TextButton")
autoSummonButton.Text = "Auto Summon: OFF"
autoSummonButton.Position = UDim2.new(0, 0, 0, 50)
autoSummonButton.Size = UDim2.new(0, 300, 0, 50)
autoSummonButton.Parent = miscFrame

local settingFrame = Instance.new("Frame")
settingFrame.Position = UDim2.new(0, 0, 0, 50)
settingFrame.Size = UDim2.new(0, 300, 0, 250)
settingFrame.Visible = false
settingFrame.Parent = Frame

local position1Button = Instance.new("TextButton")
position1Button.Text = "Position 1"
position1Button.Position = UDim2.new(0, 0, 0, 0)
position1Button.Size = UDim2.new(0, 100, 0, 50)
position1Button.Parent = settingFrame

local position2Button = Instance.new("TextButton")
position2Button.Text = "Position 2"
position2Button.Position = UDim2.new(0, 100, 0, 0)
position2Button.Size = UDim2.new(0, 100, 0, 50)
position2Button.Parent = settingFrame

local position3Button = Instance.new("TextButton")
position3Button.Text = "Position 3"
position3Button.Position = UDim2.new(0, 200, 0, 0)
position3Button.Size = UDim2.new(0, 100, 0, 50)
position3Button.Parent = settingFrame

local position4Button = Instance.new("TextButton")
position4Button.Text = "Position 4"
position4Button.Position = UDim2.new(0, 0, 0, 50)
position4Button.Size = UDim2.new(0, 100, 0, 50)
position4Button.Parent = settingFrame

local position5Button = Instance.new("TextButton")
position5Button.Text = "Position 5"
position5Button.Position = UDim2.new(0, 100, 0, 50)
position5Button.Size = UDim2.new(0, 100, 0, 50)
position5Button.Parent = settingFrame

local position6Button = Instance.new("TextButton")
position6Button.Text = "Position 6"
position6Button.Position = UDim2.new(0, 200, 0, 50)
position6Button.Size = UDim2.new(0, 100, 0, 50)
position6Button.Parent = settingFrame

-- Kết nối các nút với hàm xử lý tương ứng
autoPlaceButton.MouseButton1Click:Connect(toggleAutoPlace)
autoPlaceVipButton.MouseButton1Click:Connect(toggleAutoPlaceVip)
autoReadyButton.MouseButton1Click:Connect(toggleAutoReady)
autoReplayButton.MouseButton1Click:Connect(toggleAutoReplay)
autoInputCodeButton.MouseButton1Click:Connect(toggleAutoInputCode)
autoSummonButton.MouseButton1Click:Connect(toggleAutoSummon)
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

-- Hàm để xử lý khi nhấn nút Position 1-6
local function setPosition(slot)
    positionButtons = {position1Button, position2Button, position3Button, position4Button, position5Button, position6Button}
    -- Thực hiện lấy tọa độ địa điểm nhấn chuột
    local mouse = game.Players.LocalPlayer:GetMouse()
    local position = mouse.Hit.p
    -- Đặt unit ở slot tương ứng vào vị trí đã chọn
    createUnit("Unit"..slot, CFrame.new(position), position, "Tag"..slot)
end

position1Button.MouseButton1Click:Connect(function()
    setPosition(1)
end)

position2Button.MouseButton1Click:Connect(function()
    setPosition(2)
end)

position3Button.MouseButton1Click:Connect(function()
    setPosition(3)
end)

position4Button.MouseButton1Click:Connect(function()
    setPosition(4)
end)

position5Button.MouseButton1Click:Connect(function()
    setPosition(5)
end)

position6Button.MouseButton1Click:Connect(function()
    setPosition(6)
end)

