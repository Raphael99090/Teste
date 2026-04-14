local StateManager = {}
local HttpService = game:GetService("HttpService")

-- Nome da pasta e do arquivo que serão criados no seu celular
local folderName = "1NXITER_HUB"
local fileName = folderName .. "/Config.json"

-- [ CONFIGURAÇÕES PADRÃO ] (Se for a primeira vez abrindo o script)
local DefaultConfig = {
    Mode = "Canguru", Delay = 1.4, StartNum = 0, Quantity = 130,
    IsCountdown = false, AutoCrouch = false, AutoEquip = false, AutoRejoin = false
}

--[ ESTADO TEMPORÁRIO ] (Isso NÃO salva, pois reseta a cada jogo)
local RuntimeState = {
    IsRunning = false,
    IsActive = true
}

-- Retorna o estado temporário
function StateManager:GetRuntimeState()
    return RuntimeState
end

-- Carrega o .json do celular
function StateManager:LoadConfig()
    -- Se o executor for muito ruim e não suportar arquivos, retorna o padrão
    if not isfile or not readfile then return DefaultConfig end
    
    -- Se o arquivo JSON já existir no celular
    if isfile(fileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        
        if success and type(decoded) == "table" then
            -- Mescla com o padrão (para não bugar se adicionarmos coisas novas na próxima atualização)
            for key, value in pairs(DefaultConfig) do
                if decoded[key] == nil then
                    decoded[key] = value
                end
            end
            return decoded
        end
    end
    
    return DefaultConfig
end

-- Salva o .json no celular
function StateManager:SaveConfig(configTable)
    if not writefile or not makefolder then return false end
    
    local success, err = pcall(function()
        if not isfolder(folderName) then
            makefolder(folderName) -- Cria a pasta 1NXITER_HUB
        end
        -- Transforma a tabela em texto JSON e salva
        local jsonString = HttpService:JSONEncode(configTable)
        writefile(fileName, jsonString)
    end)
    
    return success
end

return StateManager
