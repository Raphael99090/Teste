local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local Library = { 
    Connections = {}, 
    ThemeUpdaters = {},
    ActiveTweens = {},
    NotificationQueue = {},
    IsNotifying = false
}

-- [ CORREÇÃO 1 ]: Cores completas em todos os temas (Error adicionado)
Library.Themes = {
    ["Crimson"] = { Header = Color3.fromRGB(140,0,0), Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(18,5,5), Accent = Color3.fromRGB(220,20,60), Text = Color3.fromRGB(245,245,245), TextDim = Color3.fromRGB(160,160,160), ItemBg = Color3.fromRGB(28,28,32), Success = Color3.fromRGB(80,255,120), Warning = Color3.fromRGB(255,200,50), Error = Color3.fromRGB(255,80,80), Gold = Color3.fromRGB(255,215,0) },
    ["Neon Purple"] = { Header = Color3.fromRGB(75,0,130), Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(15,5,20), Accent = Color3.fromRGB(148,0,211), Text = Color3.fromRGB(245,245,245), TextDim = Color3.fromRGB(160,160,160), ItemBg = Color3.fromRGB(28,28,32), Success = Color3.fromRGB(80,255,120), Warning = Color3.fromRGB(255,200,50), Error = Color3.fromRGB(255,80,80), Gold = Color3.fromRGB(255,215,0) },
    ["Ocean Blue"] = { Header = Color3.fromRGB(0,60,120), Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(5,10,20), Accent = Color3.fromRGB(0,150,255), Text = Color3.fromRGB(245,245,245), TextDim = Color3.fromRGB(160,160,160), ItemBg = Color3.fromRGB(28,28,32), Success = Color3.fromRGB(80,255,120), Warning = Color3.fromRGB(255,200,50), Error = Color3.fromRGB(255,80,80), Gold = Color3.fromRGB(255,215,0) },
    ["Toxic Green"] = { Header = Color3.fromRGB(0,80,0), Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(5,15,5), Accent = Color3.fromRGB(50,205,50), Text = Color3.fromRGB(245,245,245), TextDim = Color3.fromRGB(160,160,160), ItemBg = Color3.fromRGB(28,28,32), Success = Color3.fromRGB(80,255,120), Warning = Color3.fromRGB(255,200,50), Error = Color3.fromRGB(255,80,80), Gold = Color3.fromRGB(255,215,0) },
    ["Midnight Gold"] = { Header = Color3.fromRGB(100,80,0), Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(15,15,5), Accent = Color3.fromRGB(255,215,0), Text = Color3.fromRGB(245,245,245), TextDim = Color3.fromRGB(160,160,160), ItemBg = Color3.fromRGB(28,28,32), Success = Color3.fromRGB(80,255,120), Warning = Color3.fromRGB(255,200,50), Error = Color3.fromRGB(255,80,80), Gold = Color3.fromRGB(255,215,0) }
}
Library.Theme = Library.Themes["Crimson"]

function Library:ChangeTheme(name)
    if self.Themes[name] then
        self.Theme = self.Themes[name]
        for _, updater in pairs(self.ThemeUpdaters) do pcall(updater) end
    end
end

Library.Utils = {}
function Library.Utils.AddCorner(instance, radius) local c = Instance.new("UICorner", instance); c.CornerRadius = UDim.new(0, radius); return c end
function Library.Utils.AddStroke(instance, color, thickness) local s = Instance.new("UIStroke", instance); s.Color = color; s.Thickness = thickness; return s end

--[ CORREÇÃO 5 ]: Limpeza completa de Tweens
function Library.Utils.Tween(instance, prop, time)
    if not instance or not instance.Parent then return end
    if Library.ActiveTweens[instance] then Library.ActiveTweens[instance]:Cancel() end
    local t = TweenService:Create(instance, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), prop)
    Library.ActiveTweens[instance] = t
    t:Play()
    return t
end

