--[[
    1NXITER HUB - LOADER v1.4.0
    - Bypass de Cache dinâmico
    - Prevenção de Execução Dupla
    - Proteção de Rede (Net Error Handling)
]]

-- 1. Prevenção de Dupla Execução (Evita travar o jogo abrindo vários menus)
if _G.InxiterHubLoaded then
    warn("⚠️ O Hub já está em execução!")
    return
end
_G.InxiterHubLoaded = true

-- 2. Checagem de Executor Base
if not game.HttpGet or not loadstring then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO FATAL",
        Text = "Seu executor não suporta funções básicas (HttpGet/loadstring).",
        Duration = 10
    })
    _G.InxiterHubLoaded = false
    return
end

local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

-- 3. Função de Load Avançada
local function Load(path)
    -- Bypass de Cache: Adiciona um número aleatório no final para o GitHub baixar a versão atualizada instantaneamente
    local url = BaseURL .. path .. ".lua?nocache=" .. tostring(math.random(1000000, 9999999))
    
    -- Tenta baixar o arquivo de forma segura (Proteção contra queda de internet)
    local netSuccess, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not netSuccess or not code or code == "404: Not Found" then
        warn("❌ Erro de Rede ou Arquivo não encontrado: " .. path)
        return nil
    end
    
    -- Compilação do código
    local func, syntaxErr = loadstring(code)
    if not func then
        warn("❌ Erro de Sintaxe (Código quebrado) em: " .. path)
        warn("🔍 DETALHE: " .. tostring(syntaxErr))
        return nil
    end
    
    -- Execução segura
    local runSuccess, result = pcall(func)
    if not runSuccess then
        warn("❌ Erro de Lógica/Execução em: " .. path)
        warn("🔍 DETALHE: " .. tostring(result))
        return nil
    end
    
    print("✔️ Módulo carregado: " .. path)
    return result
end

print("⏳ Carregando 1NXITER HUB v1.4.0...")

-- Carrega todos os módulos
local Hub = {
    Core = { Utils = Load("Core/Utils") },
    UI = { Library = Load("UI/Library"), Interface = Load("UI/Interface") },
    Features = { 
        AutoTrain = Load("Features/AutoTrain"), 
        Aimbot = Load("Features/Aimbot"), 
        ESP = Load("Features/ESP"),
        SpyChat = Load("Features/SpyChat"), -- NOVO
        FreeCam = Load("Features/FreeCam")  -- NOVO
    }
}
-- Verifica se os módulos principais (UI) sobreviveram
if type(Hub.UI.Library) == "table" and type(Hub.UI.Interface) == "table" then
    local Config = { Mode="Canguru", Delay=1.4, StartNum=0, Quantity=130, IsCountdown=false, AutoCrouch=false, AutoEquip=false, AutoRejoin=false }
    local State = { IsRunning=false, IsActive=true }
    
    -- Se o menu for fechado pelo botão PANIC, permite executar o script novamente depois
    local CoreGui = game:GetService("CoreGui")
    local connection
    connection = CoreGui.ChildRemoved:Connect(function(child)
        if child.Name == "CrimsonUI" then
            _G.InxiterHubLoaded = false
            if connection then connection:Disconnect() end
        end
    end)

    -- Inicia os utilitários
    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    
    -- Constrói a interface final
    Hub.UI.Interface:Load(Hub, Config, State)
    
    print("✅ 1NXITER HUB Carregado com Sucesso!")
    game.StarterGui:SetCore("SendNotification", {Title="1NXITER HUB", Text="Carregado com Sucesso!", Duration=3})
else
    -- Se falhar, reseta a variável para permitir tentar novamente
    _G.InxiterHubLoaded = false 
    game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Falha no carregamento. Abra o F9."})
end
