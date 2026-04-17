local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local Library = { Connections = {}, ThemeUpdaters = {} }

Library.Themes = {["Crimson"] = {
        Header = Color3.fromRGB(140, 0, 0), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(18, 5, 5),
        Accent = Color3.fromRGB(220, 20, 60), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
        ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Warning = Color3.fromRGB(255, 200, 50), Gold = Color3.fromRGB(255, 215, 0)
    },["Neon Purple"] = {
        Header = Color3.fromRGB(75, 0, 130), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(15, 5, 20),
        Accent = Color3.fromRGB(148, 0, 211), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
        ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Warning = Color3.fromRGB(255, 200, 50), Gold = Color3.fromRGB(255, 215, 0)
    },
    ["Ocean Blue"] = {
        Header = Color3.fromRGB(0, 60, 120), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(5, 10, 20),
        Accent = Color3.fromRGB(0, 150, 255), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
        ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Warning = Color3.fromRGB(255, 200, 50), Gold = Color3.fromRGB(255, 215, 0)
    },
    ["Toxic Green"] = {
        Header = Color3.fromRGB(0, 80, 0), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(5, 15, 5),
        Accent = Color3.fromRGB(50, 205, 50), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
        ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Warning = Color3.fromRGB(255, 200, 50), Gold = Color3.fromRGB(255, 215, 0)
    },
    ["Midnight Gold"] = {
        Header = Color3.fromRGB(100, 80, 0), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(15, 15, 5),
        Accent = Color3.fromRGB(255, 215, 0), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
        ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Warning = Color3.fromRGB(255, 200, 50), Gold = Color3.fromRGB(255, 215, 0)
    }
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
function Library.Utils.Tween(instance, prop, time) TweenService:Create(instance, TweenInfo.new(time or 0.2), prop):Play() end

function Library.Utils.MakeDraggable(obj)
    obj.Active = true
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
    local B = Instance.new("TextButton", parent); B.Text = text; B.Size = UDim2.new(1, -5, 0, 40); B.BackgroundColor3 = Library.Theme.ItemBg; B.TextColor3 = Library.Theme.Text; B.Font = Enum.Font.GothamBold; B.TextSize = 14; B.AutoButtonColor = true
    Library.Utils.AddCorner(B, 8); local S = Library.Utils.AddStroke(B, Library.Theme.Accent, 1)
    B.MouseButton1Click:Connect(function() Library.Utils.Tween(B, {Size = UDim2.new(1, -10, 0, 40)}, 0.1); task.wait(0.1); Library.Utils.Tween(B, {Size = UDim2.new(1, -5, 0, 40)}, 0.1); if cb then pcall(cb) end end)
    table.insert(Library.ThemeUpdaters, function() if B.Parent then Library.Utils.Tween(B, {BackgroundColor3 = Library.Theme.ItemBg, TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(S, {Color = Library.Theme.Accent}, 0.3) end end)
    return function(t) B.Text = t end
end

function Library.Components.Toggle(parent, text, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local Box = Instance.new("TextButton", F); Box.Size = UDim2.new(0, 24, 0, 24); Box.Position = UDim2.new(0, 2, 0.5, -12); Box.BackgroundColor3 = Library.Theme.ItemBg; Box.Text = ""
    Library.Utils.AddCorner(Box, 6); local S = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    local Check = Instance.new("Frame", Box); Check.Size = def and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 0, 0, 0); Check.AnchorPoint = Vector2.new(0.5, 0.5); Check.Position = UDim2.new(0.5, 0, 0.5, 0); Check.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Check, 4)
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -35, 1, 0); Lbl.Position = UDim2.new(0, 35, 0, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.Text; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local active = def
    Box.MouseButton1Click:Connect(function() active = not active; Library.Utils.Tween(Check, {Size = active and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 0, 0, 0)}, 0.15); Library.Utils.Tween(S, {Color = active and Library.Theme.Accent or Library.Theme.TextDim}, 0.15); if cb then pcall(cb, active) end end)
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Box, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(S, {Color = active and Library.Theme.Accent or Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Check, {BackgroundColor3 = Library.Theme.Accent}, 0.3); Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.Text}, 0.3) end end)
end

