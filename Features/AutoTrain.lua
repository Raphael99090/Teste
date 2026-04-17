local AutoTrain = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

AutoTrain.Compensation = 0 

-- [NOVA FUNÇÃO]: Gerencia o Loop de Treino e avisa a Interface!
function AutoTrain:Toggle(Config, State, Hub, updateUI)
    if State.IsRunning then
        State.IsRunning = false
        if updateUI then updateUI(nil, "INICIAR TREINO") end
        Hub.UI.Library:Notificar("Status", "Treino pausado.", 2, "warn")
        return
    end

    State.IsRunning = true
    if updateUI then updateUI("INICIANDO...", "PARAR TREINO") end
    Hub.UI.Library:Notificar("Iniciado", "Contagem iniciada...", 2)

    task.spawn(function()
        local step = Config.IsCountdown and -1 or 1
        local finish = Config.IsCountdown and (Config.StartNum - Config.Quantity + 1) or (Config.StartNum + Config.Quantity - 1)

        for i = Config.StartNum, finish, step do
            if not State.IsRunning or not State.IsActive then break end
            
            -- Pede para a interface atualizar o número na tela
            if updateUI then updateUI(tostring(i)) end

            -- Humanizador (Adiciona um micro-delay aleatório antes de mandar o chat pra disfarçar)
            task.wait(math.random(1, 3) / 10) 

            -- Envio do Chat
            local msg = Hub.Core.Utils:NumberToText(i) .. " !"
            if game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel then
                game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end

            -- Chama a física do boneco
            self:ExecutePhysics(Config, State)
            
            -- Delay do próximo pulo
            task.wait(Config.Mode == "Canguru" and math.max(0, Config.Delay - 0.3) or Config.Delay)
        end

        State.IsRunning = false
        if updateUI then updateUI("FIM", "INICIAR TREINO") end
    end)
end

-- A Física do Personagem (Manteve igual)
function AutoTrain:ExecutePhysics(Config, State)
    if not State.IsActive then return end
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if Config.AutoEquip and hum then
        local bp = Player:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChildOfClass("Tool")
        if tool then hum:EquipTool(tool) end
    end

    if Config.Mode ~= "Canguru" then return end

    if hum and root then
        if Config.AutoCrouch then
            VirtualInputManager:SendKeyEvent(true, "C", false, game); task.wait()
            VirtualInputManager:SendKeyEvent(false, "C", false, game); task.wait(0.15)
            VirtualInputManager:SendKeyEvent(true, "C", false, game); task.wait()
            VirtualInputManager:SendKeyEvent(false, "C", false, game)
        end
        
        hum.Sit = false
        hum.Jump = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        
        task.wait(0.05)
        hum.AutoRotate = false
        
        local offset = 0
        if self.Compensation ~= 0 then
            offset = self.Compensation
            self.Compensation = 0
        else
            local sign = math.random(1, 2) == 1 and 1 or -1
            offset = math.random(10, 20) * sign
            self.Compensation = -offset
        end

        local targetAngle = 360 + offset
        
        task.spawn(function()
            local rotated = 0
            local spinSpeed = 900
            local spinConnection
            
            spinConnection = RunService.RenderStepped:Connect(function(dt)
                if not State.IsActive or not State.IsRunning or rotated >= targetAngle then
                    if spinConnection then spinConnection:Disconnect() end
                    if hum and hum.Parent then hum.AutoRotate = true end
                    return
                end
                
                local step = spinSpeed * dt
                if rotated + step > targetAngle then step = targetAngle - rotated end
                
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(-step), 0)
                rotated = rotated + step
            end)
            
            task.delay(1, function()
                if spinConnection then spinConnection:Disconnect() end
                if hum and hum.Parent then hum.AutoRotate = true end
            end)
        end)
    end
end

return AutoTrain
