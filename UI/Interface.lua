local Interface = {}

function Interface:Load(Hub, Config, State)
    -- 1. SANITIZAÇÃO DE DADOS (Garante que a Rayfield não receba 'nil' e trave)
    local function Sanitize(val, default)
        if val == nil then return default end
        if type(default) == "number" then return tonumber(val) or default end
        return val
    end

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "Carregando Módulos Completos...",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    -- [ ABAS ]
    local TabHome   = Window:CreateTab("⚔️ Treino")
    local TabCombat = Window:CreateTab("🎯 Combate")
    local TabExtra  = Window:CreateTab("🚀 Extras")
    local TabProf   = Window:CreateTab("👤 Perfil")

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:CreateSection("Painel de Treino")
    local LblCount = TabHome:CreateLabel("STATUS: AGUARDANDO...")

    TabHome:CreateButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(t) 
                    if t then LblCount:Set(t) end 
                end)
            end
        end,
    })

    TabHome:CreateDropdown({
        Name = "Modo de Treino",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        CurrentOption = Sanitize(Config.Mode, "Canguru"),
        Callback = function(v) Config.Mode = type(v) == "table" and v[1] or v end,
    })

    TabHome:CreateSection("Ajustes de Contador")
    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Atual: " .. Sanitize(Config.StartNum, 0),
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end,
    })
    TabHome:CreateInput({
        Name = "Quantidade",
        PlaceholderText = "Atual: " .. Sanitize(Config.Quantity, 130),
        Callback = function(v) Config.Quantity = tonumber(v) or 130 end,
    })
    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = Sanitize(Config.Delay, 1.4),
        Callback = function(v) Config.Delay = v end,
    })

    TabHome:CreateSection("Automação")
    TabHome:CreateToggle({
        Name = "Contagem Regressiva",
        CurrentValue = Sanitize(Config.IsCountdown, false),
        Callback = function(v) Config.IsCountdown = v end,
    })
    TabHome:CreateToggle({
        Name = "Auto Agachar (Canguru)",
        CurrentValue = Sanitize(Config.AutoCrouch, false),
        Callback = function(v) Config.AutoCrouch = v end,
    })
    TabHome:CreateToggle({
        Name = "Auto Equipar Arma/Ferramenta",
        CurrentValue = Sanitize(Config.AutoEquip, false),
        Callback = function(v) Config.AutoEquip = v end,
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CreateSection("Aimbot")
    TabCombat:CreateToggle({
        Name = "Ativar Auto-Mira",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end,
    })
    TabCombat:CreateSlider({
        Name = "Suavidade (Smoothness)",
        Min = 0.1, Max = 1.0, CurrentValue = 0.5,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v end end,
    })
    TabCombat:CreateSlider({
        Name = "Raio do FOV",
        Min = 50, Max = 600, CurrentValue = 150,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Mostrar Círculo FOV",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Wall Check (Não mirar por paredes)",
        CurrentValue = true,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Ignorar Aliados (Team Check)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.TeamCheck = v end end,
    })

    TabCombat:CreateSection("Hitbox")
    TabCombat:CreateToggle({
        Name = "Aumentar Hitbox Inimiga",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end end,
    })
    TabCombat:CreateSlider({
        Name = "Tamanho da Hitbox",
        Min = 2, Max = 30, CurrentValue = 10,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxSize = v end end,
    })

    TabCombat:CreateSection("Visual (ESP)")
    TabCombat:CreateToggle({
        Name = "Ativar ESP",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end,
    })
    TabCombat:CreateToggle({
        Name = "ESP Box (Caixa)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end,
    })
    TabCombat:CreateColorPicker({
        Name = "Cor da Caixa",
        Color = Color3.fromRGB(255,255,255),
        Callback = function(c) if Hub.Features.ESP then Hub.Features.ESP.Settings.BoxColor = c end end
    })
    TabCombat:CreateToggle({
        Name = "ESP Skeleton (Esqueleto)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Barra de Vida",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Tracers (Linhas)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end end,
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")
    TabExtra:CreateToggle({
        Name = "Ativar Velocidade",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end,
    })
    TabExtra:CreateSlider({
        Name = "Valor Speed",
        Min = 16, Max = 300, CurrentValue = 50,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end,
    })
    TabExtra:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "Pulo Infinito",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end end,
    })

    TabExtra:CreateSection("Câmera & Visual")
    TabExtra:CreateToggle({
        Name = "Tela Esticada (Stretch)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end end,
    })
    TabExtra:CreateSlider({
        Name = "Zoom do FOV",
        Min = 70, Max = 120, CurrentValue = 100,
        Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:UpdateFOV(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "FreeCam",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end,
    })

    TabExtra:CreateSection("Espionagem & Logs")
    TabExtra:CreateToggle({
        Name = "Spy Chat (Ver mensagens)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end,
    })

    TabExtra:CreateSection("Sistema")
    TabExtra:CreateButton({
        Name = "💾 SALVAR CONFIGURAÇÕES",
        Callback = function() if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end end,
    })
    TabExtra:CreateButton({
        Name = "⚡ FPS BOOST",
        Callback = function() Hub.Core.Utils:AntiLag() end,
    })
    TabExtra:CreateButton({
        Name = "🌐 SERVER HOP",
        Callback = function() Hub.Core.Utils:ServerHop() end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateSection("Info")
    TabProf:CreateLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    
    TabProf:CreateSection("Sair")
    TabProf:CreateButton({
        Name = "DESATIVAR TUDO (PANIC)",
        Callback = function() if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end end,
    })
    TabProf:CreateButton({
        Name = "FECHAR MENU",
        Callback = function() 
            Rayfield:Destroy() 
            getgenv().InxiterHubLoaded = false
        end,
    })
end

return Interface
