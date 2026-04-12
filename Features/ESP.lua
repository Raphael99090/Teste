local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações globais do ESP que a UI vai alterar
ESP.Settings = {
    Enabled = false,
    Box = false,
    Skeleton = false,
    HealthBar = false,
    ColorVisible = Color3.fromRGB(0, 255, 0), -- Verde se estiver visível
    ColorHidden = Color3.fromRGB(255, 0, 0)   -- Vermelho se estiver atrás da parede
}

ESP.Cache = {}

-- Cria os desenhos na tela (Drawing API)
local function CreateDrawing(class, properties)
    local drawing = Drawing.new(class)
    for prop, val in pairs(properties) do
        drawing[prop] = val
    end
    return drawing
end

-- Inicia as linhas para um jogador
function ESP:CreateDrawings(player)
    if ESP.Cache[player] then return end
    
    local cache = {
        BoxOutline = CreateDrawing("Square", {Thickness = 3, Filled = false, Transparency = 1, Color = Color3.new(0,0,0)}),
        Box = CreateDrawing("Square", {Thickness = 1.5, Filled = false, Transparency = 1}),
        HealthBg = CreateDrawing("Line", {Thickness = 3, Transparency = 1, Color = Color3.new(0,0,0)}),
        Health = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1}),
        Skeleton = {}
    }
    
    -- Pré-cria 15 linhas para os ossos do esqueleto
    for i = 1, 15 do
        cache.Skeleton[i] = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1})
    end
    
    ESP.Cache[player] = cache
end

-- Deleta os desenhos se o jogador sair do jogo ou se o ESP desligar
function ESP:RemoveDrawings(player)
    local cache = ESP.Cache[player]
    if cache then
        cache.Box:Remove()
        cache.BoxOutline:Remove()
        cache.HealthBg:Remove()
        cache.Health:Remove()
        for _, line in pairs(cache.Skeleton) do line:Remove() end
        ESP.Cache[player] = nil
    end
end

-- Checa se o jogador está atrás da parede usando Raycast
local function CheckVisibility(char, head)
    local origin = Camera.CFrame.Position
    local dir = head.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local result = workspace:Raycast(origin, dir, params)
    if result and result.Instance then
        if result.Instance:IsDescendantOf(char) then
            return true -- Visível
        end
        return false -- Parede na frente
    end
    return true
end

-- Lista de conexões de ossos (Suporta as duas versões do Roblox)
local R15Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local R6Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- Loop principal que atualiza as posições a cada frame (FPS)
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
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChild("Humanoid")
        
        local isShowingBox = false
        local isShowingHealth = false
        local isShowingSkeleton = false
        
        if ESP.Settings.Enabled and char and root and head and hum and hum.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                -- Checagem da Parede
                local isVisible = CheckVisibility(char, head)
                local espColor = isVisible and ESP.Settings.ColorVisible or ESP.Settings.ColorHidden
                
                -- Cálculo do tamanho da Box na tela
                local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                local boxWidth = boxHeight * 0.55
                
                local boxSize = Vector2.new(boxWidth, boxHeight)
                local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                
                -- [ 1. BOX ESP ]
                if ESP.Settings.Box then
                    isShowingBox = true
                    cache.BoxOutline.Size = boxSize
                    cache.BoxOutline.Position = boxPosition
                    cache.BoxOutline.Visible = true
                    
                    cache.Box.Size = boxSize
                    cache.Box.Position = boxPosition
                    cache.Box.Color = espColor
                    cache.Box.Visible = true
                end
                
                --[ 2. HEALTH BAR ]
                if ESP.Settings.HealthBar then
                    isShowingHealth = true
                    local healthPercent = hum.Health / hum.MaxHealth
                    local barHeight = boxHeight * healthPercent
                    local barX = boxPosition.X - 6
                    local barY = boxPosition.Y + boxHeight
                    
                    cache.HealthBg.From = Vector2.new(barX, barY + 1)
                    cache.HealthBg.To = Vector2.new(barX, barY - boxHeight - 1)
                    cache.HealthBg.Visible = true
                    
                    cache.Health.From = Vector2.new(barX, barY)
                    cache.Health.To = Vector2.new(barX, barY - barHeight)
                    -- Cor da vida dinâmica (Verde = cheio, Vermelho = quase morto)
                    cache.Health.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1) 
                    cache.Health.Visible = true
                end
                
                -- [ 3. SKELETON ESP ]
                if ESP.Settings.Skeleton then
                    isShowingSkeleton = true
                    local isR15 = hum.RigType == Enum.HumanoidRigType.R15
                    local bonesMap = isR15 and R15Bones or R6Bones
                    
                    for i = 1, 15 do
                        local line = cache.Skeleton[i]
                        local boneConfig = bonesMap[i]
                        
                        if boneConfig then
                            local part1 = char:FindFirstChild(boneConfig[1])
                            local part2 = char:FindFirstChild(boneConfig[2])
                            
                            if part1 and part2 then
                                local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                                
                                if vis1 or vis2 then
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Color = espColor
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                end
            end
        end
        
        -- Esconde tudo se estiver desligado ou morto
        if not isShowingBox then
            cache.Box.Visible = false
            cache.BoxOutline.Visible = false
        end
        if not isShowingHealth then
            cache.HealthBg.Visible = false
            cache.Health.Visible = false
        end
        if not isShowingSkeleton then
            for _, line in pairs(cache.Skeleton) do line.Visible = false end
        end
    end
end

-- Botão de Ligar/Desligar Master
function ESP:Toggle(state)
    ESP.Settings.Enabled = state
    if state then
        if not ESP.Connection then
            ESP.Connection = RunService.RenderStepped:Connect(function() ESP:Update() end)
        end
    else
        if ESP.Connection then
            ESP.Connection:Disconnect()
            ESP.Connection = nil
        end
        for p, _ in pairs(ESP.Cache) do ESP:RemoveDrawings(p) end
    end
end

-- Remove lixo da memória se o jogador quitar do servidor
Players.PlayerRemoving:Connect(function(p)
    ESP:RemoveDrawings(p)
end)

return ESP
