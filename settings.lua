--[[
    1NXITER v3.0 - CONFIGURAÇÕES GLOBAIS
    Todas as variáveis do sistema + cache de serviços
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local viewportSize = Camera.ViewportSize

local Settings = {
    -- ═══════════════════════════════════════════
    -- AIMBOT
    -- ═══════════════════════════════════════════
    Aimbot = false,
    AimPart = "Head",
    Smoothness = 0.5,
    FOVSize = 150,
    ShowFOV = true,
    CrosshairX = viewportSize.X / 2,
    CrosshairY = viewportSize.Y / 2,
    WallCheck = true,
    TeamCheck = true,
    
    -- Triggerbot (v3.0)
    Triggerbot = false,
    TriggerbotDelay = 0.1,
    
    -- Aim Prediction (v3.0)
    AimPrediction = false,
    PredictionStrength = 0.15,
    
    -- Target Priority (v3.0)
    TargetPriority = "Distance",
    
    -- ═══════════════════════════════════════════
    -- HITBOX
    -- ═══════════════════════════════════════════
    HitboxExpand = false,
    HitboxSize = 5,
    
    -- ═══════════════════════════════════════════
    -- ESP
    -- ═══════════════════════════════════════════
    ESP_Enabled = false,
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Names = false,
    ESP_Health = false,
    ESP_Lines = false,
    ESP_Distance = false,
    ESP_MaxDistance = 1000,
    
    -- Chams (v3.0)
    ESP_Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 100),
    ChamsTransparency = 0.3,
    
    -- Target Info (v3.0)
    ShowTargetInfo = false,
    
    -- ═══════════════════════════════════════════
    -- CORES
    -- ═══════════════════════════════════════════
    Colors = {
        FOVCircle   = Color3.fromRGB(255, 40, 40),
        ESPBox      = Color3.fromRGB(255, 40, 40),
        ESPSkeleton = Color3.fromRGB(0, 255, 0),
        ESPName     = Color3.fromRGB(255, 255, 255),
        ESPLine     = Color3.fromRGB(255, 0, 0),
        Hitbox      = Color3.fromRGB(255, 0, 0),
    },
    
    -- ═══════════════════════════════════════════
    -- OTIMIZAÇÃO
    -- ═══════════════════════════════════════════
    PotatoMode = false,
    RemoveShadows = false,
    MutarSom = false,
    RemoveTexturesActive = false,
    RemoveParticlesActive = false,
    Fullbright = false,
    NoFog = false,
    AntiAFK = false,
    ShowFPS = false,
    RemoveAccessories = false,
    NoAnimationsOthers = false,
    RemovePostProcessing = false,
    LowRenderDistance = false,
    NoTerrainDetails = false,
    
    -- ═══════════════════════════════════════════
    -- MISC (v3.0)
    -- ═══════════════════════════════════════════
    ChatSpy = false,
    ShowWatermark = false,
    
    -- Keybinds
    Keybinds = {
        ToggleAimbot = Enum.KeyCode.F,
        ToggleESP = Enum.KeyCode.G,
    },
    
    -- ═══════════════════════════════════════════
    -- BUBBLE
    -- ═══════════════════════════════════════════
    BubbleIcon = "rbxassetid://136644425560507",
    UseBubbleImage = true,
    
    -- ═══════════════════════════════════════════
    -- SISTEMA INTERNO
    -- ═══════════════════════════════════════════
    ActiveTeams = {},
    Connections = {},
    OriginalHitboxSizes = {},
    OriginalMaterials = {},
    OriginalLighting = {},
    OriginalTerrain = {},
    RemovedAccessories = {},
    DisabledAnimations = {},
    FOVCircle = nil,
    FPSDrawing = nil,
    WatermarkDrawing = nil,
    TargetInfoDrawings = {},
    ChamsCache = {},
    
    -- ═══════════════════════════════════════════
    -- SERVIÇOS (cached)
    -- ═══════════════════════════════════════════
    Services = {
        Players = Players,
        Workspace = Workspace,
        RunService = game:GetService("RunService"),
        Camera = Camera,
        LocalPlayer = LocalPlayer,
        Lighting = game:GetService("Lighting"),
        SoundService = game:GetService("SoundService"),
        UserInputService = game:GetService("UserInputService"),
        VirtualInputManager = nil,
        StarterGui = game:GetService("StarterGui"),
        Terrain = Workspace:FindFirstChildOfClass("Terrain"),
        TeleportService = game:GetService("TeleportService"),
        HttpService = game:GetService("HttpService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
    },
}

-- VirtualInputManager / VirtualUser (seguro)
pcall(function()
    Settings.Services.VirtualInputManager = game:GetService("VirtualInputManager")
end)
pcall(function()
    Settings.Services.VirtualUser = game:GetService("VirtualUser")
end)

return Settings
