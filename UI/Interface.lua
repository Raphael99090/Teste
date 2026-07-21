local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Inicialização da Rayfield
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "por Raphael99090",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "1NXITER_HUB",
            FileName = "ConfigPrincipal"
        },
        KeySystem = false
    })

    -- [ ABAS ]
    local TabHome   = Window:CreateTab("⚔️ Treino", 4483362458)
    local TabCombat = Window:CreateTab("🎯 Combate", 4483362458)
    local TabExtra  = Window:CreateTab("🚀 Extras", 4483362458)
    local TabProf   = Window:CreateTab("👤 Perfil", 4483362458)

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:CreateSection("Status do Treino")
    local LblCount = TabHome:CreateLabel("AGUARDANDO...")

    TabHome:CreateDropdown({
        Name = "Modo de Treino",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        CurrentOption = Config.Mode or "Canguru",
        Callback = function(Option)
            Config.Mode = typeof(Option) == "table" and Option[1] or Option
        end,
    })

    TabHome:CreateButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(texto)
                    if texto then LblCount:Set(texto) end
                end)
            end
        end,
    })

    TabHome:CreateSection("Ajustes")
    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = tostring(Config.StartNum or 0),
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end,
    })
    TabHome:CreateInput({
        Name = "Quantidade",
        PlaceholderText = tostring(Config.Quantity or 130),
        Callback = function(v) Config.Quantity = tonumber(v) or 130 end,
    })
    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = Config.Delay or 1.4,
        Callback = function(v) Config.Delay = v end,
    })
    TabHome:CreateToggle({
        Name = "Auto Agachar (Canguru)",
        CurrentValue = Config.AutoCrouch or false,
        Callback = function(v) Config.AutoCrouch = v end,
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
        Name = "Suavidade",
        Min = 0.05, Max = 1.0, CurrentValue = 0.2,
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
        Name = "WallCheck (Não mirar através de muros)",
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

    TabCombat:CreateSection("Visuals (ESP)")
    TabCombat:CreateToggle({
        Name = "Ativar ESP Principal",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end,
    })
    TabCombat:CreateToggle({
        Name = "Caixas (Box)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Esqueleto (Skeleton)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Barra de Vida (Health Bar)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end,
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")
    TabExtra:CreateToggle({
        Name = "Super Velocidade",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end,
    })
    TabExtra:CreateSlider({
        Name = "Velocidade",
        Min = 16, Max = 300, CurrentValue = 50,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end,
    })
    TabExtra:CreateToggle({
        Name = "Pulo Infinito",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "Noclip (Atravessar Paredes)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end,
    })

    TabExtra:CreateSection("Visual da Câmera")
    TabExtra:CreateToggle({
        Name = "Tela Esticada (Zoom FOV)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end end,
    })
    TabExtra:CreateSlider({
        Name = "Intensidade do Zoom",
        Min = 70, Max = 120, CurrentValue = 100,
        Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:UpdateFOV(v) end end,
    })

    TabExtra:CreateSection("Espionagem")
    TabExtra:CreateToggle({
        Name = "FreeCam (Câmera Livre)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "Spy Chat (Logs do Chat)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end,
    })

    TabExtra:CreateSection("Configurações do Sistema")
    TabExtra:CreateButton({
        Name = "💾 Salvar Configurações",
        Callback = function() 
            if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
            Rayfield:Notify({Title = "Sucesso", Content = "Salvo com sucesso!", Duration = 3})
        end,
    })
    TabExtra:CreateButton({
        Name = "⚡ FPS Boost (Anti-Lag)",
        Callback = function() Hub.Core.Utils:AntiLag() end,
    })
    TabExtra:CreateButton({
        Name = "🌐 Server Hop",
        Callback = function() Hub.Core.Utils:ServerHop() end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateSection("Dados do Jogador")
    TabProf:CreateLabel("Nome: " .. game.Players.LocalPlayer.Name)
    TabProf:CreateLabel("ID: " .. game.Players.LocalPlayer.UserId)
    
    TabProf:CreateSection("Finalizar")
    TabProf:CreateButton({
        Name = "REDEFINIR TUDO (PANIC)",
        Callback = function()
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
            Rayfield:Notify({Title = "Panic", Content = "Modificações desativadas.", Duration = 3})
        end,
    })
    TabProf:CreateButton({
        Name = "FECHAR INTERFACE",
        Callback = function()
            Rayfield:Destroy()
            getgenv().InxiterHubLoaded = false
        end,
    })
end

return Interface
