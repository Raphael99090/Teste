local Aimbot = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Aimbot.Settings = { 
    Enabled = false, 
    ShowFOV = false, 
    FOVRadius = 150, 
    Smoothness = 0.5, 
    HitboxExpander = false, 
    HitboxSize = 10, 
    TargetPart = "HumanoidRootPart" 
}

if CoreGui:FindFirstChild("InxiterFOVMobile") then CoreGui.InxiterFOVMobile:Destroy() end
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("InxiterFOVMobile") then LocalPlayer.PlayerGui.InxiterFOVMobile:Destroy() end

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "InxiterFOVMobile"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
pcall(function() FOVGui.Parent = CoreGui end)
if not FOVGui.Parent then FOVGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FOVImage = Instance.new("ImageLabel", FOVGui)
FOVImage.AnchorPoint = Vector2.new(0.5, 0.5)
FOVImage.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVImage.BackgroundTransparency = 1
FOVImage.Image = "rbxassetid://231147101"
FOVImage.ImageColor3 = Color3.fromRGB(220, 20, 60)
FOVImage.Visible = false

local OriginalSizes = {}

local function IsVisible(part)
    local ray = RaycastParams.new()
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera, part.Parent}
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.IgnoreWater = true
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, ray)
    return not result
end

local function GetClosestTarget()
    local closestDist = Aimbot.Settings.FOVRadius
    local closestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.Settings.TargetPart) then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = player.Character[Aimbot.Settings.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist <= closestDist and IsVisible(part) then
                        closestDist = dist; closestTarget = part
                    end
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Settings.ShowFOV then
        FOVImage.Size = UDim2.new(0, Aimbot.Settings.FOVRadius * 2, 0, Aimbot.Settings.FOVRadius * 2)
        FOVImage.Visible = true
    else
        FOVImage.Visible = false
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if not OriginalSizes[player] then OriginalSizes[player] = hrp.Size end
            
            if Aimbot.Settings.HitboxExpander then
                hrp.Size = Vector3.new(Aimbot.Settings.HitboxSize, Aimbot.Settings.HitboxSize, Aimbot.Settings.HitboxSize)
                hrp.Transparency = 0.5
                hrp.CanCollide = false
            else
                hrp.Size = OriginalSizes[player] or Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end

    if Aimbot.Settings.Enabled then
        local target = GetClosestTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Aimbot.Settings.Smoothness)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player) OriginalSizes[player] = nil end)
function Aimbot:Toggle(state) Aimbot.Settings.Enabled = state end
return Aimbot
