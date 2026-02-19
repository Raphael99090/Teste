local Logic = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

function Logic:ExecutePhysics(Config, State)
    if not State.IsActive then return end
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Auto Equip
    if Config.AutoEquip and hum then
        local bp = Player:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChildOfClass("Tool")
        if tool then hum:EquipTool(tool) end
    end

    -- Se não for Canguru, apenas retorna (Modo Estático)
    if Config.Mode ~= "Canguru" then return end

    if hum and root then
        -- Agachar
        if Config.AutoCrouch then
            VirtualInputManager:SendKeyEvent(true, "C", false, game); task.wait()
            VirtualInputManager:SendKeyEvent(false, "C", false, game); task.wait(0.15)
            VirtualInputManager:SendKeyEvent(true, "C", false, game); task.wait()
            VirtualInputManager:SendKeyEvent(false, "C", false, game)
        end
        
        -- Pular
        hum.Sit = false
        hum.Jump = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Girar
        task.wait(0.05)
        hum.AutoRotate = false
        task.spawn(function()
            local target = 360 + math.random(-20, 20)
            local rotated = 0
            while rotated < target and State.IsActive do
                local step = 50
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(-step), 0)
                rotated = rotated + step
                task.wait(0.015)
            end
            hum.AutoRotate = true
        end)
    end
end

return Logic
