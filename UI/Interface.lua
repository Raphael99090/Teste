local Interface = {}

function Interface:Load(Hub, Config, State)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "Carregando Módulos...",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    -- ABAS
    local TabHome   = Window:CreateTab("⚔️ Treino")
    local TabCombat = Window:CreateTab("🎯 Combate")
    local TabExtra  = Window:CreateTab("🚀 Extras")
    local TabProf   = Window:CreateTab("👤 Perfil")

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:CreateSection("Contador")
    local LblCount = TabHome:CreateLabel("AGUARDANDO...")

    TabHome:CreateButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(t) LblCount:Set(t) end)
            end
        end,
    })

    TabHome:CreateDropdown({
        Name = "Modo de Treino",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        CurrentOption = Config.Mode or "Canguru",
        Callback = function(v) Config.Mode = type(v) == "table" and v[1] or v end,
    })

    TabHome:CreateSection("Ajustes Numéricos")
    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Ex: 0",
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end,
    })

    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = 1.4,
        Suffix = " seg",
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
    TabCombat:CreateSection("Mira (Aimbot)")
    TabCombat:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end,
    })
    TabCombat:CreateSlider({
        Name = "Raio do FOV",
        Min = 50, Max = 600, CurrentValue = 150,
        Suffix = " px",
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Wall Check (Não varar)",
        CurrentValue = true,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end,
    })

    TabCombat:CreateSection("Hitbox")
    TabCombat:CreateToggle({
        Name = "Expandir Hitbox",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end end,
    })

    TabCombat:CreateSection("Visual (ESP)")
    TabCombat:CreateToggle({
        Name = "Ativar ESP Principal",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end,
    })
    TabCombat:CreateToggle({
        Name = "Mostrar Caixas (Box)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end,
    })
    TabCombat:CreateToggle({
        Name = "Mostrar Esqueleto",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end,
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")
    TabExtra:CreateSlider({
        Name = "Velocidade (WalkSpeed)",
        Min = 16, Max = 300, CurrentValue = 50,
        Suffix = " studs",
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end,
    })
    TabExtra:CreateToggle({
        Name = "Noclip (Atravessar)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "Pulo Infinito",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end end,
    })

    TabExtra:CreateSection("Espionagem")
    TabExtra:CreateToggle({
        Name = "Câmera Livre (FreeCam)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end,
    })
    TabExtra:CreateToggle({
        Name = "Spy Chat (Logs)",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end,
    })

    TabExtra:CreateSection("Sistema")
    TabExtra:CreateButton({
        Name = "💾 Salvar Configurações",
        Callback = function() if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end end,
    })
    TabExtra:CreateButton({
        Name = "⚡ FPS Boost",
        Callback = function() Hub.Core.Utils:AntiLag() end,
    })
    TabExtra:CreateButton({
        Name = "🌐 Server Hop",
        Callback = function() Hub.Core.Utils:ServerHop() end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateSection("Informações")
    TabProf:CreateLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    
    TabProf:CreateButton({
        Name = "REDEFINIR TUDO (PANIC)",
        Callback = function()
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
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
