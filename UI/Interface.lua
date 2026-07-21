local Interface = {}

function Interface:Load(Hub, Config, State)
    -- [CORREÇÃO CRÍTICA]: Atribuição correta do retorno do pcall
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not Fluent or type(Fluent) ~= "table" then
        warn("❌ Erro fatal ao baixar Fluent Library: " .. tostring(Fluent))
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Erro de Conexão",
                Text = "GitHub recusou o download da interface. Tente novamente.",
                Duration = 10
            })
        end)
        return
    end

    local Window = Fluent:CreateWindow({
        Title = "1NXITER HUB | V2.5",
        SubTitle = "Premium Edition",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 520),
        Acrylic = true,
        Theme = Config.UITheme or "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Helpers de Segurança
    local function GetFeature(name) return (Hub.Features and Hub.Features[name]) or nil end
    local function GetCore(name) return (Hub.Core and Hub.Core[name]) or nil end

    -- [ DEFINIÇÃO DE ABAS COM ÍCONES LUCIDE ]
    local Tabs = {
        Train = Window:AddTab({ Title = "Treino", Icon = "swords" }),
        Aimbot = Window:AddTab({ Title = "Combate", Icon = "shield" }),
        ESP = Window:AddTab({ Title = "Visual", Icon = "eye" }),
        Player = Window:AddTab({ Title = "Movimento", Icon = "zap" }),
        Camera = Window:AddTab({ Title = "Câmera", Icon = "camera" }),
        System = Window:AddTab({ Title = "Config", Icon = "settings" })
    }

    -- ==========================================
    -- [ ABA 1: TREINO ]
    -- ==========================================
    local Train = GetFeature("AutoTrain")
    Tabs.Train:AddSection("Controle Central")
    local StatusLabel = Tabs.Train:AddParagraph({ Title = "Status", Content = "Aguardando comando..." })

    Tabs.Train:AddButton({
        Title = "INICIAR / PARAR TREINO",
        Callback = function()
            if Train then Train:Toggle(Config, State, Hub, function(t) if t then StatusLabel:SetDesc(t) end end) end
        end
    })

    Tabs.Train:AddDropdown("TrainMode", {
        Title = "Exercício Selecionado",
        Values = {"Canguru", "Flexão", "Polichinelo"},
        Default = Config.Mode or "Canguru",
        Callback = function(v) Config.Mode = v end
    })

    Tabs.Train:AddSection("Parametrização")
    Tabs.Train:AddInput("StartNum", { Title = "Número Inicial", Default = tostring(Config.StartNum or 0), Callback = function(v) Config.StartNum = tonumber(v) or 0 end })
    Tabs.Train:AddInput("Quantity", { Title = "Quantidade Total", Default = tostring(Config.Quantity or 130), Callback = function(v) Config.Quantity = tonumber(v) or 130 end })
    Tabs.Train:AddSlider("TrainDelay", { Title = "Velocidade (Delay)", Default = Config.Delay or 1.4, Min = 0.1, Max = 5, Rounding = 1, Callback = function(v) Config.Delay = v end })
    
    Tabs.Train:AddToggle("Countdown", { Title = "Contagem Regressiva", Default = Config.IsCountdown or false, Callback = function(v) Config.IsCountdown = v end })
    Tabs.Train:AddToggle("AutoCrouch", { Title = "Auto Agachar (Canguru)", Default = Config.AutoCrouch or false, Callback = function(v) Config.AutoCrouch = v end })

    -- ==========================================
    -- [ ABA 2: COMBATE ]
    -- ==========================================
    local Aim = GetFeature("Aimbot")
    Tabs.Aimbot:AddSection("Aimbot & Mira")
    Tabs.Aimbot:AddToggle("AimEnable", { Title = "Ativar Auto-Mira", Default = false, Callback = function(v) if Aim then Aim.Settings.Enabled = v end end })
    Tabs.Aimbot:AddToggle("AimWall", { Title = "Wall Check", Default = true, Callback = function(v) if Aim then Aim.Settings.WallCheck = v end end })
    Tabs.Aimbot:AddSlider("AimSmooth", { Title = "Suavidade", Default = 0.5, Min = 0.1, Max = 1, Rounding = 1, Callback = function(v) if Aim then Aim.Settings.Smoothness = v end end })
    
    Tabs.Aimbot:AddSection("Hitbox Expander")
    Tabs.Aimbot:AddToggle("HitEnable", { Title = "Expandir Hitbox Inimiga", Default = false, Callback = function(v) if Aim then Aim.Settings.HitboxExpander = v end end })
    Tabs.Aimbot:AddSlider("HitSize", { Title = "Tamanho", Default = 10, Min = 2, Max = 50, Rounding = 0, Callback = function(v) if Aim then Aim.Settings.HitboxSize = v end end })

    -- ==========================================
    -- [ ABA 3: VISUAL (ESP) ]
    -- ==========================================
    local ESP = GetFeature("ESP")
    Tabs.ESP:AddSection("Configurações Master")
    Tabs.ESP:AddToggle("ESPEnable", { Title = "Ativar Sistema ESP", Default = false, Callback = function(v) if ESP then ESP:Toggle(v) end end })
    
    Tabs.ESP:AddSection("Estilos Visuais")
    Tabs.ESP:AddToggle("ESPBox", { Title = "Exibir Caixas (Box)", Default = false, Callback = function(v) if ESP then ESP.Settings.Box = v end end })
    Tabs.ESP:AddColorPicker("BoxColor", { Title = "↳ Cor da Caixa", Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.BoxColor = c end end })
    
    Tabs.ESP:AddToggle("ESPSkele", { Title = "Exibir Esqueleto", Default = false, Callback = function(v) if ESP then ESP.Settings.Skeleton = v end end })
    Tabs.ESP:AddColorPicker("SkeleColor", { Title = "↳ Cor do Esqueleto", Default = Color3.fromRGB(255,255,255), Callback = function(c) if ESP then ESP.Settings.SkeletonColor = c end end })
    
    Tabs.ESP:AddToggle("ESPHealth", { Title = "Barra de Vida", Default = false, Callback = function(v) if ESP then ESP.Settings.HealthBar = v end end })

    -- ==========================================
    -- [ ABA 4: MOVIMENTO ]
    -- ==========================================
    local Mods = GetFeature("PlayerMods")
    Tabs.Player:AddSection("Velocidade & Pulo")
    Tabs.Player:AddToggle("SpeedE", { Title = "Ativar SpeedHack", Default = false, Callback = function(v) if Mods then Mods:ToggleSpeed(v) end end })
    Tabs.Player:AddSlider("SpeedV", { Title = "Valor de Velocidade", Default = 50, Min = 16, Max = 500, Rounding = 0, Callback = function(v) if Mods then Mods.Settings.SpeedValue = v end end })
    Tabs.Player:AddToggle("Noclip", { Title = "Noclip (Atravessar)", Default = false, Callback = function(v) if Mods then Mods:ToggleNoclip(v) end end })
    Tabs.Player:AddToggle("InfJump", { Title = "Pulo Infinito", Default = false, Callback = function(v) if Mods then Mods:ToggleInfJump(v) end end })

    -- ==========================================
    -- [ ABA 5: CÂMERA ]
    -- ==========================================
    local Vis = GetFeature("Visuals")
    local Cam = GetFeature("FreeCam")
    local Spy = GetFeature("SpyChat")

    Tabs.Camera:AddSection("Manipulação de FOV")
    Tabs.Camera:AddToggle("Stretch", { Title = "Ativar Tela Esticada", Default = false, Callback = function(v) if Vis then Vis:ToggleStretched(v) end end })
    Tabs.Camera:AddSlider("FOVValue", { Title = "Ajuste de FOV", Default = 70, Min = 30, Max = 120, Rounding = 0, Callback = function(v) if Vis then Vis:UpdateFOV(v) end end })
    
    Tabs.Camera:AddSection("Câmera Livre")
    Tabs.Camera:AddToggle("FreeCamE", { Title = "Ativar FreeCam", Default = false, Callback = function(v) if Cam then Cam:Toggle(v) end end })
    Tabs.Camera:AddSlider("CamSpeed", { Title = "Velocidade", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) if Cam then Cam.Settings.Speed = v end end })

    Tabs.Camera:AddSection("Logs")
    Tabs.Camera:AddToggle("Spy", { Title = "Ativar Spy Chat", Default = false, Callback = function(v) if Spy then Spy:Toggle(v) end end })

    -- ==========================================
    -- [ ABA 6: CONFIGURAÇÕES ]
    -- ==========================================
    local CoreState = GetCore("State")
    local Utils = GetCore("Utils")

    Tabs.System:AddSection("Dados")
    Tabs.System:AddButton({ 
        Title = "💾 SALVAR CONFIGURAÇÕES", 
        Callback = function() 
            if CoreState then 
                CoreState:SaveConfig(Config) 
                Fluent:Notify({ Title = "Sistema", Content = "Arquivo JSON atualizado com sucesso.", Duration = 3 }) 
            end 
        end 
    })

    Tabs.System:AddDropdown("Theme", {
        Title = "Tema da Interface",
        Values = {"Dark", "Darker", "Light", "Aqua", "Amethyst"},
        Default = Config.UITheme or "Darker",
        Callback = function(v) Window:SetTheme(v) Config.UITheme = v end
    })

    Tabs.System:AddSection("Ações")
    Tabs.System:AddButton({ Title = "⚡ FPS BOOST", Callback = function() if Utils then Utils:AntiLag() end end })
    Tabs.System:AddButton({ Title = "FECHAR HUB", Callback = function() Window:Destroy() getgenv().InxiterHubLoaded = false end })

    Tabs.System:AddParagraph({ 
        Title = "Informações do Sistema", 
        Content = string.format("Versão: 2.5.2\nUsuário: %s\nData: %s", game.Players.LocalPlayer.Name, os.date("%d/%m/%Y")) 
    })

    Window:SelectTab(1)
end

return Interface
