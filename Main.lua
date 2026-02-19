--[[
    1NXITER TRAINER - LOADER
]]

local Links = {
    Library   = "https://raw.githubusercontent.com/Raphael99090/Teste/main/Library.lua",
    Utils     = "https://raw.githubusercontent.com/Raphael99090/Teste/main/Utils.lua",
    Logic     = "https://raw.githubusercontent.com/Raphael99090/Teste/main/Logic.lua",
    Interface = "https://raw.githubusercontent.com/Raphael99090/Teste/main/Interface.lua"
}

local function Load(url) local s, r = pcall(function() return loadstring(game:HttpGet(url))() end); if not s then warn("Erro ao carregar: "..url) end; return r end

local Library   = Load(Links.Library)
local Utils     = Load(Links.Utils)
local Logic     = Load(Links.Logic)
local Interface = Load(Links.Interface)

if Library and Utils and Logic and Interface then
    local Config = { Mode="Canguru", Delay=1.4, StartNum=0, Quantity=130, IsCountdown=false, AutoCrouch=false, AutoEquip=false, AutoRejoin=false }
    local State = { IsRunning=false, IsActive=true }
    
    Utils:AntiAFK(State)
    Utils:AutoRejoin(Config)
    Interface:Load(Library, Config, State, Utils, Logic)
    
    print("Sistema Carregado!")
else
    game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Verifique os arquivos no GitHub!"})
end
