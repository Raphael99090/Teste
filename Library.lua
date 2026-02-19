--[[
    ============================================================
    CRIMSON UI LIBRARY - V3.0 (MODULAR ARCHITECTURE)
    Structure: Single-File Module Pattern
    Modules: Theme | Utils | Components | Window
    Author: Raphael
    ============================================================
]]

-- [ 0. ROOT & SERVICES ]
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")
local RunService      = game:GetService("RunService")

local Player = Players.LocalPlayer
local Library = {
    Connections = {} -- Armazena conexões globais para limpeza
}

-- ==============================================================================
-- [ 1. MODULE: THEME (Design System) ]
-- ==============================================================================
Library.Theme = {
    Header     = Color3.fromRGB(140, 0, 0),    -- Vermelho Carmesim
    Background = Color3.fromRGB(12, 12, 14),   -- Preto Obsidiana
    Sidebar    = Color3.fromRGB(18, 5, 5),     -- Lateral Escura
    Accent     = Color3.fromRGB(220, 20, 60),  -- Crimson Vivo
    Text       = Color3.fromRGB(245, 245, 245),
    TextDim    = Color3.fromRGB(160, 160, 160),
    ItemBg     = Color3.fromRGB(28, 28, 32),
    Success    = Color3.fromRGB(80, 255, 120),
    Warning    = Color3.fromRGB(255, 200, 50),
    Error      = Color3.fromRGB(255, 80, 80),
    Gold       = Color3.fromRGB(255, 215, 0)
}

-- ==============================================================================
-- [ 2. MODULE: UTILS (Helper Functions) ]
-- ==============================================================================
Library.Utils = {}

function Library.Utils.AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function Library.Utils.AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = instance
    return stroke
end

function Library.Utils.Tween(instance, properties, time)
    TweenService:Create(instance, TweenInfo.new(time or 0.2), properties):Play()
end

function Library.Utils.MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    
    table.insert(Library.Connections, guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            local inputChanged
            inputChanged = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if inputChanged then inputChanged:Disconnect() end
                end
            end)
        end
    end))
    
    table.insert(Library.Connections, guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Library.Utils.Tween(guiObject, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.05)
        end
    end))
end
-- ==============================================================================
-- [ 3. MODULE: COMPONENTS (Building Blocks) ]
-- ==============================================================================
Library.Components = {}

function Library.Components.Button(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = "Button"
    Btn.Parent = parent
    Btn.Text = text
    Btn.Size = UDim2.new(1, -5, 0, 40)
    Btn.BackgroundColor3 = Library.Theme.ItemBg
    Btn.TextColor3 = Library.Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Library.Utils.AddCorner(Btn, 8)
    Library.Utils.AddStroke(Btn, Library.Theme.Accent, 1)
    
    Btn.MouseButton1Click:Connect(function()
        Library.Utils.Tween(Btn, {Size = UDim2.new(1, -10, 0, 40)}, 0.1)
        task.wait(0.1)
        Library.Utils.Tween(Btn, {Size = UDim2.new(1, -5, 0, 40)}, 0.1)
        if callback then pcall(callback) end
    end)
    
    return function(newText) Btn.Text = newText end
end

function Library.Components.Toggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Name = "Toggle"
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    
    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(0, 2, 0.5, -12)
    Box.BackgroundColor3 = Library.Theme.ItemBg
    Box.Text = ""
    Box.AutoButtonColor = false
    Library.Utils.AddCorner(Box, 6)
    local Stroke = Library.Utils.AddStroke(Box, Library.Theme.TextDim, 1.5)
    
    local Check = Instance.new("Frame", Box)
    Check.Size = UDim2.new(0, 14, 0, 14)
    Check.AnchorPoint = Vector2.new(0.5, 0.5)
    Check.Position = UDim2.new(0.5, 0, 0.5, 0)
    Check.BackgroundColor3 = Library.Theme.Accent
    Check.Visible = default
    Library.Utils.AddCorner(Check, 4)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Library.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local isActive = default
    Box.MouseButton1Click:Connect(function()
        isActive = not isActive
        Check.Visible = isActive
        Stroke.Color = isActive and Library.Theme.Accent or Library.Theme.TextDim
        if callback then pcall(callback, isActive) end
    end)
end

function Library.Components.Slider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Name = "Slider"
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, -50, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Library.Theme.TextDim
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.Text = tostring(default)
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -45, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Library.Theme.Text
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 12
    
    local BarBg = Instance.new("TextButton", Frame)
    BarBg.Text = ""
    BarBg.Size = UDim2.new(1, -5, 0, 6)
    BarBg.Position = UDim2.new(0, 0, 0, 30)
    BarBg.BackgroundColor3 = Library.Theme.ItemBg
    BarBg.AutoButtonColor = false
    Library.Utils.AddCorner(BarBg, 100)
    
    local Fill = Instance.new("Frame", BarBg)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Library.Theme.Accent
    Library.Utils.AddCorner(Fill, 100)
    
    local isDragging = false
    
    BarBg.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end 
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local scale = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + ((max - min) * scale) * 10) / 10
            
            Library.Utils.Tween(Fill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.05)
            ValueLabel.Text = tostring(value)
            if callback then pcall(callback, value) end
        end
    end)
