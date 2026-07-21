--[[ 1NXITER HUB - MAIN LOADER v2.5.0 (RAYFIELD EDITION) ]]

if getgenv().InxiterHubLoaded then
    return warn("⚠️ O Hub já está em execução!")
end

if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO FATAL",
        Text = "Seu executor não suporta loadstring ou HttpGet.",
        Duration = 10,
    })
    return
end

-- ======================================================
-- Configuração de Caminhos (Iniciais Maiúsculas)
-- ======================================================
local VERSION = "v2.5.0"
local BASE_URL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"
local GLOBAL_TIMEOUT = 30 

-- [AJUSTE]: Todos os nomes de arquivos agora começam com Maiúscula
local FilesToLoad = {
    Core = { "Utils", "State" },
    UI = { "Interface" }, 
    Features = { "AutoTrain", "Aimbot", "ESP", "SpyChat", "FreeCam", "Visuals", "PlayerMods" },
}

local Hub = { Core = {}, UI = {}, Features = {} }

-- ======================================================
-- Sistema de Download
-- ======================================================
local function SafeNotify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

local function DownloadFile(folder, file)
    -- O caminho agora respeita as Maiúsculas: Ex: .../Core/Utils.lua
    local url = BASE_URL .. folder .. "/" .. file .. ".lua?nocache=" .. tostring(math.random(1e6, 9e6))
    local success, code = pcall(function() return game:HttpGet(url) end)
    
    if success and code and code ~= "" and not code:match("^404") then
        return true, code
    end
    return false, "Falha no download (404 ou Conexão)"
end

-- ======================================================
-- Carregamento Assíncrono
-- ======================================================
local pendingCount = 0
for _, list in pairs(FilesToLoad) do pendingCount = pendingCount + #list end

for folder, list in pairs(FilesToLoad) do
    for _, file in pairs(list) do
        task.spawn(function()
            local ok, codeOrErr = DownloadFile(folder, file)
            if ok then
                local func, err = loadstring(codeOrErr)
                if func then
                    local runOk, result = pcall(func)
                    if runOk then
                        Hub[folder][file] = result
                    else
                        warn("❌ Erro ao rodar " .. file .. ": " .. tostring(result))
                    end
                else
                    warn("❌ Erro ao compilar " .. file .. ": " .. tostring(err))
                end
            else
                warn("⚠️ Arquivo não encontrado: " .. folder .. "/" .. file)
            end
            pendingCount = pendingCount - 1
        end)
    end
end

-- Espera os arquivos baixarem
local start = os.clock()
repeat task.wait(0.1) until pendingCount <= 0 or (os.clock() - start) > GLOBAL_TIMEOUT

if pendingCount > 0 then
    SafeNotify("ERRO", "Tempo limite excedido ou arquivos faltando.", 10)
    return
end

-- ======================================================
-- Inicialização Final
-- ======================================================
local initSuccess, initError = pcall(function()
    getgenv().InxiterHubLoaded = true

    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()

    -- Monitor de Fechamento
    task.spawn(function()
        local coreGui = game:GetService("CoreGui")
        while getgenv().InxiterHubLoaded do
            if not coreGui:FindFirstChild("Rayfield") and not coreGui:FindFirstChild("1NXITER HUB") then
                getgenv().InxiterHubLoaded = false
                break
            end
            task.wait(2)
        end
    end)

    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
end)

if not initSuccess then
    getgenv().InxiterHubLoaded = false
    warn("❌ Erro na inicialização: " .. tostring(initError))
end
