--[[ 1NXITER HUB - LOADER v2.4.0 (STRICT VALIDATION + TIMEOUT) ]]

if getgenv().InxiterHubLoaded then
    return warn("⚠️ O Hub já está em execução!")
end

if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO FATAL",
        Text = "Executor não suportado.",
        Duration = 10,
    })
    return
end

-- ======================================================
-- Configuração
-- ======================================================
local VERSION = "v2.4.0"
local BASE_URL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"
local MAX_RETRIES = 3
local RETRY_DELAY = 0.6
local GLOBAL_TIMEOUT = 30 -- segundos: evita loader travado pra sempre

local FilesToLoad = {
    Core = { "Utils", "State" },
    UI = { "Library", "Interface" },
    Features = { "AutoTrain", "Aimbot", "ESP", "SpyChat", "FreeCam", "Visuals", "PlayerMods" },
}

local Hub = { Core = {}, UI = {}, Features = {} }

-- ======================================================
-- Helpers
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

local function FailFatal(title, text)
    warn("❌ " .. title .. ": " .. text)
    SafeNotify(title, text, 10)
    getgenv().InxiterHubLoaded = false
end

-- Baixa um único arquivo com retry + backoff. Retorna (ok, code|erro)
local function DownloadFile(folder, file)
    local url = BASE_URL .. folder .. "/" .. file .. ".lua?nocache=" .. tostring(math.random(1e6, 9e6))
    local lastError = "desconhecido"

    for attempt = 1, MAX_RETRIES do
        local success, code = pcall(function()
            return game:HttpGet(url)
        end)

        if success and code and code ~= "" and not code:match("^404") then
            return true, code
        end

        lastError = (not success and tostring(code)) or (code == "" and "resposta vazia") or "404 not found"

        if attempt < MAX_RETRIES then
            task.wait(RETRY_DELAY * attempt) -- backoff simples
        end
    end

    return false, lastError
end

-- ======================================================
-- Etapa 1: Download + execução de todos os módulos
-- ======================================================
local status = {} -- status[folder][file] = { ok = bool, error = string|nil }
local pendingCount = 0

for folder, list in pairs(FilesToLoad) do
    status[folder] = {}
    pendingCount = pendingCount + #list
end

for folder, list in pairs(FilesToLoad) do
    for _, file in pairs(list) do
        task.spawn(function()
            local ok, codeOrErr = DownloadFile(folder, file)

            if ok then
                local func, compileErr = loadstring(codeOrErr)
                if func then
                    local runOk, result = pcall(func)
                    if runOk then
                        Hub[folder][file] = result
                        status[folder][file] = { ok = true }
                    else
                        status[folder][file] = { ok = false, error = "erro ao executar: " .. tostring(result) }
                    end
                else
                    status[folder][file] = { ok = false, error = "erro ao compilar: " .. tostring(compileErr) }
                end
            else
                status[folder][file] = { ok = false, error = "erro ao baixar: " .. tostring(codeOrErr) }
            end

            pendingCount = pendingCount - 1
        end)
    end
end

-- Espera com timeout global — nunca fica preso pra sempre
do
    local start = os.clock()
    while pendingCount > 0 do
        if os.clock() - start > GLOBAL_TIMEOUT then
            FailFatal("TIMEOUT", "O carregamento excedeu " .. GLOBAL_TIMEOUT .. "s. Verifique sua conexão.")
            return
        end
        task.wait(0.1)
    end
end

-- ======================================================
-- Etapa 2: Verificação de integridade
-- ======================================================
local failedList = {}

for folder, list in pairs(FilesToLoad) do
    for _, file in pairs(list) do
        local s = status[folder][file]
        if not s or not s.ok or type(Hub[folder][file]) ~= "table" then
            local reason = (s and s.error) or "retornou valor inválido (esperado table)"
            table.insert(failedList, folder .. "/" .. file .. " → " .. reason)
        end
    end
end

if #failedList > 0 then
    warn("❌ Módulos com falha:\n  " .. table.concat(failedList, "\n  "))
    FailFatal("ERRO DE INTEGRIDADE", #failedList .. " módulo(s) falharam. Veja o console (F9).")
    return
end

-- ======================================================
-- Etapa 3: Inicialização da UI
-- ======================================================
local initSuccess, initError = pcall(function()
    getgenv().InxiterHubLoaded = true

    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()

    local conn
    conn = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "CrimsonUI" then
            getgenv().InxiterHubLoaded = false
            if conn then
                conn:Disconnect()
                conn = nil
            end
        end
    end)

    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
end)

if initSuccess then
    SafeNotify("1NXITER HUB", "Carregado " .. VERSION .. " com sucesso!", 3)
else
    getgenv().InxiterHubLoaded = false
    FailFatal("ERRO AO CONSTRUIR UI", tostring(initError))
end