function Library.Utils.MakeDraggable(obj)
    obj.Active = true
    local dragStart, startPos, moveConn
    table.insert(Library.Connections, obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position; startPos = obj.Position
            if moveConn then moveConn:Disconnect() end
            moveConn = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                    local delta = input2.Position - dragStart
                    Library.Utils.Tween(obj, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
                end
            end)
            table.insert(Library.Connections, moveConn)
        end
    end))
    table.insert(Library.Connections, obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if moveConn then moveConn:Disconnect(); moveConn = nil end
        end
    end))
end
-- [ CORREÇÃO 4 ]: Versões leves dos componentes (Sem sections complexas)
Library.Components = {}

function Library.Components.Button(parent, text, cb)
    local B = Instance.new("TextButton", parent); B.Text = text; B.Size = UDim2.new(1, -5, 0, 40); B.BackgroundColor3 = Library.Theme.ItemBg; B.TextColor3 = Library.Theme.Text; B.Font = Enum.Font.GothamBold; B.TextSize = 14; B.AutoButtonColor = true
    Library.Utils.AddCorner(B, 8); local S = Library.Utils.AddStroke(B, Library.Theme.Accent, 1)
    table.insert(Library.Connections, B.MouseButton1Click:Connect(function() Library.Utils.Tween(B, {Size = UDim2.new(1, -10, 0, 40)}, 0.1); task.wait(0.1); Library.Utils.Tween(B, {Size = UDim2.new(1, -5, 0, 40)}, 0.1); if cb then pcall(cb) end end))
    table.insert(Library.ThemeUpdaters, function() if B.Parent then Library.Utils.Tween(B, {BackgroundColor3 = Library.Theme.ItemBg, TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(S, {Color = Library.Theme.Accent}, 0.3) end end)
    return function(t) B.Text = t end
end

function Library.Components.Toggle(parent, text, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local Box = Instance.new("TextButton", F); Box.Size = UDim2.new(0, 24, 0, 24); Box.Position = UDim2.new(0, 2, 0.5, -12); Box.BackgroundColor3 = Library.Theme.ItemBg; Box.Text = ""; Box.AutoButtonColor = false
    Library.Utils.AddCorner(Box, 6); local S = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    local Check = Instance.new("Frame", Box); Check.Size = def and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 0, 0, 0); Check.AnchorPoint = Vector2.new(0.5, 0.5); Check.Position = UDim2.new(0.5, 0, 0.5, 0); Check.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Check, 4)
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -35, 1, 0); Lbl.Position = UDim2.new(0, 35, 0, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.Text; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local active = def
    table.insert(Library.Connections, Box.MouseButton1Click:Connect(function() active = not active; Library.Utils.Tween(Check, {Size = active and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 0, 0, 0)}, 0.15); Library.Utils.Tween(S, {Color = active and Library.Theme.Accent or Library.Theme.TextDim}, 0.15); if cb then pcall(cb, active) end end))
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Box, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(S, {Color = active and Library.Theme.Accent or Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Check, {BackgroundColor3 = Library.Theme.Accent}, 0.3); Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.Text}, 0.3) end end)
end

function Library.Components.Slider(parent, text, min, max, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -50, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Val = Instance.new("TextLabel", F); Val.Text = tostring(def); Val.Size = UDim2.new(0, 40, 0, 20); Val.Position = UDim2.new(1, -45, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = Library.Theme.Text; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12; Val.TextXAlignment = Enum.TextXAlignment.Right; Val.TextYAlignment = Enum.TextYAlignment.Center
    local Bar = Instance.new("TextButton", F); Bar.Text = ""; Bar.Size = UDim2.new(1, -5, 0, 6); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Library.Theme.ItemBg; Bar.AutoButtonColor = false; Library.Utils.AddCorner(Bar, 100)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Fill, 100)
    local drag = false
    table.insert(Library.Connections, Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end))
    table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end))
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local num = math.floor(min + ((max - min) * pct) * 10) / 10; Library.Utils.Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05); Val.Text = tostring(num); if cb then pcall(cb, num) end end end))
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Val, {TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(Bar, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(Fill, {BackgroundColor3 = Library.Theme.Accent}, 0.3) end end)
end

function Library.Components.Input(parent, text, def, isNumeric, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Bg = Instance.new("Frame", F); Bg.Size = UDim2.new(1, -5, 0, 30); Bg.Position = UDim2.new(0, 0, 0, 20); Bg.BackgroundColor3 = Library.Theme.ItemBg; Library.Utils.AddCorner(Bg, 8)
    local Box = Instance.new("TextBox", Bg); Box.Text = tostring(def or ""); Box.Size = UDim2.new(1, -10, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0); Box.BackgroundTransparency = 1; Box.TextColor3 = Library.Theme.Text; Box.Font = Enum.Font.GothamBold; Box.TextXAlignment = Enum.TextXAlignment.Left; Box.ClearTextOnFocus = false
    if isNumeric then Box.TextInputType = Enum.TextInputType.Number; table.insert(Library.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function() Box.Text = string.gsub(Box.Text, "%D", "") end)) end
    table.insert(Library.Connections, Box.FocusLost:Connect(function() if cb then pcall(cb, Box.Text) end end))
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Bg, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(Box, {TextColor3 = Library.Theme.Text}, 0.3) end end)
end

