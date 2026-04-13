local SpyChat = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

SpyChat.Enabled = false
SpyChat.Connections = {}

function SpyChat:Toggle(state)
    self.Enabled = state
    
    if state then
        -- Cria a Interface do Chat Espião
        local gui = Instance.new("ScreenGui")
        gui.Name = "InxiterSpyChat"
        gui.ResetOnSpawn = false
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
        self.Gui = gui

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 350, 0, 200)
        frame.Position = UDim2.new(0, 20, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BackgroundTransparency = 0.2
        frame.Active = true
        frame.Draggable = true -- Permite arrastar o chat pela tela
        
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(220, 20, 60)
        stroke.Thickness = 1.5

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = " 🕵️ CHAT ESPIÃO GLOBAL"
        title.TextColor3 = Color3.fromRGB(220, 20, 60)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left

        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1, -10, 1, -35)
        scroll.Position = UDim2.new(0, 5, 0, 30)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 3
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        
        -- Auto-scroll
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
            scroll.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
        end)

        self.Scroll = scroll

        -- Função que captura a mensagem e bota na tela
        local function OnMessage(player, msg)
            if not self.Enabled then return end
            local msgLabel = Instance.new("TextLabel", scroll)
            msgLabel.Size = UDim2.new(1, 0, 0, 20)
            msgLabel.BackgroundTransparency = 1
            msgLabel.RichText = true
            msgLabel.Text = "<b>["..player.Name.."]:</b> " .. msg
            msgLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
            msgLabel.Font = Enum.Font.Gotham
            msgLabel.TextSize = 13
            msgLabel.TextXAlignment = Enum.TextXAlignment.Left
            msgLabel.TextWrapped = true
            
            -- Ajusta altura automaticamente se a mensagem for grande
            msgLabel.Size = UDim2.new(1, 0, 0, msgLabel.TextBounds.Y + 5)
        end

        -- Conecta a todos os jogadores que já estão no jogo
        for _, player in pairs(Players:GetPlayers()) do
            table.insert(self.Connections, player.Chatted:Connect(function(msg) OnMessage(player, msg) end))
        end

        -- Conecta aos jogadores novos que entrarem
        table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
            table.insert(self.Connections, player.Chatted:Connect(function(msg) OnMessage(player, msg) end))
        end))

    else
        -- Desliga tudo
        if self.Gui then self.Gui:Destroy() end
        for _, conn in pairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
    end
end

return SpyChat
