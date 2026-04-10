--[[
    1NXITER v3.0 - MÓDULO MISC
    
    ✓ Chat Spy        — Ver mensagens de todos no console
    ✓ Keybinds        — Atalhos de teclado (F = Aim, G = ESP)
    ✓ Rejoin          — Reconectar no mesmo servidor
    ✓ Watermark       — Info na tela (versão, fps, ping)
    ✓ Player List     — Listar todos os players
    ✓ Copy Username   — Copiar nome ao clipboard
]]

local Misc = {}
local Settings = nil
local Utils = nil
local ChatSpyConn = nil
local Drawings = {}
local WatermarkTime = 0

function Misc.init(settings, utils)
    Settings = settings
    Utils = utils
    Misc._createWatermark()
end

-- ═══════════════════════════════════════════════
-- 1. CHAT SPY (ver mensagens de todos)
-- ═══════════════════════════════════════════════

function Misc.toggleChatSpy(enabled)
    if enabled then
        if ChatSpyConn then return end
        
        pcall(function()
            local chatEvents = Settings.Services.ReplicatedStorage
                :FindFirstChild("DefaultChatSystemChatEvents")
            
            if chatEvents then
                local onMessage = chatEvents
                    :FindFirstChild("OnMessageDoneFiltering")
                if onMessage then
                    ChatSpyConn = onMessage.OnClientEvent:Connect(
                        function(data)
                            pcall(function()
                                local sender = data.FromSpeaker
                                local message = data.Message
                                local channel = data.OriginalChannel 
                                    or "All"
                                
                                if sender == Settings.Services
                                    .LocalPlayer.Name then return end
                                
                                local prefix = ""
                                if channel == "Team" then
                                    prefix = "[TEAM] "
                                elseif channel ~= "All" then
                                    prefix = "[" .. channel .. "] "
                                end
                                
                                print("[CHAT SPY] " .. prefix 
                                    .. sender .. ": " .. message)
                            end)
                        end
                    )
                    table.insert(Settings.Connections, ChatSpyConn)
                end
            end
            
            -- Método alternativo: PlayerChatted
            if not ChatSpyConn then
                for _, plr in ipairs(
                    Settings.Services.Players:GetPlayers()
                ) do
                    if plr ~= Settings.Services.LocalPlayer then
                        pcall(function()
                            local conn = plr.Chatted:Connect(
                                function(msg)
                                    print("[CHAT SPY] " 
                                        .. plr.Name .. ": " .. msg)
                                end
                            )
                            table.insert(Settings.Connections, conn)
                        end)
                    end
                end
                
                ChatSpyConn = Settings.Services.Players
                    .PlayerAdded:Connect(function(plr)
                        pcall(function()
                            local conn = plr.Chatted:Connect(
                                function(msg)
                                    print("[CHAT SPY] " 
                                        .. plr.Name .. ": " .. msg)
                                end
                            )
                            table.insert(Settings.Connections, conn)
                        end)
                    end)
                table.insert(Settings.Connections, ChatSpyConn)
            end
        end)
    else
        if ChatSpyConn then
            pcall(function() ChatSpyConn:Disconnect() end)
            ChatSpyConn = nil
        end
    end
    
    Settings.ChatSpy = enabled
end

-- ═══════════════════════════════════════════════
-- 2. KEYBINDS (atalhos de teclado)
-- ═══════════════════════════════════════════════

function Misc.onKeyPress(keyCode)
    local KB = Settings.Keybinds
    
    if keyCode == KB.ToggleAimbot then
        Settings.Aimbot = not Settings.Aimbot
        print("[1NXITER] Aimbot: " 
            .. (Settings.Aimbot and "ON" or "OFF"))
    
    elseif keyCode == KB.ToggleESP then
        Settings.ESP_Enabled = not Settings.ESP_Enabled
        print("[1NXITER] ESP: " 
            .. (Settings.ESP_Enabled and "ON" or "OFF"))
    end
end

-- ═══════════════════════════════════════════════
-- 3. REJOIN (reconectar no mesmo servidor)
-- ═══════════════════════════════════════════════

