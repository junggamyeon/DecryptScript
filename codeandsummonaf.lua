local codes = {
    "Visit500k",
    "ShadowMonarch",
    "Release",
    "Sub2AekZaJunior",
    "Likes2500",
}

local function inputCode(index)
    local args = {
        [1] = codes[index],
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseCode"):FireServer(unpack(args))
end

local currentIndex = 1
local interval = 1

local function inputNextCode()
    if currentIndex <= #codes then
        inputCode(currentIndex)
        currentIndex = currentIndex + 1
        wait(interval)
        inputNextCode()
    else
        
        wait(3)
        
        for i = 1, 10 do
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SpecialSummonTenRoll"):FireServer()
            wait(1)
        end
    end
end

inputNextCode()
