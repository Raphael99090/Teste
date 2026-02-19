local Utils = {}
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

-- Conversor de Números
function Utils:NumberToText(n)
    n = math.floor(tonumber(n) or 0)
    if n == 0 then return "ZERO" end
    if n > 5000 then return tostring(n) end
    
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
    
    if n>=1000 then
        local m = math.floor(n/1000); local r = n%1000; local s = (m==1 and "MIL" or C999(m).." MIL")
        if r>0 then s=s.." E "..C999(r) end; return s
    else return C999(n) end
end

function Utils:FormatTime(seconds)
    if seconds < 0 then seconds = 0 end
    return string.format("%02d:%02d", math.floor(seconds/60), math.floor(seconds%60))
end

function Utils:AntiAFK(StateTable)
    Players.LocalPlayer.Idled:Connect(function()
        if StateTable.IsActive then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

function Utils:AutoRejoin(ConfigTable)
    game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if ConfigTable.AutoRejoin and child.Name == 'ErrorPrompt' then
            task.wait(2)
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        end
    end)
end

function Utils:AntiLag()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    end
end

return Utils
