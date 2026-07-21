local FreeCam = {}
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

FreeCam.Settings = { 
    Enabled = false, 
    Speed = 1.0, 
    Sensitivity = 0.5 -- Sensibilidade do mouse
}

local Connection = nil
local Rotation = Vector2.new(0, 0) -- X = Yaw, Y = Pitch

-- Sincroniza a câmera caso ela mude
local function GetCamera()
    Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
    return Camera
end

function FreeCam:Toggle(state)
    self.Settings.Enabled = state
    local Cam = GetCamera()
    
    if state then
        -- Inicializa a rotação com base na CFrame atual da câmera
        local lookVector = Cam.CFrame.LookVector
        Rotation = Vector2.new(
            math.atan2(-lookVector.X, -lookVector.Z),
            math.asin(lookVector.Y)
        )
        
        Cam.CameraType = Enum.CameraType.Scriptable
        
        -- Trava o mouse no centro para melhor controle (opcional)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition

        Connection = RunService.RenderStepped:Connect(function(dt)
            if not self.Settings.Enabled then return end
            
            -- [1] ROTAÇÃO (Mouse)
            local delta = UserInputService:GetMouseDelta()
            Rotation = Rotation + (delta * -0.005 * self.Settings.Sensitivity)
            -- Limita o Pitch (não deixar a câmera dar cambalhota vertical)
            Rotation = Vector2.new(Rotation.X, math.clamp(Rotation.Y, -math.rad(89), math.rad(89)))
            
            Cam.CFrame = CFrame.new(Cam.CFrame.Position) * 
                         CFrame.Angles(0, Rotation.X, 0) * 
                         CFrame.Angles(Rotation.Y, 0, 0)

            -- [2] MOVIMENTAÇÃO (Teclado)
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            
            local multiplier = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or 1
            
            if moveVector.Magnitude > 0 then
                -- Move a câmera em relação à sua própria rotação
                local worldMove = Cam.CFrame:VectorToWorldSpace(moveVector.Unit)
                Cam.CFrame = Cam.CFrame + (worldMove * (self.Settings.Speed * 50 * multiplier * dt))
            end
        end)
    else
        -- DESLIGAR
        if Connection then 
            Connection:Disconnect() 
            Connection = nil
        end
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Cam.CameraType = Enum.CameraType.Custom
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            Cam.CameraSubject = LocalPlayer.Character.Humanoid 
        end
    end
end

return FreeCam
