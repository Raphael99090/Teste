--[[
    1NXITER v3.0 - MÓDULO AIMBOT
    Aimbot + FOV + Hitbox + Triggerbot + Prediction + Priority
]]

local Aimbot = {}
local Settings = nil
local Utils = nil
local Drawings = {}
local LastTriggerTime = 0

function Aimbot.init(settings, utils)
    Settings = settings
    Utils = utils
    Aimbot._createFOVCircle()
end

-- ═══════════════════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════════════════

function Aimbot._createFOVCircle()
    if Settings.FOVCircle then return end
    
    local circle = Drawing.new("Circle")
    circle.Color = Settings.Colors.FOVCircle
    circle.Thickness = 2
    circle.Filled = false
    circle.Transparency = 0.7
    circle.Visible = false
    Settings.FOVCircle = circle
    table.insert(Drawings, circle)
end

-- ═══════════════════════════════════════════════
-- TARGET SELECTOR com PRIORIDADE (v3.0)
-- ═══════════════════════════════════════════════

function Aimbot.getClosestTarget()
    local Players = Settings.Services.Players
    local Camera = Settings.Services.Camera
    
    local bestTarget = nil
    local bestScore = math.huge
    local crosshairPos = Vector2.new(Settings.CrosshairX, Settings.CrosshairY)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if Utils.IsValidTarget(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Settings.AimPart)
            
            if part then
                -- Se prediction ativo, usa posição prevista
                local targetPos = part.Position
                if Settings.AimPrediction then
                    targetPos = Utils.PredictPosition(part, Settings.PredictionStrength)
                end
                
                local screenPos, onScreen = Utils.WorldToScreen(targetPos)
                
                if onScreen then
                    local dist2d = Utils.GetDistance2D(crosshairPos, screenPos)
                    
                    if dist2d < Settings.FOVSize and Utils.IsVisible(part) then
                        local score = dist2d
                        
                        -- Prioridade de alvo (v3.0)
                        if Settings.TargetPriority == "Health" then
                            local hum = char:FindFirstChild("Humanoid")
                            if hum then score = hum.Health end
                        elseif Settings.TargetPriority == "Distance" then
                            score = Utils.GetDistance3D(
                                Camera.CFrame.Position, part.Position
                            )
                        end
                        -- "Closest to Crosshair" usa dist2d padrão
                        
                        if score < bestScore then
                            bestScore = score
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget, bestScore
end

-- ═══════════════════════════════════════════════
-- TRIGGERBOT (v3.0 - auto click no alvo)
-- ═══════════════════════════════════════════════

function Aimbot._triggerbot(target)
    if not Settings.Triggerbot or not target then return end
    
    local now = tick()
    if now - LastTriggerTime < Settings.TriggerbotDelay then return end
    
    local screenPos, onScreen = Utils.WorldToScreen(target.Position)
    if not onScreen then return end
    
    local crosshairPos = Vector2.new(Settings.CrosshairX, Settings.CrosshairY)
    local dist = Utils.GetDistance2D(crosshairPos, screenPos)
    
    -- Se está dentro de um range apertado, clica
    if dist < 30 then
        pcall(function()
            local vim = Settings.Services.VirtualInputManager
            if vim then
                vim:SendMouseButtonEvent(
                    screenPos.X, screenPos.Y, 
                    0, true, game, 0
                )
                task.wait(0.02)
                vim:SendMouseButtonEvent(
                    screenPos.X, screenPos.Y, 
                    0, false, game, 0
                )
            else
                mouse1click()
            end
        end)
        LastTriggerTime = now
    end
end

-- ═══════════════════════════════════════════════
-- HITBOX EXPAND (com Reset independente)
-- ═══════════════════════════════════════════════

-- Salva originais para reset perfeito
function Aimbot._saveHitboxOriginal(plr, root)
    if not Settings.OriginalHitboxSizes[plr] then
        Settings.OriginalHitboxSizes[plr] = {
            Size        = root.Size,
            Transparency = root.Transparency,
            CanCollide  = root.CanCollide,
            Color       = root.Color,
            Material    = root.Material,
        }
    end
end

-- Expande hitbox de um root
function Aimbot._expandRoot(root)
    local s = Settings.HitboxSize
    root.Size         = Vector3.new(s, s, s)
    root.Transparency = 0.65
    root.CanCollide   = false
    root.Color        = Settings.Colors.Hitbox
    root.Material     = Enum.Material.Neon
end

-- Restaura hitbox de um jogador para o original
function Aimbot._restoreHitbox(plr)
    local orig = Settings.OriginalHitboxSizes[plr]
    if not orig then return end
    if plr and plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root.Size         = orig.Size
                root.Transparency = orig.Transparency
                root.CanCollide   = orig.CanCollide
                root.Color        = orig.Color
                root.Material     = orig.Material
            end)
        end
    end
    Settings.OriginalHitboxSizes[plr] = nil
end

-- Botão: resetar hitbox de TODOS imediatamente (sem desativar toggle)
function Aimbot.resetAllHitboxes()
    local Players = Settings.Services.Players
    for _, plr in ipairs(Players:GetPlayers()) do
        Aimbot._restoreHitbox(plr)
    end
    Settings.OriginalHitboxSizes = {}
    -- Reaplica logo em seguida se o expand ainda estiver ativo
end

function Aimbot._updateHitbox()
    local Players = Settings.Services.Players
    
    if Settings.HitboxExpand then
        for _, plr in ipairs(Players:GetPlayers()) do
            if Utils.IsValidTarget(plr) then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    Aimbot._saveHitboxOriginal(plr, root)
                    pcall(function()
                        Aimbot._expandRoot(root)
                    end)
                end
            end
        end
    else
        for plr in pairs(Settings.OriginalHitboxSizes) do
            Aimbot._restoreHitbox(plr)
        end
        Settings.OriginalHitboxSizes = {}
    end
end

-- ═══════════════════════════════════════════════
-- UPDATE LOOP
-- ═══════════════════════════════════════════════

function Aimbot.update(deltaTime)
    local Camera = Settings.Services.Camera
    
    -- FOV Circle
    if Settings.FOVCircle then
        Settings.FOVCircle.Position = Vector2.new(
            Settings.CrosshairX, Settings.CrosshairY
        )
        Settings.FOVCircle.Radius = Settings.FOVSize
        Settings.FOVCircle.Color = Settings.Colors.FOVCircle
        Settings.FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    end
    
    -- Aimbot
    if Settings.Aimbot then
        local target = Aimbot.getClosestTarget()
        
        if target then
            local aimPos = target.Position
            if Settings.AimPrediction then
                aimPos = Utils.PredictPosition(
                    target, Settings.PredictionStrength
                )
            end
            
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, aimPos)
            Camera.CFrame = currentCFrame:Lerp(
                targetCFrame, Settings.Smoothness
            )
            
            -- Triggerbot
            Aimbot._triggerbot(target)
        end
    end
    
    Aimbot._updateHitbox()
end

-- ═══════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════

function Aimbot.cleanup()
    Settings.HitboxExpand = false
    Aimbot._updateHitbox()
    
    for _, d in ipairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    Drawings = {}
    
    if Settings.FOVCircle then
        pcall(function() Settings.FOVCircle:Remove() end)
        Settings.FOVCircle = nil
    end
end

return Aimbot