function Library.Components.Dropdown(parent, text, ops, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundTransparency = 1; F.ZIndex = 5
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Btn = Instance.new("TextButton", F); Btn.Text = ops[1] or "..."; Btn.Size = UDim2.new(1, -5, 0, 30); Btn.Position = UDim2.new(0, 0, 0, 20); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.ZIndex = 6; Library.Utils.AddCorner(Btn, 6)
    local List = Instance.new("ScrollingFrame", Btn); List.Size = UDim2.new(1, 0, 0, 0); List.Position = UDim2.new(0, 0, 1, 5); List.BackgroundColor3 = Library.Theme.ItemBg; List.Visible = false; List.ZIndex = 10; Library.Utils.AddCorner(List, 6); local S = Library.Utils.AddStroke(List, Library.Theme.Header, 1)
    local Lay = Instance.new("UIListLayout", List); Lay.Padding = UDim.new(0, 5); Lay.HorizontalAlignment = Enum.HorizontalAlignment.Center; Lay.SortOrder = Enum.SortOrder.LayoutOrder; Instance.new("UIPadding", List).PaddingTop = UDim.new(0, 5)
    local SearchBox = Instance.new("TextBox", Btn); SearchBox.Size = UDim2.new(1, -10, 1, 0); SearchBox.Position = UDim2.new(0, 5, 0, 0); SearchBox.BackgroundTransparency = 1; SearchBox.TextColor3 = Library.Theme.Text; SearchBox.Font = Enum.Font.GothamBold; SearchBox.TextSize = 14; SearchBox.PlaceholderText = "Pesquisar..."; SearchBox.Text = ""; SearchBox.Visible = false; SearchBox.ClearTextOnFocus = false
    local open = false; local optionButtons = {}
    table.insert(Library.Connections, Btn.MouseButton1Click:Connect(function()
        open = not open; List.Visible = open; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, open and math.min(#ops * 30 + 10, 120) or 0)}, 0.2)
        if open then Btn.Text = ""; SearchBox.Visible = true; SearchBox:CaptureFocus() else SearchBox.Visible = false; SearchBox.Text = ""; Btn.Text = ops[1] or "..."; for _, b in pairs(optionButtons) do b.Visible = true end end
    end))
    table.insert(Library.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(function() local query = string.lower(SearchBox.Text); for _, b in pairs(optionButtons) do b.Visible = string.find(string.lower(b.Text), query) and true or false end; Lay:ApplyLayout() end))
    for _, op in pairs(ops) do
        local B = Instance.new("TextButton", List); B.Text = op; B.Size = UDim2.new(1, -10, 0, 25); B.BackgroundTransparency = 1; B.TextColor3 = Library.Theme.TextDim; B.Font = Enum.Font.Gotham; B.ZIndex = 11
        table.insert(Library.Connections, B.MouseButton1Click:Connect(function() SearchBox.Visible = false; SearchBox.Text = ""; Btn.Text = op; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, 0)}, 0.2); task.wait(0.2); List.Visible = false; open = false; for _, ob in pairs(optionButtons) do ob.Visible = true end; if cb then pcall(cb, op) end end))
        table.insert(optionButtons, B)
    end
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Btn, {BackgroundColor3 = Library.Theme.ItemBg, TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(List, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(S, {Color = Library.Theme.Header}, 0.3) for _, b in pairs(optionButtons) do Library.Utils.Tween(b, {TextColor3 = Library.Theme.TextDim}, 0.3) end end end)
end

function Library.Components.ColorPicker(parent, text, defaultColor, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1; F.ClipsDescendants = true
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -50, 0, 40); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local ColorBtn = Instance.new("TextButton", F); ColorBtn.Text = ""; ColorBtn.Size = UDim2.new(0, 40, 0, 20); ColorBtn.Position = UDim2.new(1, -45, 0, 10); ColorBtn.BackgroundColor3 = defaultColor; Library.Utils.AddCorner(ColorBtn, 4); Library.Utils.AddStroke(ColorBtn, Library.Theme.TextDim, 1)
    local SlidersFrame = Instance.new("Frame", F); SlidersFrame.Size = UDim2.new(1, -10, 0, 90); SlidersFrame.Position = UDim2.new(0, 5, 0, 40); SlidersFrame.BackgroundTransparency = 1
    local function createMiniSlider(yPos, colorHue) local Bar = Instance.new("TextButton", SlidersFrame); Bar.Text = ""; Bar.Size = UDim2.new(1, 0, 0, 6); Bar.Position = UDim2.new(0, 0, 0, yPos); Bar.BackgroundColor3 = Library.Theme.ItemBg; Bar.AutoButtonColor = false; Library.Utils.AddCorner(Bar, 100); local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new(1, 0, 1, 0); Fill.BackgroundColor3 = colorHue; Library.Utils.AddCorner(Fill, 100); return Bar, Fill end
    local RBar, RFill = createMiniSlider(10, Color3.fromRGB(255,0,0)); local GBar, GFill = createMiniSlider(40, Color3.fromRGB(0,255,0)); local BBar, BFill = createMiniSlider(70, Color3.fromRGB(0,0,255))
    RFill.Size = UDim2.new(defaultColor.R, 0, 1, 0); GFill.Size = UDim2.new(defaultColor.G, 0, 1, 0); BFill.Size = UDim2.new(defaultColor.B, 0, 1, 0)
    local open = false
    table.insert(Library.Connections, ColorBtn.MouseButton1Click:Connect(function() open = not open; Library.Utils.Tween(F, {Size = UDim2.new(1, 0, 0, open and 140 or 40)}, 0.2) end))
    local function UpdateColor() local newCol = Color3.new(RFill.Size.X.Scale, GFill.Size.X.Scale, BFill.Size.X.Scale); Library.Utils.Tween(ColorBtn, {BackgroundColor3 = newCol}, 0.1); if cb then pcall(cb, newCol) end end
    local function attachDrag(bar, fill)
        local drag = false
        table.insert(Library.Connections, bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end))
        table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end))
        table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); Library.Utils.Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05); UpdateColor() end end))
    end
    attachDrag(RBar, RFill); attachDrag(GBar, GFill); attachDrag(BBar, BFill)
