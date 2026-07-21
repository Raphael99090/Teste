local SpyChat = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

SpyChat.Enabled = false
SpyChat.Connections = {}
SpyChat.Gui = nil

-- [FUNÇÃO DE ARRASTE MANUAL - MELHOR QUE .DRAGGABLE]
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function SpyChat:AddMessage(playerName, msg, isWhisper)
    if not self.Gui or not self.Enabled then return end
    
    local scroll = self.Gui:FindFirstChild("Main"):FindFirstChild("Scroll")
    local timeStr = os.date("%H:%M:%S")
    local color = isWhisper and "#FF8C00" or "#DCDCDC" -- Laranja para sussurros
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name = "Message"
    msgLabel.Parent = scroll
    msgLabel.Size = UDim2.new(1, -10, 0, 20)
    msgLabel.BackgroundTransparency = 1
    msgLabel.RichText = true
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextSize = 13
    msgLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    
    -- Formatação bonita: [Hora] [Nome]: Mensagem
    msgLabel.Text = string.format(
        "<font color='#888888'>[%s]</font> <font color='#DC143C'><b>%s:</b></font> <font color='%s'>%s</font>",
        timeStr, playerName, color, msg
    )
    
    -- Ajusta o tamanho da label baseado no texto
    msgLabel.Size = UDim2.new(1, -10, 0, msgLabel.TextBounds.Y + 5)
end

function SpyChat:Toggle(state)
    self.Enabled = state
    
    -- Limpa conexões anteriores
    for _, conn in pairs(self.Connections) do conn:Disconnect() end
    self.Connections = {}

    if state then
        -- [CRIAÇÃO DA UI]
        local gui = Instance.new("ScreenGui")
        gui.Name = "InxiterSpyChat"
        gui.DisplayOrder = 10
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
        self.Gui = gui

        local main = Instance.new("Frame", gui)
        main.Name = "Main"
        main.Size = UDim2.new(0, 360, 0, 220)
        main.Position = UDim2.new(0, 50, 0.5, -110)
        main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
        main.BorderSizePixel = 0
        main.Active = true
        
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", main)
        stroke.Color = Color3.fromRGB(220, 20, 60)
        stroke.Thickness = 1.8

        -- Barra de Título (Handle para arrastar)
        local titleBar = Instance.new("Frame", main)
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundTransparency = 1
        
        local title = Instance.new("TextLabel", titleBar)
        title.Size = UDim2.new(1, -10, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.Text = "🕵️ SPY CHAT (LOGS GLOBAIS)"
        title.TextColor3 = Color3.fromRGB(220, 20, 60)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.BackgroundTransparency = 1

        local scroll = Instance.new("ScrollingFrame", main)
        scroll.Name = "Scroll"
        scroll.Size = UDim2.new(1, -15, 1, -45)
        scroll.Position = UDim2.new(0, 10, 0, 35)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = Color3.fromRGB(220, 20, 60)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)

        MakeDraggable(main, titleBar)

        -- [MONITORAMENTO DE CHAT]
        
        -- 1. Sistema Legado (Jogos Antigos)
        local function setupPlayer(p)
            local conn = p.Chatted:Connect(function(msg)
                self:AddMessage(p.Name, msg, false)
            end)
            table.insert(self.Connections, conn)
        end

        for _, p in pairs(Players:GetPlayers()) do setupPlayer(p) end
        table.insert(self.Connections, Players.PlayerAdded:Connect(setupPlayer))

        -- 2. Sistema Novo (TextChatService)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local conn = TextChatService.MessageReceived:Connect(function(textResult)
                if textResult.TextSource then
                    local p = Players:GetPlayerByUserId(textResult.TextSource.UserId)
                    if p and p ~= Players.LocalPlayer then
                        self:AddMessage(p.Name, textResult.Text, false)
                    end
                end
            end)
            table.insert(self.Connections, conn)
        end

    else
        -- [DESLIGAR]
        if self.Gui then self.Gui:Destroy(); self.Gui = nil end
    end
end

return SpyChat
