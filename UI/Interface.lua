local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Carregando a Rayfield Library
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB",
        LoadingTitle = "Carregando Sistema...",
        LoadingSubtitle = "por Inxiter",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "InxiterHub", -- Pasta onde salva as configs
            FileName = "ConfigPrincipal"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = true
        },
        KeySystem = false -- Mude para true se quiser sistema de key
    })

    -- ==========================================
    -- [ ABAS ]
    -- ==========================================
    local TabHome   = Window:CreateTab("⚔ Treino", 4483362458) 
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
        MultipleOptions = false,
        Callback = function(Option)
            Config.Mode = Option[1]
        end,
    })

    local BtnStart
    TabHome:CreateButton({
        Name = "INICIAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(textoContador, textoBotao)
                    if textoContador then LblCount:Set(textoContador) end
                    -- Rayfield não permite mudar o texto do botão facilmente após criado, 
                    -- recomenda-se usar Labels para status.
                end)
            end
        end,
    })

    TabHome:CreateSection("Ajustes do Treino")
    
    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Ex: 0",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            Config.StartNum = tonumber(Text) or 0
        end,
    })

    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5,
        Max = 5.0,
        CurrentValue = Config.Delay or 1,
        Flag = "SliderDelay",
        Callback = function(Value)
            Config.Delay = Value
        end,
    })

    TabHome:CreateToggle({
        Name = "Contagem Regressiva",
        CurrentValue = Config.IsCountdown,
        Flag = "Countdown",
        Callback = function(Value)
            Config.IsCountdown = Value
        end,
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CreateSection("Sistema de Mira")

    TabCombat:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Callback = function(Value)
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = Value end
        end,
    })

    TabCombat:CreateSlider({
        Name = "Tamanho do FOV",
        Min = 50,
        Max = 500,
        CurrentValue = 150,
        Callback = function(Value)
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = Value end
        end,
    })

    TabCombat:CreateSection("Visual (ESP)")

    TabCombat:CreateToggle({
        Name = "Ativar ESP",
        CurrentValue = false,
        Callback = function(Value)
            if Hub.Features.ESP then Hub.Features.ESP:Toggle(Value) end
        end,
    })

    TabCombat:CreateColorPicker({
        Name = "Cor da Caixa",
        Color = Color3.fromRGB(255,255,255),
        Callback = function(Value)
            if Hub.Features.ESP then Hub.Features.ESP.Settings.BoxColor = Value end
        end
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")

    TabExtra:CreateToggle({
        Name = "SpeedHack",
        CurrentValue = false,
        Callback = function(Value)
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(Value) end
        end,
    })

    TabExtra:CreateSlider({
        Name = "Velocidade",
        Min = 16,
        Max = 200,
        CurrentValue = 50,
        Callback = function(Value)
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = Value end
        end,
    })

    TabExtra:CreateKeybind({
        Name = "Noclip (Atalho)",
        CurrentKeybind = "N",
        HoldToInteract = false,
        Flag = "KeybindNoclip",
        Callback = function(Keybind)
            if Hub.Features.PlayerMods then
                local estado = not Hub.Features.PlayerMods.Settings.Noclip
                Hub.Features.PlayerMods:ToggleNoclip(estado)
                Rayfield:Notify({Title = "Noclip", Content = estado and "Ligado" or "Desligado", Duration = 2})
            end
        end,
    })

    TabExtra:CreateSection("Utilitários")

    TabExtra:CreateButton({
        Name = "⚡ FPS BOOST MÁXIMO",
        Callback = function()
            Hub.Core.Utils:AntiLag()
            Rayfield:Notify({Title = "Otimização", Content = "Gráficos Reduzidos", Duration = 3, Type = "success"})
        end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL E FECHAR ]
    -- ==========================================
    TabProf:CreateLabel("Usuário: " .. game.Players.LocalPlayer.Name)
    
    TabProf:CreateButton({
        Name = "FECHAR MENU (PANIC)",
        Callback = function()
            State.IsActive = false 
            -- Desativa funções
            if Hub.Features then
                for _, feature in pairs(Hub.Features) do
                    pcall(function() if feature.Toggle then feature:Toggle(false) end end)
                end
            end
            Rayfield:Destroy()
        end,
    })
end

return Interface
