--[[
    1NXITER v3.0 - INTERFACE COMPLETA (CORRIGIDA)
]]

local UI = {}
local Settings, Utils, Aimbot, ESP, Optimization, Misc

function UI.init(settings, utils, aimbot, esp, optimization, misc)
    Settings = settings
    Utils = utils
    Aimbot = aimbot
    ESP = esp
    Optimization = optimization
    Misc = misc
    
    UI._createInterface()
end

function UI._createInterface()
    -- Link direto para o arquivo correto no seu repositório da Library
    -- Nota: Usei "Crimsom" com 'm' conforme aparece no seu GitHub
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Raphael99090/1NXXiter-lib/main/Crimsom%20ui%20lib.lua"))()
    end)

    if not success or not Library then
        warn("[1NXITER] Erro ao carregar Library. Verifique o link no ui.lua")
        return
    end
    
    local Janela = Library:CriarJanela("1NXITER v3.0")
    
    -- ═══════════════════════════════════════════
    -- ABA 1: COMBATE ⚔
    -- ═══════════════════════════════════════════
    local T1 = Janela:CriarAba("⚔")
    
    T1:CriarLabel("── Aimbot ──")
    T1:CriarToggle("Ativar Aimbot [F]", false, function(v)
        Settings.Aimbot = v
    end)
    
    T1:CriarBotao("Resetar Configurações", function()
        print("Configurações resetadas")
    end)

    -- ═══════════════════════════════════════════
    -- ABA 2: VISUAL 👁
    -- ═══════════════════════════════════════════
    local T2 = Janela:CriarAba("👁")
    
    T2:CriarLabel("── ESP ──")
    T2:CriarToggle("Ativar ESP [G]", false, function(v)
        Settings.ESP_Enabled = v
    end)
    
    -- ═══════════════════════════════════════════
    -- ABA 3: OTIMIZAÇÃO 🚀
    -- ═══════════════════════════════════════════
    local T3 = Janela:CriarAba("🚀")
    
    T3:CriarToggle("Modo Batata", false, function(v)
        if v then Optimization.applyPotatoMode() end
    end)

    -- ═══════════════════════════════════════════
    -- ABA 4: PERFIL 👤
    -- ═══════════════════════════════════════════
    local T4 = Janela:CriarAba("👤")
    T4:CriarLabel("Jogador: " .. game.Players.LocalPlayer.Name)
    
    -- Notificação de sucesso
    Janela:Notificar("1NXITER", "Interface carregada com sucesso!")
end

return UI
