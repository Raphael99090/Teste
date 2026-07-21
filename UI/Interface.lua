local Interface = {}

function Interface:Load(Hub, Config, State)
    -- [1] CARREGAMENTO SEGURO DA LIBRARY
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not Fluent then
        warn("❌ Falha crítica ao carregar Fluent Library.")
        return
    end

    local Window = Fluent:CreateWindow({
        Title = "1NXITER HUB | V2.6",
        SubTitle = "by Raphael99090",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 520),
        Acrylic = true,
        Theme = Config.UITheme or "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Helpers de Segurança
    local function GetFeature(name) return (Hub.Features and Hub.Features[name]) or nil end
    local function GetCore(name) return (Hub.Core and Hub.Core[name]) or nil end

    -- [ ABAS ]
    local Tabs = {
        Train = Window:AddTab({ Title = "Treino", Icon = "swords" }),
        Aimbot = Window:AddTab({ Title = "Combate", Icon = "shield" }),
        Visuals = Window:AddTab({ Title = "Visual", Icon = "eye" }),
        Player = Window:AddTab({ Title = "Movimento", Icon = "zap" }),
        Camera = Window:AddTab({ Title = "Câmera", Icon = "camera" }),
        System = Window:AddTab({ Title = "Sistema", Icon = "settings" })
    }

    -- ==========================================
    -- [ ABA 1: TREINO (AutoTrain.lua) ]
    -- ==========================================
    local Train = GetFeature("AutoTrain")
    Tabs.Train:AddSection("Controle de Atividade")
    
    local StatusLabel = Tabs.Train:AddParagraph({ Title = "Monitor de Treino", Content = "Pronto para iniciar." })

    Tabs.Train:AddButton({
        Title = "INICIAR / PARAR TREINO",
        Description = "Ativa o loop de mensagens e física de treino",
        Callback = function()
            if Train then Train:Toggle(Config, State, Hub, function(t) if t then StatusLabel:SetDesc(t) end end) end
        end
    })

    Tabs.Train:AddDropdown("TrainMode", {
        Title = "Exercício",
        Values = {"Canguru", "Flexão", "Polichinelo"},
        Default = Config.Mode or "Canguru",
        Callback = function(v) Config.Mode = v end
    })

    Tabs.Train:AddSection("Ajustes de Loop")
    Tabs.Train:AddInput("StartNum", { Title = "Número Inicial", Default = tostring(Config.StartNum or 0), Callback = function(v) Config.StartNum = tonumber(v) or 0 end })
    Tabs.Train:AddInput("Quantity", { Title = "Quantidade", Default = tostring(Config.Quantity or 130), Callback = function(v) Config.Quantity = tonumber(v) or 130 end })
    Tabs.Train:AddSlider("TrainDelay", { Title = "Velocidade (Delay)", Default = Config.Delay or 1.4, Min = 0.1, Max = 5, Rounding = 1, Callback = function(v) Config.Delay = v end })
    
    Tabs.Train:AddSection("Extras")
    Tabs.Train:AddToggle("Countdown", { Title = "Contagem Regressiva", Default = Config.IsCountdown or false, Callback = function(v) Config.IsCountdown = v end })
    Tabs.Train:AddToggle("AutoCrouch", { Title = "Auto Agachar (Canguru)", Default = Config.AutoCrouch or false, Callback = function(v) Config.AutoCrouch = v end })
    Tabs.Train:AddToggle("AutoEquip", { Title = "Auto Equipar Item", Default = Config.AutoEquip or false, Callback = function(v) Config.AutoEquip = v end })

    -- ==========================================
    -- [ ABA 2: COMBATE (Aimbot.lua) ]
    -- ==========================================
    local Aim = GetFeature("Aimbot")
    Tabs.Aimbot:AddSection("Aimbot Master")
    Tabs.Aimbot:AddToggle("AimEnable", { Title = "Ativar Auto-Mira", Default = false, Callback = function(v) if Aim then Aim.Settings.Enabled = v end end })
    Tabs.Aimbot:AddToggle("AimWall", { Title = "Wall Check (Não varar)", Default = true, Callback = function(v) if Aim then Aim.Settings.WallCheck = v end end })
    Tabs.Aimbot:AddToggle("AimTeam", { Title = "Team Check (Aliados)", Default = false, Callback = function(v) if Aim then Aim.Settings.TeamCheck = v end end })
    
    Tabs.Aimbot:AddSection("FOV & Suavidade")
    Tabs.Aimbot:AddToggle("AimShowFOV", { Title = "Exibir Círculo FOV", Default = false, Callback = function(v) if Aim then Aim.Settings.ShowFOV = v end end })
    Tabs.Aimbot:AddSlider("AimFOVSize", { Title = "Raio do FOV", Default = 150, Min = 30, Max = 800, Rounding = 0, Callback = function(v) if Aim then Aim.Settings.FOVRadius = v end end })
    Tabs.Aimbot:AddSlider("AimSmooth", { Title = "Suavidade (Smoothness)", Default = 0.5, Min = 0.1, Max = 1, Rounding = 1, Callback = function(v) if Aim then Aim.Settings.Smoothness = v end end })
    Tabs.Aimbot:AddDropdown("AimPart", { Title = "Parte Alvo", Values = {"Head", "HumanoidRootPart", "UpperTorso"}, Default = "HumanoidRootPart", Callback = function(v) if Aim then Aim.Settings.TargetPart = v end end })

    Tabs.Aimbot:AddSection("Hitbox Expander")
    Tabs.Aimbot:AddToggle("HitEnable", { Title = "Aumentar Hitbox Inimiga", Default = false, Callback = function(v) if Aim then Aim.Settings.HitboxExpander = v end end })
    Tabs.Aimbot:AddSlider("HitSize", { Title = "Tamanho da Hitbox", Default = 10, Min = 2, Max = 50, Rounding = 0, Callback = function(v) if Aim then Aim.Settings.HitboxSize = v end end })

    -- ==========================================
    -- [ ABA 3: VISUAL (ESP.lua) ]
    -- ==========================================
    local ESP = GetFeature("ESP")
    Tabs.Visuals:AddSection("ESP Master")
    Tabs.Visuals:AddToggle("ESPEnable", { Title = "Ativar Sistema ESP", Default = false, Callback = function(v) if ESP then ESP:Toggle(v) end end })
    Tabs.Visuals:AddToggle("ESPTeam", { Title = "Team Check (Ocultar Amigos)", Default = false, Callback = function(v) if ESP then ESP.Settings.TeamCheck = v end end })
    
    Tabs.Visuals:AddSection("Aura (Highlight)")
    Tabs.Visuals:AddToggle("ESPAura", { Title = "Ativar Aura", Default = false, Callback = function(v) if ESP then ESP.Settings.Aura = v end end })
    Tabs.Visuals:AddColorPicker("AuraColor", { Title = "Cor da Aura", Default = Color3.fromRGB(255,0,0), Callback = function(c) if ESP then ESP.Settings.AuraColor = c end end })

    Tabs.Visuals:AddSection("Desenhos (Box/Skeleton)")
    Tabs.Visuals:AddToggle("ESPBox", { Title = "Exibir Caixas (Box)", Default = false, Callback = function(v) if ESP then ESP.Settings.Box = v end end })
    Tabs.Visuals:AddColorPicker("BoxColor", { Title = "Cor da Caixa", Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.BoxColor = c end end })
    
    Tabs.Visuals:AddToggle("ESPSkele", { Title = "Exibir Esqueleto", Default = false, Callback = function(v) if ESP then ESP.Settings.Skeleton = v end end })
    Tabs.Visuals:AddColorPicker("SkeleColor", { Title = "Cor do Esqueleto", Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.SkeletonColor = c end end })
    
    Tabs.Visuals:AddToggle("ESPHealth", { Title = "Barra de Vida", Default = false, Callback = function(v) if ESP then ESP.Settings.HealthBar = v end end })

    -- ==========================================
    -- [ ABA 4: MOVIMENTO (PlayerMods.lua) ]
    -- ==========================================
    local Mods = GetFeature("PlayerMods")
    Tabs.Player:AddSection("Atributos Físicos")
    Tabs.Player:AddToggle("SpeedE", { Title = "SpeedHack", Default = false, Callback = function(v) if Mods then Mods:ToggleSpeed(v) end end })
    Tabs.Player:AddSlider("SpeedV", { Title = "Velocidade", Default = 50, Min = 16, Max = 500, Rounding = 0, Callback = function(v) if Mods then Mods.Settings.SpeedValue = v end end })
    
    Tabs.Player:AddToggle("JumpE", { Title = "Super Pulo", Default = false, Callback = function(v) if Mods then Mods:ToggleJumpPower(v) end end })
    Tabs.Player:AddSlider("JumpV", { Title = "Altura do Pulo", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(v) if Mods then Mods.Settings.JumpValue = v end end })

    Tabs.Player:AddSection("Bypass de Física")
    Tabs.Player:AddToggle("Noclip", { Title = "Noclip (Atravessar Tudo)", Default = false, Callback = function(v) if Mods then Mods:ToggleNoclip(v) end end })
    Tabs.Player:AddToggle("InfJump", { Title = "Pulo Infinito", Default = false, Callback = function(v) if Mods then Mods:ToggleInfJump(v) end end })

    -- ==========================================
    -- [ ABA 5: CÂMERA (Visuals.lua / FreeCam.lua / SpyChat.lua) ]
    -- ==========================================
    local Vis = GetFeature("Visuals")
    local Cam = GetFeature("FreeCam")
    local Spy = GetFeature("SpyChat")

    Tabs.Camera:AddSection("Manipulação Visual")
    Tabs.Camera:AddToggle("Stretch", { Title = "Tela Esticada", Default = false, Callback = function(v) if Vis then Vis:ToggleStretched(v) end end })
    Tabs.Camera:AddSlider("FOVValue", { Title = "Campo de Visão (Zoom)", Default = 70, Min = 30, Max = 120, Rounding = 0, Callback = function(v) if Vis then Vis:UpdateFOV(v) end end })
    
    Tabs.Camera:AddSection("FreeCam")
    Tabs.Camera:AddToggle("FreeCamE", { Title = "Ativar FreeCam", Default = false, Callback = function(v) if Cam then Cam:Toggle(v) end end })
    Tabs.Camera:AddSlider("CamSpeed", { Title = "Velocidade de Voo", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) if Cam then Cam.Settings.Speed = v end end })

    Tabs.Camera:AddSection("Espionagem")
    Tabs.Camera:AddToggle("Spy", { Title = "Spy Chat (Ver Logs)", Default = false, Callback = function(v) if Spy then Spy:Toggle(v) end end })

    -- ==========================================
    -- [ ABA 6: SISTEMA (Utils.lua / State.lua) ]
    -- ==========================================
    local CoreState = GetCore("State")
    local Utils = GetCore("Utils")

    Tabs.System:AddSection("Configurações")
    Tabs.System:AddButton({ 
        Title = "💾 SALVAR TUDO", 
        Description = "Gera o arquivo JSON no dispositivo",
        Callback = function() if CoreState then CoreState:SaveConfig(Config) Fluent:Notify({ Title = "Sistema", Content = "Configurações salvas!", Duration = 3 }) end end 
    })

    Tabs.System:AddDropdown("Theme", {
        Title = "Tema da Interface",
        Values = {"Dark", "Darker", "Light", "Aqua", "Amethyst"},
        Default = Config.UITheme or "Darker",
        Callback = function(v) Window:SetTheme(v) Config.UITheme = v end
    })

    Tabs.System:AddSection("Utilitários")
    Tabs.System:AddButton({ Title = "⚡ FPS BOOST", Callback = function() if Utils then Utils:AntiLag() end end })
    Tabs.System:AddButton({ Title = "🔄 REJOIN", Callback = function() if Utils then Utils:Rejoin() end end })
    Tabs.System:AddButton({ Title = "🌐 SERVER HOP", Callback = function() if Utils then Utils:ServerHop() end end })
    
    Tabs.System:AddSection("Sair")
    Tabs.System:AddButton({ Title = "FECHAR HUB", Callback = function() Window:Destroy() getgenv().InxiterHubLoaded = false end })

    Tabs.System:AddParagraph({ Title = "Informações", Content = "Desenvolvedor: Raphael99090\nVersão: 2.6.0\nData: " .. os.date("%d/%m/%Y") })

    Window:SelectTab(1)
end

return Interface
