--[[
    1NXITER v3.0 - MÓDULO ESP
    Box, Skeleton, Names, Health, Lines, Distance
    + CHAMS, Target Info (v3.0)
]]

local ESP = {}
local Settings = nil
local Utils = nil
local EspCache = {}
local Drawings = {}

function ESP.init(settings, utils)
    Settings = settings
    Utils = utils
    ESP._setupPlayerListeners()
    ESP._createTargetInfo()
end

-- ═══════════════════════════════════════════════
-- DRAWING HELPERS
-- ═══════════════════════════════════════════════

local function NewLine(color)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = color or Color3.fromRGB(255, 0, 0)
    l.Thickness = 1.5
    l.Transparency = 1
    table.insert(Drawings, l)
    return l
end

local function NewBox()
    local b = Drawing.new("Square")
    b.Visible = false
    b.Color = Settings.Colors.ESPBox
    b.Thickness = 1.5
    b.Filled = false
    table.insert(Drawings, b)
    return b
end

local function NewText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size = 16
    t.Center = true
    t.Outline = true
    t.Color = Settings.Colors.ESPName
    table.insert(Drawings, t)
    return t
end

-- ═══════════════════════════════════════════════
-- TARGET INFO PANEL (v3.0)
-- ═══════════════════════════════════════════════

function ESP._createTargetInfo()
    Settings.TargetInfoDrawings = {
        BG = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Rig = Drawing.new("Text"),
    }
    
    local bg = Settings.TargetInfoDrawings.BG
    bg.Filled = true
    bg.Color = Color3.fromRGB(15, 15, 20)
    bg.Transparency = 0.85
    bg.Visible = false
    table.insert(Drawings, bg)
    
    for key, d in pairs(Settings.TargetInfoDrawings) do
        if key ~= "BG" then
            d.Size = 14
            d.Outline = true
            d.Center = false
            d.Visible = false
            d.Color = Color3.fromRGB(255, 255, 255)
            table.insert(Drawings, d)
        end
    end
end

function ESP._updateTargetInfo()
    local ti = Settings.TargetInfoDrawings
    
    if not Settings.ShowTargetInfo or not Settings.Aimbot then
        for _, d in pairs(ti) do d.Visible = false end
        return
    end
    
    local Players = Settings.Services.Players
    local Camera = Settings.Services.Camera
    local crosshairPos = Vector2.new(Settings.CrosshairX, Settings.CrosshairY)
    local bestPlr, bestDist2d = nil, Settings.FOVSize
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if Utils.IsValidTarget(plr) then
            local part = plr.Character:FindFirstChild(Settings.AimPart)
            if part then
                local sp, on = Utils.WorldToScreen(part.Position)
                if on then
                    local d = Utils.GetDistance2D(crosshairPos, sp)
                    if d < bestDist2d then
                        bestDist2d = d
                        bestPlr = plr
                    end
                end
            end
        end
    end
    
    if not bestPlr or not bestPlr.Character then
        for _, d in pairs(ti) do d.Visible = false end
        return
    end
    
    local char = bestPlr.Character
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then
        for _, d in pairs(ti) do d.Visible = false end
        return
    end
    
    local x, y = 10, 80
    local w, h = 180, 80
    
    ti.BG.Position = Vector2.new(x, y)
    ti.BG.Size = Vector2.new(w, h)
    ti.BG.Visible = true
    
    ti.Name.Text = "Target: " .. bestPlr.Name
    ti.Name.Position = Vector2.new(x + 8, y + 6)
    ti.Name.Color = Color3.fromRGB(255, 150, 50)
    ti.Name.Visible = true
    
    local hp = math.floor(hum.Health)
    local maxHp = math.floor(hum.MaxHealth)
    ti.Health.Text = "HP: " .. hp .. "/" .. maxHp
    ti.Health.Position = Vector2.new(x + 8, y + 24)
    ti.Health.Color = Color3.fromHSV(
        (hum.Health/hum.MaxHealth) * 0.3, 1, 1
    )
    ti.Health.Visible = true
    
    local dist = math.floor(Utils.GetDistance3D(
        Camera.CFrame.Position, root.Position
    ))
    ti.Dist.Text = "Dist: " .. dist .. "m"
    ti.Dist.Position = Vector2.new(x + 8, y + 42)
    ti.Dist.Color = Color3.fromRGB(150, 200, 255)
    ti.Dist.Visible = true
    
    ti.Rig.Text = "Rig: " .. Utils.GetRigType(char)
    ti.Rig.Position = Vector2.new(x + 8, y + 60)
    ti.Rig.Color = Color3.fromRGB(180, 180, 180)
    ti.Rig.Visible = true
end

-- ═══════════════════════════════════════════════
-- CHAMS (v3.0 - Highlight through walls)
-- ═══════════════════════════════════════════════

