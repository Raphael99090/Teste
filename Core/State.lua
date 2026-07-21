local StateManager = {}
local HttpService = game:GetService("HttpService")

local FOLDER_NAME = "1NXITER_HUB"
local FILE_NAME = FOLDER_NAME .. "/Config.json"
local BACKUP_NAME = FOLDER_NAME .. "/Config.backup.json"

local DefaultConfig = {
    Mode = "Canguru",
    Delay = 1.4,
    StartNum = 0,
    Quantity = 130,
    IsCountdown = false,
    AutoCrouch = false,
    AutoEquip = false,
    AutoRejoin = false,
    Watermark = true,
}

local RuntimeState = { IsRunning = false, IsActive = true }

local function Log(...)
    warn("[StateManager]", ...)
end

-- Cópia profunda simples (evita retornar/alterar a mesma referência do DefaultConfig)
local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Garante que cada valor salvo é do MESMO TIPO que o default.
-- Se o arquivo estiver corrompido/editado errado (ex: "1.4" como texto em vez de número),
-- cai no valor padrão em vez de quebrar o script depois.
local function SanitizeConfig(decoded)
    local clean = DeepCopy(DefaultConfig)

    for key, defaultValue in pairs(DefaultConfig) do
        local value = decoded[key]
        if value ~= nil and type(value) == type(defaultValue) then
            clean[key] = value
        elseif value ~= nil then
            Log(("Config '%s' tinha tipo inválido (esperado %s, recebido %s). Usando padrão.")
                :format(key, type(defaultValue), type(value)))
        end
    end

    return clean
end

function StateManager:GetRuntimeState()
    return RuntimeState
end

function StateManager:GetDefaultConfig()
    return DeepCopy(DefaultConfig)
end

-- Tenta ler um arquivo específico e devolve (ok, tabelaDecodificada)
local function TryReadConfig(path)
    if not isfile(path) then
        return false, nil
    end

    local readOk, raw = pcall(readfile, path)
    if not readOk then
        Log("Falha ao ler arquivo:", path, raw)
        return false, nil
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not decodeOk or type(decoded) ~= "table" then
        Log("Falha ao decodificar JSON de:", path)
        return false, nil
    end

    return true, decoded
end

function StateManager:LoadConfig()
    if not isfile or not readfile then
        Log("Ambiente sem suporte a isfile/readfile. Usando config padrão.")
        return self:GetDefaultConfig()
    end

    -- Tenta o arquivo principal primeiro
    local ok, decoded = TryReadConfig(FILE_NAME)

    -- Se falhar, tenta o backup antes de desistir
    if not ok then
        Log("Config principal indisponível/corrompida, tentando backup...")
        ok, decoded = TryReadConfig(BACKUP_NAME)
    end

    if not ok then
        Log("Nenhuma config válida encontrada. Usando padrão.")
        return self:GetDefaultConfig()
    end

    return SanitizeConfig(decoded)
end

function StateManager:SaveConfig(configTable)
    if not writefile or not makefolder or not isfolder then
        Log("Ambiente sem suporte a writefile/makefolder/isfolder.")
        return false
    end

    if type(configTable) ~= "table" then
        Log("SaveConfig recebeu um valor que não é tabela:", type(configTable))
        return false
    end

    local sanitized = SanitizeConfig(configTable)

    local success, err = pcall(function()
        if not isfolder(FOLDER_NAME) then
            makefolder(FOLDER_NAME)
        end

        local encoded = HttpService:JSONEncode(sanitized)

        -- Se já existe uma config válida, promove ela a backup ANTES de sobrescrever.
        -- Assim, se a escrita nova falhar/corromper no meio do caminho, ainda existe algo salvo.
        if isfile(FILE_NAME) then
            local currentOk, currentRaw = pcall(readfile, FILE_NAME)
            if currentOk then
                pcall(writefile, BACKUP_NAME, currentRaw)
            end
        end

        writefile(FILE_NAME, encoded)
    end)

    if not success then
        Log("Falha ao salvar config:", err)
    end

    return success
end

return StateManager
