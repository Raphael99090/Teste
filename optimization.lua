--[[
    1NXITER v3.0 - OTIMIZAÇÃO COMPLETA
    15 features de performance
    
    ✓ Modo Batata    ✓ Sombras       ✓ Mutar Som
    ✓ Texturas       ✓ Partículas    ✓ Fullbright
    ✓ No Fog         ✓ Anti-AFK      ✓ FPS Counter
    ✓ Acessórios     ✓ Animações     ✓ Post-FX
    ✓ Low Render     ✓ Terreno       ✓ GC Cleanup
]]

local Optimization = {}
local Settings = nil
local Drawings = {}
local AntiAFKConn = nil
local FPSTime = 0
local FrameCount = 0

function Optimization.init(settings)
    Settings = settings
end

function Optimization.update(dt)
    if Settings.ShowFPS and Settings.FPSDrawing then
        FrameCount = FrameCount + 1
        FPSTime = FPSTime + dt
        if FPSTime >= 0.5 then
            local fps = math.floor(FrameCount / FPSTime)
            Settings.FPSDrawing.Text = "FPS: " .. fps
            Settings.FPSDrawing.Color = fps >= 50 
                and Color3.fromRGB(80,250,80) 
                or fps >= 30 
                    and Color3.fromRGB(255,200,50) 
                    or Color3.fromRGB(255,60,60)
            FrameCount = 0
            FPSTime = 0
        end
    end
end

-- 1. MODO BATATA
function Optimization.applyPotatoMode()
    local count = 0
    local Lighting = Settings.Services.Lighting
    
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then
                e:Destroy(); count = count + 1
            end
        end
    end)
    
    for _, obj in ipairs(Settings.Services.Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy(); count = count + 1
            elseif obj:IsA("BasePart") then
                if not Settings.OriginalMaterials[obj] then
                    Settings.OriginalMaterials[obj] = {
                        Material = obj.Material,
                        Reflectance = obj.Reflectance,
                        CastShadow = obj.CastShadow
                    }
                end
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                count = count + 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") 
                   or obj:IsA("Beam") then
                obj.Enabled = false; count = count + 1
            elseif obj:IsA("Light") then
                obj.Brightness = 0; count = count + 1
            end
        end)
    end
    
    Settings.PotatoMode = true
    return count
end

function Optimization.disablePotatoMode()
    for obj, data in pairs(Settings.OriginalMaterials) do
        if obj and obj.Parent then
            pcall(function()
                obj.Material = data.Material
                obj.Reflectance = data.Reflectance
                obj.CastShadow = data.CastShadow
            end)
        end
    end
    Settings.OriginalMaterials = {}
    Settings.PotatoMode = false
end

-- 2. REMOVER TEXTURAS
function Optimization.removeTextures()
    local c = 0
    for _, o in ipairs(Settings.Services.Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("Decal") or o:IsA("Texture") then
                o:Destroy(); c = c + 1
            end
        end)
    end
    return c
end

-- 3. REMOVER PARTÍCULAS
function Optimization.removeParticles()
    local c = 0
    for _, o in ipairs(Settings.Services.Workspace:GetDescendants()) do
        pcall(function()
            if o:IsA("ParticleEmitter") or o:IsA("Trail") 
               or obj:IsA("Beam") then
                o.Enabled = false; c = c + 1
            end
        end)
    end
    return c
end

-- 4. REMOVER SOMBRAS
function Optimization.removeShadows()
    pcall(function()
        Settings.Services.Lighting.GlobalShadows = false
        for _, o in ipairs(Settings.Services.Workspace:GetDescendants()) do
            pcall(function()
                if o:IsA("BasePart") then o.CastShadow = false end
            end)
        end
    end)
end

-- 5. MUTAR SOM
function Optimization.toggleMute(mute)
    pcall(function()
        for _, s in ipairs(Settings.Services.Workspace:GetDescendants()) do
            if s:IsA("Sound") then s.Volume = mute and 0 or 0.5 end
        end
        for _, s in ipairs(Settings.Services.SoundService:GetDescendants()) do
            if s:IsA("Sound") then s.Volume = mute and 0 or 0.5 end
        end
    end)
    Settings.MutarSom = mute
