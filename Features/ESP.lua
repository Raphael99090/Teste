local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

ESP.Settings = {
    Enabled = false,
    TeamCheck = false,
    Aura = false,
    Box = false,
    Skeleton = false,
    AuraColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    AuraTransparency = 0.5,
    Thickness = 1.5
}

ESP.Cache = {} -- nil = não tentado, false = falhou/sem suporte, table = sucesso

local R15Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function CreateDrawing(class, props)
    local ok, drawing = pcall(function()
        local d = Drawing.new(class)
        for k, v in pairs(props) do d[k] = v end
        return d
    end)
    return ok and drawing or nil
end

-- [OTIMIZAÇÃO]: HideVisuals definida fora do loop (Evita alocação de memória excessiva)
local function HideVisuals(data)
    if not data then return end
    data.Box.Visible = false
    data.BoxOutline.Visible = false
    for _, l in pairs(data.Skeleton) do l.Visible = false end
end

local function UpdateAura(player, char)
    if not char then return end 
    local highlight = char:FindFirstChild("InxiterAura")
    
    if not ESP.Settings.Enabled or not ESP.Settings.Aura or (ESP.Settings.TeamCheck and player.Team == LocalPlayer.Team) then
        if highlight then highlight:Destroy() end
        return
    end

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "InxiterAura"
        highlight.Parent = char
    end

    highlight.FillColor = ESP.Settings.AuraColor
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillAlpha = ESP.Settings.AuraTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

function ESP:CreateDrawings(player)
    if ESP.Cache[player] ~= nil then return end -- Já existe ou já falhou
    
    local lines = {}
    local lineSuccess = true
    for i = 1, 15 do
        local line = CreateDrawing("Line", {Thickness = ESP.Settings.Thickness, Transparency = 1, Visible = false})
        if line then lines[i] = line else lineSuccess = false end
    end

    local box = CreateDrawing("Square", {Thickness = ESP.Settings.Thickness, Filled = false, Transparency = 1, Visible = false})
    local outline = CreateDrawing("Square", {Thickness = ESP.Settings.Thickness + 1, Color = Color3.new(0,0,0), Filled = false, Transparency = 0.5, Visible = false})

    if box and outline and lineSuccess then
        ESP.Cache[player] = {
            Box = box,
            BoxOutline = outline,
            Skeleton = lines
        }
    else
        -- [CORREÇÃO]: Cache Negativo (Não tenta de novo se o executor não suportar)
        ESP.Cache[player] = false 
        warn("⚠️ Drawing API sem suporte total para player: " .. player.Name)
    end
end

function ESP:RemoveDrawings(player)
    local data = ESP.Cache[player]
    if data then -- Se for false (cache negativo) ou nil, não faz nada
        pcall(function()
            data.Box:Remove()
            data.BoxOutline:Remove()
            for _, line in pairs(data.Skeleton) do line:Remove() end
        end)
    end
    ESP.Cache[player] = nil
end

function ESP:Update()
    local Camera = workspace.CurrentCamera
    if not Camera then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        
        -- Garante tentativa única de criação
        if ESP.Cache[player] == nil then 
            ESP:CreateDrawings(player) 
        end

        local data = ESP.Cache[player] -- Pode ser table ou false
        
        -- [AURA]: Funciona mesmo se Drawing API falhar (Independente do cache data)
        UpdateAura(player, char)

        -- [DRAWING CHECK]: Se falhou na criação, pula lógica de Box/Skeleton
        if not data then continue end

        if ESP.Settings.Enabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char.HumanoidRootPart
            local head = char:FindFirstChild("Head") or root
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local isTeammate = ESP.Settings.TeamCheck and player.Team == LocalPlayer.Team

            if onScreen and not isTeammate then
                -- BOX
                if ESP.Settings.Box then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(headPos.Y - legPos.Y)
                    local w = h * 0.6
                    local bPos = Vector2.new(pos.X - w/2, pos.Y - h/2)

                    data.BoxOutline.Size = Vector2.new(w, h)
                    data.BoxOutline.Position = bPos
                    data.BoxOutline.Visible = true

                    data.Box.Size = data.BoxOutline.Size
                    data.Box.Position = data.BoxOutline.Position
                    data.Box.Color = ESP.Settings.BoxColor
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                    data.BoxOutline.Visible = false
                end

                -- SKELETON
                if ESP.Settings.Skeleton and char.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                    for i, boneGroup in pairs(R15Bones) do
                        local p1, p2 = char:FindFirstChild(boneGroup[1]), char:FindFirstChild(boneGroup[2])
                        local line = data.Skeleton[i]
                        if line and p1 and p2 then
                            local v1, os1 = Camera:WorldToViewportPoint(p1.Position)
                            local v2, os2 = Camera:WorldToViewportPoint(p2.Position)
                            if os1 and os2 then
                                line.From = Vector2.new(v1.X, v1.Y)
                                line.To = Vector2.new(v2.X, v2.Y)
                                line.Color = ESP.Settings.SkeletonColor
                                line.Visible = true
                            else line.Visible = false end
                        elseif line then line.Visible = false end
                    end
                else
                    for _, l in pairs(data.Skeleton) do l.Visible = false end
                end
            else
                HideVisuals(data)
            end
        else
            HideVisuals(data)
        end
    end
end

function ESP:Toggle(state)
    ESP.Settings.Enabled = state
    if state then
        if not ESP.Connection then
            ESP.Connection = RunService.RenderStepped:Connect(function() 
                pcall(ESP.Update, ESP)
            end)
        end
    else
        if ESP.Connection then
            ESP.Connection:Disconnect()
            ESP.Connection = nil
        end
        for p, _ in pairs(ESP.Cache) do ESP:RemoveDrawings(p) end
        -- Limpeza de Highlights residuais
        for _, p in pairs(Players:GetPlayers()) do
            local h = p.Character and p.Character:FindFirstChild("InxiterAura")
            if h then h:Destroy() end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) ESP:RemoveDrawings(p) end)

return ESP
