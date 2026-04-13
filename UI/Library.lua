local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local Library = { Connections = {} }

Library.Theme = {
    Header = Color3.fromRGB(140, 0, 0), Background = Color3.fromRGB(12, 12, 14),
    Sidebar = Color3.fromRGB(18, 5, 5), Accent = Color3.fromRGB(220, 20, 60),
    Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
    ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120),
    Warning = Color3.fromRGB(255, 200, 50), Error = Color3.fromRGB(255, 80, 80)
}

Library.Utils = {}
function Library.Utils.AddCorner(instance, radius) local c = Instance.new("UICorner", instance); c.CornerRadius = UDim.new(0, radius); return c end
function Library.Utils.AddStroke(instance, color, thickness) local s = Instance.new("UIStroke", instance); s.Color = color; s.Thickness = thickness; return s end
function Library.Utils.Tween(instance, prop, time) TweenService:Create(instance, TweenInfo.new(time or 0.2), prop):Play() end
function Library.Utils.MakeDraggable(obj)
    local drag, dragIn, dragStart, startPos
    table.insert(Library.Connections, obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = input.Position; startPos = obj.Position
            local changed; changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false; if changed then changed:Disconnect() end end
            end)
        end
    end))
    table.insert(Library.Connections, obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragIn = input end
    end))
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragIn and drag then
            local delta = input.Position - dragStart
            Library.Utils.Tween(obj, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end))
end

Library.Components = {}
function Library.Components.Button(parent, text, cb)
    local B = Instance.new("TextButton", parent); B.Text = text; B.Size = UDim2.new(1, -5, 0, 40); B.BackgroundColor3 = Library.Theme.ItemBg; B.TextColor3 = Library.Theme.Text; B.Font = Enum.Font.GothamBold; B.TextSize = 14
    Library.Utils.AddCorner(B, 8); Library.Utils.AddStroke(B, Library.Theme.Accent, 1)
    B.MouseButton1Click:Connect(function() Library.Utils.Tween(B, {Size = UDim2.new(1, -10, 0, 40)}, 0.1); task.wait(0.1); Library.Utils.Tween(B, {Size = UDim2.new(1, -5, 0, 40)}, 0.1); if cb then pcall(cb) end end)
    return function(t) B.Text = t end
end