end

-- 6. FULLBRIGHT
function Optimization.toggleFullbright(enabled)
    local L = Settings.Services.Lighting
    if enabled then
        if not Settings.OriginalLighting.Brightness then
            Settings.OriginalLighting = {
                Brightness = L.Brightness,
                ClockTime = L.ClockTime,
                GlobalShadows = L.GlobalShadows,
                Ambient = L.Ambient,
                OutdoorAmbient = L.OutdoorAmbient,
            }
        end
        pcall(function()
            L.Brightness = 2
            L.ClockTime = 14
            L.GlobalShadows = false
            L.Ambient = Color3.fromRGB(178,178,178)
            L.OutdoorAmbient = Color3.fromRGB(178,178,178)
        end)
    else
        if Settings.OriginalLighting.Brightness then
            pcall(function()
                L.Brightness = Settings.OriginalLighting.Brightness
                L.ClockTime = Settings.OriginalLighting.ClockTime
                L.GlobalShadows = Settings.OriginalLighting.GlobalShadows
                L.Ambient = Settings.OriginalLighting.Ambient
                L.OutdoorAmbient = Settings.OriginalLighting.OutdoorAmbient
            end)
        end
    end
    Settings.Fullbright = enabled
end

-- 7. NO FOG
function Optimization.toggleNoFog(enabled)
    local L = Settings.Services.Lighting
    if enabled then
        if not Settings.OriginalLighting.FogEnd then
            Settings.OriginalLighting.FogEnd = L.FogEnd
            Settings.OriginalLighting.FogStart = L.FogStart
        end
        pcall(function()
            L.FogEnd = 9e9
            L.FogStart = 9e9
            for _, c in ipairs(L:GetChildren()) do
                if c:IsA("Atmosphere") then c.Density = 0 end
            end
        end)
    else
        pcall(function()
            if Settings.OriginalLighting.FogEnd then
                L.FogEnd = Settings.OriginalLighting.FogEnd
                L.FogStart = Settings.OriginalLighting.FogStart or 0
            end
        end)
    end
    Settings.NoFog = enabled
end

-- 8. ANTI-AFK
function Optimization.toggleAntiAFK(enabled)
    if enabled then
        pcall(function()
            local VU = game:GetService("VirtualUser")
            AntiAFKConn = Settings.Services.LocalPlayer.Idled:Connect(
                function()
                    pcall(function()
                        VU:CaptureController()
                        VU:ClickButton2(Vector2.new())
                    end)
                end
            )
            table.insert(Settings.Connections, AntiAFKConn)
        end)
    else
        if AntiAFKConn then
            pcall(function() AntiAFKConn:Disconnect() end)
            AntiAFKConn = nil
        end
    end
    Settings.AntiAFK = enabled
end

-- 9. FPS COUNTER
function Optimization.toggleFPSCounter(enabled)
    if enabled then
        if not Settings.FPSDrawing then
            local f = Drawing.new("Text")
            f.Text = "FPS: --"
            f.Size = 18
            f.Position = Vector2.new(10, 10)
            f.Color = Color3.fromRGB(80,250,80)
            f.Outline = true
            f.Font = 2
            f.Visible = true
            Settings.FPSDrawing = f
            table.insert(Drawings, f)
        end
        Settings.FPSDrawing.Visible = true
    else
        if Settings.FPSDrawing then
            Settings.FPSDrawing.Visible = false
        end
    end
    Settings.ShowFPS = enabled
    FrameCount = 0
    FPSTime = 0
end

-- 10. REMOVER ACESSÓRIOS (outros players)
function Optimization.removeAccessories()
    local c = 0
    for _, plr in ipairs(Settings.Services.Players:GetPlayers()) do
        if plr ~= Settings.Services.LocalPlayer and plr.Character then
            for _, o in ipairs(plr.Character:GetChildren()) do
                pcall(function()
                    if o:IsA("Accessory") or o:IsA("Hat") then
                        local h = o:FindFirstChild("Handle")
                        if h then
                            h.Transparency = 1
                            for _, m in ipairs(h:GetDescendants()) do
                                if m:IsA("SpecialMesh") then
                                    pcall(function() m:Destroy() end)
                                end
                            end
                        end
                        c = c + 1
                    end
                end)
            end
        end
    end
    return c