end

function Library.Components.Keybind(parent, text, defaultKey, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -80, 1, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local Btn = Instance.new("TextButton", F); Btn.Text = defaultKey.Name; Btn.Size = UDim2.new(0, 70, 0, 24); Btn.Position = UDim2.new(1, -75, 0.5, -12); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Accent; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Library.Utils.AddCorner(Btn, 6); local S = Library.Utils.AddStroke(Btn, Library.Theme.TextDim, 1)
    local currentKey = defaultKey; local capturing = false
    table.insert(Library.Connections, Btn.MouseButton1Click:Connect(function() capturing = true; Btn.Text = "..."; Library.Utils.Tween(S, {Color = Library.Theme.Accent}, 0.2) end))
    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
        if capturing and input.UserInputType == Enum.UserInputType.Keyboard then capturing = false; currentKey = input.KeyCode; Btn.Text = currentKey.Name; Library.Utils.Tween(S, {Color = Library.Theme.TextDim}, 0.2); if cb then pcall(cb, currentKey, false) end
        elseif not capturing and input.KeyCode == currentKey and not gp then if cb then pcall(cb, currentKey, true) end end
    end))
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Btn, {BackgroundColor3 = Library.Theme.ItemBg, TextColor3 = Library.Theme.Accent}, 0.3) end end)
end
local Interface = {}

