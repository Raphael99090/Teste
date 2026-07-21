--[[ 
    1NXITER HUB - LOADER v2.5.0
    Desenvolvido por: Raphael99090
    Biblioteca: Kavo UI
]]

if getgenv().InxiterHubLoaded then
    warn("⚠️ 1NXITER HUB já está carregado!")
    return
end

-- Verificação de Executor
if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO FATAL",
        Text = "Seu executor não suporta o Hub (Falta HttpGet/Loadstring).",
        Duration = 10,
    })
    return
end

-- ======================================================
-- Configurações de Download
-- ======================================================
local BASE_URL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"
local VERSION = "v2.5.0"

-- Lista de arquivos (Exatamente como estão no GitHub)
local Files = {
    Core = { "Utils", "State" },
    UI = { "Interface" },
    Features = { "AutoTrain", "Aimbot", "ESP", "SpyChat", "FreeCam", "Visuals", "PlayerMods" }
}

local Hub = { Core = {}, UI = {}, Features = {} }

-- Função de Notificação Inicial
local function Notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
end

-- Função de Download
local function Download(folder, file)
    local url = BASE_URL .. folder .. "/" .. file .. ".lua"
    local success, code = pcall(function() return game:HttpGet(url) end)

    if success and code and not code:match("^404") then
        local func, err = loadstring(code)
        if func then
            local runOk, result = pcall(func)
            if runOk then
                return result
            else
                warn("❌ Erro ao executar: " .. file .. " -> " .. tostring(result))
            end
        else
            warn("❌ Erro de sintaxe: " .. file .. " -> " .. tostring(err))
        end
    else
        warn("❌ Erro 404: Arquivo não encontrado -> " .. url)
    end
    return nil
end

-- ======================================================
-- Execução do Carregamento
-- ======================================================
Notify("1NXITER HUB", "Carregando módulos, aguarde...")

-- 1. Carrega Core (Essencial)
for _, file in pairs(Files.Core) do
    Hub.Core[file] = Download("Core", file)
end

-- 2. Carrega UI (Interface)
for _, file in pairs(Files.UI) do
    Hub.UI[file] = Download("UI", file)
end

-- 3. Carrega Features (Funções do Hack)
for _, file in pairs(Files.Features) do
    Hub.Features[file] = Download("Features", file)
end

-- ======================================================
-- Inicialização Final
-- ======================================================
local function Start()
    -- Verifica se arquivos críticos foram carregados
    if not Hub.Core.State or not Hub.UI.Interface or not Hub.Core.Utils then
        Notify("ERRO", "Falha ao baixar arquivos críticos. Veja o F9.")
        return
    end

    getgenv().InxiterHubLoaded = true

    -- Carrega Configurações Salvas
    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()

    -- Ativa Funções Automáticas de Fundo
    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)

    -- Inicia a Interface Gráfica
    Hub.UI.Interface:Load(Hub, Config, State)
    
    Notify("SUCESSO", "Hub " .. VERSION .. " carregado!")
end

local success, err = pcall(Start)
if not success then
    getgenv().InxiterHubLoaded = false
    warn("❌ FALHA AO INICIAR HUB: " .. tostring(err))
    Notify("ERRO", "Falha na inicialização. Veja o F9.")
end