end

-- 11. DESATIVAR ANIMAÇÕES (outros players)
function Optimization.toggleNoAnimations(enabled)
    local c = 0
    if enabled then
        for _, plr in ipairs(Settings.Services.Players:GetPlayers()) do
            if plr ~= Settings.Services.LocalPlayer and plr.Character then
                local anim = plr.Character:FindFirstChild("Animate")
                if anim then
                    pcall(function()
                        anim.Disabled = true
                        Settings.DisabledAnimations[plr] = anim
                        c = c + 1
                    end)
                end
            end
        end
    else
        for _, a in pairs(Settings.DisabledAnimations) do
            pcall(function()
                if a.Parent then a.Disabled = false end
            end)
        end
        Settings.DisabledAnimations = {}
    end
    Settings.NoAnimationsOthers = enabled
    return c
end

-- 12. REMOVER POST-PROCESSING
function Optimization.removePostProcessing()
    local c = 0
    for _, e in ipairs(Settings.Services.Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") 
               or e:IsA("DepthOfFieldEffect")
               or e:IsA("SunRaysEffect") 
               or e:IsA("ColorCorrectionEffect") then
                e:Destroy(); c = c + 1
            end
        end)
    end
    for _, e in ipairs(Settings.Services.Camera:GetChildren()) do
        pcall(function()
            if e:IsA("PostEffect") then
                e:Destroy(); c = c + 1
            end
        end)
    end
    return c
end

-- 13. LOW RENDER DISTANCE
function Optimization.toggleLowRender(enabled)
    if enabled then
        pcall(function()
            for _, o in ipairs(
                Settings.Services.Workspace:GetDescendants()
            ) do
                pcall(function()
                    if o:IsA("MeshPart") or o:IsA("UnionOperation") then
                        o.RenderFidelity = Enum.RenderFidelity.Performance
                    end
                    if o:IsA("BasePart") and o.Size.Magnitude < 2 then
                        o.CastShadow = false
                    end
                end)
            end
        end)
    end
    Settings.LowRenderDistance = enabled
end

-- 14. REMOVER DETALHES DO TERRENO
function Optimization.removeTerrainDetails()
    local T = Settings.Services.Terrain
    if T then
        pcall(function()
            Settings.OriginalTerrain = {
                WaterWaveSize = T.WaterWaveSize,
                WaterWaveSpeed = T.WaterWaveSpeed,
                Decoration = T.Decoration,
            }
            T.WaterWaveSize = 0
            T.WaterWaveSpeed = 0
            T.Decoration = false
        end)
    end
end

-- 15. GARBAGE COLLECTOR
function Optimization.forceGarbageCollect()
    local before = gcinfo()
    pcall(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
    return math.max(0, before - gcinfo())
end

-- CLEANUP
function Optimization.cleanup()
    if Settings.PotatoMode then
        Optimization.disablePotatoMode()
    end
    if Settings.Fullbright then
        Optimization.toggleFullbright(false)
    end
    if Settings.NoFog then
        Optimization.toggleNoFog(false)
    end
    if AntiAFKConn then
        pcall(function() AntiAFKConn:Disconnect() end)
    end
    if Settings.FPSDrawing then
        pcall(function() Settings.FPSDrawing:Remove() end)
    end
    if Settings.NoAnimationsOthers then
        Optimization.toggleNoAnimations(false)
    end
    
    if Settings.NoTerrainDetails and Settings.Services.Terrain then
        pcall(function()
            local t = Settings.Services.Terrain
            if Settings.OriginalTerrain.WaterWaveSize then
                t.WaterWaveSize = Settings.OriginalTerrain.WaterWaveSize
                t.WaterWaveSpeed = Settings.OriginalTerrain.WaterWaveSpeed
                t.Decoration = Settings.OriginalTerrain.Decoration
            end
        end)
    end
    
    for _, d in ipairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    Drawings = {}
end

return Optimization
