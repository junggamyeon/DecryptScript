local codes = {
    "Sub2HotSauceHan",
    "ToadBoi120k",
    "Shutdown",
    "BUFF",
    "BlamTopSecretCodeWontWorkIfNotSubbed",
    "Sub2Blamspot524k",
    "Sub2CodeNex77k",
    "Sub2KingLuffy",
    "SorryForDelay",
    "Sub2BmGTormenter117onYT",
    "RELEASE",
    "FinalDelay",
    "NeelsTV",
    "YammoRework",
    "TyFor10kFavREAL",
    "D1SGUISED",
    "TyFor1mVisitsPart1",
    "TyFor1mVisitsPart2",
    "GoalReached"
}

local game = game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local claimCodeRemote = remotes:WaitForChild("ClaimCode")

for _, code in ipairs(codes) do
    claimCodeRemote:InvokeServer(code)
    wait(1)
end 

