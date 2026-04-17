local PlayerMods = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

PlayerMods.Settings = {
    Noclip = false,
    InfJump = false
}

PlayerMods.Connections = {}

-- ==========================================
-- 👻 NOCLIP (Atravessar Paredes)
-- ==========================================
function PlayerMods:ToggleNoclip(state)
    self.Settings.Noclip = state
    
    if state then
        if not self.Connections.Noclip then
            self.Connections.Noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if self.Connections.Noclip then
            self.Connections.Noclip:Disconnect()
            self.Connections.Noclip = nil
        end
        -- Religa a colisão para não cair no limbo
        task.wait(0.1)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CanCollide = true
        end
    end
end

-- ==========================================
-- 🦘 PULO INFINITO (Infinity Jump)
-- ==========================================
function PlayerMods:ToggleInfJump(state)
    self.Settings.InfJump = state
    
    if state then
        if not self.Connections.InfJump then
            self.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if self.Settings.InfJump then
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    else
        if self.Connections.InfJump then
            self.Connections.InfJump:Disconnect()
            self.Connections.InfJump = nil
        end
    end
end

-- [NOVA FUNÇÃO]: Desliga tudo de uma vez (Perfeito pro botão Panic)
function PlayerMods:DisableAll()
    self:ToggleNoclip(false)
    self:ToggleInfJump(false)
end

return PlayerMods
