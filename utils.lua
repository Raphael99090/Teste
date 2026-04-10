--[[
    1NXITER v3.0 - MÓDULO UTILITÁRIO
    Helpers, detecção R6/R15, math, skeleton
]]

local Utils = {}
local Settings = nil

function Utils.init(settings)
    Settings = settings
end

-- ═══════════════════════════════════════════════
-- DETECÇÃO DE RIG
-- ═══════════════════════════════════════════════

function Utils.IsR6(char)
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil 
       and char:FindFirstChild("UpperTorso") == nil
end

function Utils.IsR15(char)
    if not char then return false end
    return char:FindFirstChild("UpperTorso") ~= nil
end

function Utils.GetRigType(char)
    if Utils.IsR15(char) then return "R15"
    elseif Utils.IsR6(char) then return "R6"
    else return "Unknown" end
end

-- ═══════════════════════════════════════════════
-- VERIFICAÇÕES DE ESTADO
-- ═══════════════════════════════════════════════

function Utils.IsAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

function Utils.IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    if not targetPart or not targetPart.Parent then return false end
    
    local Camera = Settings.Services.Camera
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {
        Settings.Services.LocalPlayer.Character, Camera
    }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Settings.Services.Workspace:Raycast(origin, direction, params)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

function Utils.IsTeamSelected(plr)
    if not Settings.TeamCheck then return true end
    if not plr.Team then return true end
    return Settings.ActiveTeams[plr.Team.Name] == true
end

function Utils.IsValidTarget(plr)
    local lp = Settings.Services.LocalPlayer
    if plr == lp then return false end
    if not Utils.IsAlive(plr) then return false end
    if not Utils.IsTeamSelected(plr) then return false end
    return true
end

-- ═══════════════════════════════════════════════
-- MATEMÁTICA
-- ═══════════════════════════════════════════════

function Utils.GetDistance2D(v1, v2)
    return (v1 - v2).Magnitude
end

function Utils.GetDistance3D(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utils.WorldToScreen(position)
    local Camera = Settings.Services.Camera
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Predição de posição (v3.0)
function Utils.PredictPosition(part, strength)
    if not part or not part.Parent then return part and part.Position end
    local vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.new(0,0,0)
    return part.Position + (vel * (strength or 0.15))
end

-- ═══════════════════════════════════════════════
-- ESQUELETO (R6 + R15)
-- ═══════════════════════════════════════════════

Utils.SkeletonJoints = {
    R6 = {
        { from = "Head",  to = "Torso" },
        { from = "Torso", to = "Left Arm" },
        { from = "Torso", to = "Right Arm" },
        { from = "Torso", to = "Left Leg" },
        { from = "Torso", to = "Right Leg" },
    },
    R15 = {
        { from = "Head",          to = "UpperTorso" },
        { from = "UpperTorso",    to = "LowerTorso" },
        { from = "UpperTorso",    to = "LeftUpperArm" },
        { from = "LeftUpperArm",  to = "LeftLowerArm" },
        { from = "LeftLowerArm",  to = "LeftHand" },
        { from = "UpperTorso",    to = "RightUpperArm" },
        { from = "RightUpperArm", to = "RightLowerArm" },
        { from = "RightLowerArm", to = "RightHand" },
        { from = "LowerTorso",    to = "LeftUpperLeg" },
        { from = "LeftUpperLeg",  to = "LeftLowerLeg" },
        { from = "LeftLowerLeg",  to = "LeftFoot" },
        { from = "LowerTorso",    to = "RightUpperLeg" },
        { from = "RightUpperLeg", to = "RightLowerLeg" },
        { from = "RightLowerLeg", to = "RightFoot" },
    }
}

function Utils.GetSkeletonJoints(char)
    local rigType = Utils.GetRigType(char)
    return Utils.SkeletonJoints[rigType] or {}
end

return Utils
