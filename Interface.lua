local Interface = {}

function Interface:Load(Library, Config, State, Utils, Logic)
    print("[1NX] Carregando Interface...")

    -- 1. Cria a Janela
    local Win = Library:CriarJanela("1NXITER TRAINER")
    if not Win then return warn("[1NX] Falha ao criar janela!") end

    -- 2. Cria as Abas
    local Home = Win:CriarAba("⚔", "Inicio")
    local Conf = Win:CriarAba("⚙", "Config")
    local Extra = Win:CriarAba("🚀", "Extras")
    local Prof = Win:CriarAba("👤", "Perfil")

    -- 3. Preenche a Aba HOME
    local LblCount = Home:CriarLabel("AGUARDANDO...", Color3.fromRGB(255,45,45))
    
    Home:CriarDropdown("Modo de Treino", {"Canguru", "Flexão", "Polichinelo"}, function(v) 
        Config.Mode = v 
    end)

    local BtnStart
    BtnStart = Home:CriarBotao("INICIAR TREINO", function()
        if State.IsRunning then
            State.IsRunning = false
            BtnStart("INICIAR TREINO")
            Library:Notificar("Status", "Parado.", 2)
            return
        end

        State.IsRunning = true
        BtnStart("PARAR TREINO")
        Library:Notificar("Status", "Iniciando...", 2)

        task.spawn(function()
            local start = Config.StartNum
            local qtd = Config.Quantity
            
            -- Lógica Simples de Contagem
            local final = start + qtd
            if Config.IsCountdown then final = start - qtd end
            
            local step = 1
            if Config.IsCountdown then step = -1 end

            -- Loop de Treino
            for i = start, final, step do
                if not State.IsRunning or not State.IsActive then break end
                
                -- Atualiza Visual
                LblCount("CONTANDO: " .. tostring(i))
                
                -- Envia Chat (Usando Utils se disponível, ou direto)
                local texto = tostring(i)
                if Utils and Utils.NumberToText then texto = Utils:NumberToText(i) end
                
                local msg = texto .. " !"
                
                if game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel then
                    game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                end

                -- Executa Física
                if Logic and Logic.ExecutePhysics then
                    Logic:ExecutePhysics(Config, State)
                end

                -- Delay
                local d = Config.Delay
                if Config.Mode == "Canguru" then d = d - 0.3 end
                if d < 0 then d = 0 end
                task.wait(d)
            end

            State.IsRunning = false
            if State.IsActive then
                BtnStart("INICIAR TREINO")
                LblCount("TREINO FINALIZADO")
                Library:Notificar("Sucesso", "Fim do treino!", 5)
            end
        end)
    end)

    -- 4. Preenche a Aba CONFIG
    Conf:CriarInput("Número Inicial", "0", function(v) Config.StartNum = tonumber(v) or 0 end)
    Conf:CriarInput("Quantidade", "130", function(v) Config.Quantity = tonumber(v) or 130 end)
    Conf:CriarSlider("Velocidade (Delay)", 0.5, 5.0, 1.4, function(v) Config.Delay = v end)
    Conf:CriarToggle("Contagem Regressiva", false, function(v) Config.IsCountdown = v end)
    Conf:CriarToggle("Auto Agachar (Canguru)", false, function(v) Config.AutoCrouch = v end)

    -- 5. Preenche a Aba EXTRAS
    Extra:CriarToggle("Auto Equipar", false, function(v) Config.AutoEquip = v end)
    Extra:CriarToggle("Auto Rejoin", false, function(v) Config.AutoRejoin = v end)
    Extra:CriarBotao("ANTI-LAG (BATATA)", function() 
        if Utils and Utils.AntiLag then Utils:AntiLag() end
        Library:Notificar("GPU", "Gráficos Reduzidos", 3) 
    end)

    -- 6. Preenche a Aba PERFIL
    Prof:CriarPerfil()
    Prof:CriarBotao("PANIC (FECHAR TUDO)", function()
        State.IsActive = false
        if game.CoreGui:FindFirstChild("CrimsonUI") then game.CoreGui.CrimsonUI:Destroy() end
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("CrimsonUI") then game.Players.LocalPlayer.PlayerGui.CrimsonUI:Destroy() end
    end)
    
    print("[1NX] Interface carregada com sucesso!")
end

return Interface
