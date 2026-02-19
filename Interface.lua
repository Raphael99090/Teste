local Interface = {}

function Interface:Load(Library, Config, State, Utils, Logic)
    local Window = Library:CriarJanela("1NXITER TRAINER")

    local TabHome = Window:CriarAba("⚔", "Principal")
    local TabConf = Window:CriarAba("⚙", "Ajustes")
    local TabExtra = Window:CriarAba("🚀", "Extras")
    local TabProf = Window:CriarAba("👤", "Perfil")

    -- [HOME]
    local LblCount = TabHome:CriarLabel("AGUARDANDO...", Color3.fromRGB(255,45,45))
    local LblETA = TabHome:CriarLabel("TEMPO: --:--", Color3.fromRGB(255, 215, 0))

    TabHome:CriarDropdown("Modo de Treino", {"Canguru", "Flexão", "Polichinelo"}, function(v)
        Config.Mode = v
    end)

    local BtnStart
    BtnStart = TabHome:CriarBotao("INICIAR TREINO", function()
        if State.IsRunning then
            State.IsRunning = false
            BtnStart("INICIAR TREINO")
            LblETA("TEMPO: PARADO")
            Library:Notificar("Status", "Pausado pelo usuário.", 2, "aviso")
            return
        end

        State.IsRunning = true
        BtnStart("PARAR TREINO")
        Library:Notificar("Iniciado", "Contagem iniciada...", 2)

        task.spawn(function()
            local start = Config.StartNum
            local qtd = Config.Quantity
            local step = Config.IsCountdown and -1 or 1
            local finish = Config.IsCountdown and (start - qtd + 1) or (start + qtd - 1)

            for i = start, finish, step do
                if not State.IsRunning or not State.IsActive then break end

                LblCount(tostring(i))
                
                -- Enviar Chat
                local msg = Utils:NumberToText(i) .. " !"
                if game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel then
                    game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                end

                -- Executar Física
                Logic:ExecutePhysics(Config, State)

                -- Delay Inteligente
                local d = Config.Delay
                if Config.Mode == "Canguru" then d = d - 0.3 end
                if d < 0 then d = 0 end
                task.wait(d)
            end

            State.IsRunning = false
            if State.IsActive then
                BtnStart("INICIAR TREINO")
                LblCount("FIM")
                LblETA("CONCLUÍDO")
                Library:Notificar("Sucesso", "Treino finalizado!", 5)
            end
        end)
    end)

    -- [CONFIG]
    TabConf:CriarInput("Número Inicial", "0", function(v) Config.StartNum = tonumber(v) or 0 end)
    TabConf:CriarInput("Quantidade", "130", function(v) Config.Quantity = tonumber(v) or 130 end)
    TabConf:CriarSlider("Velocidade (Delay)", 0.5, 5.0, 1.4, function(v) Config.Delay = v end)
    TabConf:CriarToggle("Contagem Regressiva", false, function(v) Config.IsCountdown = v end)
    TabConf:CriarToggle("Auto Agachar (Canguru)", false, function(v) Config.AutoCrouch = v end)

    -- [EXTRAS]
    TabExtra:CriarToggle("Auto Equipar", false, function(v) Config.AutoEquip = v end)
    TabExtra:CriarToggle("Auto Rejoin", false, function(v) Config.AutoRejoin = v end)
    TabExtra:CriarBotao("ANTI-LAG (TEXTURAS OFF)", function() Utils:AntiLag(); Library:Notificar("Otimização", "Gráficos reduzidos.", 3) end)

    -- [PERFIL]
    TabProf:CriarPerfil()
    TabProf:CriarBotao("PANIC (FECHAR)", function()
        State.IsActive = false
        game.CoreGui["CrimsonUI"]:Destroy()
    end)
end

return Interface
