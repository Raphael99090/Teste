--[[
    CRIMSON UI LIBRARY - V3.2 (PROFILE FIXED)
    Fixes: Exposed CriarJanela + Restored Profile Info (HWID/Key)
]]

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Library = {
    Connections = {} 
}

-- Gera um HWID Falso para estética
local FAKE_HWID = "CRM-" .. string.upper(string.sub(HttpService:GenerateGUID(false), 1, 4)) .. "-" .. math.random(1000, 9999)

-- [ 1. THEME ]
Library.Theme = {
    Header     = Color3.fromRGB(140, 0, 0),
    Background = Color3.fromRGB(12, 12, 14),
    Sidebar    = Color3.fromRGB(18, 5, 5),
    Accent     = Color3.fromRGB(220, 20, 60),
    Text       = Color3.fromRGB(245, 245, 245),
    TextDim    = Color3.fromRGB(160, 160, 160),
    ItemBg     = Color3.fromRGB(28, 28, 32),
    Success    = Color3.fromRGB(80, 255, 120),
    Gold       = Color3.fromRGB(255, 215, 0)
}

-- [ 2. UTILS ]
Library.Utils = {}

function Library.Utils.AddCorner(instance, radius)
    local corner = Instance.new("UICorner", instance)
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

function Library.Utils.AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke", instance)
    stroke.Color = color
    stroke.Thickness = thickness
    return stroke
end

function Library.Utils.Tween(instance, properties, time)
    TweenService:Create(instance, TweenInfo.new(time or 0.2), properties):Play()
end

function Library.Utils.MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    
    local c1 = guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            local c2; c2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if c2 then c2:Disconnect() end
                end
            end)
        end
    end)
    table.insert(Library.Connections, c1)
    
    local c3 = guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(Library.Connections, c3)
    
    local c4 = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Library.Utils.Tween(guiObject, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.05)
        end
    end)
    table.insert(Library.Connections, c4)
end

-- [ 3. COMPONENTS ]
Library.Components = {}

function Library.Components.Button(parent, text, callback)
    local Btn = Instance.new("TextButton", parent); Btn.Text = text; Btn.Size = UDim2.new(1, -5, 0, 40); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 14
    Library.Utils.AddCorner(Btn, 8); Library.Utils.AddStroke(Btn, Library.Theme.Accent, 1)
    Btn.MouseButton1Click:Connect(function() 
        Library.Utils.Tween(Btn, {Size = UDim2.new(1, -10, 0, 40)}, 0.1); task.wait(0.1)
        Library.Utils.Tween(Btn, {Size = UDim2.new(1, -5, 0, 40)}, 0.1); if callback then pcall(callback) end 
    end)
    return function(t) Btn.Text = t end
end