function ESP._updateChams(plr)
    if not Settings.ESP_Chams then
        if Settings.ChamsCache[plr] then
            pcall(function() Settings.ChamsCache[plr]:Destroy() end)
            Settings.ChamsCache[plr] = nil
        end
        return
    end
    
    if not Utils.IsValidTarget(plr) or not plr.Character then
        if Settings.ChamsCache[plr] then
            pcall(function() Settings.ChamsCache[plr]:Destroy() end)
            Settings.ChamsCache[plr] = nil
        end
        return
    end
    
    if not Settings.ChamsCache[plr] then
        pcall(function()
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Settings.ChamsColor
            highlight.FillTransparency = Settings.ChamsTransparency
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.5
            highlight.Adornee = plr.Character
            highlight.Parent = plr.Character
            Settings.ChamsCache[plr] = highlight
        end)
    else
        pcall(function()
            Settings.ChamsCache[plr].FillColor = Settings.ChamsColor
            Settings.ChamsCache[plr].FillTransparency = Settings.ChamsTransparency
        end)
    end
end

-- ═══════════════════════════════════════════════
-- PLAYER ESP MANAGEMENT
-- ═══════════════════════════════════════════════

function ESP.addPlayer(plr)
    if EspCache[plr] or plr == Settings.Services.LocalPlayer then return end
    
    local objects = {
        Box = NewBox(),
        Name = NewText(),
        Distance = NewText(),
        HealthBar = Drawing.new("Line"),
        HealthBG = Drawing.new("Line"),
        Snapline = NewLine(Settings.Colors.ESPLine),
        SkeletonLines = {},
    }
    
    objects.HealthBar.Thickness = 3
    objects.HealthBar.Visible = false
    table.insert(Drawings, objects.HealthBar)
    
    objects.HealthBG.Thickness = 5
    objects.HealthBG.Color = Color3.fromRGB(30, 30, 30)
    objects.HealthBG.Visible = false
    table.insert(Drawings, objects.HealthBG)
    
    for i = 1, 20 do
        table.insert(objects.SkeletonLines, NewLine(Settings.Colors.ESPSkeleton))
    end
    
    EspCache[plr] = objects
end

function ESP.removePlayer(plr)
    local esp = EspCache[plr]
    if not esp then return end
    
    pcall(function() esp.Box:Remove() end)
    pcall(function() esp.Name:Remove() end)
    pcall(function() esp.Distance:Remove() end)
    pcall(function() esp.HealthBar:Remove() end)
    pcall(function() esp.HealthBG:Remove() end)
    pcall(function() esp.Snapline:Remove() end)
    for _, line in ipairs(esp.SkeletonLines) do
        pcall(function() line:Remove() end)
    end
    
    if Settings.ChamsCache[plr] then
        pcall(function() Settings.ChamsCache[plr]:Destroy() end)
        Settings.ChamsCache[plr] = nil
    end
    
    EspCache[plr] = nil
end

function ESP._hideAll(esp)
    esp.Box.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    esp.HealthBar.Visible = false
    esp.HealthBG.Visible = false
    esp.Snapline.Visible = false
    for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
end

-- ═══════════════════════════════════════════════
-- SKELETON (R6/R15 auto)
-- ═══════════════════════════════════════════════

function ESP._drawSkeleton(char, esp)
    if not Settings.ESP_Skeleton then
        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        return
    end
    
    local joints = Utils.GetSkeletonJoints(char)
    local idx = 1
    
    for _, joint in ipairs(joints) do
        local p1 = char:FindFirstChild(joint.from)
        local p2 = char:FindFirstChild(joint.to)
        
        if p1 and p2 and idx <= #esp.SkeletonLines then
            local s1, _, z1 = Utils.WorldToScreen(p1.Position)
            local s2, _, z2 = Utils.WorldToScreen(p2.Position)
            
            local line = esp.SkeletonLines[idx]
            if z1 > 0 and z2 > 0 then
                line.From = s1
                line.To = s2
                line.Color = Settings.Colors.ESPSkeleton
                line.Visible = true
            else
                line.Visible = false
            end
            idx = idx + 1
        end
    end
    
    for i = idx, #esp.SkeletonLines do
        esp.SkeletonLines[i].Visible = false
    end
end

-- ═══════════════════════════════════════════════
-- UPDATE PLAYER ESP
-- ═══════════════════════════════════════════════

