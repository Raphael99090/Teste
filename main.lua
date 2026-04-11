--[[
    1NXITER AIMBOT - V3.0 MODULAR
    Sistema completo: Aimbot, ESP, Optimization, Misc, UI
]]

-- ═══════════════════════════════════════════════════════
-- CONFIGURAÇÃO DO REPOSITÓRIO
-- ═══════════════════════════════════════════════════════

-- Link atualizado para o seu repositório real
local REPO = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

local function requireModule(name)
    local url = REPO .. name .. ".lua"
    
    -- Tenta baixar o conteúdo do arquivo
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success or content:find("404: Not Found") then
        warn("[1NXITER] ✗ Erro ao baixar módulo: " .. name .. " (Verifique se o arquivo existe no GitHub)")
        return nil
    end

    -- Tenta transformar o texto em código executável
    local func, err = loadstring(content)
    if not func then
        warn("[1NXITER] ✗ Erro de sintaxe no módulo " .. name .. ": " .. tostring(err))
        return nil
    end

    -- Executa o módulo e captura o que ele retorna (a tabela do módulo)
    local runSuccess, result = pcall(func)
    if not runSuccess then
        warn("[1NXITER] ✗ Erro ao inicializar módulo " .. name .. ": " .. tostring(result))
        return nil
    end

    print("[1NXITER] ✓ " .. name .. " carregado com sucesso.")
    return result
end

-- ═══════════════════════════════════════════════════════
-- CARREGAR MÓDULOS
-- ═══════════════════════════════════════════════════════

print("\n[1NXITER] ╔══════════════════════════════════╗")
print("[1NXITER] ║   1NXITER v3.0 MODULAR           ║")
print("[1NXITER] ║   Iniciando carregamento...      ║")
print("[1NXITER] ╚══════════════════════════════════╝\n")

-- Importante: Nomes em minúsculo conforme aparecem no seu GitHub
local Settings     = requireModule("settings")
local Utils        = requireModule("utils")
local Aimbot       = requireModule("aimbot")
local ESP          = requireModule("esp")
local Optimization = requireModule("optimization")
local Misc         = requireModule("misc")
local UI           = requireModule("ui")

-- Verificar se todos os módulos essenciais foram carregados
local allLoaded = Settings and Utils and Aimbot and ESP 
    and Optimization and Misc and UI

if not allLoaded then
    warn("[1NXITER] ✗ Falha crítica: Alguns módulos não puderam ser carregados.")
    return
end

-- ═══════════════════════════════════════════════════════
-- INICIALIZAR MÓDULOS E INTERFACE
-- ═══════════════════════════════════════════════════════

-- 1. Baixar a Library Visual (Crimson UI)
local libSuccess, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Raphael99090/1NXXiter-lib/main/Crimsom%20ui%20lib.lua"))()
end)

if not libSuccess or type(Library) ~= "table" then
    warn("[1NXITER] ✗ Falha ao carregar a Crimson UI Library do GitHub.")
    return
end

-- 2. Configuração de Estado para o Treino (usado no ui.lua)
local State = { IsRunning = false, IsActive = true }

-- 3. Inicializar os módulos técnicos
pcall(function()
    if Utils.init then Utils.init(Settings) end
    if Aimbot.init then Aimbot.init(Settings, Utils) end
    if ESP.init then ESP.init(Settings, Utils) end
    if Optimization.init then Optimization.init(Settings) end
    if Misc.init then Misc.init(Settings, Utils) end
    
    -- 4. Inicializar a Interface usando o formato correto (:Load)
    -- O 'Misc' foi passado como 'Logic' porque no seu UI original ele esperava um Logic
    UI:Load(Library, Settings, State, Utils, Misc) 
end)

-- ═══════════════════════════════════════════════════════
-- LOOP PRINCIPAL E CONEXÕES
-- ═══════════════════════════════════════════════════════

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Garantir que a tabela de conexões exista no seu Settings.lua
Settings.Connections = Settings.Connections or {}

local mainLoop = RunService.RenderStepped:Connect(function(dt)
    if Aimbot.update then Aimbot.update(dt) end
    if ESP.update then ESP.update(dt) end
    if Optimization.update then Optimization.update(dt) end
    if Misc.update then Misc.update(dt) end
end)

table.insert(Settings.Connections, mainLoop)

local keybindConn = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Misc.onKeyPress then Misc.onKeyPress(input.KeyCode) end
end)

table.insert(Settings.Connections, keybindConn)

-- ═══════════════════════════════════════════════════════
-- FINALIZAÇÃO
-- ═══════════════════════════════════════════════════════

local function destroy()
    print("[1NXITER] Limpando recursos...")
    for _, conn in ipairs(Settings.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    print("[1NXITER] ✓ Script finalizado.")
end

getgenv()._1NXITER_DESTROY = destroy

print("\n[1NXITER] ✓ Tudo pronto! Aproveite.")
