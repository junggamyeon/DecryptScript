
local function createUnit(unitName, cframe, position, tag)
    local args = {
        [1] = unitName,
        [2] = cframe,
        [3] = position,
        [4] = tag
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CreateUnits"):FireServer(unpack(args))
end

local function upgradeUnit(unit)
    local args = {
        [1] = unit
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Upgrades"):FireServer(unpack(args))
end

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Ready"):FireServer()

for i = 1, 2 do
    createUnit("Sion", CFrame.new(-197.45103454589844, 21.662912368774414, -195.91720581054688, -1, -1.898014487548491e-16, -4.3722536702262005e-09, 1.898014487548491e-16, 1, -1.0307296178000509e-15, -4.3722536702262005e-09, 1.0307296178000509e-15, -1), Vector3.new(0,0,0), "Sion1714621296.434626")
    wait(3) 
end

for i = 1, 30 do
    createUnit("GodOfSky", CFrame.new(-180.97279357910156, 25.435632705688477, -214.21017456054688, -1, 6.730403096687687e-16, 1.1714984538002682e-08, -6.730403096687687e-16, 1, -1.0799049625858466e-15, 1.1714984538002682e-08, 1.0799049625858466e-15, -1), Vector3.new(0,0,0), "GodOfSky1714621289.4789224")
    createUnit("GodOfSky", CFrame.new(-178.48233032226562, 25.435630798339844, -214.23829650878906, -1, -1.2618550511943587e-15, -1.3625651718029985e-09, 1.2618550511943587e-15, 1, 3.322416220112134e-15, -1.3625651718029985e-09, -3.322416220112134e-15, -1), Vector3.new(0,0,0), "GodOfSky1714621289.4789224")
    createUnit("GodOfSky", CFrame.new(-175.51004028320312, 25.435630798339844, -215.30426025390625, -1, -3.31526577972965e-15, 1.8302088733435085e-09, 3.31526577972965e-15, 1, -7.558464623505859e-16, 1.8302088733435085e-09, 7.558464623505859e-16, -1), Vector3.new(0,0,0), "GodOfSky1714621289.4789224")
    wait(5)
end

while true do
    upgradeUnit(workspace:WaitForChild("Unit"):WaitForChild("jungafez26"):WaitForChild("GodOfSky"))
    wait(3) 
end

local function replay()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Replay"):FireServer()
end

wait(10)
replay()
-- Auto Logger cái lồn mẹ mày dùng thì dùng đéo dùng thì cút men mày đi
