local PlayerMods = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

PlayerMods.Settings = { 
    Noclip = false, 
    InfJump = false, 
    SpeedEnabled = false, 
    SpeedValue = 50, 
    JumpEnabled = false, 
    JumpValue = 100,
    DefaultSpeed = 16,
    DefaultJump = 50
}

PlayerMods.Connections = {}

-- Helper para pegar o Humanoid de forma segura
local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- [1] NOCLIP (Atravessar Paredes)
function PlayerMods:ToggleNoclip(state)
    self.Settings.Noclip = state
    
    if state then
        if not self.Connections.Noclip then
            self.Connections.Noclip = RunService.Stepped:Connect(function()
                if not self.Settings.Noclip then return end
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
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
    end
end

-- [2] INFINITE JUMP (Pulo Infinito)
function PlayerMods:ToggleInfJump(state)
    self.Settings.InfJump = state
    if state then
        if not self.Connections.InfJump then
            self.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if self.Settings.InfJump then
                    local hum = GetHumanoid()
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

-- [3] SPEED & JUMP (Loop Centralizado)
function PlayerMods:ToggleSpeed(state) 
    self.Settings.SpeedEnabled = state 
    if not state then
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = self.Settings.DefaultSpeed end
    end
end

function PlayerMods:ToggleJumpPower(state) 
    self.Settings.JumpEnabled = state 
    if not state then
        local hum = GetHumanoid()
        if hum then 
            hum.JumpPower = self.Settings.DefaultJump 
            hum.UseJumpPower = true 
        end
    end
end

-- Loop de Gerenciamento de Atributos (Roda sempre para combater resets do jogo)
if not PlayerMods.Connections.MainLoop then
    PlayerMods.Connections.MainLoop = RunService.RenderStepped:Connect(function()
        local hum = GetHumanoid()
        if hum then
            if PlayerMods.Settings.SpeedEnabled then
                hum.WalkSpeed = PlayerMods.Settings.SpeedValue
            end
            
            if PlayerMods.Settings.JumpEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = PlayerMods.Settings.JumpValue
            end
        end
    end)
end

-- [4] DESATIVAR TUDO (Panic Button / Reset)
function PlayerMods:DisableAll()
    self:ToggleNoclip(false)
    self:ToggleInfJump(false)
    self:ToggleSpeed(false)
    self:ToggleJumpPower(false)
    
    -- Força volta imediata dos valores originais
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = self.Settings.DefaultSpeed
        hum.JumpPower = self.Settings.DefaultJump
    end
end

return PlayerMods
