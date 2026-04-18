local Utils = {}
local Players = game:GetService("Players"); local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser"); local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting"); local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

function Utils:NumberToText(n)
    n = math.floor(tonumber(n) or 0); if n == 0 then return "ZERO" end; if n > 5000 then return tostring(n) end
    local function C999(num)
        if num == 0 then return "" end; if num == 100 then return "CEM" end
        local U = {"","UM","DOIS","TRÊS","QUATRO","CINCO","SEIS","SETE","OITO","NOVE"}
        local E = {"DEZ","ONZE","DOZE","TREZE","QUATORZE","QUINZE","DEZESSEIS","DEZESSETE","DEZOITO","DEZENOVE"}
        local D = {"","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"}
        local C = {"","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"}
        local s = ""
        if num>=100 then local c=math.floor(num/100); s=C[c+1]; num=num%100; if num>0 then s=s.." E " end end
        if num>=10 and num<=19 then s=s..E[num-9] elseif num>=20 then local d=math.floor(num/10); s=s..D[d+1]; local u=num%10; if u>0 then s=s.." E "..U[u+1] end elseif num>0 then s=s..U[num+1] end
        return s
    end
    if n>=1000 then local m = math.floor(n/1000); local r = n%1000; local s = (m==1 and "MIL" or C999(m).." MIL"); if r>0 then s=s.." E "..C999(r) end; return s else return C999(n) end
end

function Utils:AntiAFK(StateTable) local conn; conn = Player.Idled:Connect(function() if StateTable.IsActive then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) else conn:Disconnect() end end) end
function Utils:AutoRejoin(ConfigTable) local p = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"); if p and p:FindFirstChild("promptOverlay") then p.promptOverlay.ChildAdded:Connect(function(c) if ConfigTable.AutoRejoin and c.Name == 'ErrorPrompt' then task.wait(2); TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end end) end end
function Utils:Rejoin() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end

-- [MELHORIA]: Otimizado para não dar Error 429
function Utils:ServerHop()
    local req = request or http_request or (syn and syn.request)
    if req then
        local success, res = pcall(function() return req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100", Method = "GET"}) end)
        if success and res.StatusCode == 200 then
            local data = HttpService:JSONDecode(res.Body); local servers = {}
            for _, server in pairs(data.data) do if server.playing < server.maxPlayers and server.id ~= game.JobId then table.insert(servers, server.id) end end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player); return true end
        end
    end
    TeleportService:Teleport(game.PlaceId, Player)
end

function Utils:AntiLag()
    Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
    for _, v in pairs(Lighting:GetDescendants()) do if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled = false end end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0; v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then v.Visible = false end
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end
return Utils