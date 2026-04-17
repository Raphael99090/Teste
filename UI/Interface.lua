local Interface = {}

function Interface:Load(Hub, Config, State)
    local Window = Hub.UI.Library:CriarJanela("1NXITER HUB")

    local TabHome   = Window:CriarAba("⚔", "Treino")
    local TabCombat = Window:CriarAba("🎯", "Combate")
    local TabExtra  = Window:CriarAba("🚀", "Extras")
    local TabProf   = Window:CriarAba("👤", "Perfil")

    local coresNomes = {"Branco", "Vermelho", "Verde", "Azul", "Amarelo", "Roxo"}
    local coresMap = {["Branco"] = Color3.fromRGB(255, 255, 255), ["Vermelho"] = Color3.fromRGB(255, 0, 0), ["Verde"] = Color3.fromRGB(50, 255, 50), ["Azul"] = Color3.fromRGB(0, 150, 255), ["Amarelo"] = Color3.fromRGB(255, 215, 0), ["Roxo"] = Color3.fromRGB(150, 0, 255) }

    -- ==========================================
    --[ ABA 1: TREINO E AJUSTES ]
    -- ==========================================
    local LblCount = TabHome:CriarLabel("AGUARDANDO...", Color3.fromRGB(255,45,45))
    TabHome:CriarDropdown("Modo de Treino", {"Canguru", "Flexão", "Polichinelo"}, function(v) Config.Mode = v end)

    local BtnStart
    BtnStart = TabHome:CriarBotao("INICIAR TREINO", function()
        -- O Módulo de AutoTrain cuida de tudo e usa esse 'Callback' para mudar o texto da UI
        if Hub.Features.AutoTrain then
            Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(textoContador, textoBotao)
                if textoContador then LblCount(textoContador) end
                if textoBotao then BtnStart(textoBotao) end
            end)
        end
    end)

    TabHome:CriarLabel("---  AJUSTES DO TREINO  ---", Color3.fromRGB(255, 200, 50))
    TabHome:CriarInput("Número Inicial", Config.StartNum, function(v) Config.StartNum = tonumber(v) or 0 end)
    TabHome:CriarInput("Quantidade", Config.Quantity, function(v) Config.Quantity = tonumber(v) or 130 end)
    TabHome:CriarSlider("Velocidade (Delay)", 0.5, 5.0, Config.Delay, function(v) Config.Delay = v end)
    TabHome:CriarToggle("Contagem Regressiva", Config.IsCountdown, function(v) Config.IsCountdown = v end)
    TabHome:CriarToggle("Auto Agachar (Canguru)", Config.AutoCrouch, function(v) Config.AutoCrouch = v end)

    -- ==========================================
    --[ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CriarLabel("---  SISTEMA DE MIRA (AIMBOT)  ---", Color3.fromRGB(220, 20, 60))
    TabCombat:CriarToggle("Ativar Aimbot (Auto-Mira)", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end)
    TabCombat:CriarToggle("Mostrar Círculo FOV", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end end)
    TabCombat:CriarSlider("Tamanho do FOV", 50, 500, 150, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end)
    TabCombat:CriarSlider("Suavidade (Aimbot)", 0.1, 1.0, 0.5, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v end end)

    TabCombat:CriarLabel("---  HITBOX EXPANDER  ---", Color3.fromRGB(255, 200, 50))
    TabCombat:CriarToggle("Aumentar Hitbox (Tiros fáceis)", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end end)
    TabCombat:CriarSlider("Tamanho da Hitbox", 2, 30, 10, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxSize = v end end)

    TabCombat:CriarLabel("---  TELA ESTICADA (FOV)  ---", Color3.fromRGB(255, 100, 255))
    TabCombat:CriarToggle("Ativar Tela Esticada", false, function(v) if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end end)
    TabCombat:CriarSlider("Campo de Visão (Zoom)", 70, 120, 100, function(v) if Hub.Features.Visuals then Hub.Features.Visuals.Settings.FOVValue = v end end)

    TabCombat:CriarLabel("---  VISUAL (ESP)  ---", Color3.fromRGB(80, 255, 120))
    TabCombat:CriarToggle("Ativar ESP Principal", false, function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end)
    TabCombat:CriarToggle("Time / Sigla [ESP]", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamText = v end end)
    TabCombat:CriarToggle("Health Bar (Barra de Vida)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end)
    TabCombat:CriarToggle("Box (Caixa)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end)
    TabCombat:CriarDropdown("↳ Cor da Caixa", coresNomes, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.BoxColor = coresMap[v] end end)
    TabCombat:CriarToggle("Skeleton (Esqueleto)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end)
    TabCombat:CriarDropdown("↳ Cor do Esqueleto", coresNomes, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.SkeletonColor = coresMap[v] end end)
    TabCombat:CriarToggle("Tracers (Linhas)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end end)
    TabCombat:CriarDropdown("↳ Cor das Linhas", coresNomes, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TracerColor = coresMap[v] end end)

    -- ==========================================
    --[ ABA 3: EXTRAS E MEMÓRIA ]
    -- ==========================================
    TabExtra:CriarLabel("---  INTELIGÊNCIA E ESPIONAGEM  ---", Color3.fromRGB(255, 80, 80))
    TabExtra:CriarToggle("FreeCam (Câmera Livre - PC)", false, function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end)
    TabExtra:CriarSlider("Velocidade da FreeCam", 1, 10, 2, function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam.Settings.Speed = v end end)
    TabExtra:CriarToggle("Spy Chat (Ver Chat Oculto)", false, function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end)

    TabExtra:CriarLabel("---  MEMÓRIA / CONFIGURAÇÕES  ---", Color3.fromRGB(80, 255, 120))
    TabExtra:CriarBotao("💾 SALVAR CONFIGURAÇÕES", function()
        if Hub.Core.State then local sucesso = Hub.Core.State:SaveConfig(Config); if sucesso then Hub.UI.Library:Notificar("Sucesso!", "Configurações salvas no celular (.json)", 3) else Hub.UI.Library:Notificar("Aviso", "Seu executor não suporta salvar arquivos.", 3) end end
    end)

    TabExtra:CriarLabel("---  ESTILO DO MENU  ---", Color3.fromRGB(255, 215, 0))
    TabExtra:CriarDropdown("Tema da Interface", {"Crimson", "Neon Purple", "Ocean Blue", "Toxic Green", "Midnight Gold"}, function(tema) Hub.UI.Library:ChangeTheme(tema); Hub.UI.Library:Notificar("Tema", "Atualizado para " .. tema, 3) end)

    TabExtra:CriarLabel("---  UTILITÁRIOS  ---", Color3.fromRGB(245, 245, 245))
    TabExtra:CriarToggle("Auto Equipar Arma (Treino)", Config.AutoEquip, function(v) Config.AutoEquip = v end)
    TabExtra:CriarToggle("Auto Rejoin", Config.AutoRejoin, function(v) Config.AutoRejoin = v end)
    TabExtra:CriarBotao("ANTI-LAG (Remover Texturas)", function() Hub.Core.Utils:AntiLag(); Hub.UI.Library:Notificar("Otimização", "Gráficos reduzidos.", 3) end)

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CriarPerfil()
    
    TabProf:CriarBotao("FECHAR MENU (PANIC)", function() 
        State.IsActive = false 
        
        -- [MÁGICA DO CÓDIGO LIMPO]: Em vez de escrever 50 linhas desligando hack por hack, 
        -- o laço 'for' varre a pasta Features inteira e desliga tudo que estiver ligado automaticamente!
        if Hub.Features then
            for _, feature in pairs(Hub.Features) do
                if feature and type(feature.Toggle) == "function" then
                    pcall(function() feature:Toggle(false) end)
                elseif feature and feature.Settings and feature.Settings.Enabled ~= nil then
                    feature.Settings.Enabled = false
                end
            end
        end
        
        -- Limpa a Interface da tela
        if game.CoreGui:FindFirstChild("CrimsonUI") then game.CoreGui["CrimsonUI"]:Destroy() end
        if game.CoreGui:FindFirstChild("InxiterFOVMobile") then game.CoreGui["InxiterFOVMobile"]:Destroy() end
        if game.CoreGui:FindFirstChild("InxiterSpyChat") then game.CoreGui["InxiterSpyChat"]:Destroy() end
    end)
end

return Interface
