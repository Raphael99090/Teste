local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Carregando a Rayfield Library
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    -- Criando a Janela Principal
    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "por Raphael99090",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "1NXITER_HUB",
            FileName = "RayfieldConfig"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = true
        },
        KeySystem = false
    })

    -- ==========================================
    -- [ ABAS ]
    -- ==========================================
    local TabHome   = Window:CreateTab("⚔️ Treino", 4483362458)
    local TabCombat = Window:CreateTab("🎯 Combate", 4483362458)
    local TabExtra  = Window:CreateTab("🚀 Extras", 4483362458)
    local TabProf   = Window:CreateTab("👤 Perfil", 4483362458)

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    local LblCount = TabHome:CreateLabel("AGUARDANDO...")

    TabHome:CreateDropdown({
        Name = "Modo de Treino",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        CurrentOption = Config.Mode or "Canguru",
        Callback = function(Option)
            Config.Mode = Option[1]
        end,
    })

    TabHome:CreateButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(textoLabel)
                    if textoLabel then LblCount:Set(textoLabel) end
                end)
            end
        end,
    })

    TabHome:CreateSection("Ajustes do Treino")

    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Ex: 0",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text) Config.StartNum = tonumber(Text) or 0 end,
    })

    TabHome:CreateInput({
        Name = "Quantidade",
        PlaceholderText = "Ex: 130",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text) Config.Quantity = tonumber(Text) or 130 end,
    })

    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = Config.Delay or 1.4,
        Callback = function(Value) Config.Delay = Value end,
    })

    TabHome:CreateToggle({
        Name = "Contagem Regressiva",
        CurrentValue = Config.IsCountdown,
        Callback = function(Value) Config.IsCountdown = Value end,
    })

    TabHome:CreateToggle({
        Name = "Auto Agachar (Canguru)",
        CurrentValue = Config.AutoCrouch,
        Callback = function(Value) Config.AutoCrouch = Value end,
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CreateSection("Aimbot (Auto-Mira)")

    TabCombat:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end,
    })

    TabCombat:CreateSlider({
        Name = "Tamanho do FOV",
        Min = 50, Max = 600, CurrentValue = 150,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end,
    })

    TabCombat:CreateSlider({
        Name = "Suavidade (Smoothness)",
        Min = 0.05, Max = 1.0, CurrentValue = 0.2,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v end end,
    })

    TabCombat:CreateToggle({
        Name = "Mostrar Círculo FOV",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end end,
    })

    TabCombat:CreateToggle({
        Name = "Checagem de Parede (WallCheck)",
        CurrentValue = true,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end,
    })

    TabCombat:CreateSection("Hitbox Expander")

    TabCombat:CreateToggle({
        Name = "Aumentar Hitbox (Inimigos)",
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
        Name = "Ativar ESP Principal",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end,
    })

    TabCombat:CreateToggle({
        Name = "ESP Box (Caixa)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end,
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

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")

    TabExtra:CreateToggle({
        Name = "SpeedHack",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end,
    })

    TabExtra:CreateSlider({
        Name = "Velocidade",
        Min = 16, Max = 250, CurrentValue = 50,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end,
    })

    TabExtra:CreateToggle({
        Name = "JumpHack (Super Pulo)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleJumpPower(v) end end,
    })

    TabExtra:CreateToggle({
        Name = "Noclip (Atravessar Paredes)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end,
    })

    TabExtra:CreateKeybind({
        Name = "Atalho Noclip",
        CurrentKeybind = "N",
        HoldToInteract = false,
        Callback = function()
            if Hub.Features.PlayerMods then
                local novoEstado = not Hub.Features.PlayerMods.Settings.Noclip
                Hub.Features.PlayerMods:ToggleNoclip(novoEstado)
                Rayfield:Notify({Title = "Noclip", Content = novoEstado and "Ativado" or "Desativado", Duration = 2})
            end
        end,
    })

    TabExtra:CreateSection("Câmera e Espionagem")

    TabExtra:CreateToggle({
        Name = "FreeCam (Câmera Livre)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end,
    })

    TabExtra:CreateToggle({
        Name = "Spy Chat (Ver Chat Oculto)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end,
    })

    TabExtra:CreateSection("Configurações do Script")

    TabExtra:CreateButton({
        Name = "💾 SALVAR CONFIGURAÇÕES",
        Callback = function()
            if Hub.Core.State then
                Hub.Core.State:SaveConfig(Config)
                Rayfield:Notify({Title = "Sucesso", Content = "Configurações salvas no celular!", Duration = 3})
            end
        end,
    })

    TabExtra:CreateButton({
        Name = "⚡ FPS BOOST MÁXIMO",
        Callback = function()
            Hub.Core.Utils:AntiLag()
            Rayfield:Notify({Title = "Otimização", Content = "Gráficos reduzidos para melhor FPS.", Duration = 3})
        end,
    })

    TabExtra:CreateButton({
        Name = "🔄 REJOIN",
        Callback = function() Hub.Core.Utils:Rejoin() end,
    })

    TabExtra:CreateButton({
        Name = "🌐 SERVER HOP",
        Callback = function() Hub.Core.Utils:ServerHop() end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateLabel("Usuário: " .. game.Players.LocalPlayer.Name)
    TabProf:CreateLabel("ID: " .. game.Players.LocalPlayer.UserId)
    
    TabProf:CreateButton({
        Name = "DESATIVAR TUDO (PANIC)",
        Callback = function()
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
            if Hub.Features.ESP then Hub.Features.ESP:Toggle(false) end
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = false end
            Rayfield:Notify({Title = "Panic", Content = "Todas as funções foram desligadas.", Duration = 3})
        end,
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
