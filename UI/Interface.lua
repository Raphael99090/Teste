local Interface = {}

function Interface:Load(Hub, Config, State)
    -- Carregamento da Fluent
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "1NXITER HUB | V2.5",
        SubTitle = "by Raphael99090",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 520),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Verificação de Módulos (Para não dar erro se um arquivo falhar)
    local function GetFeature(name)
        if Hub.Features and Hub.Features[name] then
            return Hub.Features[name]
        end
        warn("⚠️ Módulo faltando: " .. name)
        return nil
    end

    -- [ ABAS ]
    local Tabs = {
        Train = Window:AddTab({ Title = "⚔️ Treino", Icon = "dumbbell" }),
        Aimbot = Window:AddTab({ Title = "🎯 Mira", Icon = "target" }),
        ESP = Window:AddTab({ Title = "👁️ Visual", Icon = "eye" }),
        Player = Window:AddTab({ Title = "🚀 Player", Icon = "zap" }),
        Camera = Window:AddTab({ Title = "📷 Câmera", Icon = "camera" }),
        System = Window:AddTab({ Title = "⚙️ Sistema", Icon = "settings" })
    }

    -- ==========================================
    -- [ ABA 1: TREINO (AutoTrain.lua) ]
    -- ==========================================
    local Train = GetFeature("AutoTrain")
    Tabs.Train:AddSection("Status")
    local StatusLabel = Tabs.Train:AddParagraph({ Title = "Contador", Content = "Aguardando..." })

    Tabs.Train:AddButton({
        Title = "INICIAR / PARAR TREINO",
        Callback = function()
            if Train then
                Train:Toggle(Config, State, Hub, function(t) 
                    if t then StatusLabel:SetDesc(t) end 
                end)
            end
        end
    })

    Tabs.Train:AddDropdown("TrainMode", {
        Title = "Modo de Exercício",
        Values = {"Canguru", "Flexão", "Polichinelo"},
        Default = Config.Mode or "Canguru",
        Callback = function(v) Config.Mode = v end
    })

    Tabs.Train:AddSection("Ajustes de Treino")
    Tabs.Train:AddInput("StartNum", { Title = "Número Inicial", Default = tostring(Config.StartNum or 0), Callback = function(v) Config.StartNum = tonumber(v) or 0 end })
    Tabs.Train:AddInput("Quantity", { Title = "Quantidade", Default = tostring(Config.Quantity or 130), Callback = function(v) Config.Quantity = tonumber(v) or 130 end })
    Tabs.Train:AddSlider("TrainDelay", { Title = "Velocidade (Delay)", Default = Config.Delay or 1.4, Min = 0.1, Max = 5, Rounding = 1, Callback = function(v) Config.Delay = v end })
    Tabs.Train:AddToggle("Countdown", { Title = "Contagem Regressiva", Default = Config.IsCountdown or false, Callback = function(v) Config.IsCountdown = v end })
    Tabs.Train:AddToggle("AutoCrouch", { Title = "Auto Agachar (Canguru)", Default = Config.AutoCrouch or false, Callback = function(v) Config.AutoCrouch = v end })
    Tabs.Train:AddToggle("AutoEquip", { Title = "Auto Equipar Item", Default = Config.AutoEquip or false, Callback = function(v) Config.AutoEquip = v end })

    -- ==========================================
    -- [ ABA 2: MIRA (Aimbot.lua) ]
    -- ==========================================
    local Aim = GetFeature("Aimbot")
    Tabs.Aimbot:AddSection("Aimbot Settings")
    Tabs.Aimbot:AddToggle("AimEnable", { Title = "Ativar Aimbot", Default = false, Callback = function(v) if Aim then Aim.Settings.Enabled = v end end })
    Tabs.Aimbot:AddToggle("AimWall", { Title = "Wall Check (Não varar)", Default = true, Callback = function(v) if Aim then Aim.Settings.WallCheck = v end end })
    Tabs.Aimbot:AddToggle("AimTeam", { Title = "Team Check (Aliados)", Default = false, Callback = function(v) if Aim then Aim.Settings.TeamCheck = v end end })
    Tabs.Aimbot:AddToggle("AimFOV", { Title = "Mostrar Círculo FOV", Default = false, Callback = function(v) if Aim then Aim.Settings.ShowFOV = v end end })
    Tabs.Aimbot:AddSlider("AimFOVSize", { Title = "Raio do FOV", Default = 150, Min = 50, Max = 800, Rounding = 0, Callback = function(v) if Aim then Aim.Settings.FOVRadius = v end end })
    Tabs.Aimbot:AddSlider("AimSmooth", { Title = "Suavidade (Smoothness)", Default = 0.5, Min = 0.1, Max = 1, Rounding = 1, Callback = function(v) if Aim then Aim.Settings.Smoothness = v end end })
    Tabs.Aimbot:AddDropdown("AimPart", { Title = "Focar em:", Values = {"Head", "HumanoidRootPart", "UpperTorso"}, Default = "HumanoidRootPart", Callback = function(v) if Aim then Aim.Settings.TargetPart = v end end })

    Tabs.Aimbot:AddSection("Hitbox Expander")
    Tabs.Aimbot:AddToggle("HitEnable", { Title = "Expandir Hitbox Inimiga", Default = false, Callback = function(v) if Aim then Aim.Settings.HitboxExpander = v end end })
    Tabs.Aimbot:AddSlider("HitSize", { Title = "Tamanho da Hitbox", Default = 10, Min = 2, Max = 50, Rounding = 0, Callback = function(v) if Aim then Aim.Settings.HitboxSize = v end end })

    -- ==========================================
    -- [ ABA 3: VISUAL (ESP.lua) ]
    -- ==========================================
    local ESP = GetFeature("ESP")
    Tabs.ESP:AddSection("ESP Master")
    Tabs.ESP:AddToggle("ESPEnable", { Title = "Ativar Sistema ESP", Default = false, Callback = function(v) if ESP then ESP:Toggle(v) end end })
    Tabs.ESP:AddToggle("ESPTeam", { Title = "Team Check (Ocultar Time)", Default = false, Callback = function(v) if ESP then ESP.Settings.TeamCheck = v end end })

    Tabs.ESP:AddSection("Estilos")
    local BoxT = Tabs.ESP:AddToggle("ESPBox", { Title = "Caixas (Box)", Default = false, Callback = function(v) if ESP then ESP.Settings.Box = v end end })
    BoxT:AddColorPicker("BoxC", { Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.BoxColor = c end end })

    local SkeleT = Tabs.ESP:AddToggle("ESPSkele", { Title = "Esqueleto (Skeleton)", Default = false, Callback = function(v) if ESP then ESP.Settings.Skeleton = v end end })
    SkeleT:AddColorPicker("SkeleC", { Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.SkeletonColor = c end end })

    local TracerT = Tabs.ESP:AddToggle("ESPTracer", { Title = "Linhas (Tracers)", Default = false, Callback = function(v) if ESP then ESP.Settings.Tracer = v end end })
    TracerT:AddColorPicker("TracerC", { Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.TracerColor = c end end })

    Tabs.ESP:AddToggle("ESPHealth", { Title = "Barra de Vida", Default = false, Callback = function(v) if ESP then ESP.Settings.HealthBar = v end end })
    Tabs.ESP:AddToggle("ESPNames", { Title = "Nome do Time", Default = false, Callback = function(v) if ESP then ESP.Settings.TeamText = v end end })

    -- ==========================================
    -- [ ABA 4: PLAYER (PlayerMods.lua) ]
    -- ==========================================
    local Mods = GetFeature("PlayerMods")
    Tabs.Player:AddSection("Movimento")
    Tabs.Player:AddToggle("SpeedE", { Title = "SpeedHack", Default = false, Callback = function(v) if Mods then Mods:ToggleSpeed(v) end end })
    Tabs.Player:AddSlider("SpeedV", { Title = "Velocidade", Default = 50, Min = 16, Max = 500, Rounding = 0, Callback = function(v) if Mods then Mods.Settings.SpeedValue = v end end })
    
    Tabs.Player:AddToggle("JumpE", { Title = "JumpHack", Default = false, Callback = function(v) if Mods then Mods:ToggleJumpPower(v) end end })
    Tabs.Player:AddSlider("JumpV", { Title = "Força do Pulo", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(v) if Mods then Mods.Settings.JumpValue = v end end })

    Tabs.Player:AddSection("Física")
    Tabs.Player:AddToggle("Noclip", { Title = "Noclip (Atravessar)", Default = false, Callback = function(v) if Mods then Mods:ToggleNoclip(v) end end })
    Tabs.Player:AddToggle("InfJump", { Title = "Pulo Infinito", Default = false, Callback = function(v) if Mods then Mods:ToggleInfJump(v) end end })

    -- ==========================================
    -- [ ABA 5: CÂMERA (Visuals.lua / FreeCam.lua) ]
    -- ==========================================
    local Vis = GetFeature("Visuals")
    local Cam = GetFeature("FreeCam")
    local Spy = GetFeature("SpyChat")

    Tabs.Camera:AddSection("Visual de Tela")
    Tabs.Camera:AddToggle("Stretch", { Title = "Tela Esticada", Default = false, Callback = function(v) if Vis then Vis:ToggleStretched(v) end end })
    Tabs.Camera:AddSlider("FOVValue", { Title = "Ajuste de FOV (Zoom)", Default = 70, Min = 30, Max = 120, Rounding = 0, Callback = function(v) if Vis then Vis:UpdateFOV(v) end end })

    Tabs.Camera:AddSection("FreeCam")
    Tabs.Camera:AddToggle("FreeCamE", { Title = "Ativar Câmera Livre", Default = false, Callback = function(v) if Cam then Cam:Toggle(v) end end })
    Tabs.Camera:AddSlider("CamSpeed", { Title = "Velocidade da Câmera", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) if Cam then Cam.Settings.Speed = v end end })
    Tabs.Camera:AddSlider("CamSens", { Title = "Sensibilidade Mouse", Default = 0.5, Min = 0.1, Max = 2, Rounding = 1, Callback = function(v) if Cam then Cam.Settings.Sensitivity = v end end })

    Tabs.Camera:AddSection("Espionagem")
    Tabs.Camera:AddToggle("Spy", { Title = "Spy Chat (Logs)", Default = false, Callback = function(v) if Spy then Spy:Toggle(v) end end })

    -- ==========================================
    -- [ ABA 6: SISTEMA (Utils.lua / State.lua) ]
    -- ==========================================
    local Utils = Hub.Core.Utils
    Tabs.System:AddSection("Automação de Fundo")
    Tabs.System:AddToggle("AFK", { Title = "Anti-AFK (VirtualUser)", Default = true, Callback = function(v) if Utils then if v then Utils:AntiAFK(State) else Utils:StopAll() end end end })
    Tabs.System:AddToggle("AutoRe", { Title = "Auto-Rejoin (Erros)", Default = Config.AutoRejoin or false, Callback = function(v) Config.AutoRejoin = v; if Utils then Utils:AutoRejoin(Config) end end })

    Tabs.System:AddSection("Configurações")
    Tabs.System:AddButton({ Title = "💾 SALVAR TUDO", Description = "Gera o arquivo JSON", Callback = function() if Hub.Core.State then Hub.Core.State:SaveConfig(Config) Fluent:Notify({ Title = "Salvo", Content = "Configurações gravadas!", Duration = 3 }) end end })
    Tabs.System:AddButton({ Title = "⚡ FPS BOOST", Callback = function() if Utils then Utils:AntiLag() end end })
    Tabs.System:AddButton({ Title = "🔄 REJOIN AGORA", Callback = function() if Utils then Utils:Rejoin() end end })
    Tabs.System:AddButton({ Title = "🌐 MUDAR SERVIDOR", Callback = function() if Utils then Utils:ServerHop() end end })

    Tabs.System:AddSection("Interface")
    Tabs.System:AddButton({ Title = "FECHAR HUB", Callback = function() Window:Destroy() getgenv().InxiterHubLoaded = false end })

    Window:SelectTab(1)
    Fluent:Notify({ Title = "1NXITER HUB", Content = "Sistema carregado com sucesso!", Duration = 5 })
end

return Interface
