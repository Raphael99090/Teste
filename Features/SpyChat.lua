local SpyChat = {}
local Players = game:GetService("Players"); local CoreGui = game:GetService("CoreGui")

SpyChat.Enabled = false; SpyChat.Connections = {}

function SpyChat:Toggle(state)
    self.Enabled = state
    if state then
        local gui = Instance.new("ScreenGui"); gui.Name = "InxiterSpyChat"; gui.ResetOnSpawn = false
        pcall(function() gui.Parent = CoreGui end); if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
        self.Gui = gui

        local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 350, 0, 200); frame.Position = UDim2.new(0, 20, 0.5, -100); frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); frame.BackgroundTransparency = 0.2; frame.Active = true; frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8); local stroke = Instance.new("UIStroke", frame); stroke.Color = Color3.fromRGB(220, 20, 60); stroke.Thickness = 1.5

        local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 25); title.BackgroundTransparency = 1; title.Text = " 🕵️ CHAT ESPIÃO GLOBAL"; title.TextColor3 = Color3.fromRGB(220, 20, 60); title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left
        local scroll = Instance.new("ScrollingFrame", frame); scroll.Size = UDim2.new(1, -10, 1, -35); scroll.Position = UDim2.new(0, 5, 0, 30); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        local layout = Instance.new("UIListLayout", scroll); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 2)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y); scroll.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y) end)

        local function OnMessage(player, msg)
            if not self.Enabled then return end
            -- [MELHORIA]: Adicionado o horário em que a pessoa mandou a mensagem!
            local timeStr = os.date("%H:%M:%S")
            local msgLabel = Instance.new("TextLabel", scroll); msgLabel.Size = UDim2.new(1, 0, 0, 20); msgLabel.BackgroundTransparency = 1; msgLabel.RichText = true
            msgLabel.Text = "<b><font color='#888888'>["..timeStr.."]</font>["..player.Name.."]:</b> " .. msg
            msgLabel.TextColor3 = Color3.fromRGB(245, 245, 245); msgLabel.Font = Enum.Font.Gotham; msgLabel.TextSize = 13; msgLabel.TextXAlignment = Enum.TextXAlignment.Left; msgLabel.TextWrapped = true
            msgLabel.Size = UDim2.new(1, 0, 0, msgLabel.TextBounds.Y + 5)
        end

        for _, p in pairs(Players:GetPlayers()) do table.insert(self.Connections, p.Chatted:Connect(function(m) OnMessage(p, m) end)) end
        table.insert(self.Connections, Players.PlayerAdded:Connect(function(p) table.insert(self.Connections, p.Chatted:Connect(function(m) OnMessage(p, m) end)) end))
    else
        if self.Gui then self.Gui:Destroy() end; for _, conn in pairs(self.Connections) do conn:Disconnect() end; self.Connections = {}
    end
end
return SpyChat