function Library.Components.Toggle(parent, text, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local Box = Instance.new("TextButton", F); Box.Size = UDim2.new(0, 24, 0, 24); Box.Position = UDim2.new(0, 2, 0.5, -12); Box.BackgroundColor3 = Library.Theme.ItemBg; Box.Text = ""
    Library.Utils.AddCorner(Box, 6); local S = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    local Check = Instance.new("Frame", Box); Check.Size = UDim2.new(0, 14, 0, 14); Check.AnchorPoint = Vector2.new(0.5, 0.5); Check.Position = UDim2.new(0.5, 0, 0.5, 0); Check.BackgroundColor3 = Library.Theme.Accent; Check.Visible = def; Library.Utils.AddCorner(Check, 4)
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -35, 1, 0); Lbl.Position = UDim2.new(0, 35, 0, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.Text; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local active = def
    Box.MouseButton1Click:Connect(function() active = not active; Check.Visible = active; S.Color = active and Library.Theme.Accent or Library.Theme.TextDim; if cb then pcall(cb, active) end end)
end

function Library.Components.Slider(parent, text, min, max, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -50, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local Val = Instance.new("TextLabel", F); Val.Text = tostring(def); Val.Size = UDim2.new(0, 40, 0, 20); Val.Position = UDim2.new(1, -45, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = Library.Theme.Text; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12
    local Bar = Instance.new("TextButton", F); Bar.Text = ""; Bar.Size = UDim2.new(1, -5, 0, 6); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Library.Theme.ItemBg; Bar.AutoButtonColor = false; Library.Utils.AddCorner(Bar, 100)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Fill, 100)
    local drag = false
    Bar.MouseButton1Down:Connect(function() drag = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local num = math.floor(min + ((max - min) * pct) * 10) / 10
            Library.Utils.Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05); Val.Text = tostring(num); if cb then pcall(cb, num) end
        end
    end)
end

function Library.Components.Input(parent, text, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local Bg = Instance.new("Frame", F); Bg.Size = UDim2.new(1, -5, 0, 30); Bg.Position = UDim2.new(0, 0, 0, 20); Bg.BackgroundColor3 = Library.Theme.ItemBg; Library.Utils.AddCorner(Bg, 8)
    local Box = Instance.new("TextBox", Bg); Box.Text = tostring(def or ""); Box.Size = UDim2.new(1, -10, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0); Box.BackgroundTransparency = 1; Box.TextColor3 = Library.Theme.Text; Box.Font = Enum.Font.GothamBold; Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() if cb then pcall(cb, Box.Text) end end)
end

function Library.Components.Dropdown(parent, text, ops, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundTransparency = 1; F.ZIndex = 5
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local Btn = Instance.new("TextButton", F); Btn.Text = ops[1] or "..."; Btn.Size = UDim2.new(1, -5, 0, 30); Btn.Position = UDim2.new(0, 0, 0, 20); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.ZIndex = 6; Library.Utils.AddCorner(Btn, 6)
    local List = Instance.new("ScrollingFrame", Btn); List.Size = UDim2.new(1, 0, 0, 0); List.Position = UDim2.new(0, 0, 1, 5); List.BackgroundColor3 = Library.Theme.ItemBg; List.Visible = false; List.ZIndex = 10; Library.Utils.AddCorner(List, 6); Library.Utils.AddStroke(List, Library.Theme.Header, 1)
    local Lay = Instance.new("UIListLayout", List); Lay.Padding = UDim.new(0, 5); Lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local open = false
    Btn.MouseButton1Click:Connect(function() open = not open; List.Visible = open; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, open and math.min(#ops * 30, 120) or 0)}, 0.2) end)
    for _, op in pairs(ops) do
        local B = Instance.new("TextButton", List); B.Text = op; B.Size = UDim2.new(1, -10, 0, 25); B.BackgroundTransparency = 1; B.TextColor3 = Library.Theme.TextDim; B.Font = Enum.Font.Gotham; B.ZIndex = 11
        B.MouseButton1Click:Connect(function() open = false; Btn.Text = op; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, 0)}, 0.2); task.wait(0.2); List.Visible = false; if cb then pcall(cb, op) end end)
    end
end

Library.Window = {}
function Library.Window.Create(title)
    if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
    if Player.PlayerGui:FindFirstChild("CrimsonUI") then Player.PlayerGui["CrimsonUI"]:Destroy() end

    local Gui = Instance.new("ScreenGui"); Gui.Name = "CrimsonUI"; Gui.ResetOnSpawn = false
    pcall(function() Gui.Parent = CoreGui end); if not Gui.Parent then Gui.Parent = Player:WaitForChild("PlayerGui") end

    local Notif = Instance.new("Frame", Gui); Notif.Size = UDim2.new(0, 300, 1, 0); Notif.Position = UDim2.new(1, -320, 0, 50); Notif.BackgroundTransparency = 1
    local NLay = Instance.new("UIListLayout", Notif); NLay.VerticalAlignment = Enum.VerticalAlignment.Top; NLay.Padding = UDim.new(0, 10)

    Library.Notificar = function(self, t, d, time, type)
        local col = (type == "warn" and Library.Theme.Warning) or Library.Theme.Accent
        local F = Instance.new("Frame", Notif); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundColor3 = Library.Theme.Background; Library.Utils.AddCorner(F, 6); Library.Utils.AddStroke(F, col, 1)
        local TT = Instance.new("TextLabel", F); TT.Text = t; TT.Size = UDim2.new(1, -10, 0, 20); TT.Position = UDim2.new(0, 10, 0, 5); TT.BackgroundTransparency = 1; TT.TextColor3 = col; TT.Font = Enum.Font.GothamBlack; TT.TextSize = 14; TT.TextXAlignment = Enum.TextXAlignment.Left
        local DD = Instance.new("TextLabel", F); DD.Text = d; DD.Size = UDim2.new(1, -10, 0, 30); DD.Position = UDim2.new(0, 10, 0, 25); DD.BackgroundTransparency = 1; DD.TextColor3 = Library.Theme.Text; DD.Font = Enum.Font.Gotham; DD.TextSize = 12; DD.TextXAlignment = Enum.TextXAlignment.Left; DD.TextWrapped = true
        F.Position = UDim2.new(1, 50, 0, 0); Library.Utils.Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function() task.wait(time or 3); Library.Utils.Tween(F, {Position = UDim2.new(1, 50, 0, 0)}, 0.5); task.wait(0.5); F:Destroy() end)
    end

    local Bubble = Instance.new("TextButton", Gui); Bubble.Size = UDim2.new(0, 50, 0, 50); Bubble.Position = UDim2.new(0, 50, 0, 100); Bubble.BackgroundColor3 = Library.Theme.Header; Bubble.Text = "CRM"; Bubble.TextColor3 = Library.Theme.Text; Bubble.Font = Enum.Font.GothamBlack; Bubble.Visible = false
    Library.Utils.AddCorner(Bubble, 100); Library.Utils.AddStroke(Bubble, Library.Theme.Text, 2); Library.Utils.MakeDraggable(Bubble)

    local Main = Instance.new("Frame", Gui); Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.BackgroundColor3 = Library.Theme.Background; Main.ClipsDescendants = true
    Library.Utils.AddCorner(Main, 10); Library.Utils.AddStroke(Main, Library.Theme.Header, 2); Library.Utils.MakeDraggable(Main)

    local Head = Instance.new("Frame", Main); Head.Size = UDim2.new(1, 0, 0, 40); Head.BackgroundColor3 = Library.Theme.Header; Head.BorderSizePixel = 0
    local TitleLbl = Instance.new("TextLabel", Head); TitleLbl.Text = "  " .. string.upper(title); TitleLbl.Size = UDim2.new(0.7, 0, 1, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = Library.Theme.Text; TitleLbl.Font = Enum.Font.GothamBlack; TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local MinBtn = Instance.new("TextButton", Head); MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Library.Theme.Text; MinBtn.TextSize = 22; MinBtn.Font = Enum.Font.GothamBold

    MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; Bubble.Visible = true end)
    Bubble.MouseButton1Click:Connect(function() Bubble.Visible = false; Main.Visible = true end)

    local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 65, 1, -40); Side.Position = UDim2.new(0, 0, 0, 40); Side.BackgroundColor3 = Library.Theme.Sidebar; Side.BorderSizePixel = 0
    Instance.new("UIListLayout", Side).Padding = UDim.new(0, 10); Instance.new("UIPadding", Side).PaddingTop = UDim.new(0, 10)
    local Cont = Instance.new("Frame", Main); Cont.Size = UDim2.new(1, -75, 1, -50); Cont.Position = UDim2.new(0, 70, 0, 45); Cont.BackgroundTransparency = 1

    local Win = {}; local first = true; local tabs = {}
    function Win:CriarAba(icon, name)
        local Tab = {}; local Btn = Instance.new("TextButton", Side); Btn.Text = icon; Btn.Size = UDim2.new(0, 45, 0, 45); Btn.BackgroundTransparency = 1; Btn.TextColor3 = Library.Theme.TextDim; Btn.TextSize = 24
        local Scr = Instance.new("ScrollingFrame", Cont); Scr.Size = UDim2.new(1, 0, 1, 0); Scr.BackgroundTransparency = 1; Scr.BorderSizePixel = 0; Scr.Visible = false; Scr.ScrollBarThickness = 2; Scr.ScrollBarImageColor3 = Library.Theme.Accent
        Instance.new("UIListLayout", Scr).Padding = UDim.new(0, 6); local Pad = Instance.new("UIPadding", Scr); Pad.PaddingTop = UDim.new(0, 5); Pad.PaddingBottom = UDim.new(0, 5)

        if first then Scr.Visible = true; Btn.TextColor3 = Library.Theme.Accent; first = false end
        Btn.MouseButton1Click:Connect(function() for _, t in pairs(tabs) do t.Scr.Visible = false; t.Btn.TextColor3 = Library.Theme.TextDim end; Scr.Visible = true; Btn.TextColor3 = Library.Theme.Accent end)
        table.insert(tabs, {Scr = Scr, Btn = Btn})

        function Tab:CriarBotao(t, c) return Library.Components.Button(Scr, t, c) end
        function Tab:CriarToggle(t, d, c) return Library.Components.Toggle(Scr, t, d, c) end
        function Tab:CriarSlider(t, m, mx, d, c) return Library.Components.Slider(Scr, t, m, mx, d, c) end
        function Tab:CriarInput(t, d, c) return Library.Components.Input(Scr, t, d, c) end
        function Tab:CriarDropdown(t, o, c) return Library.Components.Dropdown(Scr, t, o, c) end
        function Tab:CriarLabel(t, c) local L = Instance.new("TextLabel", Scr); L.Text = t; L.Size = UDim2.new(1, 0, 0, 30); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 14; return function(tx) L.Text = tx end end
        function Tab:CriarPerfil()
            local C = Instance.new("Frame", Scr); C.Size = UDim2.new(1, -5, 0, 160); C.BackgroundColor3 = Color3.fromRGB(20,20,25); Library.Utils.AddCorner(C, 12); Library.Utils.AddStroke(C, Library.Theme.ItemBg, 1)
            local Av = Instance.new("ImageLabel", C); Av.Size = UDim2.new(0,70,0,70); Av.Position = UDim2.new(0,15,0,45); Av.BackgroundTransparency = 1; Library.Utils.AddCorner(Av, 100); Library.Utils.AddStroke(Av, Library.Theme.Accent, 2)
            task.spawn(function() pcall(function() Av.Image = Players.LocalPlayer:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end) end)
            local function Info(t, v, y, c) local L = Instance.new("TextLabel", C); L.Text = t..": "..v; L.Size = UDim2.new(0.6,0,0,18); L.Position = UDim2.new(0,100,0,y); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left end
            Info("USER", string.upper(Player.Name), 20, Library.Theme.Text); Info("ID", Player.UserId, 40, Library.Theme.TextDim); Info("STATUS", "VIP ACTIVE", 60, Library.Theme.Success)
        end
        return Tab
    end
    return Win
end

function Library:CriarJanela(title) return Library.Window.Create(title) end
return Library
