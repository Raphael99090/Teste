--[[ 1NXITER HUB - LOADER v1.6.0 (BUG FIXES & TELA ESTICADA) ]]
if getgenv().InxiterHubLoaded then warn("⚠️ O Hub já está em execução!"); return end

if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {Title = "ERRO FATAL", Text = "Executor não suportado.", Duration = 10})
    return
end

local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

local function Load(path)
    local url = BaseURL .. path .. ".lua?nocache=" .. tostring(math.random(1000000, 9999999))
    local netSuccess, code = pcall(function() return game:HttpGet(url) end)
    if not netSuccess or not code or code == "404: Not Found" then warn("❌ Erro 404: " .. path); return nil end
    local func, syntaxErr = loadstring(code)
    if not func then warn("❌ Erro de Sintaxe em: " .. path .. "\n" .. tostring(syntaxErr)); return nil end
    local runSuccess, result = pcall(func)
    if not runSuccess then warn("❌ Erro de Execução em: " .. path .. "\n" .. tostring(result)); return nil end
    return result
end

print("⏳ Carregando 1NXITER HUB v1.6.0...")

local Hub = {
    Core = { Utils = Load("Core/Utils"), State = Load("Core/State") },
    UI = { Library = Load("UI/Library"), Interface = Load("UI/Interface") },
    Features = { 
        AutoTrain = Load("Features/AutoTrain"), 
        Aimbot = Load("Features/Aimbot"), 
        ESP = Load("Features/ESP"),
        SpyChat = Load("Features/SpyChat"),
        FreeCam = Load("Features/FreeCam"),
        Visuals = Load("Features/Visuals") -- [NOVO MÓDULO AQUI!]
    }
}

if type(Hub.UI.Library) == "table" and type(Hub.UI.Interface) == "table" and type(Hub.Core.State) == "table" then
    getgenv().InxiterHubLoaded = true 
    local Config = Hub.Core.State:LoadConfig()
    local State = Hub.Core.State:GetRuntimeState()
    
    local CoreGui = game:GetService("CoreGui")
    local connection
    connection = CoreGui.ChildRemoved:Connect(function(child)
        if child.Name == "CrimsonUI" then
            getgenv().InxiterHubLoaded = false
            if connection then connection:Disconnect() end
        end
    end)

    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
    
    print("✅ 1NXITER HUB Carregado com Sucesso!")
    game.StarterGui:SetCore("SendNotification", {Title="1NXITER HUB", Text="Carregado com Sucesso!", Duration=3})
else
    getgenv().InxiterHubLoaded = false 
    game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Falha no carregamento. Abra o F9."})
end