function Interface:Load(Hub, Config, State)
    local Window = Hub.UI.Library:CriarJanela("1NXITER HUB")

    -- [NOVO]: Inicia a Watermark baseada no seu arquivo de configuração
    if Config.Watermark then Window:SetWatermark(true) end

    local TabHome   = Window:CriarAba("⚔", "Treino")
    local TabCombat = Window:CriarAba("🎯", "Combate")
    local TabExtra  = Window:CriarAba("🚀", "Extras")
    local TabProf   = Window:CriarAba("👤", "Perfil")

    local coresNomes = {"Branco", "Vermelho", "Verde", "Azul", "Amarelo", "Roxo"}
    local coresMap = { ["Branco"] = Color3.fromRGB(255, 255, 255), ["Vermelho"] = Color3.fromRGB(255, 0, 0), ["Verde"] = Color3.fromRGB(50, 255, 50), ["Azul"] = Color3.fromRGB(0, 150, 255), ["Amarelo"] = Color3.fromRGB(255, 215, 0), ["Roxo"] = Color3.fromRGB(150, 0, 255) }

    -- [ ABA 1: TREINO ]
    local LblCount = TabHome:CriarLabel("AGUARDANDO...", Color3.fromRGB(255,45,45))
    TabHome:CriarDropdown("Modo de Treino", {"Canguru", "Flexão", "Polichinelo"}, function(v) Config.Mode = v end)

    local BtnStart
    BtnStart = TabHome:CriarBotao("INICIAR TREINO", function()
        if Hub.Features.AutoTrain then
            Hub.Features.AutoTrain:Toggle(Config, State, Hub, function(textoContador, textoBotao)
                if textoContador then LblCount(textoContador) end
                if textoBotao then BtnStart(textoBotao) end
            end)
        end
    end)

    TabHome:CriarLabel("---  AJUSTES DO TREINO  ---", Color3.fromRGB(255, 200, 50))
    TabHome:CriarInput("Número Inicial", Config.StartNum, true, function(v) Config.StartNum = tonumber(v) or 0 end)
    TabHome:CriarInput("Quantidade", Config.Quantity, true, function(v) Config.Quantity = tonumber(v) or 130 end)
    TabHome:CriarSlider("Velocidade (Delay)", 0.5, 5.0, Config.Delay, function(v) Config.Delay = v end)
    TabHome:CriarToggle("Contagem Regressiva", Config.IsCountdown, function(v) Config.IsCountdown = v end)
    TabHome:CriarToggle("Auto Agachar (Canguru)", Config.AutoCrouch, function(v) Config.AutoCrouch = v end)

    -- [ ABA 2: COMBATE ]
    TabCombat:CriarLabel("---  SISTEMA DE MIRA (AIMBOT)  ---", Color3.fromRGB(220, 20, 60))
    TabCombat:CriarToggle("Ativar Aimbot (Auto-Mira)", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Enabled = v end end)
    TabCombat:CriarToggle("Ignorar Aliados (Team Check)", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.TeamCheck = v end end)
    TabCombat:CriarToggle("Checagem de Parede (Wall Check)", true, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.WallCheck = v end end)
    TabCombat:CriarToggle("Mostrar Círculo FOV", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = v end end)
    TabCombat:CriarSlider("Tamanho do FOV", 50, 500, 150, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.FOVRadius = v end end)
    TabCombat:CriarSlider("Suavidade (Aimbot)", 0.1, 1.0, 0.5, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.Smoothness = v end end)

    TabCombat:CriarLabel("---  HITBOX EXPANDER  ---", Color3.fromRGB(255, 200, 50))
    TabCombat:CriarToggle("Aumentar Hitbox (Tiros fáceis)", false, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxExpander = v end end)
    TabCombat:CriarSlider("Tamanho da Hitbox", 2, 30, 10, function(v) if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.HitboxSize = v end end)

    TabCombat:CriarLabel("---  TELA ESTICADA (FOV)  ---", Color3.fromRGB(255, 100, 255))
    TabCombat:CriarToggle("Ativar Tela Esticada", false, function(v) if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(v) end end)
    TabCombat:CriarKeybind("Atalho: Tela Esticada", Enum.KeyCode.Z, function(key, isPressed)
        if isPressed and Hub.Features.Visuals then
            local estado = not Hub.Features.Visuals.Settings.StretchedEnabled
            Hub.Features.Visuals:ToggleStretched(estado)
            Hub.UI.Library:Notificar("Tela Esticada", estado and "Ligado" or "Desligado", 2)
        end
    end)
    TabCombat:CriarSlider("Campo de Visão (Zoom)", 70, 120, 100, function(v) if Hub.Features.Visuals then Hub.Features.Visuals.Settings.FOVValue = v end end)

    TabCombat:CriarLabel("---  VISUAL (ESP)  ---", Color3.fromRGB(80, 255, 120))
    TabCombat:CriarToggle("Ativar ESP Principal", false, function(v) if Hub.Features.ESP then Hub.Features.ESP:Toggle(v) end end)
    TabCombat:CriarToggle("Ocultar Aliados (Team Check)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamCheck = v end end)
    TabCombat:CriarToggle("Time / Sigla [ESP]", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.TeamText = v end end)
    TabCombat:CriarToggle("Health Bar (Barra de Vida)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.HealthBar = v end end)
    
    TabCombat:CriarToggle("Box (Caixa)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Box = v end end)
    TabCombat:CriarColorPicker("↳ Cor da Caixa", Color3.fromRGB(255, 255, 255), function(color) if Hub.Features.ESP then Hub.Features.ESP.Settings.BoxColor = color end end)
    
    TabCombat:CriarToggle("Skeleton (Esqueleto)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Skeleton = v end end)
    TabCombat:CriarColorPicker("↳ Cor do Esqueleto", Color3.fromRGB(255, 255, 255), function(color) if Hub.Features.ESP then Hub.Features.ESP.Settings.SkeletonColor = color end end)
    
    TabCombat:CriarToggle("Tracers (Linhas)", false, function(v) if Hub.Features.ESP then Hub.Features.ESP.Settings.Tracer = v end end)
    TabCombat:CriarColorPicker("↳ Cor das Linhas", Color3.fromRGB(255, 255, 255), function(color) if Hub.Features.ESP then Hub.Features.ESP.Settings.TracerColor = color end end)

    -- [ ABA 3: EXTRAS E MEMÓRIA ]
    TabExtra:CriarLabel("---  MOVIMENTAÇÃO E FUGA  ---", Color3.fromRGB(0, 150, 255))
    TabExtra:CriarToggle("SpeedHack (Super Velocidade)", false, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleSpeed(v) end end)
    TabExtra:CriarSlider("Velocidade do SpeedHack", 16, 200, 50, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.SpeedValue = v end end)
    TabExtra:CriarToggle("JumpHack (Super Pulo)", false, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleJumpPower(v) end end)
    TabExtra:CriarSlider("Força do Pulo", 50, 300, 100, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods.Settings.JumpValue = v end end)
    
    TabExtra:CriarToggle("Noclip (Atravessar Paredes)", false, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleNoclip(v) end end)
    TabExtra:CriarKeybind("Atalho: Noclip", Enum.KeyCode.N, function(key, isPressed)
        if isPressed and Hub.Features.PlayerMods then
            local estado = not Hub.Features.PlayerMods.Settings.Noclip
            Hub.Features.PlayerMods:ToggleNoclip(estado)
            Hub.UI.Library:Notificar("Noclip", estado and "Ligado" or "Desligado", 2)
        end
    end)
    TabExtra:CriarToggle("Infinity Jump (Pulo Infinito)", false, function(v) if Hub.Features.PlayerMods then Hub.Features.PlayerMods:ToggleInfJump(v) end end)

    TabExtra:CriarLabel("---  INTELIGÊNCIA E ESPIONAGEM  ---", Color3.fromRGB(255, 80, 80))
    TabExtra:CriarToggle("FreeCam (Câmera Livre - PC)", false, function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam:Toggle(v) end end)
    TabExtra:CriarSlider("Velocidade da FreeCam", 1, 10, 2, function(v) if Hub.Features.FreeCam then Hub.Features.FreeCam.Settings.Speed = v end end)
    TabExtra:CriarToggle("Spy Chat (Ver Chat Oculto)", false, function(v) if Hub.Features.SpyChat then Hub.Features.SpyChat:Toggle(v) end end)

    TabExtra:CriarLabel("---  ESTILO DO MENU  ---", Color3.fromRGB(255, 215, 0))
    
    -- [NOVO]: Botão para ligar e desligar a Marca D'água
    TabExtra:CriarToggle("Mostrar Marca D'água (FPS/Ping)", Config.Watermark, function(v) 
        Config.Watermark = v
        Window:SetWatermark(v)
    end)
    
    TabExtra:CriarDropdown("Tema da Interface", {"Crimson", "Neon Purple", "Ocean Blue", "Toxic Green", "Midnight Gold"}, function(tema) Hub.UI.Library:ChangeTheme(tema); Hub.UI.Library:Notificar("Tema", "Atualizado para " .. tema, 3) end)

    TabExtra:CriarLabel("---  MEMÓRIA / CONFIGURAÇÕES  ---", Color3.fromRGB(80, 255, 120))
    TabExtra:CriarBotao("💾 SALVAR CONFIGURAÇÕES", function()
        if Hub.Core.State then local sucesso = Hub.Core.State:SaveConfig(Config); if sucesso then Hub.UI.Library:Notificar("Sucesso!", "Salvo no celular (.json)", 3) else Hub.UI.Library:Notificar("Aviso", "Executor não suportado.", 3) end end
    end)

    TabExtra:CriarLabel("---  UTILITÁRIOS E FUGA  ---", Color3.fromRGB(245, 245, 245))
    TabExtra:CriarToggle("Auto Equipar Arma (Treino)", Config.AutoEquip, function(v) Config.AutoEquip = v end)
    TabExtra:CriarToggle("Auto Rejoin (Queda de Net)", Config.AutoRejoin, function(v) Config.AutoRejoin = v end)
    TabExtra:CriarBotao("🔄 REJOIN (Entrar na mesma sala)", function() Hub.UI.Library:Notificar("Rejoin", "Reconectando...", 5); Hub.Core.Utils:Rejoin() end)
    TabExtra:CriarBotao("🌐 SERVER HOP (Fugir de sala)", function() Hub.UI.Library:Notificar("Server Hop", "Buscando servidor vazio...", 5); Hub.Core.Utils:ServerHop() end)
    TabExtra:CriarBotao("⚡ FPS BOOST MÁXIMO (Anti-Lag)", function() Hub.Core.Utils:AntiLag(); Hub.UI.Library:Notificar("Otimização", "Gráficos reduzidos.", 3, "success") end)

    -- [ ABA 4: PERFIL ]
    TabProf:CriarPerfil()
    TabProf:CriarBotao("FECHAR MENU (PANIC)", function() 
        State.IsActive = false 
        if Hub.Features then
            for _, feature in pairs(Hub.Features) do
                if feature and type(feature.Toggle) == "function" then pcall(function() feature:Toggle(false) end)
                elseif feature and feature.Settings and feature.Settings.Enabled ~= nil then feature.Settings.Enabled = false end
            end
            if Hub.Features.PlayerMods then Hub.Features.PlayerMods:DisableAll() end
            if Hub.Features.Visuals then Hub.Features.Visuals:ToggleStretched(false) end
            if Hub.Features.Aimbot then Hub.Features.Aimbot.Settings.ShowFOV = false; Hub.Features.Aimbot.Settings.HitboxExpander = false end
        end
        
        -- [NOVO]: Desliga a Watermark ao fechar o menu
        Window:SetWatermark(false)
        
        local CoreGui = game:GetService("CoreGui")
        if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
        if CoreGui:FindFirstChild("InxiterFOVMobile") then CoreGui["InxiterFOVMobile"]:Destroy() end
        if CoreGui:FindFirstChild("InxiterSpyChat") then CoreGui["InxiterSpyChat"]:Destroy() end
    end)
end

return Library
