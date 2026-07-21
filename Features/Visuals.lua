local Visuals = {}
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

Visuals.Settings = { 
    StretchedEnabled = false, 
    FOVValue = 100,
    DefaultFOV = 70,
    LerpSpeed = 10 
}

Visuals.Connection = nil

-- Função de interpolação local (sem mexer na tabela math)
local function lerp(a, b, t)
    return a + (b - a) * t
end

function Visuals:ToggleStretched(state)
    self.Settings.StretchedEnabled = state
    local Cam = workspace.CurrentCamera
    
    if state then
        self.Settings.DefaultFOV = Cam.FieldOfView
        if not self.Connection then
            self.Connection = RunService.RenderStepped:Connect(function(dt)
                if not self.Settings.StretchedEnabled then return end
                Cam.FieldOfView = lerp(Cam.FieldOfView, self.Settings.FOVValue, math.clamp(dt * self.Settings.LerpSpeed, 0, 1))
            end)
        end
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        TweenService:Create(Cam, TweenInfo.new(0.5), {FieldOfView = self.Settings.DefaultFOV}):Play()
    end
end

function Visuals:UpdateFOV(newValue)
    self.Settings.FOVValue = math.clamp(newValue, 1, 120)
end

return Visuals