function Library.Components.Toggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundTransparency = 1
    local Box = Instance.new("TextButton", Frame); Box.Size = UDim2.new(0, 24, 0, 24); Box.Position = UDim2.new(0, 2, 0.5, -12); Box.BackgroundColor3 = Library.Theme.ItemBg; Box.Text = ""; Box.AutoButtonColor = false; Library.Utils.AddCorner(Box, 6); local Stroke = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    local Check = Instance.new("Frame", Box); Check.Size = UDim2.new(0, 14, 0, 14); Check.AnchorPoint = Vector2.new(0.5, 0.5); Check.Position = UDim2.new(0.5, 0, 0.5, 0); Check.BackgroundColor3 = Library.Theme.Accent; Check.Visible = default; Library.Utils.AddCorner(Check, 4)
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, -35, 1, 0); Label.Position = UDim2.new(0, 35, 0, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.Text; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left
    local On = default
    Box.MouseButton1Click:Connect(function()
        On = not On; Check.Visible = On; Stroke.Color = On and Library.Theme.Accent or Library.Theme.TextDim
        if callback then pcall(callback, On) end
    end)
end

function Library.Components.Slider(parent, text, min, max, default, callback)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local L = Instance.new("TextLabel", F); L.Text = text; L.Size = UDim2.new(1, -50, 0, 20); L.BackgroundTransparency=1; L.TextColor3=Library.Theme.TextDim; L.Font=Enum.Font.Gotham; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left
    local V = Instance.new("TextLabel", F); V.Text = tostring(default); V.Size = UDim2.new(0, 40, 0, 20); V.Position=UDim2.new(1,-45,0,0); V.BackgroundTransparency=1; V.TextColor3=Library.Theme.Text; V.Font=Enum.Font.GothamBold; V.TextSize=12
    local Bg = Instance.new("TextButton", F); Bg.Text=""; Bg.Size=UDim2.new(1,-5,0,6); Bg.Position=UDim2.new(0,0,0,30); Bg.BackgroundColor3=Library.Theme.ItemBg; Bg.AutoButtonColor=false; Library.Utils.AddCorner(Bg, 100)
    local Fil = Instance.new("Frame", Bg); Fil.Size=UDim2.new((default - min)/(max - min), 0, 1, 0); Fil.BackgroundColor3=Library.Theme.Accent; Library.Utils.AddCorner(Fil, 100)
    local Drag = false
    Bg.MouseButton1Down:Connect(function() Drag = true end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Drag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if Drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local S = math.clamp((i.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
            local Val = math.floor(min + ((max - min) * S) * 10) / 10
            Library.Utils.Tween(Fil, {Size = UDim2.new(S, 0, 1, 0)}, 0.05); V.Text = tostring(Val); if callback then pcall(callback, Val) end
        end
    end)
end

function Library.Components.Input(parent, text, default, callback)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local L = Instance.new("TextLabel", F); L.Text = text; L.Size = UDim2.new(1,0,0,20); L.BackgroundTransparency=1; L.TextColor3=Library.Theme.TextDim; L.Font=Enum.Font.Gotham; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left
    local Bg = Instance.new("Frame", F); Bg.Size=UDim2.new(1,-5,0,30); Bg.Position=UDim2.new(0,0,0,20); Bg.BackgroundColor3=Library.Theme.ItemBg; Library.Utils.AddCorner(Bg, 8)
    local Box = Instance.new("TextBox", Bg); Box.Text = tostring(default or ""); Box.Size=UDim2.new(1,-10,1,0); Box.Position=UDim2.new(0,10,0,0); Box.BackgroundTransparency=1; Box.TextColor3=Library.Theme.Text; Box.Font=Enum.Font.GothamBold; Box.TextXAlignment=Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() if callback then pcall(callback, Box.Text) end end)
end

function Library.Components.Dropdown(parent, text, options, callback)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundTransparency = 1; F.ZIndex = 5
    local L = Instance.new("TextLabel", F); L.Text = text; L.Size = UDim2.new(1,0,0,20); L.BackgroundTransparency=1; L.TextColor3=Library.Theme.TextDim; L.Font=Enum.Font.Gotham; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left
    local B = Instance.new("TextButton", F); B.Text = options[1] or "..."; B.Size=UDim2.new(1,-5,0,30); B.Position=UDim2.new(0,0,0,20); B.BackgroundColor3=Library.Theme.ItemBg; B.TextColor3=Library.Theme.Text; B.Font=Enum.Font.GothamBold; B.ZIndex = 6; Library.Utils.AddCorner(B, 6)
    local Sc = Instance.new("ScrollingFrame", B); Sc.Size = UDim2.new(1, 0, 0, 0); Sc.Position = UDim2.new(0, 0, 1, 5); Sc.BackgroundColor3 = Library.Theme.ItemBg; Sc.Visible = false; Sc.ZIndex = 10; Library.Utils.AddCorner(Sc, 6); Library.Utils.AddStroke(Sc, Library.Theme.Header, 1)
    local UI = Instance.new("UIListLayout", Sc); UI.Padding = UDim.new(0, 5); UI.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local Open = false
    B.MouseButton1Click:Connect(function() Open = not Open; Sc.Visible = Open; Library.Utils.Tween(Sc, {Size = UDim2.new(1, 0, 0, Open and math.min(#options*30, 120) or 0)}, 0.2) end)
    for _, o in pairs(options) do
        local Opt = Instance.new("TextButton", Sc); Opt.Text = o; Opt.Size = UDim2.new(1, -10, 0, 25); Opt.BackgroundTransparency = 1; Opt.TextColor3 = Library.Theme.TextDim; Opt.Font = Enum.Font.Gotham; Opt.ZIndex = 11
        Opt.MouseButton1Click:Connect(function() Open = false; B.Text = o; Library.Utils.Tween(Sc, {Size = UDim2.new(1, 0, 0, 0)}, 0.2); task.wait(0.2); Sc.Visible = false; if callback then pcall(callback, o) end end)
    end
end

-- [ 4. WINDOW ]
function Library:CriarJanela(title)
    local WindowObj = {}
    if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
    if Player.PlayerGui:FindFirstChild("CrimsonUI") then Player.PlayerGui["CrimsonUI"]:Destroy() end
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "CrimsonUI"
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
    
    local NotifContainer = Instance.new("Frame", ScreenGui); NotifContainer.Size = UDim2.new(0, 300, 1, 0); NotifContainer.Position = UDim2.new(1, -320, 0, 50); NotifContainer.BackgroundTransparency = 1
    local NotifList = Instance.new("UIListLayout", NotifContainer); NotifList.Padding = UDim.new(0, 10); NotifList.VerticalAlignment = Enum.VerticalAlignment.Top

    local Bubble = Instance.new("TextButton", ScreenGui); Bubble.Size = UDim2.new(0, 50, 0, 50); Bubble.Position = UDim2.new(0, 50, 0, 100); Bubble.BackgroundColor3 = Library.Theme.Header; Bubble.Text = "CRM"; Bubble.TextColor3 = Library.Theme.Text; Bubble.Font = Enum.Font.GothamBlack; Bubble.Visible = false
    Library.Utils.AddCorner(Bubble, 100); Library.Utils.AddStroke(Bubble, Library.Theme.Text, 2); Library.Utils.MakeDraggable(Bubble)

    local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.BackgroundColor3 = Library.Theme.Background; Main.ClipsDescendants = true
    Library.Utils.AddCorner(Main, 10); Library.Utils.AddStroke(Main, Library.Theme.Header, 2); Library.Utils.MakeDraggable(Main)

    local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Library.Theme.Header; Header.BorderSizePixel = 0
    local TitleLbl = Instance.new("TextLabel", Header); TitleLbl.Text = "  " .. string.upper(title); TitleLbl.Size = UDim2.new(0.7, 0, 1, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = Library.Theme.Text; TitleLbl.Font = Enum.Font.GothamBlack; TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local MinBtn = Instance.new("TextButton", Header); MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Library.Theme.Text; MinBtn.TextSize = 22; MinBtn.Font = Enum.Font.GothamBold
    MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; Bubble.Visible = true end)
    Bubble.MouseButton1Click:Connect(function() Bubble.Visible = false; Main.Visible = true end)

    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 65, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40); Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Sidebar.BorderSizePixel = 0
    local SideList = Instance.new("UIListLayout", Sidebar); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideList.Padding = UDim.new(0, 10)
    local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -75, 1, -50); Content.Position = UDim2.new(0, 70, 0, 45); Content.BackgroundTransparency = 1

    local function Notify(t, d, time)
        local F = Instance.new("Frame", NotifContainer); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundColor3 = Library.Theme.Background; Library.Utils.AddCorner(F, 6); Library.Utils.AddStroke(F, Library.Theme.Accent, 1)
        local T = Instance.new("TextLabel", F); T.Text = t; T.Size = UDim2.new(1, -10, 0, 20); T.Position = UDim2.new(0, 10, 0, 5); T.BackgroundTransparency = 1; T.TextColor3 = Library.Theme.Accent; T.Font = Enum.Font.GothamBlack; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left
        local DS = Instance.new("TextLabel", F); DS.Text = d; DS.Size = UDim2.new(1, -10, 0, 30); DS.Position = UDim2.new(0, 10, 0, 25); DS.BackgroundTransparency = 1; DS.TextColor3 = Library.Theme.Text; DS.Font = Enum.Font.Gotham; DS.TextSize = 12; DS.TextXAlignment = Enum.TextXAlignment.Left; DS.TextWrapped = true
        F.Position = UDim2.new(1, 50, 0, 0); Library.Utils.Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function() task.wait(time or 3); Library.Utils.Tween(F, {Position = UDim2.new(1, 50, 0, 0)}, 0.5); task.wait(0.5); F:Destroy() end)
    end

    local Tabs = {}; local FirstTab = true
    function WindowObj:CriarAba(icon)
        local TabObj = {}
        local Btn = Instance.new("TextButton", Sidebar); Btn.Text = icon; Btn.Size = UDim2.new(0, 45, 0, 45); Btn.BackgroundTransparency = 1; Btn.TextColor3 = Library.Theme.TextDim; Btn.TextSize = 24
        local Scroll = Instance.new("ScrollingFrame", Content); Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.Visible = false; Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Library.Theme.Accent
        local List = Instance.new("UIListLayout", Scroll); List.Padding = UDim.new(0, 6); List.SortOrder = Enum.SortOrder.LayoutOrder
        local Pad = Instance.new("UIPadding", Scroll); Pad.PaddingTop = UDim.new(0, 5); Pad.PaddingBottom = UDim.new(0, 5)
        if FirstTab then Scroll.Visible = true; Btn.TextColor3 = Library.Theme.Accent; FirstTab = false end
        Btn.MouseButton1Click:Connect(function() for _, t in pairs(Tabs) do t.Frame.Visible = false; t.Btn.TextColor3 = Library.Theme.TextDim end; Scroll.Visible = true; Btn.TextColor3 = Library.Theme.Accent end)
        table.insert(Tabs, {Frame = Scroll, Btn = Btn})

        function TabObj:CriarBotao(t, c) return Library.Components.Button(Scroll, t, c) end
        function TabObj:CriarToggle(t, d, c) return Library.Components.Toggle(Scroll, t, d, c) end
        function TabObj:CriarSlider(t, min, max, d, c) return Library.Components.Slider(Scroll, t, min, max, d, c) end
        function TabObj:CriarInput(t, d, c) return Library.Components.Input(Scroll, t, d, c) end
        function TabObj:CriarDropdown(t, o, c) return Library.Components.Dropdown(Scroll, t, o, c) end
        function TabObj:CriarLabel(t, c) local L = Instance.new("TextLabel", Scroll); L.Text = t; L.Size = UDim2.new(1, 0, 0, 30); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 14; return function(tx) L.Text = tx end end
        
        -- PERFIL COMPLETO (RESTAURADO)
        function TabObj:CriarPerfil()
            local C = Instance.new("Frame", Scroll); C.Size = UDim2.new(1, -5, 0, 160); C.BackgroundColor3 = Color3.fromRGB(20,20,25)
            Library.Utils.AddCorner(C, 12); Library.Utils.AddStroke(C, Library.Theme.ItemBg, 1)
            
            -- FOTO FIX (RbxThumb)
            local Av = Instance.new("ImageLabel", C); Av.Size=UDim2.new(0,70,0,70); Av.Position=UDim2.new(0,15,0,45); Av.BackgroundTransparency=1
            Library.Utils.AddCorner(Av, 100); Library.Utils.AddStroke(Av, Library.Theme.Accent, 2)
            Av.Image = "rbxthumb://type=AvatarHeadShot&id="..Player.UserId.."&w=150&h=150"
            
            local function Info(t, v, y, c) local L = Instance.new("TextLabel", C); L.Text=t..": "..v; L.Size=UDim2.new(0.6,0,0,18); L.Position=UDim2.new(0,100,0,y); L.BackgroundTransparency=1; L.TextColor3=c or Library.Theme.Text; L.Font=Enum.Font.GothamBold; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left end
            
            -- INFOS COMPLETAS
            Info("USER", string.upper(Player.Name), 20, Library.Theme.Text)
            Info("ID", Player.UserId, 40, Library.Theme.TextDim)
            Info("ACCESS", "LIFETIME", 60, Library.Theme.Gold)
            Info("HWID", FAKE_HWID, 80, Library.Theme.Accent)
            Info("VER", "3.2 FINAL", 100, Library.Theme.TextDim)
            Info("STATUS", "VIP ACTIVE", 120, Library.Theme.Success)
        end
        return TabObj
    end
    function Library:Notificar(t, d, time) Notify(t, d, time) end
    return WinObj
end

return Library
