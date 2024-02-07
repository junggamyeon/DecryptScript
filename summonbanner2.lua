while true do
local args = {
    [1] = "10",
    [2] = "2"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Summon"):InvokeServer(unpack(args))
wait(1)
end