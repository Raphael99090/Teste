local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

ESP.Settings = { 
    Enabled = false, 
    TeamCheck = false, 
    Box = false, 
    BoxColor = Color3.fromRGB(255, 255, 255), 
    Skeleton = false, 
    SkeletonColor = Color3.fromRGB(255, 255, 255), 
    Tracer = false, 
    TracerColor = Color3.fromRGB(255, 255, 255), 
    TeamText = false, 
    HealthBar = false, 
    ColorVisible = Color3.fromRGB(0, 255, 0), 
    ColorHidden = Color3.fromRGB(255, 0, 0),
    Thickness = 1.5
}

ESP.Cache = {}

-- Mapas de Ossos para R15 e R6
local R15Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- Função Auxiliar para Criar Desenhos
local function CreateDrawing(class, properties)
    local drawing = Drawing.new(class)
    for prop, val in pairs(properties) do
        drawing[prop] = val
    end
    return drawing
end

function ESP:CreateDrawings(player)
    if ESP.Cache[player] then return end
    
    local cache = {
        BoxOutline = CreateDrawing("Square", {Thickness = 3, Filled = false, Transparency = 1, Color = Color3.new(0,0,0), Visible = false}),
        Box = CreateDrawing("Square", {Thickness = ESP.Settings.Thickness, Filled = false, Transparency = 1, Visible = false}),
        HealthBg = CreateDrawing("Line", {Thickness = 3, Transparency = 1, Color = Color3.new(0,0,0), Visible = false}),
        Health = CreateDrawing("Line", {Thickness = ESP.Settings.Thickness, Transparency = 1, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = ESP.Settings.Thickness, Transparency = 1, Visible = false}),
        TeamText = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 2, Transparency = 1, Visible = false}),
        Skeleton = {}
    }
    
    for i = 1, 15 do
        cache.Skeleton[i] = CreateDrawing("Line", {Thickness = ESP.Settings.Thickness, Transparency = 1, Visible = false})
    end
    
    ESP.Cache[player] = cache
end

function ESP:RemoveDrawings(player)
    local cache = ESP.Cache[player]
    if cache then
        cache.Box:Remove()
        cache.BoxOutline:Remove()
        cache.HealthBg:Remove()
        cache.Health:Remove()
        cache.Tracer:Remove()
        cache.TeamText:Remove()
        for _, line in pairs(cache.Skeleton) do line:Remove() end
        ESP.Cache[player] = nil
    end
end

-- Wall Check para mudar a cor do ESP
local function CheckVisibility(char, part)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return result == nil
end

function ESP:Update()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local cache = ESP.Cache[player]
        if not cache then 
            ESP:CreateDrawings(player)
            cache = ESP.Cache[player]
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local head = char and char:FindFirstChild("Head")

        -- Resetar Visibilidade (Optimization)
        local function HideAll()
            cache.Box.Visible = false; cache.BoxOutline.Visible = false
            cache.Health.Visible = false; cache.HealthBg.Visible = false
            cache.Tracer.Visible = false; cache.TeamText.Visible = false
            for _, line in pairs(cache.Skeleton) do line.Visible = false end
        end

        if not ESP.Settings.Enabled or not char or not root or not hum or hum.Health <= 0 then
            HideAll()
            continue
        end

        -- Team Check
        if ESP.Settings.TeamCheck and player.Team == LocalPlayer.Team then
            HideAll()
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            HideAll()
            continue
        end

        -- Cores Dinâmicas
        local isVisible = CheckVisibility(char, head or root)
        local renderColor = isVisible and ESP.Settings.ColorVisible or ESP.Settings.ColorHidden
        
        -- Cálculos de Caixa (Ajustado para ser mais preciso)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(pos.X - boxWidth/2, pos.Y - boxHeight/2)

        -- [1] BOX
        if ESP.Settings.Box then
            cache.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            cache.BoxOutline.Position = boxPos
            cache.BoxOutline.Visible = true

            cache.Box.Size = cache.BoxOutline.Size
            cache.Box.Position = cache.BoxOutline.Position
            cache.Box.Color = (ESP.Settings.BoxColor == Color3.fromRGB(255,255,255)) and renderColor or ESP.Settings.BoxColor
            cache.Box.Visible = true
        else
            cache.Box.Visible = false; cache.BoxOutline.Visible = false
        end

        -- [2] HEALTH BAR
        if ESP.Settings.HealthBar then
            local healthPercent = hum.Health / hum.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barPos = boxPos.X - 6
            
            cache.HealthBg.From = Vector2.new(barPos, boxPos.Y + boxHeight)
            cache.HealthBg.To = Vector2.new(barPos, boxPos.Y)
            cache.HealthBg.Visible = true

            cache.Health.From = Vector2.new(barPos, boxPos.Y + boxHeight)
            cache.Health.To = Vector2.new(barPos, boxPos.Y + boxHeight - barHeight)
            cache.Health.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1) -- Verde -> Vermelho
            cache.Health.Visible = true
        else
            cache.Health.Visible = false; cache.HealthBg.Visible = false
        end

        -- [3] TEAM TEXT
        if ESP.Settings.TeamText then
            local tName = player.Team and player.Team.Name or "Sem Time"
            cache.TeamText.Text = string.format("[%s]", tName)
            cache.TeamText.Position = Vector2.new(pos.X, boxPos.Y - 15)
            cache.TeamText.Color = player.TeamColor.Color
            cache.TeamText.Visible = true
        else
            cache.TeamText.Visible = false
        end

        -- [4] SKELETON
        if ESP.Settings.Skeleton then
            local bones = hum.RigType == Enum.HumanoidRigType.R15 and R15Bones or R6Bones
            for i, boneGroup in pairs(bones) do
                local p1 = char:FindFirstChild(boneGroup[1])
                local p2 = char:FindFirstChild(boneGroup[2])
                if p1 and p2 then
                    local v1, os1 = Camera:WorldToViewportPoint(p1.Position)
                    local v2, os2 = Camera:WorldToViewportPoint(p2.Position)
                    if os1 or os2 then
                        local line = cache.Skeleton[i]
                        line.From = Vector2.new(v1.X, v1.Y)
                        line.To = Vector2.new(v2.X, v2.Y)
                        line.Color = (ESP.Settings.SkeletonColor == Color3.fromRGB(255,255,255)) and renderColor or ESP.Settings.SkeletonColor
                        line.Visible = true
                    else
                        cache.Skeleton[i].Visible = false
                    end
                else
                    cache.Skeleton[i].Visible = false
                end
            end
        else
            for _, line in pairs(cache.Skeleton) do line.Visible = false end
        end

        -- [5] TRACERS
        if ESP.Settings.Tracer then
            cache.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            cache.Tracer.To = Vector2.new(pos.X, pos.Y + (boxHeight/2))
            cache.Tracer.Color = (ESP.Settings.TracerColor == Color3.fromRGB(255,255,255)) and renderColor or ESP.Settings.TracerColor
            cache.Tracer.Visible = true
        else
            cache.Tracer.Visible = false
        end
    end
end

function ESP:Toggle(state)
    ESP.Settings.Enabled = state
    if state then
        if not ESP.Connection then
            ESP.Connection = RunService.RenderStepped:Connect(function()
                ESP:Update()
            end)
        end
    else
        if ESP.Connection then
            ESP.Connection:Disconnect()
            ESP.Connection = nil
        end
        for player, _ in pairs(ESP.Cache) do
            ESP:RemoveDrawings(player)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    ESP:RemoveDrawings(player)
end)

return ESP
