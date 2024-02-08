game:GetService("GuiService").ErrorMessageChanged:Connect(function()
wait (2) 
game:GetService("TeleportService"):Teleport(game.placeid)
    end)