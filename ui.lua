--[[
    1NXITER v3.0 - INTERFACE COMPLETA
    6 Abas: Combate, Visual, Otimização, Misc, Times, Perfil
]]

local UI = {}
local Settings, Utils, Aimbot, ESP, Optimization, Misc

function UI.init(settings, utils, aimbot, esp, optimization, misc)
    Settings = settings
    Utils = utils
    Aimbot = aimbot
    ESP = esp
    Optimization = optimization
    Misc = misc
    
    UI._createInterface()
end

function UI._createInterface()
    local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Raphael99090/" ..
        "1NXXiter-lib/refs/heads/main/1NXXITER%20lib.lua"
    ))()
    
    local Janela = Library:CriarJanela("1NXITER v3.0")
    
    -- ═══════════════════════════════════════════
    -- ABA 1: COMBATE ⚔
    -- ═══════════════════════════════════════════
    
    local T1 = Janela:CriarAba("⚔")
    
    T1:CriarLabel("── Aimbot ──")
    T1:CriarToggle("Ativar Aimbot [F]", false, function(v)
        Settings.Aimbot = v
    end)
    
    T1:CriarDropdown("Parte do Corpo", {
        "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"
    }, function(v) Settings.AimPart = v end)
    
    T1:CriarDropdown("Prioridade de Alvo", {
        "Closest to Crosshair", "Distance", "Health"
    }, function(v) Settings.TargetPriority = v end)
    
    T1:CriarSlider("Suavidade", 0.05, 1.0, Settings.Smoothness, 
        function(v) Settings.Smoothness = v end)
    
    T1:CriarSlider("Tamanho FOV", 30, 600, Settings.FOVSize, 
        function(v) Settings.FOVSize = v end)
    
    T1:CriarToggle("Desenhar FOV", true, function(v)
        Settings.ShowFOV = v
    end)
    T1:CriarToggle("Wallcheck", true, function(v)
        Settings.WallCheck = v
    end)
    
    T1:CriarLabel("── Extras ──")
    
    T1:CriarToggle("🎯 Triggerbot (Auto-Click)", false, function(v)
        Settings.Triggerbot = v
    end)
    
    T1:CriarSlider("Triggerbot Delay (s)", 0.05, 0.5, 
        Settings.TriggerbotDelay, function(v)
        Settings.TriggerbotDelay = v
    end)
    
    T1:CriarToggle("🔮 Aim Prediction", false, function(v)
        Settings.AimPrediction = v
    end)
    
    T1:CriarSlider("Prediction Strength", 0.05, 0.5, 
        Settings.PredictionStrength, function(v)
        Settings.PredictionStrength = v
    end)
    
    T1:CriarLabel("── Hitbox ──")
    
    T1:CriarToggle("Expandir Hitbox", false, function(v)
        Settings.HitboxExpand = v
    end)
    T1:CriarSlider("Tamanho Hitbox", 2, 15, Settings.HitboxSize, 
        function(v) Settings.HitboxSize = v end)
    
    -- ═══════════════════════════════════════════
    -- ABA 2: VISUAL 👁
    -- ═══════════════════════════════════════════
    
    local T2 = Janela:CriarAba("👁")
    
    T2:CriarLabel("── ESP ──")
    T2:CriarToggle("Ativar ESP [G]", false, function(v)
        Settings.ESP_Enabled = v
    end)
    T2:CriarToggle("Box", false, function(v)
        Settings.ESP_Box = v
    end)
    T2:CriarToggle("Skeleton", false, function(v)
        Settings.ESP_Skeleton = v
    end)
    T2:CriarToggle("Nomes", false, function(v)
        Settings.ESP_Names = v
    end)
    T2:CriarToggle("Barra de Vida", false, function(v)
        Settings.ESP_Health = v
    end)
    T2:CriarToggle("Tracers", false, function(v)
        Settings.ESP_Lines = v
    end)
    T2:CriarToggle("Distância", false, function(v)
        Settings.ESP_Distance = v
    end)
    T2:CriarSlider("Distância Máxima", 100, 2000, 
        Settings.ESP_MaxDistance, function(v)
        Settings.ESP_MaxDistance = v
    end)
    
    T2:CriarLabel("── Novidades v3.0 ──")
    
    T2:CriarToggle("✨ Chams (Highlight)", false, function(v)
        Settings.ESP_Chams = v
    end)
    
    T2:CriarToggle("🎯 Target Info Panel", false, function(v)
        Settings.ShowTargetInfo = v
    end)
    
    -- ═══════════════════════════════════════════
    -- ABA 3: OTIMIZAÇÃO 🚀
    -- ═══════════════════════════════════════════
    
    local T3 = Janela:CriarAba("🚀")
    
    T3:CriarLabel("── Performance ──")
    
    T3:CriarToggle("🥔 Modo Batata", false, function(v)
        if v then Optimization.applyPotatoMode()
        else Optimization.disablePotatoMode() end
    end)
    
    T3:CriarToggle("🌑 Remover Sombras", false, function(v)
        if v then Optimization.removeShadows() end
    end)
    
    T3:CriarToggle("🔽 Low Render", false, function(v)
        Optimization.toggleLowRender(v)
    end)
    
    T3:CriarBotao("🧹 Limpar RAM (GC)", function()
        local freed = Optimization.forceGarbageCollect()
        Library:Notificar("🧹 GC", 
            "Liberado ~" .. math.floor(freed) .. " KB", 3)
    end)
    
    T3:CriarToggle("📊 Mostrar FPS", false, function(v)
        Optimization.toggleFPSCounter(v)
    end)
    
    T3:CriarLabel("── Visual ──")
    
    T3:CriarToggle("🔦 Fullbright", false, function(v)
        Optimization.toggleFullbright(v)
    end)
    
    T3:CriarToggle("🌫️ No Fog", false, function(v)
        Optimization.toggleNoFog(v)
    end)
    
    T3:CriarBotao("🌊 Remover Post-FX", function()
        local c = Optimization.removePostProcessing()
        Library:Notificar("🌊", "Removidos " .. c .. " efeitos", 2)
    end)
    
    T3:CriarBotao("🎨 Remover Texturas", function()
        local c = Optimization.removeTextures()
        Library:Notificar("🎨", "Removidas " .. c .. " texturas", 2)
    end)
    
    T3:CriarBotao("✨ Remover Partículas", function()
        local c = Optimization.removeParticles()
        Library:Notificar("✨", 
            "Removidas " .. c .. " partículas", 2)
    end)
    
    T3:CriarBotao("🏔️ Simplificar Terreno", function()
        Optimization.removeTerrainDetails()
        Library:Notificar("🏔️", "Terreno simplificado", 2)
    end)
    
    T3:CriarLabel("── Ambiente ──")
    
    T3:CriarToggle("🔇 Mutar Sons", false, function(v)
        Optimization.toggleMute(v)
    end)
    
    T3:CriarBotao("🎩 Remover Acessórios", function()
        local c = Optimization.removeAccessories()
        Library:Notificar("🎩", 
            "Removidos " .. c .. " acessórios", 2)
    end)
    
    T3:CriarToggle("💀 No Animações (outros)", false, function(v)
        Optimization.toggleNoAnimations(v)
    end)
    
    T3:CriarToggle("⏰ Anti-AFK", false, function(v)
        Optimization.toggleAntiAFK(v)
    end)
    
    -- ═══════════════════════════════════════════
    -- ABA 4: MISC 🔮
    -- ═══════════════════════════════════════════
    
    local T4 = Janela:CriarAba("🔮")
    
    T4:CriarLabel("── Espionagem ──")
    
    T4:CriarToggle("🕵️ Chat Spy", false, function(v)
        Misc.toggleChatSpy(v)
        Library:Notificar("🕵️", 
            v and "Chat Spy ATIVO (veja console)" 
            or "Chat Spy OFF", 3)
    end)
    
    T4:CriarLabel("── Watermark ──")
    
    T4:CriarToggle("📌 Watermark", false, function(v)
        Misc.toggleWatermark(v)
    end)
    
    T4:CriarLabel("── Servidor ──")
    
    T4:CriarBotao("🔁 Rejoin", function()
        Library:Notificar("🔁", "Reconectando...", 2)
        Misc.rejoin()
    end)
    
    T4:CriarLabel("── Keybinds ──")
    T4:CriarLabel("[F] Toggle Aimbot")
    T4:CriarLabel("[G] Toggle ESP")
    
    -- ═══════════════════════════════════════════
    -- ABA 5: TIMES 🛡
    -- ═══════════════════════════════════════════
    
    local T5 = Janela:CriarAba("🛡")
    
    T5:CriarToggle("Filtro de Time", true, function(v)
        Settings.TeamCheck = v
    end)
    
    local function refreshTeams()
        local Teams = game:GetService("Teams")
        for _, team in ipairs(Teams:GetTeams()) do
            if not Settings.ActiveTeams[team.Name] then
                Settings.ActiveTeams[team.Name] = false
                pcall(function()
                    T5:CriarToggle("🏳 " .. team.Name, false, 
                        function(v)
                            Settings.ActiveTeams[team.Name] = v
                        end)
                end)
            end
        end
    end
    
    pcall(refreshTeams)
    
    T5:CriarBotao("🔄 Atualizar Times", function()
        pcall(refreshTeams)
        Library:Notificar("🛡", "Times atualizados!", 2)
    end)
    
    -- ═══════════════════════════════════════════
    -- ABA 6: PERFIL 👤
    -- ═══════════════════════════════════════════
    
    local T6 = Janela:CriarAba("👤")
    
    local lp = Settings.Services.LocalPlayer
    
    T6:CriarLabel("━━━━━ Info ━━━━━")
    T6:CriarLabel("Jogador: " .. lp.Name)
    T6:CriarLabel("Display: " .. lp.DisplayName)
    T6:CriarLabel("ID: " .. tostring(lp.UserId))
    T6:CriarLabel("━━━━━ Script ━━━━━")
    T6:CriarLabel("Versão: 3.0")
    T6:CriarLabel("Módulos: 8")
    T6:CriarLabel("Features: 30+")
    T6:CriarLabel("Rig: Auto-detectado")
    
    T6:CriarBotao("📋 Copiar meu Username", function()
        Misc.copyUsername(lp.Name)
        Library:Notificar("📋", "Username copiado!", 2)
    end)
    
    T6:CriarBotao("🗑 Destruir Script", function()
        local fn = getgenv()._1NXITER_DESTROY
        if fn then fn() end
        Library:Notificar("👋", "Script destruído!", 3)
    end)
    
    -- Notificação final
    Library:Notificar(
        "🔥 1NXITER v3.0", 
        "8 módulos • 30+ features • Keybinds ativos!", 
        5
    )
end

return UI
