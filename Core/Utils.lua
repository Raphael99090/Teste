local Utils = {}
Utils._connections = {}
Utils.Debug = false

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

local function Log(...)
    if Utils.Debug then
        print("[Utils]", ...)
    end
end

local function WarnLog(...)
    warn("[Utils]", ...)
end

-- ======================================================
-- Números para texto (PT-BR)
-- ======================================================
local UNIDADES = {"", "UM", "DOIS", "TRÊS", "QUATRO", "CINCO", "SEIS", "SETE", "OITO", "NOVE"}
local ESPECIAIS = {"DEZ", "ONZE", "DOZE", "TREZE", "QUATORZE", "QUINZE", "DEZESSEIS", "DEZESSETE", "DEZOITO", "DEZENOVE"}
local DEZENAS = {"", "", "VINTE", "TRINTA", "QUARENTA", "CINQUENTA", "SESSENTA", "SETENTA", "OITENTA", "NOVENTA"}
local CENTENAS = {"", "CENTO", "DUZENTOS", "TREZENTOS", "QUATROCENTOS", "QUINHENTOS", "SEISCENTOS", "SETECENTOS", "OITOCENTOS", "NOVECENTOS"}

local function centenaParaTexto(num)
    if num == 0 then return "" end
    if num == 100 then return "CEM" end

    local partes = {}

    if num >= 100 then
        local c = math.floor(num / 100)
        table.insert(partes, CENTENAS[c + 1])
        num = num % 100
    end

    if num >= 10 and num <= 19 then
        table.insert(partes, ESPECIAIS[num - 9])
    elseif num >= 20 then
        local d = math.floor(num / 10)
        table.insert(partes, DEZENAS[d + 1])
        local u = num % 10
        if u > 0 then
            table.insert(partes, UNIDADES[u + 1])
        end
    elseif num > 0 then
        table.insert(partes, UNIDADES[num + 1])
    end

    return table.concat(partes, " E ")
end

function Utils:NumberToText(n)
    n = math.floor(tonumber(n) or 0)

    if n == 0 then return "ZERO" end
    if n > 5000 then return tostring(n) end

    if n >= 1000 then
        local milhar = math.floor(n / 1000)
        local resto = n % 1000

        local texto = (milhar == 1) and "MIL" or (centenaParaTexto(milhar) .. " MIL")
        if resto > 0 then
            texto = texto .. " E " .. centenaParaTexto(resto)
        end
        return texto
    end

    return centenaParaTexto(n)
end

-- ======================================================
-- Gerenciamento de conexões (evita duplicar/perder listeners)
-- ======================================================
local function SetConnection(key, conn)
    if Utils._connections[key] then
        Utils._connections[key]:Disconnect()
    end
    Utils._connections[key] = conn
    return conn
end

local function ClearConnection(key)
    if Utils._connections[key] then
        Utils._connections[key]:Disconnect()
        Utils._connections[key] = nil
        Log(key, "desconectado.")
    end
end

-- ======================================================
-- Anti-AFK
-- ======================================================
function Utils:AntiAFK(StateTable)
    StateTable = StateTable or { IsActive = true }

    local conn = Player.Idled:Connect(function()
        if not StateTable.IsActive then
            ClearConnection("AntiAFK")
            return
        end

        Log("Anti-AFK acionado.")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    return SetConnection("AntiAFK", conn)
end

function Utils:StopAntiAFK()
    ClearConnection("AntiAFK")
end

-- ======================================================
-- Auto Rejoin
-- ======================================================
function Utils:AutoRejoin(ConfigTable)
    ConfigTable = ConfigTable or { AutoRejoin = true }

    local coreGui = game:GetService("CoreGui")
    local prompt = coreGui:FindFirstChild("RobloxPromptGui")
    local overlay = prompt and prompt:FindFirstChild("promptOverlay")

    if not overlay then
        WarnLog("AutoRejoin: promptOverlay não encontrado (tente chamar depois de PlayerGui carregar).")
        return
    end

    local conn = overlay.ChildAdded:Connect(function(child)
        if ConfigTable.AutoRejoin and child.Name == "ErrorPrompt" then
            Log("Prompt de erro detectado, reconectando em 2s...")
            task.wait(2)
            self:Rejoin()
        end
    end)

    return SetConnection("AutoRejoin", conn)
end

function Utils:StopAutoRejoin()
    ClearConnection("AutoRejoin")
end

function Utils:Rejoin()
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end)
    if not ok then
        WarnLog("Rejoin falhou:", err)
    end
    return ok
end

-- ======================================================
-- Server Hop
-- ======================================================
function Utils:ServerHop()
    local req = request or http_request or (syn and syn.request)

    local function FallbackTeleport(reason)
        WarnLog("ServerHop:", reason, "— usando Teleport padrão.")
        TeleportService:Teleport(game.PlaceId, Player)
        return false
    end

    if not req then
        return FallbackTeleport("função de request indisponível")
    end

    local url = string.format(
        "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
        game.PlaceId
    )

    local success, res = pcall(function()
        return req({ Url = url, Method = "GET" })
    end)

    if not success or not res or res.StatusCode ~= 200 then
        return FallbackTeleport("requisição falhou (status: " .. tostring(res and res.StatusCode) .. ")")
    end

    local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
    if not decodeOk or not data or not data.data then
        return FallbackTeleport("resposta inválida da API")
    end

    local servers = {}
    for _, server in ipairs(data.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server.id)
        end
    end

    if #servers == 0 then
        return FallbackTeleport("nenhum servidor disponível")
    end

    local targetId = servers[math.random(1, #servers)]
    Log("ServerHop: indo para servidor", targetId)

    local teleportOk, teleportErr = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Player)
    end)

    if not teleportOk then
        WarnLog("ServerHop: teleporte falhou:", teleportErr)
    end

    return teleportOk
end

-- ======================================================
-- Anti Lag
-- ======================================================
local EFFECT_CLASSES = {
    "PostEffect", "BlurEffect", "SunRaysEffect",
    "ColorCorrectionEffect", "BloomEffect", "DepthOfFieldEffect"
}

local function DisableEffects(root)
    for _, v in ipairs(root:GetDescendants()) do
        for _, className in ipairs(EFFECT_CLASSES) do
            if v:IsA(className) then
                v.Enabled = false
                break
            end
        end
    end
end

function Utils:AntiLag(options)
    options = options or {}

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    DisableEffects(Lighting)

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif (v:IsA("ParticleEmitter") or v:IsA("Trail")) and options.KillParticles ~= false then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.Visible = false
        end
    end

    local qualityOk = pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    if not qualityOk then
        WarnLog("AntiLag: não foi possível alterar QualityLevel (sem permissão do executor?).")
    end

    Log("AntiLag aplicado.")
end

-- ======================================================
-- Limpeza geral
-- ======================================================
function Utils:StopAll()
    for key in pairs(self._connections) do
        ClearConnection(key)
    end
end

return Utils