function Misc.rejoin()
    pcall(function()
        local TS = Settings.Services.TeleportService
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
end

-- ═══════════════════════════════════════════════
-- 4. WATERMARK (info na tela)
-- ═══════════════════════════════════════════════

function Misc._createWatermark()
    Settings.WatermarkDrawing = {
        BG = Drawing.new("Square"),
        Text = Drawing.new("Text"),
    }
    
    local bg = Settings.WatermarkDrawing.BG
    bg.Filled = true
    bg.Color = Color3.fromRGB(10, 10, 15)
    bg.Transparency = 0.8
    bg.Visible = false
    bg.Size = Vector2.new(250, 28)
    table.insert(Drawings, bg)
    
    local txt = Settings.WatermarkDrawing.Text
    txt.Size = 14
    txt.Font = 2
    txt.Outline = true
    txt.Center = false
    txt.Color = Color3.fromRGB(255, 150, 50)
    txt.Visible = false
    table.insert(Drawings, txt)
end

function Misc.toggleWatermark(enabled)
    Settings.ShowWatermark = enabled
    if not enabled then
        Settings.WatermarkDrawing.BG.Visible = false
        Settings.WatermarkDrawing.Text.Visible = false
    end
end

function Misc._updateWatermark(dt)
    if not Settings.ShowWatermark then return end
    
    WatermarkTime = WatermarkTime + dt
    if WatermarkTime < 1 then return end
    WatermarkTime = 0
    
    local wm = Settings.WatermarkDrawing
    local Camera = Settings.Services.Camera
    local vpSize = Camera.ViewportSize
    
    local info = "1NXITER v3.0 | " 
        .. Settings.Services.LocalPlayer.Name 
        .. " | " .. #Settings.Services.Players:GetPlayers() 
        .. " players"
    
    pcall(function()
        local stats = game:GetService("Stats")
        local ping = math.floor(
            stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        )
        info = info .. " | " .. ping .. "ms"
    end)
    
    wm.BG.Position = Vector2.new(vpSize.X - 260, 10)
    wm.BG.Visible = true
    
    wm.Text.Text = info
    wm.Text.Position = Vector2.new(vpSize.X - 255, 16)
    wm.Text.Visible = true
end

-- ═══════════════════════════════════════════════
-- 5. PLAYER LIST
-- ═══════════════════════════════════════════════

function Misc.getPlayerList()
    local list = {}
    for _, plr in ipairs(Settings.Services.Players:GetPlayers()) do
        local info = {
            Name = plr.Name,
            DisplayName = plr.DisplayName,
            UserId = plr.UserId,
            Team = plr.Team and plr.Team.Name or "None",
            IsAlive = Utils.IsAlive(plr),
        }
        
        if plr.Character and plr.Character
            :FindFirstChild("HumanoidRootPart") then
            info.Distance = math.floor(Utils.GetDistance3D(
                Settings.Services.Camera.CFrame.Position,
                plr.Character.HumanoidRootPart.Position
            ))
        end
        
        table.insert(list, info)
    end
    return list
end

-- ═══════════════════════════════════════════════
-- 6. COPY USERNAME
-- ═══════════════════════════════════════════════

function Misc.copyUsername(playerName)
    pcall(function()
        setclipboard(playerName)
    end)
end

-- ═══════════════════════════════════════════════
-- 7. ANTI-SCREENSHOT (esconde drawings na captura)
-- ═══════════════════════════════════════════════

local ScreenshotConn = nil

function Misc.toggleAntiScreenshot(enabled)
    if enabled then
        if ScreenshotConn then return end
        
        pcall(function()
            -- Roblox dispara o evento Screenshot antes de capturar
            -- Escondemos todos os drawings por ~0.1s e restauramos
            local ScreenshotHud = game:GetService("GuiService")
            
            ScreenshotConn = Settings.Services.LocalPlayer
                .OnScreenshotReady:Connect(function()
                    -- Fallback: esconde pela flag
                    Settings._screenshotHideActive = true
                    task.delay(0.15, function()
                        Settings._screenshotHideActive = false
                    end)
                end)
        end)
        
        -- Método principal via input: detecta PrintScreen / F12
        if not ScreenshotConn then
            ScreenshotConn = game:GetService("UserInputService")
                .InputBegan:Connect(function(input, gp)
                    if gp then return end
                    local k = input.KeyCode
                    if k == Enum.KeyCode.Print 
                    or k == Enum.KeyCode.F12 
                    or k == Enum.KeyCode.SysRq then
                        Settings._screenshotHideActive = true
                        task.delay(0.2, function()
                            Settings._screenshotHideActive = false
                        end)
                    end
                end)
            table.insert(Settings.Connections, ScreenshotConn)
        end
    else
        if ScreenshotConn then
            pcall(function() ScreenshotConn:Disconnect() end)
            ScreenshotConn = nil
        end
        Settings._screenshotHideActive = false
    end
    
    Settings.AntiScreenshot = enabled
end

-- ═══════════════════════════════════════════════
-- UPDATE
-- ═══════════════════════════════════════════════

function Misc.update(dt)
    Misc._updateWatermark(dt)
    Misc._applyAntiScreenshot()
end

-- Anti-screenshot: oculta todos os Drawings durante captura
function Misc._applyAntiScreenshot()
    if not Settings.AntiScreenshot then return end
    -- A flag é setada por ScreenshotConn e o esp/aimbot verifica antes de renderizar
    -- Os módulos consultam Settings._screenshotHideActive antes de setar Visible=true
end

-- ═══════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════

function Misc.cleanup()
    if ChatSpyConn then
        pcall(function() ChatSpyConn:Disconnect() end)
    end
    
    for _, d in ipairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    
    if Settings.WatermarkDrawing then
        pcall(function()
            Settings.WatermarkDrawing.BG:Remove()
            Settings.WatermarkDrawing.Text:Remove()
        end)
    end
    
    Drawings = {}
    print("[1NXITER] Misc cleanup completo")
end

return Misc
