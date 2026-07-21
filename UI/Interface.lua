local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Carregando a Fluent Library (A mais moderna e completa)
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "1NXITER HUB | V2.5",
        SubTitle = "Sistema de Automação Profissional",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- [ DEFINIÇÃO DE ABAS ]
    local Tabs = {
        Main = Window:AddTab({ Title = "⚔️ Treino", Icon = "dumbbell" }),
        Combat = Window:AddTab({ Title = "🎯 Combate", Icon = "target" }),
        Visuals = Window:AddTab({ Title = "👁️ Visual (ESP)", Icon = "eye" }),
        Player = Window:AddTab({ Title = "👤 Personagem", Icon = "user" }),
        Settings = Window:AddTab({ Title = "⚙️ Sistema", Icon = "settings" })
    }

    -- ==========================================
    -- [ ABA: TREINO ]
    -- ==========================================
    local StatusLabel = Tabs.Main:AddParagraph({
        Title = "Contador",
        Content = "Aguardando início..."
    })

    Tabs.Main:AddButton({
        Title = "INICIAR / PARAR TREINO",
        Callback = function()
            if Hub.Features.AutoTrain then
                Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(t) 
                    if t then StatusLabel:SetDesc(t) end 
                end)
            end
        end
    })

    Tabs.Main:AddDropdown("ModeSelector", {
        Title = "Exercício",
        Values = {"Canguru", "Flexão", "Polichinelo"},
        Default = Config.Mode or "Canguru",
        Callback = function(v) Config.Mode = v end
    })

    Tabs.Main:AddInput("StartNum", {
        Title = "Número Inicial",
        Default = tostring(Config.StartNum or 0),
        Callback = function(v) Config.StartNum = tonumber(v) or 0 end
    })

    Tabs.Main:AddInput("Quantity", {
        Title = "Quantidade (Série)",
        Default = tostring(Config.Quantity or 130),
        Callback = function(v) Config.Quantity = tonumber(v) or 130 end
    })

    Tabs.Main:AddSlider("DelaySlider", {
        Title = "Velocidade (Delay)",
        Default = Config.Delay or 1.4,
        Min = 0.5, Max = 5, Rounding = 1,
        Callback = function(v) Config.Delay = v end
    })

    Tabs.Main:AddToggle("Countdown", { Title = "Contagem Regressiva", Default = Config.IsCountdown or false, Callback = function(v) Config.IsCountdown = v end })
    Tabs.Main:AddToggle("AutoCrouch", { Title = "Auto Agachar (Canguru)", Default = Config.AutoCrouch or false, Callback = function(v) Config.AutoCrouch = v end })
    Tabs.Main:AddToggle("AutoEquip", { Title = "Auto Equipar Ferramenta", Default = Config.AutoEquip or false, Callback = function(v) Config.AutoEquip = v end })

    -- ==========================================
    -- [ ABA: COMBATE ]
    -- ==========================================
    Tabs.Combat:AddSection("Aimbot")
    
    Tabs.Combat:AddToggle("AimbotEnable", { Title = "Ativar Auto-Mira", Default = false, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end })
    
    Tabs.Combat:AddSlider("AimbotSmooth", {
        Title = "Suavidade (Smoothness)",
        Default = 5, Min = 1, Max = 10, Rounding = 1,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v/10 end end
    })

    Tabs.Combat:AddSlider("AimbotFOV", {
        Title = "Raio do FOV",
        Default = 150, Min = 50, Max = 600, Rounding = 0,
        Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end
    })

    Tabs.Combat:AddToggle("ShowFOV", { Title = "Mostrar Círculo FOV", Default = false, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end end })
    Tabs.Combat:AddToggle("WallCheck", { Title = "Wall Check (Não Varar)", Default = true, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end })
    Tabs.Combat:AddToggle("TeamCheckAim", { Title = "Team Check (Aimbot)", Default = false, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.TeamCheck = v end end })

    Tabs.Combat:AddSection("Hitbox Expander")
    Tabs.Combat:AddToggle("HitboxEnable", { Title = "Aumentar Hitbox Inimiga", Default = false, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end end })
    Tabs.Combat:AddSlider("HitboxSize", { Title = "Tamanho da Hitbox", Default = 10, Min = 2, Max = 30, Rounding = 0, Callback = function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxSize = v end end })

    -- ==========================================
    -- [ ABA: VISUAL (ESP) ]
    -- ==========================================
    Tabs.Visuals:AddSection("Configurações Master")
    Tabs.Visuals:AddToggle("ESPEnable", { Title = "Ativar ESP Principal", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end })
    Tabs.Visuals:AddToggle("ESPTeam", { Title = "Ocultar Aliados (Team Check)", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamCheck = v end end })

    Tabs.Visuals:AddSection("Elementos Visuais")
    
    local BoxToggle = Tabs.Visuals:AddToggle("ESPBox", { Title = "Caixas (Box)", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end })
    BoxToggle:AddColorPicker("BoxColor", { Default = Color3.fromRGB(255, 255, 255), Callback = function(c) if Hub.Features.ESP then Hub.Features.ESP.Settings.BoxColor = c end end })

    local SkeleToggle = Tabs.Visuals:AddToggle("ESPSkeleton", { Title = "Esqueleto (Skeleton)", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end })
    SkeleToggle:AddColorPicker("SkeleColor", { Default = Color3.fromRGB(255, 255, 255), Callback = function(c) if Hub.Features.ESP then Hub.Features.ESP.Settings.SkeletonColor = c end end })

    local TracerToggle = Tabs.Visuals:AddToggle("ESPTracer", { Title = "Linhas (Tracers)", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end end })
    TracerToggle:AddColorPicker("TracerColor", { Default = Color3.fromRGB(255, 255, 255), Callback = function(c) if Hub.Features.ESP then Hub.Features.ESP.Settings.TracerColor = c end end })

    Tabs.Visuals:AddToggle("ESPHealth", { Title = "Barra de Vida (Health Bar)", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end })
    Tabs.Visuals:AddToggle("ESPTeamText", { Title = "Nomes de Times", Default = false, Callback = function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamText = v end end })

    -- ==========================================
    -- [ ABA: PERSONAGEM ]
    -- ==========================================
    Tabs.Player:AddSection("Movimentação")
    Tabs.Player:AddToggle("SpeedEnable", { Title = "SpeedHack", Default = false, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end })
    Tabs.Player:AddSlider("SpeedValue", { Title = "Velocidade", Default = 50, Min = 16, Max = 300, Rounding = 0, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end })
    
    Tabs.Player:AddToggle("JumpEnable", { Title = "JumpHack", Default = false, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleJumpPower(v) end end })
    Tabs.Player:AddSlider("JumpValue", { Title = "Força do Pulo", Default = 100, Min = 50, Max = 300, Rounding = 0, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.JumpValue = v end end })

    Tabs.Player:AddToggle("Noclip", { Title = "Noclip (Atravessar)", Default = false, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end })
    Tabs.Player:AddToggle("InfJump", { Title = "Pulo Infinito", Default = false, Callback = function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end end })

    Tabs.Player:AddSection("Visual & Câmera")
    Tabs.Player:AddToggle("Stretch", { Title = "Tela Esticada (Stretch)", Default = false, Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end end })
    Tabs.Player:AddSlider("FOVStretch", { Title = "Ajuste FOV", Default = 100, Min = 70, Max = 120, Rounding = 0, Callback = function(v) if Hub.Features.Visuals then Hub.Features.Visuals:UpdateFOV(v) end end })

    Tabs.Player:AddSection("Espionagem")
    Tabs.Player:AddToggle("FreeCam", { Title = "FreeCam (Câmera Livre)", Default = false, Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end })
    Tabs.Player:AddSlider("FreeCamSpeed", { Title = "Velocidade FreeCam", Default = 1, Min = 0.5, Max = 5, Rounding = 1, Callback = function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam.Settings.Speed = v end end })
    Tabs.Player:AddToggle("SpyChat", { Title = "Spy Chat (Ver mensagens)", Default = false, Callback = function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end })

    -- ==========================================
    -- [ ABA: SISTEMA ]
    -- ==========================================
    Tabs.Settings:AddSection("Gerenciamento")
    Tabs.Settings:AddButton({
        Title = "💾 SALVAR CONFIGURAÇÕES",
        Description = "Gera o arquivo .json no seu celular",
        Callback = function()
            if Hub.Core.State then Hub.Core.State:SaveConfig(Config) end
            Fluent:Notify({ Title = "Sucesso", Content = "Configurações salvas!", Duration = 5 })
        end
    })

    Tabs.Settings:AddSection("Utilitários")
    Tabs.Settings:AddButton({ Title = "⚡ FPS BOOST", Callback = function() Hub.Core.Utils:AntiLag() end })
    Tabs.Settings:AddButton({ Title = "🔄 REJOIN", Callback = function() Hub.Core.Utils:Rejoin() end })
    Tabs.Settings:AddButton({ Title = "🌐 SERVER HOP", Callback = function() Hub.Core.Utils:ServerHop() end })

    Tabs.Settings:AddButton({
        Title = "FECHAR MENU",
        Callback = function()
            Window:Destroy()
            getgenv().InxiterHubLoaded = false
        end
    })

    Window:SelectTab(1)
    Fluent:Notify({ Title = "1NXITER HUB", Content = "Tudo carregado com sucesso!", Duration = 5 })
end

return Interface
