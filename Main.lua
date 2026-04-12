--[[
    1NXITER HUB - LOADER V2
]]
local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

local function Load(path)
    local url = BaseURL .. path .. ".lua"
    local s, r = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not s then warn("❌ Erro ao carregar: " .. path) end
    return r
end

local Hub = {
    Core = { Utils = Load("Core/Utils") },
    UI = { Library = Load("UI/Library"), Interface = Load("UI/Interface") },
    Features = { AutoTrain = Load("Features/AutoTrain"), Aimbot = Load("Features/Aimbot"), ESP = Load("Features/ESP") }
}

if Hub.UI.Library and Hub.UI.Interface then
    local Config = { Mode="Canguru", Delay=1.4, StartNum=0, Quantity=130, IsCountdown=false, AutoCrouch=false, AutoEquip=false, AutoRejoin=false }
    local State = { IsRunning=false, IsActive=true }
    
    Hub.Core.Utils:AntiAFK(State)
    Hub.Core.Utils:AutoRejoin(Config)
    Hub.UI.Interface:Load(Hub, Config, State)
    
    print("✅ 1NXITER HUB Carregado!")
else
    game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Verifique os arquivos no GitHub!"})
end
