local AutoTrain = {}
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function SendChatMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
        if channel then channel:SendAsync(msg) end
    else
        local event = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
        if event then event:FireServer(msg, "All") end
    end
end

function AutoTrain:Toggle(Config, State, Hub, updateUI)
    if State.IsRunning then 
        State.IsRunning = false
        if updateUI then updateUI("STATUS: PAUSADO") end
        return 
    end

    State.IsRunning = true
    if updateUI then updateUI("STATUS: EM EXECUÇÃO") end

    task.spawn(function()
        local finish = (Config.StartNum or 0) + (Config.Quantity or 100)
        for i = (Config.StartNum or 0), finish do
            if not State.IsRunning or not State.IsActive then break end
            
            if updateUI then updateUI("Contagem: " .. tostring(i)) end
            
            local msg = (Hub.Core.Utils and Hub.Core.Utils:NumberToText(i)) or tostring(i)
            SendChatMessage(msg .. " !")
            
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            task.wait(Config.Delay or 1.4)
        end
        State.IsRunning = false
        if updateUI then updateUI("STATUS: FIM") end
    end)
end

return AutoTrain
