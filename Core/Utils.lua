local Utils = {}
Utils._connections = {}
Utils.Debug = true

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer

-- ======================================================
-- NÚMEROS PARA TEXTO (PT-BR) - VERSÃO DEFINITIVA
-- ======================================================
local UNIDADES = {"ZERO", "UM", "DOIS", "TRÊS", "QUATRO", "CINCO", "SEIS", "SETE", "OITO", "NOVE"}
local ESPECIAIS = {"DEZ", "ONZE", "DOZE", "TREZE", "QUATORZE", "QUINZE", "DEZESSEIS", "DEZESSETE", "DEZOITO", "DEZENOVE"}
local DEZENAS = {"", "", "VINTE", "TRINTA", "QUARENTA", "CINQUENTA", "SESSENTA", "SETENTA", "OITENTA", "NOVENTA"}
local CENTENAS = {"", "CENTO", "DUZENTOS", "TREZENTOS", "QUATROCENTOS", "QUINHENTOS", "SEISCENTOS", "SETECENTOS", "OITOCENTOS", "NOVECENTOS"}

local function centenaParaTexto(num)
    if num == 0 then return "" end
    if num == 100 then return "CEM" end

    local partes = {}
    local c = math.floor(num / 100)
    local resto = num % 100

    -- Centenas
    if c > 0 then 
        table.insert(partes, CENTENAS[c + 1]) 
    end

    -- Dezenas e Unidades
    if resto > 0 then
        if resto >= 10 and resto <= 19 then
            table.insert(partes, ESPECIAIS[resto - 9])
        else
            local d = math.floor(resto / 10)
            local u = resto % 10
            
            if d >= 2 then 
                table.insert(partes, DEZENAS[d + 1]) 
                if u > 0 then table.insert(partes, UNIDADES[u + 1]) end
            elseif u > 0 then
                table.insert(partes, UNIDADES[u + 1])
            end
        end
    end

    -- Junta as partes com " E " (Ex: CENTO E VINTE E UM)
    return table.concat(partes, " E ")
end

function Utils:NumberToText(n)
    n = math.floor(tonumber(n) or 0)
    
    -- Caso isolado do Zero
    if n == 0 then return UNIDADES[1] end
    if n > 9999 then return tostring(n) end 

    if n >= 1000 then
        local milhar = math.floor(n / 1000)
        local resto = n % 1000
        
        -- Regra do "MIL" sozinho ou "DOIS MIL..."
        local textoMilhar = (milhar == 1) and "MIL" or (centenaParaTexto(milhar) .. " MIL")
        
        if resto > 0 then
            -- Gramática: "MIL E CEM" ou "MIL E SETE", mas "MIL CENTO E UM"
            local conector = (resto < 100 or resto % 100 == 0) and " E " or " "
            return textoMilhar .. conector .. centenaParaTexto(resto)
        end
        return textoMilhar
    end

    return centenaParaTexto(n)
end

-- ======================================================
-- RESTANTE DOS MÓDULOS (ANTI-AFK, REJOIN, SERVER HOP, ANTI-LAG)
-- ======================================================

function Utils:AntiAFK()
    if self._connections["AntiAFK"] then return end
    self._connections["AntiAFK"] = Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

function Utils:AutoRejoin(Config)
    if self._connections["AutoRejoin"] then self._connections["AutoRejoin"]:Disconnect() end
    self._connections["AutoRejoin"] = GuiService.ErrorMessageChanged:Connect(function()
        if Config.AutoRejoin then
            task.wait(3)
            self:Rejoin()
        end
    end)
end

function Utils:Rejoin()
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, Player)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end
end

function Utils:ServerHop()
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local success, result = pcall(function()
        local raw = game:HttpGet(Api)
        local data = Http:JSONDecode(raw)
        if data and data.data then
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                    return true
                end
            end
        end
    end)
    if not success then TeleportService:Teleport(game.PlaceId, Player) end
end

function Utils:AntiLag()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    local function Optimize(obj)
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("PostEffect") then
            obj.Enabled = false
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do Optimize(v) end
    workspace.DescendantAdded:Connect(Optimize)
end

function Utils:StopAll()
    for _, conn in pairs(self._connections) do conn:Disconnect() end
    self._connections = {}
end

return Utils
