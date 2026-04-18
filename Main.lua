--[[ 1NXITER HUB - LOADER v2.3.0 (STRICT VALIDATION) ]]
if getgenv().InxiterHubLoaded then return warn("⚠️ O Hub já está em execução!") end

if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {Title="ERRO FATAL", Text="Executor não suportado.", Duration=10})
    return
end

local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"
local Hub = { Core = {}, UI = {}, Features = {} }

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
    game.StarterGui:SetCore("SendNotification", {Title="ERRO DE REDE", Text=failedFiles.." arquivos falharam no download.", Duration=5})
    return
end

-- [NOVO]: VERIFICAÇÃO DE INTEGRIDADE MÍNIMA E CRÍTICA
local missingModules = {}
for folder, list in pairs(FilesToLoad) do
    for _, file in pairs(list) do
        if type(Hub[folder][file]) ~= "table" then
            table.insert(missingModules, folder .. "/" .. file)
        end
    end
end

if #missingModules > 0 then
    warn("❌ Módulos corrompidos ou ausentes: " .. table.concat(missingModules, ", "))
    game.StarterGui:SetCore("SendNotification", {Title="ERRO DE INTEGRIDADE", Text="Alguns módulos retornaram Nil. Olhe o F9.", Duration=10})
    return
end

-- Tudo 100% íntegro, prossegue com o carregamento da UI
local initSuccess, initError = pcall(function()
    getgenv().InxiterHubLoaded = true 
    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()
    
    local conn
    conn = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "CrimsonUI" then getgenv().InxiterHubLoaded = false; if conn then conn:Disconnect() end end
    end)

    Hub.Core.Utils:AntiAFK(State); Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
end)

if initSuccess then
    game.StarterGui:SetCore("SendNotification", {Title="1NXITER HUB", Text="Carregado v2.3.0 com sucesso!", Duration=3})
else
    getgenv().InxiterHubLoaded = false 
    warn("❌ Erro ao construir UI: " .. tostring(initError))
end
