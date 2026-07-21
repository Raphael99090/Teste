local AutoTrain = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
AutoTrain.Compensation = 0 

-- Função auxiliar para enviar mensagens no chat (Compatível com novos e velhos jogos)
local function SendChatMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
        if channel then
            channel:SendAsync(msg)
        end
    else
        local event = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
        if event then
            event:FireServer(msg, "All")
        end
    end
end

function AutoTrain:Toggle(Config, State, Hub, updateUI)
    -- Referência à Rayfield para notificações
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    if State.IsRunning then 
        State.IsRunning = false
        if updateUI then updateUI(nil, "INICIAR TREINO") end
        Rayfield:Notify({Title = "Status", Content = "Treino pausado.", Duration = 2})
        return 
    end

    State.IsRunning = true
    if updateUI then updateUI("INICIANDO...", "PARAR TREINO") end
    Rayfield:Notify({Title = "Iniciado", Content = "Treino em execução!", Duration = 2})

    task.spawn(function()
        local step = Config.IsCountdown and -1 or 1
        local finish = Config.IsCountdown and (Config.StartNum - Config.Quantity + 1) or (Config.StartNum + Config.Quantity - 1)
        
        for i = Config.StartNum, finish, step do
            if not State.IsRunning or not State.IsActive then break end
            
            -- Verifica se o personagem existe antes de prosseguir
            if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then
                repeat task.wait(1) until Player.Character and Player.Character:FindFirstChild("Humanoid")
            end

            if updateUI then updateUI("Contagem: " .. tostring(i)) end
            
            task.wait(math.random(1, 3) / 10) -- Delay humano antes de falar
            
            local textoNum = Hub.Core.Utils:NumberToText(i) or tostring(i)
            local msg = textoNum .. " !"
            SendChatMessage(msg)
            
            self:ExecutePhysics(Config, State)
            
            -- Delay entre repetições
            local finalDelay = Config.Mode == "Canguru" and math.max(0.1, Config.Delay - 0.3) or Config.Delay
            task.wait(finalDelay)
        end
        
        State.IsRunning = false
        if updateUI then updateUI("FIM", "INICIAR TREINO") end
        Rayfield:Notify({Title = "Fim", Content = "Série finalizada com sucesso!", Duration = 3})
    end)
end

function AutoTrain:ExecutePhysics(Config, State)
    if not State.IsActive or not State.IsRunning then return end
    
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end

    -- [1] AUTO EQUIPAR
    if Config.AutoEquip then 
        local bp = Player:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChildOfClass("Tool")
        if tool then hum:EquipTool(tool) end 
    end

    -- Se não for Canguru, não faz o pulo/giro
    if Config.Mode ~= "Canguru" then return end

    -- [2] AGUCHAR (CROUCH)
    if Config.AutoCrouch then 
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        task.wait(0.1)
    end

    -- [3] PULO E GIRO (360)
    hum.Sit = false
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.05)
    
    hum.AutoRotate = false
    
    -- Lógica de compensação de giro (Anti-detecção e estética)
    local offset = math.random(5, 15) * (math.random(1, 2) == 1 and 1 or -1)
    local targetAngle = 360 + offset
    
    task.spawn(function()
        local rotated = 0
        local spinSpeed = 1000 -- Velocidade do giro
        local spinConn
        
        spinConn = RunService.RenderStepped:Connect(function(dt)
            if not State.IsActive or not State.IsRunning or rotated >= targetAngle or not root.Parent then 
                if spinConn then spinConn:Disconnect() end
                if hum and hum.Parent then hum.AutoRotate = true end
                return 
            end
            
            local step = spinSpeed * dt
            if rotated + step > targetAngle then step = targetAngle - rotated end
            
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(-step), 0)
            rotated = rotated + step
        end)
        
        -- Segurança: Se o giro travar por mais de 1.5s, ele força a liberação
        task.delay(1.5, function() 
            if spinConn then spinConn:Disconnect() end
            if hum and hum.Parent then hum.AutoRotate = true end
        end)
    end)
end

return AutoTrain
