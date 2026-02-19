--[[
    CRIMSON UI LIBRARY - V3.1 (COMPATIBILITY FIX)
    Fix: Exposed 'CriarJanela' directly to root table.
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
    local Box = Instance.new("TextButton", Frame); Box.Size = UDim2.new(0, 24, 0, 24); Box.Position = UDim2.new(0, 2, 0.5, -12); Box.BackgroundColor3 = Library.Theme.ItemBg; Box.Text = ""; Box.AutoButtonColor = false
    Library.Utils.AddCorner(Box, 6); local Stroke = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    local Check = Instance.new("Frame", Box); Check.Size = UDim2.new(0, 14, 0, 14); Check.AnchorPoint = Vector2.new(0.5, 0.5); Check.Position = UDim2.new(0.5, 0, 0.5, 0); Check.BackgroundColor3 = Library.Theme.Accent; Check.Visible = default
    Library.Utils.AddCorner(Check, 4)
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, -35, 1, 0); Label.Position = UDim2.new(0, 35, 0, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.Text; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local isActive = default
    Box.MouseButton1Click:Connect(function()
        isActive = not isActive
        Check.Visible = isActive
        Stroke.Color = isActive and Library.Theme.Accent or Library.Theme.TextDim
        if callback then pcall(callback, isActive) end
    end)
end

function Library.Components.Slider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 50); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, -50, 0, 20); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.TextDim; Label.Font = Enum.Font.Gotham; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Value = Instance.new("TextLabel", Frame); Value.Text = tostring(default); Value.Size = UDim2.new(0, 40, 0, 20); Value.Position = UDim2.new(1, -45, 0, 0); Value.BackgroundTransparency = 1; Value.TextColor3 = Library.Theme.Text; Value.Font = Enum.Font.GothamBold; Value.TextSize = 12
    local BarBg = Instance.new("TextButton", Frame); BarBg.Text = ""; BarBg.Size = UDim2.new(1, -5, 0, 6); BarBg.Position = UDim2.new(0, 0, 0, 30); BarBg.BackgroundColor3 = Library.Theme.ItemBg; BarBg.AutoButtonColor = false; Library.Utils.AddCorner(BarBg, 100)
    local Fill = Instance.new("Frame", BarBg); Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = Library.Theme.Accent; Library.Utils.AddCorner(Fill, 100)
    
    local isDragging = false
    BarBg.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local scale = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + ((max - min) * scale) * 10) / 10
            Library.Utils.Tween(Fill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.05)
            Value.Text = tostring(val)
            if callback then pcall(callback, val) end
        end
    end)
end

function Library.Components.Input(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 50); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, 0, 0, 20); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.TextDim; Label.Font = Enum.Font.Gotham; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Bg = Instance.new("Frame", Frame); Bg.Size = UDim2.new(1, -5, 0, 30); Bg.Position = UDim2.new(0, 0, 0, 20); Bg.BackgroundColor3 = Library.Theme.ItemBg; Library.Utils.AddCorner(Bg, 8)
    local Box = Instance.new("TextBox", Bg); Box.Text = tostring(default or ""); Box.Size = UDim2.new(1, -10, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0); Box.BackgroundTransparency = 1; Box.TextColor3 = Library.Theme.Text; Box.Font = Enum.Font.GothamBold; Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() if callback then pcall(callback, Box.Text) end end)
end

