local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Library = {}
local FAKE_HWID = "CRM-" .. string.upper(string.sub(HttpService:GenerateGUID(false), 1, 4)) .. "-" .. math.random(1000,9999)

Library.Theme = {
    Header = Color3.fromRGB(140, 0, 0), Background = Color3.fromRGB(12, 12, 14), Sidebar = Color3.fromRGB(18, 5, 5),
    Accent = Color3.fromRGB(220, 20, 60), Text = Color3.fromRGB(245, 245, 245), TextDim = Color3.fromRGB(160, 160, 160),
    ItemBg = Color3.fromRGB(28, 28, 32), Success = Color3.fromRGB(80, 255, 120), Gold = Color3.fromRGB(255, 215, 0)
}

Library.Utils = {}

function Library.Utils.AddCorner(o, r) 
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
    return c 
end

function Library.Utils.AddStroke(o, c, t) 
    local s = Instance.new("UIStroke")
    s.Color = c
    s.Thickness = t
    s.Parent = o
    return s 
end

function Library.Utils.Tween(o, p, t) 
    TweenService:Create(o, TweenInfo.new(t or 0.2), p):Play() 
end

function Library.Utils.MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local dragConnection
    dragConnection = UserInputService.InputChanged:Connect(function(input)
        if not obj or not obj.Parent then
            dragConnection:Disconnect()
            return
        end
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Library.Utils.Tween(obj, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

Library.Components = {}

function Library.Components.Button(parent, text, callback)
    local B = Instance.new("TextButton")
    B.Text = text
    B.Size = UDim2.new(1, -5, 0, 40)
    B.BackgroundColor3 = Library.Theme.ItemBg
    B.TextColor3 = Library.Theme.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 14
    Library.Utils.AddCorner(B, 8)
    Library.Utils.AddStroke(B, Library.Theme.Accent, 1)
    B.Parent = parent

    B.MouseButton1Click:Connect(function() 
        Library.Utils.Tween(B, {Size = UDim2.new(1, -10, 0, 40)}, 0.1)
        task.wait(0.1)
        Library.Utils.Tween(B, {Size = UDim2.new(1, -5, 0, 40)}, 0.1)
        if callback then pcall(callback) end 
    end)
    return function(t) B.Text = t end
end

function Library.Components.Toggle(parent, text, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 40)
    F.BackgroundTransparency = 1
    
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 24, 0, 24)
    B.Position = UDim2.new(0, 2, 0.5, -12)
    B.BackgroundColor3 = Library.Theme.ItemBg
    B.Text = ""
    Library.Utils.AddCorner(B, 6)
    local S = Library.Utils.AddStroke(B, Library.Theme.TextDim, 1.5)
    B.Parent = F
    
    local C = Instance.new("Frame")
    C.Size = UDim2.new(0, 14, 0, 14)
    C.AnchorPoint = Vector2.new(0.5, 0.5)
    C.Position = UDim2.new(0.5, 0, 0.5, 0)
    C.BackgroundColor3 = Library.Theme.Accent
    C.Visible = default
    Library.Utils.AddCorner(C, 4)
    C.Parent = B
    
    local L = Instance.new("TextLabel")
    L.Text = text
    L.Size = UDim2.new(1, -35, 1, 0)
    L.Position = UDim2.new(0, 35, 0, 0)
    L.BackgroundTransparency = 1
    L.TextColor3 = Library.Theme.Text
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F

    F.Parent = parent

    local On = default
    B.MouseButton1Click:Connect(function() 
        On = not On
        C.Visible = On
        S.Color = On and Library.Theme.Accent or Library.Theme.TextDim
        if callback then pcall(callback, On) end 
    end)
end
