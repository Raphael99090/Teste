local Visuals = {}
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

Visuals.Settings = { StretchedEnabled = false, FOVValue = 100 }
Visuals.Connection = nil

function Visuals:ToggleStretched(state)
    self.Settings.StretchedEnabled = state
    
    if state then
        if not self.Connection then
            self.Connection = RunService.RenderStepped:Connect(function(dt)
                -- [MELHORIA]: Transição suave pro FOV esticado
                Camera.FieldOfView = Camera.FieldOfView + (self.Settings.FOVValue - Camera.FieldOfView) * (dt * 10)
            end)
        end
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        -- Retorna pro padrão do Roblox com animação
        TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
    end
end

return Visuals