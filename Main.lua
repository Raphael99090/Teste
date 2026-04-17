--[[ 1NXITER HUB - LOADER v2.1.0 ]]
if getgenv().InxiterHubLoaded then return warn("⚠️ O Hub já está em execução!") end

if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {Title="ERRO FATAL", Text="Executor não suportado.", Duration=10})
    return
end

local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"
local Hub = { Core = {}, UI = {}, Features = {} }

-- LISTA DE TODOS OS MÓDULOS DO SEU PROJETO
local FilesToLoad = {
    Core = {"Utils", "State"},
    UI = {"Library", "Interface"},
    Features = {"AutoTrain", "Aimbot", "ESP", "SpyChat", "FreeCam", "Visuals", "PlayerMods"}
}

local totalFiles, loadedFiles, failedFiles = 0, 0, 0
for _, list in pairs(FilesToLoad) do totalFiles = totalFiles + #list end

for folder, list in pairs(FilesToLoad) do
    for _, file in pairs(list) do
        task.spawn(function()
            local url = BaseURL .. folder .. "/" .. file .. ".lua?nocache=" .. tostring(math.random(1e6, 9e6))
            local success, code
            
            for i = 1, 3 do 
                success, code = pcall(function() return game:HttpGet(url) end)
                if success and code and code ~= "404: Not Found" then break end
                task.wait(0.5)
            end

            if success and code and code ~= "404: Not Found" then
                local func = loadstring(code)
                if func then
                    local runSuccess, result = pcall(func)
                    if runSuccess then Hub[folder][file] = result; loadedFiles = loadedFiles + 1; return end
                end
            end
            failedFiles = failedFiles + 1
        end)
    end
end

while loadedFiles + failedFiles < totalFiles do task.wait(0.1) end

if failedFiles > 0 then
    game.StarterGui:SetCore("SendNotification", {Title="ERRO DE REDE", Text=failedFiles.." arquivos falharam.", Duration=5})
    return
end

if Hub.UI.Library and Hub.UI.Interface and Hub.Core.State then
    getgenv().InxiterHubLoaded = true 
    
    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()
    
    local conn
    conn = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "CrimsonUI" then
            getgenv().InxiterHubLoaded = false
            if conn then conn:Disconnect() end
        end
    end)

    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
else
    game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Falha no carregamento. Abra o F9."})
end
