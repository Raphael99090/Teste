local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Garante que a Config não tenha valores nulos que quebrem a Rayfield
    Config.Mode = Config.Mode or "Canguru"
    Config.Delay = Config.Delay or 1.4
    Config.StartNum = Config.StartNum or 0
    Config.Quantity = Config.Quantity or 130

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "por Raphael99090",
        ConfigurationSaving = { Enabled = false }, -- Desativado temporariamente para isolar o erro
        KeySystem = false
    })

    -- Criando as Abas sem ícones para evitar erro de carregamento de asset
    local TabHome   = Window:CreateTab("Treino")
    local TabCombat = Window:CreateTab("Combate")
    local TabExtra  = Window:CreateTab("Extras")
    local TabProf   = Window:CreateTab("Perfil")

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:CreateSection("Painel Principal")
    local LblCount = TabHome:CreateLabel("AGUARDANDO...")

    TabHome:CreateDropdown({
        Name = "Modo de Treino",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        CurrentOption = Config.Mode,
        Callback = function(Option)
            -- A Rayfield às vezes retorna uma tabela {"Opção"} ou só a string "Opção"
            if type(Option) == "table" then
                Config.Mode = Option[1]
            else
                Config.Mode = Option
            end
        end,
    })

    TabHome:CreateButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(texto)
                    LblCount:Set(texto)
                end)
            end
        end,
    })

    TabHome:CreateSection("Ajustes")
    TabHome:CreateInput({
        Name = "Número Inicial",
        PlaceholderText = "Atual: " .. tostring(Config.StartNum),
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end,
    })
    
    TabHome:CreateSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5.0, CurrentValue = Config.Delay,
        Callback = function(v) Config.Delay = v end,
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:CreateSection("Aimbot")
    TabCombat:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end,
    })
    TabCombat:CreateSlider({
        Name = "Raio do FOV",
        Min = 50, Max = 600, CurrentValue = 150,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end,
    })

    TabCombat:CreateSection("Visual (ESP)")
    TabCombat:CreateToggle({
        Name = "Ativar ESP",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end,
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:CreateSection("Movimentação")
    TabExtra:CreateSlider({
        Name = "Velocidade (Speed)",
        Min = 16, Max = 300, CurrentValue = 50,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end,
    })
    TabExtra:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end,
    })

    TabExtra:CreateSection("Utilidades")
    TabExtra:CreateButton({
        Name = "💾 Salvar Configurações",
        Callback = function() 
            if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
            Rayfield:Notify({Title = "Sucesso", Content = "Configurações salvas!", Duration = 2})
        end,
    })
    TabExtra:CreateButton({
        Name = "⚡ FPS Boost",
        Callback = function() Hub.Core.Utils:AntiLag() end,
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:CreateLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    TabProf:CreateButton({
        Name = "FECHAR MENU",
        Callback = function() 
            Rayfield:Destroy() 
            getgenv().InxiterHubLoaded = false
        end,
    })
end

return Interface
