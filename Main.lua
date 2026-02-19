--[[
    1NXITER TRAINER - MODULAR LOADER
    Repositório: Raphael99090/Teste
]]

-- 1. BASE URL (Onde estão seus arquivos)
local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

-- Função para carregar módulos da nuvem
local function Import(Asset)
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(BaseURL .. Asset .. ".lua"))()
    end)
    if not Success then
        warn("[1NX LOADER] Falha ao carregar: " .. Asset)
        print(Result) -- Mostra o erro no console (F9)
        return nil
    end
    return Result
end

-- 2. IMPORTAR MÓDULOS
-- OBS: Certifique-se de upar o arquivo 'Library.lua' no repositório também!
-- Se não quiser upar, troque a linha abaixo pelo link antigo da lib.
local Library = Import("Library") 
local Utils   = Import("Utils")
local Logic   = Import("Logic")
local Interface = Import("Interface")

-- Verifica se tudo carregou
if not Library or not Utils or not Logic or not Interface then
    return game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO CRÍTICO",
        Text = "Faltam arquivos no GitHub! (Verifique Library.lua)"
    })
end

-- 3. ESTADO GLOBAL (Compartilhado entre os módulos)
local Config = {
    Mode = "Canguru",
    Delay = 1.4,
    StartNum = 0,
    Quantity = 130,
    IsCountdown = false,
    AutoCrouch = false,
    AutoEquip = false,
    AutoRejoin = false
}

local State = {
    IsRunning = false,
    IsActive = true
}

-- 4. INICIALIZAÇÃO DE SISTEMAS
Utils:AntiAFK(State)
Utils:AutoRejoin(Config)

-- 5. CARREGAR UI
Interface:Load(Library, Config, State, Utils, Logic)

print("[1NX] Sistema Modular Carregado com Sucesso!")
