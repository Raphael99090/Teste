--[[
    1NXITER AIMBOT - V3.0 MODULAR
    Sistema completo: Aimbot, ESP, Optimization, Misc
    
    Estrutura (8 módulos):
        main.lua         → Ponto de entrada (este arquivo)
        settings.lua     → Configurações globais
        utils.lua        → Funções utilitárias
        aimbot.lua       → Aimbot + Triggerbot + Prediction
        esp.lua          → ESP + Chams + Target Info
        optimization.lua → Modo batata, fullbright, anti-afk...
        misc.lua         → Chat Spy, Keybinds, Watermark, Rejoin
        ui.lua           → Interface gráfica (6 abas)
]]

-- ═══════════════════════════════════════════════════════
-- CONFIGURAÇÃO DO REPOSITÓRIO
-- ═══════════════════════════════════════════════════════

local REPO = "https://raw.githubusercontent.com/SEU_USER/1NXITER-v3/main/"

local function requireModule(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO .. name .. ".lua"))()
    end)
    if not success then
        warn("[1NXITER] ✗ Falha ao carregar: " .. name)
        warn("[1NXITER] Erro: " .. tostring(result))
        return nil
    end
    print("[1NXITER] ✓ " .. name)
    return result
end

-- ═══════════════════════════════════════════════════════
-- CARREGAR MÓDULOS
-- ═══════════════════════════════════════════════════════

print("")
print("[1NXITER] ╔══════════════════════════════════╗")
print("[1NXITER] ║   1NXITER v3.0 MODULAR           ║")
print("[1NXITER] ║   8 Modules • 30+ Features       ║")
print("[1NXITER] ╚══════════════════════════════════╝")
print("")

local Settings     = requireModule("settings")
local Utils        = requireModule("utils")
local Aimbot       = requireModule("aimbot")
local ESP          = requireModule("esp")
local Optimization = requireModule("optimization")
local Misc         = requireModule("misc")
local UI           = requireModule("ui")

-- Verificar módulos críticos
local allLoaded = Settings and Utils and Aimbot and ESP 
    and Optimization and Misc and UI

if not allLoaded then
    warn("[1NXITER] ✗ Módulos faltando. Abortando.")
    return
end

-- ═══════════════════════════════════════════════════════
-- INICIALIZAR (ordem importa!)
-- ═══════════════════════════════════════════════════════

Utils.init(Settings)
Aimbot.init(Settings, Utils)
ESP.init(Settings, Utils)
Optimization.init(Settings)
Misc.init(Settings, Utils)
UI.init(Settings, Utils, Aimbot, ESP, Optimization, Misc)

-- ═══════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ═══════════════════════════════════════════════════════

local RunService = game:GetService("RunService")

local mainLoop = RunService.RenderStepped:Connect(function(dt)
    Aimbot.update(dt)
    ESP.update(dt)
    Optimization.update(dt)
    Misc.update(dt)
end)

table.insert(Settings.Connections, mainLoop)

-- ═══════════════════════════════════════════════════════
-- KEYBIND GLOBAL LISTENER
-- ═══════════════════════════════════════════════════════

local UIS = game:GetService("UserInputService")

local keybindConn = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    Misc.onKeyPress(input.KeyCode)
end)

table.insert(Settings.Connections, keybindConn)

-- ═══════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════

local function destroy()
    print("[1NXITER] Limpando recursos...")
    
    for _, conn in ipairs(Settings.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    ESP.cleanup()
    Aimbot.cleanup()
    Optimization.cleanup()
    Misc.cleanup()
    
    print("[1NXITER] ✓ Script finalizado.")
end

getgenv()._1NXITER_DESTROY = destroy

print("")
print("[1NXITER] ✓ 8 módulos carregados")
print("[1NXITER] ✓ 30+ features ativas")
print("[1NXITER] ✓ Keybinds prontos")
print("[1NXITER] ✓ Script rodando!")
