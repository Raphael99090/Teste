local Visuals = {}
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

Visuals.Settings = { 
    StretchedEnabled = false, 
    FOVValue = 100,
    DefaultFOV = 70,
    LerpSpeed = 10 -- Velocidade da transição
}

Visuals.Connection = nil

-- Garante que temos a câmera atual (caso ela mude em alguns jogos)
local function GetCamera()
    return workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
end

function Visuals:ToggleStretched(state)
    self.Settings.StretchedEnabled = state
    local Cam = GetCamera()
    
    if state then
        -- Salva o FOV original do jogador antes de mudar
        self.Settings.DefaultFOV = Cam.FieldOfView
        
        if not self.Connection then
            self.Connection = RunService.RenderStepped:Connect(function(dt)
                if not self.Settings.StretchedEnabled then return end
                
                -- Se o jogador estiver mirando (ADS), muitos jogos mudam o FOV.
                -- Opcional: Você pode adicionar uma checagem aqui para não forçar o FOV se estiver mirando.
                
                local targetFOV = self.Settings.FOVValue
                -- Interpolação suave para não dar "tranco" na tela
                Cam.FieldOfView = math.lerp(Cam.FieldOfView, targetFOV, math.clamp(dt * self.Settings.LerpSpeed, 0, 1))
            end)
        end
    else
        -- Desconecta o loop
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        
        -- Retorna para o FOV original com uma transição suave de Tween
        local returnTween = TweenService:Create(Cam, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            FieldOfView = self.Settings.DefaultFOV
        })
        returnTween:Play()
    end
end

-- Função auxiliar para mudar o valor do FOV em tempo real sem precisar religar o Toggle
function Visuals:UpdateFOV(newValue)
    self.Settings.FOVValue = math.clamp(newValue, 1, 120) -- Limite do Roblox é 120
end

-- Helper de matemática para interpolação linear (caso não exista)
function math.lerp(a, b, t)
    return a + (b - a) * t
end

return Visuals