function Library.Components.Slider(parent, text, min, max, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, -50, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Val = Instance.new("TextLabel", F); Val.Text = tostring(def); Val.Size = UDim2.new(0, 40, 0, 20); Val.Position = UDim2.new(1, -45, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = Library.Theme.Text; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12; Val.TextXAlignment = Enum.TextXAlignment.Right; Val.TextYAlignment = Enum.TextYAlignment.Center
    local Bar = Instance.new("TextButton", F); Bar.Text = ""; Bar.Size = UDim2.new(1, -5, 0, 6); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Library.Theme.ItemBg; Bar.AutoButtonColor = false; Library.Utils.AddCorner(Bar, 100)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Fill, 100)
    local drag = false
    Bar.MouseButton1Down:Connect(function() drag = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local num = math.floor(min + ((max - min) * pct) * 10) / 10; Library.Utils.Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05); Val.Text = tostring(num); if cb then pcall(cb, num) end end end)
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Val, {TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(Bar, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(Fill, {BackgroundColor3 = Library.Theme.Accent}, 0.3) end end)
end

function Library.Components.Input(parent, text, def, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 50); F.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Bg = Instance.new("Frame", F); Bg.Size = UDim2.new(1, -5, 0, 30); Bg.Position = UDim2.new(0, 0, 0, 20); Bg.BackgroundColor3 = Library.Theme.ItemBg; Library.Utils.AddCorner(Bg, 8)
    local Box = Instance.new("TextBox", Bg); Box.Text = tostring(def or ""); Box.Size = UDim2.new(1, -10, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0); Box.BackgroundTransparency = 1; Box.TextColor3 = Library.Theme.Text; Box.Font = Enum.Font.GothamBold; Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() if cb then pcall(cb, Box.Text) end end)
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Bg, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(Box, {TextColor3 = Library.Theme.Text}, 0.3) end end)
end

