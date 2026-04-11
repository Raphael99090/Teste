--[[
    ============================================================
    1NXITER TRAINER - INTERFACE MODULE
    Arquivo: ui.lua
    ============================================================
]]

local Interface = {}

function Interface:Load(Library, Config, State, Utils, Logic)
    -- Criar a Janela Principal
    local Window = Library:CriarJanela("1NXITER TRAINER")

    -- Criar as Abas (A Lib usa o ícone para a Sidebar)
    local TabHome = Window:CriarAba("⚔")
    local TabConf = Window:CriarAba("⚙")
    local TabExtra = Window:CriarAba("🚀")
    local TabProf = Window:CriarAba("👤")

    -- ═══════════════════════════════════════════
    -- ABA PRINCIPAL (HOME)
    -- ═══════════════════════════════════════════
    local LblCount = TabHome:CriarLabel("AGUARDANDO...")
    local LblETA = TabHome:CriarLabel("TEMPO: --:--")

    TabHome:CriarDropdown("Modo de Treino", {"Canguru", "Flexão", "Polichinelo"}, function(v)
        Config.Mode = v
    end)

    local BtnStart
    BtnStart = TabHome:CriarBotao("INICIAR TREINO", function()
        if State.IsRunning then
            State.IsRunning = false
            BtnStart("INICIAR TREINO")
            LblETA("TEMPO: PARADO")
            Library:Notificar("Status", "Pausado pelo usuário.")
            return
        end

        State.IsRunning = true
        BtnStart("PARAR TREINO")
        Library:Notificar("Iniciado", "Contagem iniciada...")

        task.spawn(function()
            local start = Config.StartNum or 0
            local qtd = Config.Quantity or 100
            local step = Config.IsCountdown and -1 or 1
            local finish = Config.IsCountdown and (start - qtd + 1) or (start + qtd - 1)

            for i = start, finish, step do
                if not State.IsRunning or not State.IsActive then break end

                LblCount(tostring(i))
                
                -- Sistema de Chat
                local msg = Utils:NumberToText(i) .. " !"
                local tcs = game:GetService("TextChatService")
                
                if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = tcs.ChatInputBarConfiguration.TargetTextChannel
                    if channel then channel:SendAsync(msg) end
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                end

                -- Executar Lógica de Física (vinda do módulo Logic/Misc)
                if Logic and Logic.ExecutePhysics then
                    Logic:ExecutePhysics(Config, State)
                end

                -- Delay Inteligente
                local d = Config.Delay or 1.4
                if Config.Mode == "Canguru" then d = d - 0.3 end
                task.wait(math.max(d, 0.1))
            end

            State.IsRunning = false
            if State.IsActive then
                BtnStart("INICIAR TREINO")
                LblCount("FIM")
                LblETA("CONCLUÍDO")
                Library:Notificar("Sucesso", "Treino finalizado!")
            end
        end)
    end)

    -- ═══════════════════════════════════════════
    -- ABA CONFIGURAÇÕES
    -- ═══════════════════════════════════════════
    TabConf:CriarSlider("Velocidade (Delay)", 0.5, 5.0, 1.4, function(v) Config.Delay = v end)
    TabConf:CriarToggle("Contagem Regressiva", false, function(v) Config.IsCountdown = v end)
    TabConf:CriarToggle("Auto Agachar", false, function(v) Config.AutoCrouch = v end)

    -- ═══════════════════════════════════════════
    -- ABA EXTRAS
    -- ═══════════════════════════════════════════
    TabExtra:CriarToggle("Auto Equipar", false, function(v) Config.AutoEquip = v end)
    TabExtra:CriarToggle("Auto Rejoin", false, function(v) Config.AutoRejoin = v end)
    TabExtra:CriarBotao("ANTI-LAG", function() 
        if Utils.AntiLag then Utils:AntiLag() end
        Library:Notificar("Otimização", "Gráficos reduzidos.") 
    end)

    -- ═══════════════════════════════════════════
    -- ABA PERFIL
    -- ═══════════════════════════════════════════
    TabProf:CriarLabel("Usuário: " .. game.Players.LocalPlayer.Name)
    
    TabProf:CriarBotao("FECHAR SCRIPT", function()
        State.IsActive = false
        State.IsRunning = false
        local ui = game:GetService("CoreGui"):FindFirstChild("CrimsonUI") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("CrimsonUI")
        if ui then ui:Destroy() end
    end)
end

return Interface
