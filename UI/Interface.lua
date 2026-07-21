local Interface = {}

function Interface:Load(Hub, Config, State)
    -- 1. LIMPEZA DE DADOS (Mata o erro "index nil with number")
    -- Garantimos que todos os valores que vão para Sliders sejam NÚMEROS
    local safe = {
        Delay = tonumber(Config.Delay) or 1.4,
        StartNum = tonumber(Config.StartNum) or 0,
        Quantity = tonumber(Config.Quantity) or 130,
        Speed = 50,
        FOV = 150
    }
    
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "1NXITER HUB | V2.5",
        LoadingTitle = "Inxiter System",
        LoadingSubtitle = "Carregando Abas...",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    -- 2. CRIAR TODAS AS ABAS PRIMEIRO
    local TabHome   = Window:CreateTab("⚔️ Treino")
    local TabCombat = Window:CreateTab("🎯 Combate")
    local TabExtra  = Window:CreateTab("🚀 Extras")
    local TabProf   = Window:CreateTab("👤 Perfil")

    -- ==========================================
    -- [ CONTEÚDO: ABA TREINO ]
    -- ==========================================
    pcall(function()
        TabHome:CreateSection("Status")
        local LblCount = TabHome:CreateLabel("AGUARDANDO...")

        TabHome:CreateDropdown({
            Name = "Modo de Treino",
            Options = {"Canguru", "Flexão", "Polichinelo"},
            CurrentOption = "Canguru",
            Callback = function(Option)
                Config.Mode = type(Option) == "table" and Option[1] or Option
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

        TabHome:CreateSlider({
            Name = "Velocidade (Delay)",
            Min = 0.5, Max = 5.0, CurrentValue = safe.Delay,
            Callback = function(v) Config.Delay = v end,
        })
    end)

    -- ==========================================
    -- [ CONTEÚDO: ABA COMBATE ]
    -- ==========================================
    pcall(function()
        TabCombat:CreateSection("Aimbot")
        
        TabCombat:CreateToggle({
            Name = "Ativar Aimbot",
            CurrentValue = false,
            Callback = function(v) 
                if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end 
            end,
        })

        TabCombat:CreateSlider({
            Name = "Raio do FOV",
            Min = 50, Max = 600, CurrentValue = safe.FOV,
            Callback = function(v) 
                if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end 
            end,
        })

        TabCombat:CreateSection("Visual (ESP)")
        
        TabCombat:CreateToggle({
            Name = "Ativar ESP Principal",
            CurrentValue = false,
            Callback = function(v) 
                if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end 
            end,
        })
    end)

    -- ==========================================
    -- [ CONTEÚDO: ABA EXTRAS ]
    -- ==========================================
    pcall(function()
        TabExtra:CreateSection("Movimentação")
        
        TabExtra:CreateSlider({
            Name = "Velocidade (WalkSpeed)",
            Min = 16, Max = 300, CurrentValue = safe.Speed,
            Callback = function(v) 
                if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end 
            end,
        })

        TabExtra:CreateToggle({
            Name = "Noclip (Atravessar Paredes)",
            CurrentValue = false,
            Callback = function(v) 
                if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end 
            end,
        })

        TabExtra:CreateSection("Sistema")
        
        TabExtra:CreateButton({
            Name = "⚡ FPS Boost (Anti-Lag)",
            Callback = function() Hub.Core.Utils:AntiLag() end,
        })

        TabExtra:CreateButton({
            Name = "💾 Salvar Configurações",
            Callback = function() 
                if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
                Rayfield:Notify({Title = "Salvo", Content = "Configurações salvas!", Duration = 2})
            end,
        })
    end)

    -- ==========================================
    -- [ CONTEÚDO: ABA PERFIL ]
    -- ==========================================
    pcall(function()
        TabProf:CreateSection("Informações")
        TabProf:CreateLabel("Jogador: " .. game.Players.LocalPlayer.Name)
        
        TabProf:CreateButton({
            Name = "FECHAR MENU",
            Callback = function() 
                Rayfield:Destroy() 
                getgenv().InxiterHubLoaded = false
            end,
        })
    end)
end

return Interface
