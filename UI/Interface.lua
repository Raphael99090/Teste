local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Carregando a Orion Library (Muito mais estável)
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

    local Window = OrionLib:MakeWindow({
        Name = "1NXITER HUB | V2.5", 
        HidePremium = true, 
        SaveConfig = false, 
        IntroText = "Inxiter System Loading...",
        IntroIcon = "rbxassetid://4483362458"
    })

    -- [ ABAS ]
    local TabHome   = Window:MakeTab({ Name = "⚔️ Treino", Icon = "rbxassetid://4483362458", Premium = false })
    local TabCombat = Window:MakeTab({ Name = "🎯 Combate", Icon = "rbxassetid://4483362458", Premium = false })
    local TabExtra  = Window:MakeTab({ Name = "🚀 Extras", Icon = "rbxassetid://4483362458", Premium = false })
    local TabProf   = Window:MakeTab({ Name = "👤 Perfil", Icon = "rbxassetid://4483362458", Premium = false })

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    TabHome:AddSection({ Name = "Controle de Treino" })

    -- Label que o AutoTrain vai atualizar
    local LblStatus = "AGUARDANDO..."
    local Label = TabHome:AddLabel(LblStatus)

    TabHome:AddButton({
        Name = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(t) 
                    if t then Label:Set(t) end 
                end)
            end
        end
    })

    TabHome:AddDropdown({
        Name = "Modo de Treino",
        Default = Config.Mode or "Canguru",
        Options = {"Canguru", "Flexão", "Polichinelo"},
        Callback = function(v) Config.Mode = v end
    })

    TabHome:AddSection({ Name = "Ajustes Numéricos" })

    TabHome:AddTextbox({
        Name = "Número Inicial",
        Default = tostring(Config.StartNum or 0),
        TextDisappear = false,
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end
    })

    TabHome:AddSlider({
        Name = "Velocidade (Delay)",
        Min = 0.5, Max = 5, Default = Config.Delay or 1.4,
        Color = Color3.fromRGB(220, 20, 60),
        Increment = 0.1, ValueName = "seg",
        Callback = function(v) Config.Delay = v end
    })

    TabHome:AddToggle({
        Name = "Auto Agachar (Canguru)",
        Default = Config.AutoCrouch or false,
        Callback = function(v) Config.AutoCrouch = v end
    })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    TabCombat:AddSection({ Name = "Aimbot" })

    TabCombat:AddToggle({
        Name = "Ativar Auto-Mira",
        Default = false,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end
    })

    TabCombat:AddSlider({
        Name = "Raio do FOV",
        Min = 50, Max = 600, Default = 150,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1, ValueName = "px",
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end
    })

    TabCombat:AddToggle({
        Name = "Wall Check (Não mirar por paredes)",
        Default = true,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end
    })

    TabCombat:AddSection({ Name = "ESP (Visual Completo)" })

    TabCombat:AddToggle({
        Name = "Ativar ESP",
        Default = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end
    })

    TabCombat:AddToggle({
        Name = "ESP Box (Caixas)",
        Default = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end
    })

    TabCombat:AddToggle({
        Name = "ESP Skeleton (Esqueleto)",
        Default = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end
    })

    TabCombat:AddToggle({
        Name = "ESP Health Bar (Barra de Vida)",
        Default = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end
    })

    TabCombat:AddToggle({
        Name = "ESP Tracers (Linhas)",
        Default = false,
        Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end end
    })

    -- ==========================================
    -- [ ABA 3: EXTRAS ]
    -- ==========================================
    TabExtra:AddSection({ Name = "Movimentação" })

    TabExtra:AddSlider({
        Name = "Velocidade (Speed)",
        Min = 16, Max = 300, Default = 50,
        Increment = 1, ValueName = "studs",
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end
    })

    TabExtra:AddToggle({
        Name = "Ativar SpeedHack",
        Default = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end
    })

    TabExtra:AddToggle({
        Name = "Noclip (Atravessar Paredes)",
        Default = false,
        Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end
    })

    TabExtra:AddSection({ Name = "Espionagem" })

    TabExtra:AddToggle({
        Name = "FreeCam (Câmera Livre)",
        Default = false,
        Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end
    })

    TabExtra:AddToggle({
        Name = "Spy Chat (Ver mensagens)",
        Default = false,
        Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end
    })

    TabExtra:AddSection({ Name = "Sistema" })

    TabExtra:AddButton({
        Name = "💾 SALVAR CONFIGURAÇÕES",
        Callback = function() 
            if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
            OrionLib:MakeNotification({Name = "Sucesso", Content = "Configurações salvas!", Time = 3})
        end
    })

    TabExtra:AddButton({
        Name = "⚡ FPS BOOST",
        Callback = function() Hub.Core.Utils:AntiLag() end
    })

    -- ==========================================
    -- [ ABA 4: PERFIL ]
    -- ==========================================
    TabProf:AddLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    
    TabProf:AddButton({
        Name = "DESATIVAR TUDO (PANIC)",
        Callback = function() if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end end
    })

    TabProf:AddButton({
        Name = "FECHAR MENU",
        Callback = function() 
            OrionLib:Destroy() 
            getgenv().InxiterHubLoaded = false
        end
    })

    -- Inicializa a Orion
    OrionLib:Init()
end

return Interface
