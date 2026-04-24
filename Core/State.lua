local StateManager = {}
local HttpService = game:GetService("HttpService")

local folderName = "1NXITER_HUB"
local fileName = folderName .. "/Config.json"

local DefaultConfig = {
    Mode = "Canguru", Delay = 1.4, StartNum = 0, Quantity = 130,
    IsCountdown = false, AutoCrouch = false, AutoEquip = false, AutoRejoin = false,
    Watermark = true -- [NOVO]: Salva se a marca d'água está ligada ou não
}

local RuntimeState = { IsRunning = false, IsActive = true }

function StateManager:GetRuntimeState() return RuntimeState end

function StateManager:LoadConfig()
    if not isfile or not readfile then return DefaultConfig end
    if isfile(fileName) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success and type(decoded) == "table" then
            for key, value in pairs(DefaultConfig) do
                if decoded[key] == nil then decoded[key] = value end
            end
            return decoded
        end
    end
    return DefaultConfig
end

function StateManager:SaveConfig(configTable)
    if not writefile or not makefolder then return false end
    local success, err = pcall(function()
        if not isfolder(folderName) then makefolder(folderName) end
        writefile(fileName, HttpService:JSONEncode(configTable))
    end)
    return success
end
return StateManager
