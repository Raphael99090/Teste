local Visuals = {}
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

Visuals.Settings = {
    StretchedEnabled = false,
    FOVValue = 100 -- Padrão de tela esticada
}

function Visuals:ToggleStretched(state)
    self.Settings.StretchedEnabled = state
    
    if state then
        -- Trava a câmera no FOV escolhido a cada frame para o jogo não resetar
        if not self.Connection then
            self.Connection = RunService.RenderStepped:Connect(function()
                Camera.FieldOfView = self.Settings.FOVValue
            end)
        end
    else
        -- Desliga e volta pro padrão do Roblox (70)
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        Camera.FieldOfView = 70
    end
end

return Visuals
