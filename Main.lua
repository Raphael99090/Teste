Playground
319.945 tokens

Model
ThinkingThoughts
Expand to view model thoughts

chevron_right
Model
ThinkingThoughts
**Focusing on User Intent**

I'm now zeroing in on the user's ultimate objective: ease of code copying. Understanding this, I'm analyzing the previous response to confirm the 'Main.lua' code is present and appropriately formatted for seamless reproduction via copy-paste. The central goal is to facilitate code utilization.


**Addressing the 404s**

I've reviewed the proposed `Main.lua` code and I see that it incorporates `Anti-Cache` URL modifications to counter 404 errors, and detailed `warn` statements to pinpoint file load failures. It now includes dependency checks to prevent execution if core modules are unavailable, ensuring stability. I'm also ensuring a central state passes down to all modules.


**Generating the Output**

I'm now generating the final output. I've confirmed the `BaseURL` matches the user's repository (`Raphael99090/Teste`). I've reviewed and adjusted the `Import` function to correctly handle `loadstring` and verified the correct import of dependencies: `Library`, `Utils`, `Logic`, and `Interface`. Now, I'm formatting the `Main.lua` code with Lua syntax highlighting and finalizing the checklist for the user.


Collapse to hide model thoughts

chevron_right
Aqui está o código do **`Main.lua`** atualizado com o sistema **Anti-Cache** (para evitar o erro 404 mesmo que o arquivo exista) e mensagens de erro detalhadas.

Copie este código e substitua o que está no seu arquivo `Main.lua` no GitHub:

### 📄 ARQUIVO: `Main.lua`

```lua
--[[
    1NXITER TRAINER - MODULAR LOADER (FIX 404 & CACHE)
    Repositório: Raphael99090/Teste
]]

-- 1. BASE URL (Onde estão seus arquivos)
-- O "?v=" no final serve para evitar que o Roblox use uma versão antiga salva na memória
local BaseURL = "https://raw.githubusercontent.com/Raphael99090/Teste/main/"

-- Função para carregar módulos da nuvem
local function Import(Asset)
    -- Gera um link único a cada execução para garantir que baixou o arquivo real
    local Url = BaseURL .. Asset .. ".lua?v=" .. tostring(math.random(1, 100000))
    
    print("[1NX] Baixando: " .. Asset .. " ...")
    
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Url))()
    end)
    
    if not Success then
        warn("---------------------------------------------------")
        warn("[1NX LOADER] FALHA CRÍTICA AO CARREGAR: " .. Asset)
        warn("Link tentado: " .. Url)
        warn("Erro do Roblox: " .. tostring(Result))
        warn("VERIFIQUE SE O ARQUIVO '" .. Asset .. ".lua' EXISTE NO GITHUB!")
        warn("---------------------------------------------------")
        return nil
    end
    
    return Result
end

-- 2. IMPORTAR MÓDULOS NA ORDEM CERTA
local Library   = Import("Library")   -- Precisa criar esse arquivo no GitHub!
local Utils     = Import("Utils")
local Logic     = Import("Logic")
local Interface = Import("Interface")

-- Verifica se tudo carregou antes de continuar
if not Library or not Utils or not Logic or not Interface then
    local msg = "Erro ao baixar arquivos!\nAbra o console (F9) para ver qual arquivo falhou."
    
    if not Library then msg = "Faltando: Library.lua" end
    
    return game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO 404 / CRÍTICO",
        Text = msg,
        Duration = 10
    })
end

-- 3. ESTADO GLOBAL (Compartilhado entre os módulos)
local Config = {
    Mode = "Canguru",
    Delay = 1.4,
    StartNum = 0,
    Quantity = 130,
    IsCountdown = false,
    AutoCrouch = false,
    AutoEquip = false,
    AutoRejoin = false
}

local State = {
    IsRunning = false,
    IsActive = true
}

-- 4. INICIALIZAÇÃO DE SISTEMAS
Utils:AntiAFK(State)
Utils:AutoRejoin(Config)

-- 5. CARREGAR UI
Interface:Load(Library, Config, State, Utils, Logic)

print("---------------------------------------------------")
print("[1NX] SISTEMA MODULAR CARREGADO COM SUCESSO!")
print("---------------------------------------------------")