function ESP._updatePlayer(plr, esp)
    ESP._updateChams(plr)
    
    if not Settings.ESP_Enabled or not Utils.IsValidTarget(plr) then
        ESP._hideAll(esp)
        return
    end
    
    -- Anti-Screenshot: oculta tudo durante captura de tela
    if Settings.AntiScreenshot and Settings._screenshotHideActive then
        ESP._hideAll(esp)
        return
    end
    
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    local hum  = char and char:FindFirstChild("Humanoid")
    
    if not (root and head and hum) then
        ESP._hideAll(esp)
        return
    end
    
    if Settings.ESP_MaxDistance > 0 then
        local d3d = Utils.GetDistance3D(
            Settings.Services.Camera.CFrame.Position, root.Position
        )
        if d3d > Settings.ESP_MaxDistance then
            ESP._hideAll(esp)
            return
        end
    end
    
    local rootPos, onScreen, depth = Utils.WorldToScreen(root.Position)
    if not onScreen or depth <= 0 then
        ESP._hideAll(esp)
        return
    end
    
    local legScreen = Utils.WorldToScreen(
        root.Position - Vector3.new(0, 3, 0)
    )
    local height = math.abs(rootPos.Y - legScreen.Y) * 2.2
    local width = height / 1.8
    local crosshairPos = Vector2.new(
        Settings.CrosshairX, Settings.CrosshairY
    )
    
    -- BOX com VIS CHECK COLOR
    if Settings.ESP_Box then
        esp.Box.Size = Vector2.new(width, height)
        esp.Box.Position = Vector2.new(
            rootPos.X - width/2, rootPos.Y - height/2
        )
        -- Vis Check: verde = visível, vermelho = atrás de parede
        if Settings.ESP_VisCheck then
            local headPart = char:FindFirstChild("Head")
            local visible = headPart and Utils.IsVisible(headPart)
            esp.Box.Color = visible
                and Color3.fromRGB(0, 255, 80)   -- visível = verde
                or  Color3.fromRGB(255, 50, 50)  -- parede  = vermelho
        else
            esp.Box.Color = Settings.Colors.ESPBox
        end
        esp.Box.Visible = true
    else esp.Box.Visible = false end
    
    -- HEALTH BAR
    if Settings.ESP_Health and Settings.ESP_Box then
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local bx = rootPos.X - width/2 - 6
        local top = rootPos.Y - height/2
        local bot = rootPos.Y + height/2
        
        esp.HealthBG.From = Vector2.new(bx, bot)
        esp.HealthBG.To = Vector2.new(bx, top)
        esp.HealthBG.Visible = true
        
        esp.HealthBar.From = Vector2.new(bx, bot)
        esp.HealthBar.To = Vector2.new(bx, bot - (height * hp))
        esp.HealthBar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
        esp.HealthBar.Visible = true
    else
        esp.HealthBar.Visible = false
        esp.HealthBG.Visible = false
    end
    
    -- NAME
    if Settings.ESP_Names then
        esp.Name.Text = plr.Name
        esp.Name.Position = Vector2.new(
            rootPos.X, rootPos.Y - height/2 - 18
        )
        esp.Name.Visible = true
    else esp.Name.Visible = false end
    
    -- DISTANCE
    if Settings.ESP_Distance then
        local d = math.floor(Utils.GetDistance3D(
            Settings.Services.Camera.CFrame.Position, root.Position
        ))
        esp.Distance.Text = d .. "m"
        esp.Distance.Position = Vector2.new(
            rootPos.X, rootPos.Y + height/2 + 4
        )
        esp.Distance.Size = 14
        esp.Distance.Visible = true
    else esp.Distance.Visible = false end
    
    -- TRACERS
    if Settings.ESP_Lines then
        esp.Snapline.From = crosshairPos
        esp.Snapline.To = rootPos
        esp.Snapline.Color = Settings.Colors.ESPLine
        esp.Snapline.Visible = true
    else esp.Snapline.Visible = false end
    
    ESP._drawSkeleton(char, esp)
end

-- ═══════════════════════════════════════════════
-- MAIN UPDATE
-- ═══════════════════════════════════════════════

function ESP.update(dt)
    for plr, esp in pairs(EspCache) do
        ESP._updatePlayer(plr, esp)
    end
    
    ESP._updateTargetInfo()
end

-- ═══════════════════════════════════════════════
-- LISTENERS
-- ═══════════════════════════════════════════════

function ESP._setupPlayerListeners()
    local P = Settings.Services.Players
    local LP = Settings.Services.LocalPlayer
    
    for _, plr in ipairs(P:GetPlayers()) do
        if plr ~= LP then ESP.addPlayer(plr) end
    end
    
    local c1 = P.PlayerAdded:Connect(function(plr)
        ESP.addPlayer(plr)
    end)
    local c2 = P.PlayerRemoving:Connect(function(plr)
        ESP.removePlayer(plr)
    end)
    table.insert(Settings.Connections, c1)
    table.insert(Settings.Connections, c2)
end

-- ═══════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════

function ESP.cleanup()
    for plr in pairs(EspCache) do ESP.removePlayer(plr) end
    
    for _, d in ipairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    
    for plr, hl in pairs(Settings.ChamsCache) do
        pcall(function() hl:Destroy() end)
    end
    
    for _, d in pairs(Settings.TargetInfoDrawings or {}) do
        pcall(function() d:Remove() end)
    end
    
    EspCache = {}
    Drawings = {}
    Settings.ChamsCache = {}
end

return ESP