end

function Library.Components.Input(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Name = "Input"
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Library.Theme.TextDim
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Bg = Instance.new("Frame", Frame)
    Bg.Size = UDim2.new(1, -5, 0, 30)
    Bg.Position = UDim2.new(0, 0, 0, 20)
    Bg.BackgroundColor3 = Library.Theme.ItemBg
    Library.Utils.AddCorner(Bg, 8)
    
    local Box = Instance.new("TextBox", Bg)
    Box.Text = tostring(default or "")
    Box.Size = UDim2.new(1, -10, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.TextColor3 = Library.Theme.Text
    Box.Font = Enum.Font.GothamBold
    Box.TextXAlignment = Enum.TextXAlignment.Left
    
    Box.FocusLost:Connect(function()
        if callback then pcall(callback, Box.Text) end
    end)
end

function Library.Components.Dropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Name = "Dropdown"
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 5
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Library.Theme.TextDim
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local MainBtn = Instance.new("TextButton", Frame)
    MainBtn.Text = options[1] or "Select..."
    MainBtn.Size = UDim2.new(1, -5, 0, 30)
    MainBtn.Position = UDim2.new(0, 0, 0, 20)
    MainBtn.BackgroundColor3 = Library.Theme.ItemBg
    MainBtn.TextColor3 = Library.Theme.Text
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.ZIndex = 6
    Library.Utils.AddCorner(MainBtn, 6)
    
    local ListFrame = Instance.new("ScrollingFrame", MainBtn)
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.Position = UDim2.new(0, 0, 1, 5)
    ListFrame.BackgroundColor3 = Library.Theme.ItemBg
    ListFrame.Visible = false
    ListFrame.ZIndex = 10
    Library.Utils.AddCorner(ListFrame, 6)
    Library.Utils.AddStroke(ListFrame, Library.Theme.Header, 1)
    
    local ListLayout = Instance.new("UIListLayout", ListFrame)
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local isOpen = false
    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ListFrame.Visible = isOpen
        Library.Utils.Tween(ListFrame, {Size = UDim2.new(1, 0, 0, isOpen and math.min(#options * 30, 120) or 0)}, 0.2)
    end)
    
    for _, option in pairs(options) do
        local OptBtn = Instance.new("TextButton", ListFrame)
        OptBtn.Text = option
        OptBtn.Size = UDim2.new(1, -10, 0, 25)
        OptBtn.BackgroundTransparency = 1
        OptBtn.TextColor3 = Library.Theme.TextDim
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.ZIndex = 11
        
        OptBtn.MouseButton1Click:Connect(function()
            isOpen = false
            MainBtn.Text = option
            Library.Utils.Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            ListFrame.Visible = false
            if callback then pcall(callback, option) end
        end)
    end
end
-- ==============================================================================
-- [ 4. MODULE: WINDOW (The Main Interface) ]
-- ==============================================================================
Library.Window = {}

function Library.Window.Create(title)
    -- Limpeza Inicial
    if CoreGui:FindFirstChild("CrimsonUI") then CoreGui["CrimsonUI"]:Destroy() end
    if Player.PlayerGui:FindFirstChild("CrimsonUI") then Player.PlayerGui["CrimsonUI"]:Destroy() end

    -- GUI Base
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrimsonUI"
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
    ScreenGui.ResetOnSpawn = false

    -- Container de Notificações
    local NotifContainer = Instance.new("Frame", ScreenGui)
    NotifContainer.Name = "Notifications"
    NotifContainer.Size = UDim2.new(0, 300, 1, 0)
    NotifContainer.Position = UDim2.new(1, -320, 0, 50)
    NotifContainer.BackgroundTransparency = 1
    
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifLayout.Padding = UDim.new(0, 10)

    -- Função Interna de Notificação
    local function Notify(titleText, descText, duration, type)
        local color = (type == "error" and Library.Theme.Error) or (type == "warn" and Library.Theme.Warning) or Library.Theme.Accent
        local F = Instance.new("Frame", NotifContainer)
        F.Size = UDim2.new(1, 0, 0, 60); F.BackgroundColor3 = Library.Theme.Background
        Library.Utils.AddCorner(F, 6); Library.Utils.AddStroke(F, color, 1)
        
        local T = Instance.new("TextLabel", F); T.Text = titleText
        T.Size = UDim2.new(1, -10, 0, 20); T.Position = UDim2.new(0, 10, 0, 5)
        T.BackgroundTransparency = 1; T.TextColor3 = color; T.Font = Enum.Font.GothamBlack; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left
        
        local D = Instance.new("TextLabel", F); D.Text = descText
        D.Size = UDim2.new(1, -10, 0, 30); D.Position = UDim2.new(0, 10, 0, 25)
        D.BackgroundTransparency = 1; D.TextColor3 = Library.Theme.Text; D.Font = Enum.Font.Gotham; D.TextSize = 12; D.TextXAlignment = Enum.TextXAlignment.Left; D.TextWrapped = true
        
        F.Position = UDim2.new(1, 50, 0, 0)
        Library.Utils.Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        
        task.spawn(function()
            task.wait(duration or 3)
            Library.Utils.Tween(F, {Position = UDim2.new(1, 50, 0, 0)}, 0.5)
            task.wait(0.5)
            F:Destroy()
        end)
    end

    -- Bubble (Minimizado)
    local Bubble = Instance.new("TextButton", ScreenGui)
    Bubble.Name = "Bubble"
    Bubble.Size = UDim2.new(0, 50, 0, 50); Bubble.Position = UDim2.new(0, 50, 0, 100)
    Bubble.BackgroundColor3 = Library.Theme.Header; Bubble.Text = "CRM"; Bubble.TextColor3 = Library.Theme.Text; Bubble.Font = Enum.Font.GothamBlack
    Bubble.Visible = false
    Library.Utils.AddCorner(Bubble, 100); Library.Utils.AddStroke(Bubble, Library.Theme.Text, 2)
    Library.Utils.MakeDraggable(Bubble)

    -- Main Frame
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Library.Theme.Background; Main.ClipsDescendants = true
    Library.Utils.AddCorner(Main, 10); Library.Utils.AddStroke(Main, Library.Theme.Header, 2)
    Library.Utils.MakeDraggable(Main)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Library.Theme.Header; Header.BorderSizePixel = 0
    
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Text = "  " .. string.upper(title)
    TitleLbl.Size = UDim2.new(0.7, 0, 1, 0); TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = Library.Theme.Text; TitleLbl.Font = Enum.Font.GothamBlack; TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0)
    MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Library.Theme.Text; MinBtn.TextSize = 22; MinBtn.Font = Enum.Font.GothamBold

    -- Lógica Minimizar
    MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; Bubble.Visible = true end)
    Bubble.MouseButton1Click:Connect(function() Bubble.Visible = false; Main.Visible = true end)

    -- Sidebar & Content
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 65, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Sidebar.BorderSizePixel = 0
    local SideList = Instance.new("UIListLayout", Sidebar); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideList.Padding = UDim.new(0, 10)
    local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0, 10)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -75, 1, -50); Content.Position = UDim2.new(0, 70, 0, 45); Content.BackgroundTransparency = 1
  -- Objeto de Janela para Retorno
    local WindowObj = {}
    local FirstTab = true
    local Tabs = {}

    function WindowObj:CriarAba(icon, name)
        local TabObj = {}
        
        -- Botão Sidebar
        local SideBtn = Instance.new("TextButton", Sidebar)
        SideBtn.Text = icon; SideBtn.Size = UDim2.new(0, 45, 0, 45); SideBtn.BackgroundTransparency = 1
        SideBtn.TextColor3 = Library.Theme.TextDim; SideBtn.TextSize = 24
        
        -- Frame Scroll
        local Scroll = Instance.new("ScrollingFrame", Content)
        Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.Visible = false
        Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Library.Theme.Accent
        
        local List = Instance.new("UIListLayout", Scroll); List.Padding = UDim.new(0, 6); List.SortOrder = Enum.SortOrder.LayoutOrder
        local Pad = Instance.new("UIPadding", Scroll); Pad.PaddingTop = UDim.new(0, 5); Pad.PaddingBottom = UDim.new(0, 5)

        if FirstTab then Scroll.Visible = true; SideBtn.TextColor3 = Library.Theme.Accent; FirstTab = false end
        
        SideBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Frame.Visible = false; t.Btn.TextColor3 = Library.Theme.TextDim end
            Scroll.Visible = true; SideBtn.TextColor3 = Library.Theme.Accent
        end)
        table.insert(Tabs, {Frame = Scroll, Btn = SideBtn})

        -- Mapping Component Functions to Tab Object
        function TabObj:CriarBotao(t, c) return Library.Components.Button(Scroll, t, c) end
        function TabObj:CriarToggle(t, d, c) return Library.Components.Toggle(Scroll, t, d, c) end
        function TabObj:CriarSlider(t, min, max, d, c) return Library.Components.Slider(Scroll, t, min, max, d, c) end
        function TabObj:CriarInput(t, d, c) return Library.Components.Input(Scroll, t, d, c) end
        function TabObj:CriarDropdown(t, o, c) return Library.Components.Dropdown(Scroll, t, o, c) end
        
        -- Funções Especiais da Aba
        function TabObj:CriarLabel(text, color)
            local L = Instance.new("TextLabel", Scroll); L.Text = text; L.Size = UDim2.new(1, 0, 0, 30)
            L.BackgroundTransparency = 1; L.TextColor3 = color or Library.Theme.Text
            L.Font = Enum.Font.GothamBold; L.TextSize = 14
            return function(t) L.Text = t end
        end

        function TabObj:CriarPerfil()
            local C = Instance.new("Frame", Scroll); C.Size = UDim2.new(1, -5, 0, 160); C.BackgroundColor3 = Color3.fromRGB(20,20,25)
            Library.Utils.AddCorner(C, 12); Library.Utils.AddStroke(C, Library.Theme.ItemBg, 1)
            local Av = Instance.new("ImageLabel", C); Av.Size=UDim2.new(0,70,0,70); Av.Position=UDim2.new(0,15,0,45); Av.BackgroundTransparency=1
            Library.Utils.AddCorner(Av, 100); Library.Utils.AddStroke(Av, Library.Theme.Accent, 2)
            task.spawn(function() Av.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
            
            local function Info(t, v, y, color)
                local L = Instance.new("TextLabel", C); L.Text=t..": "..v; L.Size=UDim2.new(0.6,0,0,18); L.Position=UDim2.new(0,100,0,y); L.BackgroundTransparency=1
                L.TextColor3=color or Library.Theme.Text; L.Font=Enum.Font.GothamBold; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left
            end
            Info("USER", string.upper(Player.Name), 20, Library.Theme.Text)
            Info("ID", Player.UserId, 40, Library.Theme.TextDim)
            Info("ACCESS", "LIFETIME", 60, Library.Theme.Gold)
            Info("SESSION", "CRM-"..math.random(1000,9999), 80, Library.Theme.Accent)
            Info("VER", "3.0 PRO", 100, Library.Theme.TextDim)
            Info("STATUS", "SECURE", 120, Library.Theme.Success)
        end

        return TabObj
    end

    -- Expose Notify globally
    function Library:Notificar(t, txt, time, type) Notify(t, txt, time, type) end

    return WindowObj
end

-- [ 5. EXPORT ]
return Library