function Library.Components.Dropdown(parent, text, ops, cb)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundTransparency = 1; F.ZIndex = 5
    local Lbl = Instance.new("TextLabel", F); Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Library.Theme.TextDim; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.TextYAlignment = Enum.TextYAlignment.Center
    local Btn = Instance.new("TextButton", F); Btn.Text = ops[1] or "..."; Btn.Size = UDim2.new(1, -5, 0, 30); Btn.Position = UDim2.new(0, 0, 0, 20); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.ZIndex = 6; Library.Utils.AddCorner(Btn, 6)
    local List = Instance.new("ScrollingFrame", Btn); List.Size = UDim2.new(1, 0, 0, 0); List.Position = UDim2.new(0, 0, 1, 5); List.BackgroundColor3 = Library.Theme.ItemBg; List.Visible = false; List.ZIndex = 10; Library.Utils.AddCorner(List, 6); local S = Library.Utils.AddStroke(List, Library.Theme.Header, 1)
    local Lay = Instance.new("UIListLayout", List); Lay.Padding = UDim.new(0, 5); Lay.HorizontalAlignment = Enum.HorizontalAlignment.Center; Lay.SortOrder = Enum.SortOrder.LayoutOrder
    local open = false
    Btn.MouseButton1Click:Connect(function() open = not open; List.Visible = open; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, open and math.min(#ops * 30, 120) or 0)}, 0.2) end)
    for _, op in pairs(ops) do
        local B = Instance.new("TextButton", List); B.Text = op; B.Size = UDim2.new(1, -10, 0, 25); B.BackgroundTransparency = 1; B.TextColor3 = Library.Theme.TextDim; B.Font = Enum.Font.Gotham; B.ZIndex = 11
        B.MouseButton1Click:Connect(function() open = false; Btn.Text = op; Library.Utils.Tween(List, {Size = UDim2.new(1, 0, 0, 0)}, 0.2); task.wait(0.2); List.Visible = false; if cb then pcall(cb, op) end end)
    end
    table.insert(Library.ThemeUpdaters, function() if F.Parent then Library.Utils.Tween(Lbl, {TextColor3 = Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Btn, {BackgroundColor3 = Library.Theme.ItemBg, TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(List, {BackgroundColor3 = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(S, {Color = Library.Theme.Header}, 0.3) for _, b in pairs(List:GetChildren()) do if b:IsA("TextButton") then Library.Utils.Tween(b, {TextColor3 = Library.Theme.TextDim}, 0.3) end end end end)
end
Library.Window = {}
function Library.Window.Create(title)
    if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
    if Player.PlayerGui:FindFirstChild("CrimsonUI") then Player.PlayerGui["CrimsonUI"]:Destroy() end

    local Gui = Instance.new("ScreenGui"); Gui.Name = "CrimsonUI"; Gui.ResetOnSpawn = false
    pcall(function() Gui.Parent = CoreGui end); if not Gui.Parent then Gui.Parent = Player:WaitForChild("PlayerGui") end

    local Notif = Instance.new("Frame", Gui); Notif.Size = UDim2.new(0, 300, 1, 0); Notif.Position = UDim2.new(1, -320, 0, 50); Notif.BackgroundTransparency = 1
    local NLay = Instance.new("UIListLayout", Notif); NLay.VerticalAlignment = Enum.VerticalAlignment.Top; NLay.Padding = UDim.new(0, 10); NLay.SortOrder = Enum.SortOrder.LayoutOrder

    Library.Notificar = function(self, t, d, time, type)
        local col = (type == "warn" and Library.Theme.Warning) or Library.Theme.Accent
        local F = Instance.new("Frame", Notif); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundColor3 = Library.Theme.Background; Library.Utils.AddCorner(F, 6); Library.Utils.AddStroke(F, col, 1)
        local TT = Instance.new("TextLabel", F); TT.Text = t; TT.Size = UDim2.new(1, -10, 0, 20); TT.Position = UDim2.new(0, 10, 0, 5); TT.BackgroundTransparency = 1; TT.TextColor3 = col; TT.Font = Enum.Font.GothamBlack; TT.TextSize = 14; TT.TextXAlignment = Enum.TextXAlignment.Left
        local DD = Instance.new("TextLabel", F); DD.Text = d; DD.Size = UDim2.new(1, -10, 0, 30); DD.Position = UDim2.new(0, 10, 0, 25); DD.BackgroundTransparency = 1; DD.TextColor3 = Library.Theme.Text; DD.Font = Enum.Font.Gotham; DD.TextSize = 12; DD.TextXAlignment = Enum.TextXAlignment.Left; DD.TextWrapped = true
        F.Position = UDim2.new(1, 50, 0, 0); Library.Utils.Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function() task.wait(time or 3); Library.Utils.Tween(F, {Position = UDim2.new(1, 50, 0, 0)}, 0.5); task.wait(0.5); F:Destroy() end)
    end

    local Bubble = Instance.new("ImageButton", Gui); Bubble.Size = UDim2.new(0, 50, 0, 50); Bubble.Position = UDim2.new(0, 50, 0, 100); Bubble.BackgroundColor3 = Library.Theme.Background; Bubble.Image = "rbxassetid://129790168468751"; Bubble.ScaleType = Enum.ScaleType.Crop; Bubble.Visible = false
    Library.Utils.AddCorner(Bubble, 100); local BStrk = Library.Utils.AddStroke(Bubble, Library.Theme.Accent, 2); Library.Utils.MakeDraggable(Bubble)

    local Main = Instance.new("Frame", Gui); Main.Active = true; Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.BackgroundColor3 = Library.Theme.Background; Main.ClipsDescendants = true
    Library.Utils.AddCorner(Main, 10); local MStrk = Library.Utils.AddStroke(Main, Library.Theme.Header, 2); Library.Utils.MakeDraggable(Main)

    local MainScale = Instance.new("UIScale", Main); MainScale.Scale = 0; Library.Utils.Tween(MainScale, {Scale = 1}, 0.3)
    local BubbleScale = Instance.new("UIScale", Bubble); BubbleScale.Scale = 0

    local Head = Instance.new("Frame", Main); Head.Size = UDim2.new(1, 0, 0, 40); Head.BackgroundColor3 = Library.Theme.Header; Head.BorderSizePixel = 0
    local TitleLbl = Instance.new("TextLabel", Head); TitleLbl.Text = "  " .. string.upper(title); TitleLbl.Size = UDim2.new(0.7, 0, 1, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = Library.Theme.Text; TitleLbl.Font = Enum.Font.GothamBlack; TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local MinBtn = Instance.new("TextButton", Head); MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Library.Theme.Text; MinBtn.TextSize = 22; MinBtn.Font = Enum.Font.GothamBold

    MinBtn.MouseButton1Click:Connect(function() Library.Utils.Tween(MainScale, {Scale = 0}, 0.2); task.wait(0.2); Main.Visible = false; Bubble.Visible = true; Library.Utils.Tween(BubbleScale, {Scale = 1}, 0.2) end)
    Bubble.MouseButton1Click:Connect(function() Library.Utils.Tween(BubbleScale, {Scale = 0}, 0.2); task.wait(0.2); Bubble.Visible = false; Main.Visible = true; Library.Utils.Tween(MainScale, {Scale = 1}, 0.2) end)

    local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 65, 1, -40); Side.Position = UDim2.new(0, 0, 0, 40); Side.BackgroundColor3 = Library.Theme.Sidebar; Side.BorderSizePixel = 0
    local SLay = Instance.new("UIListLayout", Side); SLay.Padding = UDim.new(0, 10); SLay.SortOrder = Enum.SortOrder.LayoutOrder; Instance.new("UIPadding", Side).PaddingTop = UDim.new(0, 10)
    local Cont = Instance.new("Frame", Main); Cont.Size = UDim2.new(1, -75, 1, -50); Cont.Position = UDim2.new(0, 70, 0, 45); Cont.BackgroundTransparency = 1

    table.insert(Library.ThemeUpdaters, function()
        Library.Utils.Tween(Bubble, {BackgroundColor3 = Library.Theme.Background}, 0.3); Library.Utils.Tween(BStrk, {Color = Library.Theme.Accent}, 0.3)
        Library.Utils.Tween(Main, {BackgroundColor3 = Library.Theme.Background}, 0.3); Library.Utils.Tween(MStrk, {Color = Library.Theme.Header}, 0.3)
        Library.Utils.Tween(Head, {BackgroundColor3 = Library.Theme.Header}, 0.3); Library.Utils.Tween(TitleLbl, {TextColor3 = Library.Theme.Text}, 0.3); Library.Utils.Tween(MinBtn, {TextColor3 = Library.Theme.Text}, 0.3)
        Library.Utils.Tween(Side, {BackgroundColor3 = Library.Theme.Sidebar}, 0.3)
    end)

    local Win = {}; local first = true; local tabs = {}
    function Win:CriarAba(icon, name)
        local Tab = {IsActive = first}; local Btn = Instance.new("TextButton", Side); Btn.Text = icon; Btn.Size = UDim2.new(0, 45, 0, 45); Btn.BackgroundTransparency = 1; Btn.TextColor3 = Library.Theme.TextDim; Btn.TextSize = 24
        local Scr = Instance.new("ScrollingFrame", Cont); Scr.Size = UDim2.new(1, 0, 1, 0); Scr.BackgroundTransparency = 1; Scr.BorderSizePixel = 0; Scr.Visible = false; Scr.ScrollBarThickness = 2; Scr.ScrollBarImageColor3 = Library.Theme.Accent
        local CLay = Instance.new("UIListLayout", Scr); CLay.Padding = UDim.new(0, 6); CLay.SortOrder = Enum.SortOrder.LayoutOrder; local Pad = Instance.new("UIPadding", Scr); Pad.PaddingTop = UDim.new(0, 5); Pad.PaddingBottom = UDim.new(0, 5)

        CLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scr.CanvasSize = UDim2.new(0, 0, 0, CLay.AbsoluteContentSize.Y + 30) end)

        if first then Scr.Visible = true; Btn.TextColor3 = Library.Theme.Accent; first = false end
        Btn.MouseButton1Click:Connect(function() 
            for _, t in pairs(tabs) do t.Scr.Visible = false; t.Tab.IsActive = false; Library.Utils.Tween(t.Btn, {TextColor3 = Library.Theme.TextDim}, 0.2) end
            Scr.Visible = true; Tab.IsActive = true; Library.Utils.Tween(Btn, {TextColor3 = Library.Theme.Accent}, 0.2) 
        end)
        table.insert(tabs, {Scr = Scr, Btn = Btn, Tab = Tab})

        table.insert(Library.ThemeUpdaters, function() Library.Utils.Tween(Btn, {TextColor3 = Tab.IsActive and Library.Theme.Accent or Library.Theme.TextDim}, 0.3); Library.Utils.Tween(Scr, {ScrollBarImageColor3 = Library.Theme.Accent}, 0.3) end)

        function Tab:CriarBotao(t, c) return Library.Components.Button(Scr, t, c) end
        function Tab:CriarToggle(t, d, c) return Library.Components.Toggle(Scr, t, d, c) end
        function Tab:CriarSlider(t, m, mx, d, c) return Library.Components.Slider(Scr, t, m, mx, d, c) end
        function Tab:CriarInput(t, d, c) return Library.Components.Input(Scr, t, d, c) end
        function Tab:CriarDropdown(t, o, c) return Library.Components.Dropdown(Scr, t, o, c) end
        function Tab:CriarLabel(t, c) 
            local L = Instance.new("TextLabel", Scr); L.Text = t; L.Size = UDim2.new(1, 0, 0, 30); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 14; L.TextYAlignment = Enum.TextYAlignment.Center
            table.insert(Library.ThemeUpdaters, function() if L.Parent and not c then Library.Utils.Tween(L, {TextColor3 = Library.Theme.Text}, 0.3) end end); return function(tx) L.Text = tx end 
        end
        
        function Tab:CriarPerfil()
            local C = Instance.new("Frame", Scr); C.Size = UDim2.new(1, -5, 0, 160); C.BackgroundColor3 = Color3.fromRGB(20,20,25); Library.Utils.AddCorner(C, 12); local CStrk = Library.Utils.AddStroke(C, Library.Theme.ItemBg, 1)
            local Av = Instance.new("ImageLabel", C); Av.Size = UDim2.new(0,70,0,70); Av.Position = UDim2.new(0,15,0,45); Av.BackgroundTransparency = 1; Library.Utils.AddCorner(Av, 100); local AStrk = Library.Utils.AddStroke(Av, Library.Theme.Accent, 2)
            
            --[CORREÇÃO AQUI]: Chamando Players:GetUserThumbnailAsync() do jeito nativo certo!
            task.spawn(function()
                local success, img = pcall(function()
                    return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                end)
                if success and img then
                    Av.Image = img
                end
            end)
            
            local function Info(t, v, y, c) local L = Instance.new("TextLabel", C); L.Text = t..": "..v; L.Size = UDim2.new(0.6,0,0,18); L.Position = UDim2.new(0,100,0,y); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left; L.TextYAlignment = Enum.TextYAlignment.Center end
            local fakeHWID = string.upper(string.sub(HttpService:GenerateGUID(false), 1, 14)); local fakeKey = "1NX-" .. string.upper(string.sub(HttpService:GenerateGUID(false), 1, 8))
            
            Info("USER", string.upper(Player.Name), 15, Library.Theme.Text); Info("ID", Player.UserId, 35, Library.Theme.TextDim); Info("STATUS", "VIP ACTIVE", 55, Library.Theme.Success); Info("HWID", fakeHWID, 90, Library.Theme.Warning); Info("KEY", fakeKey, 110, Library.Theme.Gold)
            table.insert(Library.ThemeUpdaters, function() if C.Parent then Library.Utils.Tween(CStrk, {Color = Library.Theme.ItemBg}, 0.3); Library.Utils.Tween(AStrk, {Color = Library.Theme.Accent}, 0.3) end end)
        end
        return Tab
    end
    return Win
end

function Library:CriarJanela(title) return Library.Window.Create(title) end
return Library
