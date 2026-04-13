local FreeCam = {}
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

FreeCam.Settings = {
    Enabled = false,
    Speed = 2 -- Velocidade de voo da câmera
}

local Connection = nil

function FreeCam:Toggle(state)
    self.Settings.Enabled = state

    if state then
        -- Salva o foco atual e muda pro modo Scriptable (Livre)
        Camera.CameraType = Enum.CameraType.Scriptable
        
        Connection = RunService.RenderStepped:Connect(function()
            if not self.Settings.Enabled then return end
            
            local moveVector = Vector3.new()
            
            -- Controles (W,A,S,D, E=Sobe, Q=Desce)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit * self.Settings.Speed
                -- Move a câmera respeitando a direção que você está olhando
                Camera.CFrame = Camera.CFrame * CFrame.new(moveVector)
            end
        end)
    else
        -- Desliga a Freecam e volta a focar no seu personagem
        if Connection then Connection:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end

return FreeCam
