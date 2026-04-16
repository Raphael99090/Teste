local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

ESP.Settings = { 
    Enabled = false, 
    Box = false, BoxColor = Color3.fromRGB(255, 255, 255),
    Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255),
    Tracer = false, TracerColor = Color3.fromRGB(255, 255, 255),
    HealthBar = false,
    ColorVisible = Color3.fromRGB(0, 255, 0), -- Verde
    ColorHidden = Color3.fromRGB(255, 0, 0)   -- Vermelho
}
ESP.Cache = {}

local function CreateDrawing(class, properties)
    local drawing = Drawing.new(class)
    for prop, val in pairs(properties) do drawing[prop] = val end
    return drawing
end

function ESP:CreateDrawings(player)
    if ESP.Cache[player] then return end
    local cache = {
        BoxOutline = CreateDrawing("Square", {Thickness = 3, Filled = false, Transparency = 1, Color = Color3.new(0,0,0)}),
        Box = CreateDrawing("Square", {Thickness = 1.5, Filled = false, Transparency = 1}),
        HealthBg = CreateDrawing("Line", {Thickness = 3, Transparency = 1, Color = Color3.new(0,0,0)}),
        Health = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1}),
        Tracer = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1}),
        Skeleton = {}
    }
    for i = 1, 15 do cache.Skeleton[i] = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1}) end
    ESP.Cache[player] = cache
end

function ESP:RemoveDrawings(player)
    local cache = ESP.Cache[player]
    if cache then
        cache.Box:Remove(); cache.BoxOutline:Remove(); cache.HealthBg:Remove(); cache.Health:Remove(); cache.Tracer:Remove()
        for _, line in pairs(cache.Skeleton) do line:Remove() end
        ESP.Cache[player] = nil
    end
end

--[SOLUÇÃO DEFINITIVA DA PAREDE]: Ignora o corpo do alvo e procura só muro!
local function CheckVisibility(char, head)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, char} -- IGNORA O ALVO TOTALMENTE
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local dir = head.Position - Camera.CFrame.Position
    local result = workspace:Raycast(Camera.CFrame.Position, dir, params)
    
    return not result -- Se o raio bateu no vazio, é porque NÃO tem parede (True = Verde).
end

local R15Bones = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6Bones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

function ESP:Update()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local cache = ESP.Cache[player]
        if not cache then ESP:CreateDrawings(player); cache = ESP.Cache[player] end
        
        local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local head = char and char:FindFirstChild("Head"); local hum = char and char:FindFirstChild("Humanoid")
        local isShowingBox, isShowingHealth, isShowingSkeleton, isShowingTracer = false, false, false, false
        
        if ESP.Settings.Enabled and char and root and head and hum and hum.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            -- [MUDANÇA DE COR]: Checa se tem parede
            local isVisible = CheckVisibility(char, head)
            local WallColor = isVisible and ESP.Settings.ColorVisible or ESP.Settings.ColorHidden

            if ESP.Settings.Tracer then
                isShowingTracer = true
                cache.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                cache.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                -- Cor da Linha + Parede
                cache.Tracer.Color = ESP.Settings.TracerColor == Color3.fromRGB(255,255,255) and WallColor or ESP.Settings.TracerColor
                cache.Tracer.Visible = true
            end

            if onScreen then
                local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(topPos.Y - bottomPos.Y); local boxWidth = boxHeight * 0.55
                local boxSize = Vector2.new(boxWidth, boxHeight); local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                
                if ESP.Settings.Box then
                    isShowingBox = true
                    cache.BoxOutline.Size = boxSize; cache.BoxOutline.Position = boxPosition; cache.BoxOutline.Visible = true
                    -- Cor da Caixa + Parede
                    cache.Box.Size = boxSize; cache.Box.Position = boxPosition; cache.Box.Color = ESP.Settings.BoxColor == Color3.fromRGB(255,255,255) and WallColor or ESP.Settings.BoxColor; cache.Box.Visible = true
                end
                if ESP.Settings.HealthBar then
                    isShowingHealth = true
                    local hp = hum.Health / hum.MaxHealth; local barX = boxPosition.X - 6; local barY = boxPosition.Y + boxHeight
                    cache.HealthBg.From = Vector2.new(barX, barY + 1); cache.HealthBg.To = Vector2.new(barX, barY - boxHeight - 1); cache.HealthBg.Visible = true
                    cache.Health.From = Vector2.new(barX, barY); cache.Health.To = Vector2.new(barX, barY - (boxHeight * hp)); cache.Health.Color = Color3.fromHSV(hp * 0.3, 1, 1); cache.Health.Visible = true
                end
                if ESP.Settings.Skeleton then
                    isShowingSkeleton = true
                    local bonesMap = hum.RigType == Enum.HumanoidRigType.R15 and R15Bones or R6Bones
                    for i = 1, 15 do
                        local line = cache.Skeleton[i]; local bone = bonesMap[i]
                        if bone and char:FindFirstChild(bone[1]) and char:FindFirstChild(bone[2]) then
                            local pos1, v1 = Camera:WorldToViewportPoint(char[bone[1]].Position); local pos2, v2 = Camera:WorldToViewportPoint(char[bone[2]].Position)
                            if v1 or v2 then 
                                line.From = Vector2.new(pos1.X, pos1.Y); line.To = Vector2.new(pos2.X, pos2.Y); 
                                line.Color = ESP.Settings.SkeletonColor == Color3.fromRGB(255,255,255) and WallColor or ESP.Settings.SkeletonColor; 
                                line.Visible = true 
                            else line.Visible = false end
                        else line.Visible = false end
                    end
                end
            end
        end
        if not isShowingBox then cache.Box.Visible = false; cache.BoxOutline.Visible = false end
        if not isShowingHealth then cache.HealthBg.Visible = false; cache.Health.Visible = false end
        if not isShowingTracer then cache.Tracer.Visible = false end
        if not isShowingSkeleton then for _, line in pairs(cache.Skeleton) do line.Visible = false end end
    end
end

function ESP:Toggle(state)
    ESP.Settings.Enabled = state
    if state then
        if not ESP.Connection then ESP.Connection = RunService.RenderStepped:Connect(function() ESP:Update() end) end
    else
        if ESP.Connection then ESP.Connection:Disconnect(); ESP.Connection = nil end
        for p, _ in pairs(ESP.Cache) do ESP:RemoveDrawings(p) end
    end
end

Players.PlayerRemoving:Connect(function(p) ESP:RemoveDrawings(p) end)
return ESP
