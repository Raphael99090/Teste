local PlayerMods = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

PlayerMods.Settings = { Noclip = false, InfJump = false, SpeedEnabled = false, SpeedValue = 50, JumpEnabled = false, JumpValue = 100 }
PlayerMods.Connections = {}

function PlayerMods:ToggleNoclip(state)
    self.Settings.Noclip = state
    if state then
        if not self.Connections.Noclip then
            self.Connections.Noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
            end)
        end
    else
        if self.Connections.Noclip then self.Connections.Noclip:Disconnect(); self.Connections.Noclip = nil end
        task.wait(0.1); if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CanCollide = true end
    end
end

function PlayerMods:ToggleInfJump(state)
    self.Settings.InfJump = state
    if state then
        if not self.Connections.InfJump then
            self.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if self.Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    else
        if self.Connections.InfJump then self.Connections.InfJump:Disconnect(); self.Connections.InfJump = nil end
    end
end

-- [NOVO E MELHORADO]: SpeedHack e JumpHack (Modificados com segurança no loop)
function PlayerMods:ToggleSpeed(state) self.Settings.SpeedEnabled = state end
function PlayerMods:ToggleJumpPower(state) self.Settings.JumpEnabled = state end

if not PlayerMods.Connections.MainLoop then
    PlayerMods.Connections.MainLoop = RunService.Stepped:Connect(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if PlayerMods.Settings.SpeedEnabled then hum.WalkSpeed = PlayerMods.Settings.SpeedValue end
            if PlayerMods.Settings.JumpEnabled then hum.UseJumpPower = true; hum.JumpPower = PlayerMods.Settings.JumpValue end
        end
    end)
end

function PlayerMods:DisableAll()
    self:ToggleNoclip(false); self:ToggleInfJump(false); self:ToggleSpeed(false); self:ToggleJumpPower(false)
end
return PlayerMods