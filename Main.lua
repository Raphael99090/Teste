--[[
    1NXITER TRAINER - LOADER (V11)
    Repositório: GitHub/Raphael99090
]]

-- 1. CONFIGURAÇÃO DO REPOSITÓRIO
local Repo = "https://raw.githubusercontent.com/Raphael99090/1NXXiter-lib/refs/heads/main/"

-- Função de Carregamento Seguro
local function LoadModule(name)
    local url = Repo .. name .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("[1NX LOADER] Erro ao carregar " .. name .. ": " .. tostring(result))
        return nil
    end
    return result
end

-- 2. CARREGAR MÓDULOS
local Library = LoadModule("Library") -- A sua lib de UI (Crimson)
local Utils   = LoadModule("Utils")
local Logic   = LoadModule("Logic")
local UI      = LoadModule("Interface")

if not Library or not Utils or not Logic or not UI then
    return game.StarterGui:SetCore("SendNotification", {Title="ERRO", Text="Falha ao baixar módulos do GitHub!"})
end

-- 3. ESTADO GLOBAL (Shared State)
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

-- 4. INICIALIZAÇÃO
Utils:AntiAFK(State)
Utils:AutoRejoin(Config)

-- Iniciar Interface
UI:Load(Library, Config, State, Utils, Logic)

print("[1NXITER] Sistema carregado com sucesso (Modular).")
