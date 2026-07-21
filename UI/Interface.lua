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
        KeySystem = false
    })

    -- ==========================================
    -- [ CRIAÇÃO DAS ABAS ]
    -- ==========================================
    local TabHome   = Window:CreateTab("⚔️ Treino")
    local TabCombat = Window:CreateTab("🎯 Combate")
    local TabExtra  = Window:CreateTab("🚀 Extras")
    local TabProf   = Window:CreateTab("👤 Perfil")

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:CreateSection("Painel de Treino")
    
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
            if Hub.Features and Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(textoLabel)
                    if textoLabel then LblCount:Set(textoLabel) end
                end)
            else
                Rayfield:Notify({Title = "Erro", Content = "Módulo AutoTrain não carregado!", Duration = 3})
            end
        end,
    })

    TabHome:CreateSection("Configurações")

    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Ex: 0",
        Callback = function(Text) Config.StartNum = tonumber(Text) or 0 end,
    })

    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = Config.Delay or 1.4,
        Callback = function(Value) Config.Delay = Value end,
    })

    TabHome:CreateToggle({
        Name = "Auto Agachar (Canguru)",
        CurrentValue = Config.AutoCrouch or false,
        Callback = function(Value) Config.AutoCrouch = Value end,
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CreateSection("Aimbot & Mira")

    TabCombat:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = Value end 
        end,
    })

    TabCombat:CreateSlider({
        Name = "Tamanho do FOV",
        Min = 50, Max = 600, CurrentValue = 150,
        Callback = function(Value) 
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = Value end 
        end,
    })

    TabCombat:CreateToggle({
        Name = "Mostrar Círculo FOV",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = Value end 
        end,
    })

    TabCombat:CreateSection("Visual (ESP)")

    TabCombat:CreateToggle({
        Name = "Ativar ESP Principal",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.ESP then Hub.Features.ESP:Toggle(Value) end 
        end,
    })

    TabCombat:CreateToggle({
        Name = "Exibir Caixas (Box)",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = Value end 
        end,
    })

    TabCombat:CreateSection("Outros")

    TabCombat:CreateToggle({
        Name = "Aumentar Hitbox",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = Value end 
        end,
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")

    TabExtra:CreateToggle({
        Name = "Super Velocidade (Speed)",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(Value) end 
        end,
    })

    TabExtra:CreateSlider({
        Name = "Valor da Velocidade",
        Min = 16, Max = 300, CurrentValue = 50,
        Callback = function(Value) 
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = Value end 
        end,
    })

    TabExtra:CreateToggle({
        Name = "Atravessar Paredes (Noclip)",
        CurrentValue = false,
        Callback = function(Value) 
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(Value) end 
        end,
    })

    TabExtra:CreateSection("Utilidades")

    TabExtra:CreateButton({
        Name = "💾 Salvar Configurações",
        Callback = function()
            if Hub.Core.State then 
                Hub.Core.State:SaveConfig(Config)
                Rayfield:Notify({Title = "Sistema", Content = "Configurações salvas!", Duration = 2})
            end
        end,
    })

    TabExtra:CreateButton({
        Name = "🌐 Mudar de Servidor (Server Hop)",
        Callback = function() 
            if Hub.Core.Utils then Hub.Core.Utils:ServerHop() end 
        end,
    })

    TabExtra:CreateButton({
        Name = "⚡ FPS Boost",
        Callback = function() 
            if Hub.Core.Utils then Hub.Core.Utils:AntiLag() end 
        end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateSection("Informações")
    TabProf:CreateLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    
    TabProf:CreateSection("Controle do Menu")
    
    TabProf:CreateButton({
        Name = "REDEFINIR TUDO (PANIC)",
        Callback = function()
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
            Rayfield:Notify({Title = "Panic", Content = "Funções desligadas.", Duration = 2})
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
