local Interface = {}

function Interface:Load(Hub, Config, State)
    local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Kavo.CreateLib("1NXITER HUB | V2.5", "BloodTheme")

    -- [ ABAS ]
    local TabHome = Window:NewTab("⚔️ Treino")
    local TabCombat = Window:NewTab("🎯 Combate")
    local TabExtra = Window:NewTab("🚀 Extras")
    local TabSettings = Window:NewTab("⚙️ Configs")
    local TabProf = Window:NewTab("👤 Perfil")

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    local SectionStatus = TabHome:NewSection("Status: AGUARDANDO...")
    
    TabHome:NewSection("Controles")
    TabHome:NewButton("INICIAR / PARAR TREINO", "Liga/Desliga o contador", function()
        if Hub.Features.AutoTrain then
            Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(t) 
                if t then SectionStatus:UpdateLabel(t) end 
            end)
        end
    end)

    TabHome:NewDropdown("Modo de Treino", "Exercício atual", {"Canguru", "Flexão", "Polichinelo"}, function(v)
        Config.Mode = v
    end)

    TabHome:NewSection("Ajustes Finos")
    TabHome:NewTextBox("Número Inicial", "Onde o contador começa", function(v)
        Config.StartNum = tonumber(v) or 0
    end)
    TabHome:NewTextBox("Quantidade", "Total de repetições", function(v)
        Config.Quantity = tonumber(v) or 130
    end)
    TabHome:NewSlider("Velocidade (Delay)", "Segundos entre cada repetição", 5, 1, function(v)
        Config.Delay = v
    end)
    TabHome:NewToggle("Contagem Regressiva", "Inverte a ordem", function(v)
        Config.IsCountdown = v
    end)
    TabHome:NewToggle("Auto Agachar", "Apenas para Canguru", function(v)
        Config.AutoCrouch = v
    end)
    TabHome:NewToggle("Auto Equipar", "Segura a ferramenta", function(v)
        Config.AutoEquip = v
    end)

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:NewSection("Aimbot (Auto-Mira)")
    TabCombat:NewToggle("Ativar Aimbot", "Foca a mira no inimigo", function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end
    end)
    TabCombat:NewSlider("Suavidade (Smoothness)", "Mira mais lenta/humana", 10, 1, function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v/10 end
    end)
    TabCombat:NewSlider("Raio do FOV", "Círculo de alcance", 600, 50, function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end
    end)
    TabCombat:NewToggle("Mostrar Círculo FOV", "Desenha o círculo na tela", function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end
    end)
    TabCombat:NewToggle("Wall Check", "Não mira através de paredes", function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end
    end)
    TabCombat:NewToggle("Team Check (Aimbot)", "Ignora aliados", function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.TeamCheck = v end
    end)

    TabCombat:NewSection("Hitbox Expander")
    TabCombat:NewToggle("Ativar Hitbox", "Aumenta o corpo do inimigo", function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end
    end)
    TabCombat:NewSlider("Tamanho da Hitbox", "Ajuste o tamanho (default 10)", 30, 2, function(v)
        if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxSize = v end
    end)

    TabCombat:NewSection("Visual (ESP)")
    TabCombat:NewToggle("Ativar ESP Master", "Liga o sistema visual", function(v)
        if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end
    end)
    TabCombat:NewToggle("ESP Box (Caixas)", "Desenha caixas nos players", function(v)
        if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end
    end)
    TabCombat:NewToggle("ESP Skeleton (Esqueleto)", "Desenha os ossos", function(v)
        if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end)
    TabCombat:NewToggle("ESP Health (Vida)", "Barra de vida lateral", function(v)
        if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end
    end)
    TabCombat:NewToggle("ESP Tracers", "Linhas até o player", function(v)
        if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end
    end)
    TabCombat:NewToggle("Team Check (ESP)", "Oculta aliados no ESP", function(v)
        if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamCheck = v end
    end)

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:NewSection("Movimentação")
    TabExtra:NewToggle("SpeedHack", "Corre rápido", function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end
    end)
    TabExtra:NewSlider("Velocidade", "Ajuste de WalkSpeed", 300, 16, function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end
    end)
    TabExtra:NewToggle("JumpHack", "Pula mais alto", function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleJumpPower(v) end
    end)
    TabExtra:NewSlider("Força do Pulo", "Ajuste de JumpPower", 300, 50, function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.JumpValue = v end
    end)
    TabExtra:NewToggle("Noclip", "Atravessa paredes", function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end
    end)
    TabExtra:NewToggle("Pulo Infinito", "Pula no ar", function(v)
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end
    end)

    TabExtra:NewSection("Visual e Espionagem")
    TabExtra:NewToggle("Tela Esticada", "FOV Esticado", function(v)
        if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end
    end)
    TabExtra:NewSlider("Ajuste FOV", "Zoom da tela", 120, 70, function(v)
        if Hub.Features.Visuals then Hub.Features.Visuals:UpdateFOV(v) end
    end)
    TabExtra:NewToggle("FreeCam (Câmera Livre)", "Voar com a câmera", function(v)
        if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end
    end)
    TabExtra:NewToggle("Spy Chat", "Ver mensagens ocultas", function(v)
        if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end
    end)

    -- ==========================================
    -- [ ABA 4: SISTEMA ]
    -- ==========================================
    TabSettings:NewSection("Configurações")
    TabSettings:NewButton("💾 SALVAR CONFIGURAÇÕES", "Salva seus ajustes no arquivo JSON", function()
        if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
    end)
    TabSettings:NewButton("⚡ FPS BOOST", "Reduz gráficos para aumentar FPS", function()
        if Hub.Core.Utils then Hub.Core.Utils:AntiLag() end
    end)
    TabSettings:NewButton("🔄 REJOIN", "Entra no mesmo servidor", function()
        if Hub.Core.Utils then Hub.Core.Utils:Rejoin() end
    end)
    TabSettings:NewButton("🌐 SERVER HOP", "Troca de servidor", function()
        if Hub.Core.Utils then Hub.Core.Utils:ServerHop() end
    end)

    -- ==========================================
    -- [ ABA 5: PERFIL ]
    -- ==========================================
    TabProf:NewSection("Usuário")
    TabProf:NewLabel("Nick: " .. game.Players.LocalPlayer.Name)
    TabProf:NewLabel("ID: " .. game.Players.LocalPlayer.UserId)
    
    TabProf:NewSection("Segurança")
    TabProf:NewButton("DESATIVAR TUDO (PANIC)", "Desliga todos os hacks", function()
        if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
        if Hub.Features.ESP then Hub.Features.ESP:Toggle(false) end
    end)
    TabProf:NewButton("FECHAR MENU", "Remove a interface da tela", function()
        getgenv().InxiterHubLoaded = false
        pcall(function() game:GetService("CoreGui")["1NXITER HUB | V2.5"]:Destroy() end)
    end)
end

return Interface
