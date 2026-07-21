local StateManager = {}
local HttpService = game:GetService("HttpService")

local FOLDER_NAME = "1NXITER_HUB"
local FILE_NAME = FOLDER_NAME .. "/Config.json"
local BACKUP_NAME = FOLDER_NAME .. "/Config.backup.json"

-- [MELHORIA]: Configurações Padrão Organizadas
local DefaultConfig = {
    -- Treino
    Mode = "Canguru",
    Delay = 1.4,
    StartNum = 0,
    Quantity = 130,
    IsCountdown = false,
    AutoCrouch = false,
    AutoEquip = false,
    
    -- Utilidades
    AutoRejoin = false,
    Watermark = true,
    Theme = "Crimson",
    
    -- Combate (Novos padrões adicionados para evitar erros)
    AimbotEnabled = false,
    FOVRadius = 150,
    Smoothness = 0.2,
    ESPEnabled = false,
    BoxColor = {255, 255, 255} -- JSON não salva Color3 diretamente, salvamos como tabela
}

local RuntimeState = { 
    IsRunning = false, 
    IsActive = true,
    LoadedAt = os.date("%X")
}

-- [HELPERS]
local function Log(msg, isError)
    local prefix = isError and "❌ [STATE ERROR]: " or "💾 [STATE]: "
    print(prefix .. tostring(msg))
end

-- Verifica se o executor suporta escrita de arquivos
local function IsFileSystemSupported()
    return isfile and readfile and writefile and makefolder and isfolder
end

-- Mescla a config salva com a padrão (Garante que novas opções do script apareçam para o usuário)
local function MergeDefaults(target, source)
    target = target or {}
    for k, v in pairs(DefaultConfig) do
        if source[k] == nil then
            target[k] = v
        else
            target[k] = source[k]
        end
    end
    return target
end

function StateManager:GetRuntimeState()
    return RuntimeState
end

-- [CARREGAR CONFIG]
function StateManager:LoadConfig()
    if not IsFileSystemSupported() then
        Log("Executor não suporta salvamento. Usando padrões.")
        return DefaultConfig
    end

    local function RawLoad(path)
        if isfile(path) then
            local success, content = pcall(readfile, path)
            if success then
                local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, content)
                if decodeSuccess and type(decoded) == "table" then
                    return decoded
                end
            end
        end
        return nil
    end

    -- Tenta carregar principal, se falhar tenta backup
    local loadedData = RawLoad(FILE_NAME) or RawLoad(BACKUP_NAME)

    if not loadedData then
        Log("Nenhuma configuração encontrada. Iniciando padrões.")
        return DefaultConfig
    end

    Log("Configurações carregadas com sucesso.")
    return MergeDefaults({}, loadedData)
end

-- [SALVAR CONFIG]
function StateManager:SaveConfig(currentConfig)
    if not IsFileSystemSupported() then return false end

    local success, err = pcall(function()
        if not isfolder(FOLDER_NAME) then
            makefolder(FOLDER_NAME)
        end

        -- Backup do arquivo atual antes de sobrescrever
        if isfile(FILE_NAME) then
            local currentRaw = readfile(FILE_NAME)
            writefile(BACKUP_NAME, currentRaw)
        end

        -- Transforma a tabela em JSON "Bonito" (Indentado)
        -- O 'true' no final do JSONEncode (se suportado pelo executor) ou formatação manual
        local encoded = HttpService:JSONEncode(currentConfig)
        writefile(FILE_NAME, encoded)
    end)

    if success then
        Log("Configurações salvas.")
    else
        Log("Erro ao salvar: " .. tostring(err), true)
    end

    return success
end

-- [RESETAR]
function StateManager:ResetConfig()
    if isfile(FILE_NAME) then delfile(FILE_NAME) end
    if isfile(BACKUP_NAME) then delfile(BACKUP_NAME) end
    Log("Configurações resetadas para o padrão.")
    return DefaultConfig
end

return StateManager
