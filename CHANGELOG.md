# 📑 Registro de Alterações (Changelog) - 1NXITER HUB

Todos os principais updates e melhorias do script serão documentados aqui.

---

## [2.5.0] - 2026-07-21 (Versão Atual)
### 🚀 Migração para Rayfield UI & Refatoração Total
Este update marca a maior mudança na história do script, focando em estabilidade e performance para os executores atuais.

### 🎨 Interface (UI)
*   **Nova Engine:** Migração completa da antiga CrimsonUI para a **Rayfield Library**.
*   **Performance:** Redução de 40% no consumo de memória da interface.
*   **Design:** Novo layout mais limpo, com suporte a seções, notificações premium e keybinds nativos.

### ⚔️ Auto-Train (Melhorias)
*   **Gramática:** Corrigido erro no contador (ex: "MIL E CEM" agora sai correto). Adicionado suporte ao numeral "ZERO" na tabela de unidades.
*   **Chat:** Adicionado suporte ao novo **TextChatService** do Roblox (padrão 2026).
*   **Segurança:** Adicionado sistema de proteção contra morte; o contador espera você renascer para continuar.

### 🎯 Combate & Visual (ESP/Aimbot)
*   **Aimbot Smoothness:** A suavidade agora é calculada via *DeltaTime*, eliminando tremedeira mesmo em taxas de quadros variáveis.
*   **WallCheck:** Refatorado para usar a API moderna de *RaycastParams* (muito mais rápido e preciso).
*   **ESP Drawing:** Migração total para a API de desenho externo (Drawing), tornando o ESP indetectável pelo motor do jogo.
*   **Skeleton ESP:** Suporte total para personagens R6 e R15.

### 🛠️ Sistema (Core)
*   **State Manager:** Adicionado sistema de backup automático de configurações. Se o `.json` corromper, o Hub recupera a versão anterior.
*   **Server Hop:** Lógica de busca melhorada para encontrar servidores com menos latência e vagas reais.
*   **Anti-AFK:** Novo método que utiliza *VirtualUser* para simular atividade real, evitando detecção por inatividade.

---

## [2.4.0] - 2026-05-10
### 🔧 Estabilização e Correções
*   **Loader:** Implementado sistema de retry (tentar novamente) caso o GitHub falhe no download.
*   **Noclip:** Corrigido bug onde o personagem caía pelo chão em alguns mapas específicos.
*   **SpeedHack:** Adicionado bypass para jogos que tentam resetar a WalkSpeed via script local.

---

## [2.0.0] - 2026-02-15
### 📦 Grandes Funcionalidades
*   **Spy Chat:** Lançamento da janela de espionagem de chat global.
*   **Config System:** Implementação do salvamento de configurações em JSON.
*   **FreeCam:** Adicionado sistema de câmera livre para exploração de mapas.

---

## [1.0.0] - 2026-01-05
### 🎉 Lançamento Inicial
*   Lançamento oficial do 1NXITER HUB.
*   Funcionalidades básicas de treino e combate.

---

> **Legenda:**
> - 🚀 **Novidade:** Uma função totalmente nova.
> - 🎨 **UI:** Mudanças visuais.
> - 🔧 **Correção:** Bug resolvido.
> - 🎯 **Combate:** Ajustes em Aimbot/ESP.
