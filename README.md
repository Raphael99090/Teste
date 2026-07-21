# 1NXITER HUB

Hub modular em Lua para Roblox, construído com um sistema de **loader remoto** que baixa e monta seus módulos em tempo de execução, com interface gráfica própria (baseada na biblioteca Rayfield) e persistência de configuração em JSON.

## Arquitetura

O projeto é dividido em três camadas principais, carregadas dinamicamente pelo `Main.lua`:

```
Teste-main/
├── Main.lua              # Loader: baixa, compila e inicializa todos os módulos
├── Core/
│   ├── Utils.lua          # Funções utilitárias (Anti-AFK, Auto-Rejoin, conversão numérica PT-BR, etc.)
│   └── State.lua          # Gerenciamento de configuração (leitura/escrita de JSON, defaults, backup)
├── UI/
│   ├── Interface.lua      # Monta as abas e componentes visuais do hub (via Rayfield)
│   └── Library.lua        # Sistema de temas, tweens e notificações da interface
└── Features/
    ├── AutoTrain.lua      # Automação de sequência de treino (input virtual, chat, contadores)
    ├── Visuals.lua        # Ajustes visuais de câmera (FOV estilizado)
    ├── FreeCam.lua        # Câmera livre desacoplada do personagem
    ├── PlayerMods.lua     # Modificadores do próprio personagem (velocidade, pulo, noclip)
    └── ...                # Módulos adicionais de combate/utilidade
```

### Como o loader funciona

1. `Main.lua` define a lista de módulos (`FilesToLoad`) organizados por pasta (`Core`, `UI`, `Features`).
2. Cada módulo é baixado via `game:HttpGet` a partir de um repositório remoto, com retentativas automáticas (`MAX_RETRIES`) e timeout global (`GLOBAL_TIMEOUT`).
3. O código baixado é compilado com `loadstring` e executado; o resultado (uma tabela Lua) é armazenado na tabela `Hub`, indexado por pasta e nome do arquivo.
4. Após o download de todos os módulos, é feita uma verificação de integridade: se algum módulo falhar ao baixar, compilar ou executar, o carregamento é abortado com uma notificação de erro.
5. Com todos os módulos validados, a interface (`UI.Interface`) é inicializada, recebendo o `Hub`, a configuração carregada (`Core.State`) e o estado de execução.

### Sistema de configuração (`Core/State.lua`)

- Mantém um conjunto de valores padrão (`DefaultConfig`) para todas as opções do hub.
- Salva e carrega a configuração do usuário em JSON, com um arquivo de backup (`Config.backup.json`) para recuperação em caso de corrupção do arquivo principal.
- Separa configuração persistente (`Config`) de estado de execução em memória (`RuntimeState`).

### Interface (`UI/Interface.lua` e `UI/Library.lua`)

- A janela principal é criada sobre a biblioteca externa **Rayfield**, organizada em abas (ex.: Treino, Combate, Extras).
- `Library.lua` implementa um sistema de temas (paletas de cor intercambiáveis), fila de notificações e animações (tweens) reutilizados pelos componentes da interface.

### Utilidades (`Core/Utils.lua`)

- Anti-AFK e auto-reconexão (`AutoRejoin`) para manter a sessão ativa.
- Conversor de números para texto em português (ex.: `130` → `"CENTO E TRINTA"`), usado em mensagens/contadores exibidos ao usuário.

### Módulos de automação e câmera

- **AutoTrain**: automatiza uma sequência de treino, com envio de mensagens de chat e compensação de tempo, compatível com o sistema de chat legado e o `TextChatService`.
- **Visuals**: ajusta o campo de visão (FOV) da câmera de forma suavizada (tween) para um efeito "estilizado".
- **FreeCam**: desacopla a câmera do personagem, permitindo navegação livre pelo cenário com controle de velocidade e sensibilidade.
- **PlayerMods**: altera atributos do próprio personagem local (velocidade, altura do pulo, colisão).

> O projeto também inclui módulos adicionais na pasta `Features/` voltados a combate e monitoramento em partida. Este README documenta apenas a arquitetura geral do hub — a configuração e o uso detalhado desses módulos específicos não são cobertos aqui.

## Requisitos

- Um executor de scripts Roblox compatível com `loadstring` e `game:HttpGet` (o loader verifica isso e falha com uma mensagem clara caso não seja suportado).

## Autor

Desenvolvido por **Raphael99090**.