function Library.Components.Dropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 60); Frame.BackgroundTransparency = 1; Frame.ZIndex = 5
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, 0, 0, 20); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.TextDim; Label.Font = Enum.Font.Gotham; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Btn = Instance.new("TextButton", Frame); Btn.Text = options[1] or "..."; Btn.Size = UDim2.new(1, -5, 0, 30); Btn.Position = UDim2.new(0, 0, 0, 20); Btn.BackgroundColor3 = Library.Theme.ItemBg; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.ZIndex = 6; Library.Utils.AddCorner(Btn, 6)
    
    local Scroll = Instance.new("ScrollingFrame", Btn); Scroll.Size = UDim2.new(1, 0, 0, 0); Scroll.Position = UDim2.new(0, 0, 1, 5); Scroll.BackgroundColor3 = Library.Theme.ItemBg; Scroll.Visible = false; Scroll.ZIndex = 10; Library.Utils.AddCorner(Scroll, 6); Library.Utils.AddStroke(Scroll, Library.Theme.Header, 1)
    local List = Instance.new("UIListLayout", Scroll); List.Padding = UDim.new(0, 5); List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local isOpen = false
    Btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        Scroll.Visible = isOpen
        Library.Utils.Tween(Scroll, {Size = UDim2.new(1, 0, 0, isOpen and math.min(#options * 30, 120) or 0)}, 0.2)
    end)
    
    for _, opt in pairs(options) do
        local Item = Instance.new("TextButton", Scroll); Item.Text = opt; Item.Size = UDim2.new(1, -10, 0, 25); Item.BackgroundTransparency = 1; Item.TextColor3 = Library.Theme.TextDim; Item.Font = Enum.Font.Gotham; Item.ZIndex = 11
        Item.MouseButton1Click:Connect(function()
            isOpen = false; Btn.Text = opt; Library.Utils.Tween(Scroll, {Size = UDim2.new(1, 0, 0, 0)}, 0.2); task.wait(0.2); Scroll.Visible = false
            if callback then pcall(callback, opt) end
        end)
    end
end

-- [ 4. WINDOW ]
-- CORREÇÃO PRINCIPAL: Expus a função CriarJanela diretamente na tabela Library
function Library:CriarJanela(title)
    local WindowObj = {}
    
    if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
    if Player.PlayerGui:FindFirstChild("CrimsonUI") then Player.PlayerGui["CrimsonUI"]:Destroy() end

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "CrimsonUI"
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
    
    local NotifContainer = Instance.new("Frame", ScreenGui); NotifContainer.Size = UDim2.new(0, 300, 1, 0); NotifContainer.Position = UDim2.new(1, -320, 0, 50); NotifContainer.BackgroundTransparency = 1
    local NotifList = Instance.new("UIListLayout", NotifContainer); NotifList.Padding = UDim.new(0, 10); NotifList.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Bubble
    local Bubble = Instance.new("TextButton", ScreenGui); Bubble.Size = UDim2.new(0, 50, 0, 50); Bubble.Position = UDim2.new(0, 50, 0, 100); Bubble.BackgroundColor3 = Library.Theme.Header; Bubble.Text = "CRM"; Bubble.TextColor3 = Library.Theme.Text; Bubble.Font = Enum.Font.GothamBlack; Bubble.Visible = false
    Library.Utils.AddCorner(Bubble, 100); Library.Utils.AddStroke(Bubble, Library.Theme.Text, 2); Library.Utils.MakeDraggable(Bubble)

    -- Main
    local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.BackgroundColor3 = Library.Theme.Background; Main.ClipsDescendants = true
    Library.Utils.AddCorner(Main, 10); Library.Utils.AddStroke(Main, Library.Theme.Header, 2); Library.Utils.MakeDraggable(Main)

    -- Header
    local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Library.Theme.Header; Header.BorderSizePixel = 0
    local Title = Instance.new("TextLabel", Header); Title.Text = "  " .. string.upper(title); Title.Size = UDim2.new(0.7, 0, 1, 0); Title.BackgroundTransparency = 1; Title.TextColor3 = Library.Theme.Text; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local MinBtn = Instance.new("TextButton", Header); MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Library.Theme.Text; MinBtn.TextSize = 22; MinBtn.Font = Enum.Font.GothamBold
    MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; Bubble.Visible = true end)
    Bubble.MouseButton1Click:Connect(function() Bubble.Visible = false; Main.Visible = true end)

    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 65, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40); Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Sidebar.BorderSizePixel = 0
    local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -75, 1, -50); Content.Position = UDim2.new(0, 70, 0, 45); Content.BackgroundTransparency = 1
    
    local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0, 10); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0, 10)

    -- Abas
    local Tabs = {}; local FirstTab = true
    function WindowObj:CriarAba(icon)
        local TabObj = {}
        local Btn = Instance.new("TextButton", Sidebar); Btn.Text = icon; Btn.Size = UDim2.new(0, 45, 0, 45); Btn.BackgroundTransparency = 1; Btn.TextColor3 = Library.Theme.TextDim; Btn.TextSize = 24
        
        local Scroll = Instance.new("ScrollingFrame", Content); Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.Visible = false; Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Library.Theme.Accent
        local List = Instance.new("UIListLayout", Scroll); List.Padding = UDim.new(0, 6); List.SortOrder = Enum.SortOrder.LayoutOrder
        local Pad = Instance.new("UIPadding", Scroll); Pad.PaddingTop = UDim.new(0, 5); Pad.PaddingBottom = UDim.new(0, 5)

        if FirstTab then Scroll.Visible = true; Btn.TextColor3 = Library.Theme.Accent; FirstTab = false end
        
        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Frame.Visible = false; t.Btn.TextColor3 = Library.Theme.TextDim end
            Scroll.Visible = true; Btn.TextColor3 = Library.Theme.Accent
        end)
        table.insert(Tabs, {Frame = Scroll, Btn = Btn})

        function TabObj:CriarBotao(t, c) return Library.Components.Button(Scroll, t, c) end
        function TabObj:CriarToggle(t, d, c) return Library.Components.Toggle(Scroll, t, d, c) end
        function TabObj:CriarSlider(t, min, max, d, c) return Library.Components.Slider(Scroll, t, min, max, d, c) end
        function TabObj:CriarInput(t, d, c) return Library.Components.Input(Scroll, t, d, c) end
        function TabObj:CriarDropdown(t, o, c) return Library.Components.Dropdown(Scroll, t, o, c) end
        function TabObj:CriarLabel(t, c) 
            local L = Instance.new("TextLabel", Scroll); L.Text = t; L.Size = UDim2.new(1, 0, 0, 30); L.BackgroundTransparency = 1; L.TextColor3 = c or Library.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 14
            return function(tx) L.Text = tx end 
        end
        function TabObj:CriarPerfil()
            local C = Instance.new("Frame", Scroll); C.Size = UDim2.new(1, -5, 0, 160); C.BackgroundColor3 = Color3.fromRGB(20,20,25)
            Library.Utils.AddCorner(C, 12); Library.Utils.AddStroke(C, Library.Theme.ItemBg, 1)
            local Av = Instance.new("ImageLabel", C); Av.Size=UDim2.new(0,70,0,70); Av.Position=UDim2.new(0,15,0,45); Av.BackgroundTransparency=1
            Library.Utils.AddCorner(Av, 100); Library.Utils.AddStroke(Av, Library.Theme.Accent, 2)
            task.spawn(function() Av.Image = Players.LocalPlayer:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
            local function Info(t, v, y, c) local L = Instance.new("TextLabel", C); L.Text=t..": "..v; L.Size=UDim2.new(0.6,0,0,18); L.Position=UDim2.new(0,100,0,y); L.BackgroundTransparency=1; L.TextColor3=c or Library.Theme.Text; L.Font=Enum.Font.GothamBold; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left end
            Info("USER", string.upper(Player.Name), 20, Library.Theme.Text); Info("ID", Player.UserId, 40, Library.Theme.TextDim); Info("STATUS", "VIP ACTIVE", 60, Library.Theme.Success)
        end
        return TabObj
    end

    function Library:Notificar(t, d, time)
        local F = Instance.new("Frame", NotifContainer); F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundColor3 = Library.Theme.Background; Library.Utils.AddCorner(F, 6); Library.Utils.AddStroke(F, Library.Theme.Accent, 1)
        local T = Instance.new("TextLabel", F); T.Text = t; T.Size = UDim2.new(1, -10, 0, 20); T.Position = UDim2.new(0, 10, 0, 5); T.BackgroundTransparency = 1; T.TextColor3 = Library.Theme.Accent; T.Font = Enum.Font.GothamBlack; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left
        local D = Instance.new("TextLabel", F); D.Text = d; D.Size = UDim2.new(1, -10, 0, 30); D.Position = UDim2.new(0, 10, 0, 25); D.BackgroundTransparency = 1; D.TextColor3 = Library.Theme.Text; D.Font = Enum.Font.Gotham; D.TextSize = 12; D.TextXAlignment = Enum.TextXAlignment.Left; D.TextWrapped = true
        F.Position = UDim2.new(1, 50, 0, 0); Library.Utils.Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function() task.wait(time or 3); Library.Utils.Tween(F, {Position = UDim2.new(1, 50, 0, 0)}, 0.5); task.wait(0.5); F:Destroy() end)
    end

    return WindowObj
end

return Library
