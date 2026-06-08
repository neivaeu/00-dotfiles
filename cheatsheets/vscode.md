```jsonc
{
    // =========================================================================
    // EDITOR — FONTE E TIPOGRAFIA
    // =========================================================================

    // Tamanho da fonte em píxeis
    "editor.fontSize": 14,

    // Família de fontes — a primeira disponível no sistema é usada
    "editor.fontFamily": "'Fira Code', 'Cascadia Code', 'JetBrains Mono', 'Courier New', monospace",

    // Ligatures tipográficas (=>, !==, <=, etc. são renderizados como glifos únicos)
    // Requer fonte compatível: Fira Code, Cascadia Code, JetBrains Mono
    "editor.fontLigatures": true,

    // Altura de linha (0 = automático baseado no fontSize)
    "editor.lineHeight": 22,

    // Espaçamento entre letras em píxeis
    "editor.letterSpacing": 0,

    // Peso da fonte: "normal", "bold", ou número: 100, 200, 300, 400, 600, 700, 800, 900
    "editor.fontWeight": "400",


    // =========================================================================
    // EDITOR — APARÊNCIA
    // =========================================================================

    // Números de linha: "on", "off", "relative", "interval"
    // "relative" é útil para saltar N linhas com Vim ou com Ctrl+G
    "editor.lineNumbers": "on",

    // Réguas verticais — guias visuais nas colunas indicadas
    "editor.rulers": [80, 120],

    // Realçar a linha atual: "none", "gutter", "line", "all"
    "editor.renderLineHighlight": "line",

    // Mostrar caracteres de espaço em branco
    // "none"     — nunca mostra
    // "boundary" — mostra só nos limites (não entre palavras)
    // "selection"— mostra só na seleção
    // "trailing" — mostra só no final das linhas
    // "all"      — mostra sempre
    "editor.renderWhitespace": "boundary",

    // Quebra de linha automática: "off", "on", "wordWrapColumn", "bounded"
    "editor.wordWrap": "off",

    // Coluna onde a linha quebra (usado com wordWrap: "wordWrapColumn" ou "bounded")
    "editor.wordWrapColumn": 120,

    // Indentação das linhas continuadas após quebra
    // "none", "same", "indent", "deepIndent"
    "editor.wrappingIndent": "same",

    // Mostrar minimapa (visão geral do código à direita)
    "editor.minimap.enabled": false,

    // Largura máxima do minimapa em colunas
    "editor.minimap.maxColumn": 120,

    // Renderizar caracteres reais no minimapa (false = blocos coloridos)
    "editor.minimap.renderCharacters": true,

    // Escala do minimapa: 1, 2, 3
    "editor.minimap.scale": 1,

    // Posição do minimapa: "right", "left"
    "editor.minimap.side": "right",

    // Quando mostrar o slider do minimapa: "always", "mouseover"
    "editor.minimap.showSlider": "mouseover",

    // Mostrar breadcrumbs (caminho do ficheiro + símbolo atual no topo)
    "breadcrumbs.enabled": true,

    // Realçar parênteses/chavetas correspondentes: "never", "near", "always"
    "editor.matchBrackets": "always",

    // Colorir pares de parênteses com cores diferentes
    "editor.bracketPairColorization.enabled": true,

    // Cada tipo de parêntese usa o seu próprio conjunto de cores
    "editor.bracketPairColorization.independentColorPoolPerBracketType": false,

    // Mostrar guias de indentação (linhas verticais)
    "editor.guides.indentation": true,

    // Mostrar guias de pares de parênteses
    "editor.guides.bracketPairs": false,

    // Realçar a guia de indentação ativa
    "editor.guides.highlightActiveIndentation": true,

    // Quando mostrar controlos de fold no gutter: "always", "never", "mouseover"
    "editor.showFoldingControls": "mouseover",

    // Scroll suave no editor
    "editor.smoothScrolling": true,

    // Animação do cursor: "blink", "smooth", "phase", "expand", "solid"
    "editor.cursorBlinking": "smooth",

    // Estilo do cursor: "block", "block-outline", "line", "line-thin", "underline", "underline-thin"
    "editor.cursorStyle": "line",

    // Largura do cursor quando cursorStyle é "line"
    "editor.cursorWidth": 2,

    // Mostrar caracteres de controlo (ex: carriage return ^M)
    "editor.renderControlCharacters": false,

    // Sticky scroll — mantém o cabeçalho do scope visível enquanto scrollas
    "editor.stickyScroll.enabled": true,

    // Número máximo de linhas sticky visíveis
    "editor.stickyScroll.maxLineCount": 5,

    // Continuar a fazer scroll além da última linha
    "editor.scrollBeyondLastLine": true,

    // Número de linhas a manter visíveis acima/abaixo do cursor ao fazer scroll
    "editor.cursorSurroundingLines": 4,

    // Estilo: "default" (só quando scroll) ou "all" (sempre)
    "editor.cursorSurroundingLinesStyle": "default",


    // =========================================================================
    // EDITOR — COMPORTAMENTO
    // =========================================================================

    // Tamanho do tab em espaços
    "editor.tabSize": 4,

    // Inserir espaços ao pressionar Tab (false = tabs reais)
    "editor.insertSpaces": true,

    // Detetar automaticamente indentação do ficheiro (sobrepõe tabSize e insertSpaces)
    "editor.detectIndentation": true,

    // Remover espaços em branco de auto-indentação em linhas vazias
    "editor.trimAutoWhitespace": true,

    // Formatar documento automaticamente ao guardar
    "editor.formatOnSave": false,

    // Ao formatar no save, formatar só as linhas modificadas
    // "modificationsIfAvailable" — só diff, "modifications" — sempre diff, "file" — ficheiro todo
    "editor.formatOnSaveMode": "file",

    // Formatar ao colar conteúdo
    "editor.formatOnPaste": false,

    // Formatar enquanto escreve (pode ser lento em ficheiros grandes)
    "editor.formatOnType": false,

    // Formatter padrão — substitui pelo ID da extensão (ex: "esbenp.prettier-vscode")
    // "editor.defaultFormatter": null,

    // Realçar ocorrências da palavra selecionada: "off", "singleFile", "multiFile"
    "editor.occurrencesHighlight": "singleFile",

    // Realçar seleção (mostrar outras ocorrências idênticas à seleção atual)
    "editor.selectionHighlight": true,

    // Mostrar lâmpada de ações de código (quick fix, refactor)
    "editor.lightbulb.enabled": "on",

    // Permitir arrastar seleções com o rato
    "editor.dragAndDrop": true,

    // Tecla modificadora para multi-cursor com clique: "alt" ou "ctrlCmd"
    "editor.multiCursorModifier": "alt",

    // Como colar com múltiplos cursores:
    // "spread" — distribui cada linha do clipboard por cada cursor
    // "full"   — cola o conteúdo completo em cada cursor
    "editor.multiCursorPaste": "spread",

    // Fechar automaticamente parênteses: "always", "languageDefined", "beforeWhitespace", "never"
    "editor.autoClosingBrackets": "languageDefined",

    // Fechar automaticamente aspas: "always", "languageDefined", "beforeWhitespace", "never"
    "editor.autoClosingQuotes": "languageDefined",

    // Rodear seleção automaticamente com parênteses/aspas: "languageDefined", "quotes", "brackets", "never"
    "editor.autoSurround": "languageDefined",

    // Aceitar sugestão ao pressionar Enter (além de Tab)
    "editor.acceptSuggestionOnEnter": "on",

    // Aceitar sugestão ao escrever um caracter de commit (ex: ".")
    "editor.acceptSuggestionOnCommitCharacter": true,

    // Hover — mostrar informação ao passar o rato sobre o código
    "editor.hover.enabled": true,

    // Delay em ms antes de mostrar o hover
    "editor.hover.delay": 300,

    // Manter o hover visível ao mover o rato para cima dele
    "editor.hover.sticky": true,

    // Mostrar código não utilizado com opacidade reduzida
    "editor.showUnused": true,

    // Mostrar código deprecated com risco
    "editor.showDeprecated": true,

    // Edição ligada — renomear tag HTML de abertura renomeia também a de fecho
    "editor.linkedEditing": true,

    // Realce semântico (cores mais precisas baseadas no tipo de símbolo)
    "editor.semanticHighlighting.enabled": true,

    // Inlay hints — anotações inline (tipos, nomes de parâmetros, etc.)
    // "on", "onUnlessPressed" (esconde ao pressionar Ctrl+Alt), "offUnlessPressed", "off"
    "editor.inlayHints.enabled": "on",

    // Estratégia de folding: "auto" (usa language server), "indentation"
    "editor.foldingStrategy": "auto",

    // Máximo de regiões foldáveis por documento
    "editor.foldingMaximumRegions": 5000,

    // Manter o fold ao fazer refactor/rename
    "editor.unfoldOnClickAfterEndOfLine": false,

    // Sugestões inline (estilo GitHub Copilot ghost text)
    "editor.inlineSuggest.enabled": true,


    // =========================================================================
    // EDITOR — INTELLISENSE E SUGESTÕES
    // =========================================================================

    // Ativar sugestões automáticas
    "editor.suggest.enabled": true,

    // Mostrar documentação da sugestão selecionada no painel lateral
    "editor.suggest.showInlineDetails": true,

    // Pré-visualizar sugestão inline no código
    "editor.suggest.preview": false,

    // Inserir sugestão em vez de substituir a palavra a seguir ao cursor
    // "insert" ou "replace"
    "editor.suggest.insertMode": "insert",

    // Ordenação de sugestões: "recentlyUsed", "recentlyUsedByPrefix", "inline"
    "editor.suggestSelection": "recentlyUsed",

    // Sugestões rápidas enquanto escreves
    "editor.quickSuggestions": {
        "other": "on",      // fora de strings e comentários
        "comments": "off",  // dentro de comentários
        "strings": "off"    // dentro de strings
    },

    // Delay em ms antes de mostrar sugestões rápidas
    "editor.quickSuggestionsDelay": 10,

    // Mostrar sugestões ao escrever caracteres especiais (ex: ".", "(")
    "editor.suggestOnTriggerCharacters": true,

    // Snippets nas sugestões: "top", "bottom", "inline", "none"
    "editor.snippetSuggestions": "top",

    // Tab completion: "on", "off", "onlySnippets"
    "editor.tabCompletion": "off",

    // Ativar hints de parâmetros ao escrever chamadas de função
    "editor.parameterHints.enabled": true,

    // Ciclar pelos hints de parâmetros (em vez de fechar ao chegar ao último)
    "editor.parameterHints.cycle": true,

    // Word-based suggestions (sugestões baseadas em palavras do documento)
    // "off", "currentDocument", "matchingDocuments", "allDocuments"
    "editor.wordBasedSuggestions": "matchingDocuments",


    // =========================================================================
    // EDITOR — SELEÇÃO E MOVIMENTO
    // =========================================================================

    // Colar no terminal com Ctrl+V (vs Ctrl+Shift+V)
    // (configurado no terminal, não aqui)

    // Comportamento do duplo clique para seleção de palavra
    "editor.wordSeparators": "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?",

    // Scroll suave com trackpad/rato
    "editor.mouseWheelScrollSensitivity": 1,

    // Zoom com Ctrl+roda do rato
    "editor.mouseWheelZoom": false,


    // =========================================================================
    // FICHEIROS
    // =========================================================================

    // Auto save: "off", "afterDelay", "onFocusChange", "onWindowChange"
    "files.autoSave": "off",

    // Delay em ms para auto save (usado com afterDelay)
    "files.autoSaveDelay": 1000,

    // Remover espaços em branco no final das linhas ao guardar
    "files.trimTrailingWhitespace": true,

    // Inserir linha final no fim do ficheiro ao guardar
    "files.insertFinalNewline": true,

    // Remover linhas em branco extra no fim do ficheiro
    "files.trimFinalNewlines": true,

    // Fim de linha padrão: "auto", "\n" (LF, Linux/Mac), "\r\n" (CRLF, Windows)
    "files.eol": "\n",

    // Encoding padrão para ler/escrever ficheiros
    "files.encoding": "utf8",

    // Tentar detetar encoding automaticamente ao abrir ficheiros
    "files.autoGuessEncoding": false,

    // Associações de extensões a linguagens
    "files.associations": {
        "*.html.twig": "html",
        "*.env.*": "dotenv",
        "Dockerfile*": "dockerfile",
        "*.hbs": "handlebars",
        "*.mdx": "markdown",
        ".bashrc": "shellscript",
        ".bash_profile": "shellscript",
        "*.conf": "ini"
    },

    // Ficheiros/pastas excluídos do explorador de ficheiros
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/Thumbs.db": true,
        "**/__pycache__": true,
        "**/*.pyc": true,
        "**/*.pyo": true
    },

    // Ficheiros/pastas excluídos do file watcher (economiza recursos)
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/**": true,
        "**/dist/**": true,
        "**/build/**": true,
        "**/.venv/**": true,
        "**/venv/**": true
    },

    // Máximo de ficheiros watched pelo sistema (aumentar se tiveres erros de watcher)
    "files.watcherLimit": 8,

    // Inserir BOM (Byte Order Mark) em ficheiros UTF-8
    "files.insertBOM": false,


    // =========================================================================
    // PESQUISA
    // =========================================================================

    // Excluir pastas da pesquisa global (Ctrl+Shift+F)
    "search.exclude": {
        "**/.git": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true,
        "**/.nuxt": true,
        "**/env": true,
        "**/venv": true,
        "**/.venv": true,
        "**/__pycache__": true,
        "**/*.min.js": true,
        "**/*.min.css": true,
        "**/coverage": true,
        "**/.yarn": true
    },

    // Respeitar .gitignore ao pesquisar
    "search.useIgnoreFiles": true,

    // Respeitar .gitignore de directorias pai
    "search.useParentIgnoreFiles": true,

    // Respeitar .gitignore global (~/.gitignore_global)
    "search.useGlobalIgnoreFiles": true,

    // Seguir links simbólicos na pesquisa
    "search.followSymlinks": true,

    // Smart case: insensível se tudo minúsculas, sensível se tiver maiúsculas
    "search.smartCase": false,

    // Número máximo de resultados mostrados
    "search.maxResults": 20000,

    // Mostrar ficheiros que apenas têm match no nome (sem abrir)
    "search.quickOpen.includeSymbols": false,

    // Mostrar histórico de pesquisa
    "search.searchOnType": true,

    // Delay em ms antes de pesquisar ao escrever
    "search.searchOnTypeDebouncePeriod": 300,


    // =========================================================================
    // TERMINAL
    // =========================================================================

    // Perfil padrão no Linux
    "terminal.integrated.defaultProfile.linux": "bash",

    // Perfis de terminal disponíveis
    "terminal.integrated.profiles.linux": {
        "bash": {
            "path": "/bin/bash",
            "args": ["-l"],
            "icon": "terminal-bash"
        },
        "zsh": {
            "path": "/bin/zsh",
            "args": ["-l"]
        },
        "fish": {
            "path": "/usr/bin/fish",
            "args": ["-l"]
        },
        "sh": {
            "path": "/bin/sh"
        }
    },

    // Tamanho da fonte no terminal
    "terminal.integrated.fontSize": 13,

    // Família de fontes no terminal (deixar vazio para herdar do editor)
    // Usar uma Nerd Font para ícones no prompt (oh-my-zsh, starship, etc.)
    "terminal.integrated.fontFamily": "",

    // Altura de linha no terminal
    "terminal.integrated.lineHeight": 1.2,

    // Buffer de scroll — número de linhas guardadas em memória
    "terminal.integrated.scrollback": 10000,

    // Copiar seleção automaticamente para o clipboard
    "terminal.integrated.copyOnSelection": false,

    // Estilo do cursor no terminal: "block", "underline", "bar"
    "terminal.integrated.cursorStyle": "block",

    // Cursor a piscar no terminal
    "terminal.integrated.cursorBlinking": true,

    // Aceleração GPU no terminal: "auto", "on", "off", "canvas"
    "terminal.integrated.gpuAcceleration": "auto",

    // Confirmar ao fechar terminal com processo a correr: "never", "always", "hasChildProcesses"
    "terminal.integrated.confirmOnExit": "hasChildProcesses",

    // Herdar variáveis de ambiente da shell (importante para PATH, virtualenvs, etc.)
    "terminal.integrated.inheritEnv": true,

    // Echo local — mostra caracteres escritos antes da shell responder
    "terminal.integrated.localEcho.enabled": "auto",

    // Variáveis de ambiente passadas ao terminal
    "terminal.integrated.env.linux": {},

    // Tamanho do separador ao fazer split do terminal
    "terminal.integrated.splitCwd": "workspaceRoot",

    // Diretoria inicial do terminal: "initial", "workspaceRoot", "inherited"
    "terminal.integrated.cwd": "",

    // Comportamento do clique do meio no terminal: colar do clipboard de seleção
    "terminal.integrated.middleClickPastesSelection": true,

    // Permitir que o terminal use sequências de escape para alterar o título do separador
    "terminal.integrated.enableBell": false,

    // Mostrar aviso ao colar múltiplas linhas no terminal
    "terminal.integrated.confirmOnPaste": true,


    // =========================================================================
    // WORKBENCH — TEMA E APARÊNCIA
    // =========================================================================

    // Tema de cores
    "workbench.colorTheme": "Default Dark Modern",

    // Tema de ícones de ficheiros
    "workbench.iconTheme": "vs-seti",

    // Tema de ícones do produto (ícones da UI do VS Code)
    "workbench.productIconTheme": "Default",

    // Personalizar cores do tema atual
    "workbench.colorCustomizations": {
        // Exemplos — descomenta e ajusta ao teu gosto:
        // "statusBar.background": "#8252be",
        // "statusBar.foreground": "#eeffff",
        // "titleBar.activeBackground": "#282b3c",
        // "titleBar.activeForeground": "#eeefff",
        // "editor.background": "#1e1e2e",
        // "sideBar.background": "#181825",
        // "activityBar.background": "#181825",
        // "tab.activeBackground": "#1e1e2e",
        // "tab.inactiveBackground": "#181825"
    },

    // Personalizar regras de sintaxe (cores de tokens)
    "editor.tokenColorCustomizations": {
        // Exemplos:
        // "comments": "#6a9955",
        // "keywords": "#c792ea",
        // "strings": "#c3e88d"
    },

    // Nível de zoom da janela (0 = 100%, 1 = +20%, -1 = -20%)
    "window.zoomLevel": 0,

    // O que mostrar no arranque: "none", "welcomePage", "readme", "newUntitledFile", "welcomePageInEmptyWorkbench"
    "workbench.startupEditor": "none",

    // Antialiasing de fontes na UI: "default", "antialiased", "subpixel-antialiased", "auto"
    "workbench.fontAliasing": "antialiased",

    // Posição da activity bar (barra lateral com ícones): "default", "top", "bottom", "hidden"
    "workbench.activityBar.location": "default",

    // Posição da sidebar: "left", "right"
    "workbench.sideBar.location": "left",

    // Posição padrão do painel inferior: "bottom", "right", "left"
    "workbench.panel.defaultLocation": "bottom",

    // Mostrar o painel inferior maximizado por padrão
    "workbench.panel.opensMaximized": "preserve",

    // Indentação das árvores da sidebar em píxeis
    "workbench.tree.indent": 12,

    // Scroll suave em listas e árvores
    "workbench.list.smoothScrolling": true,

    // Renderização das tabs: "fit" (tabela sobe), "shrink" (encolhe), "fixed" (largura fixa)
    "workbench.editor.tabSizing": "shrink",

    // Botão de fechar tab: "always", "left", "off"
    "workbench.editor.tabCloseButton": "right",

    // Mostrar tabs: "multiple", "single", "none"
    "workbench.editor.showTabs": "multiple",

    // Tabs em várias linhas quando transbordam
    "workbench.editor.wrapTabs": false,

    // Preview de tab — clique simples abre em preview (itálico), duplo clique fixa
    "workbench.editor.enablePreview": true,

    // Preview ao abrir de Quick Open
    "workbench.editor.enablePreviewFromQuickOpen": false,

    // Restaurar estado da view (posição de scroll, seleção) ao trocar de tab
    "workbench.editor.restoreViewState": true,

    // Centrar o layout do editor (reduz a largura para algo mais legível)
    "workbench.editor.centeredLayoutAutoResize": true,

    // Manter a tab aberta ao fazer edições (evita ser substituída por preview)
    "workbench.editor.autoLockGroups": {},

    // Confirmar antes de fechar a janela com ficheiros não guardados
    "window.confirmBeforeClose": "keyboardOnly",

    // Decorações de ficheiros no explorador (git status, erros, avisos)
    "workbench.editor.decorations.colors": true,
    "workbench.editor.decorations.badges": true,


    // =========================================================================
    // EXPLORADOR DE FICHEIROS
    // =========================================================================

    // Confirmar antes de apagar ficheiros
    "explorer.confirmDelete": true,

    // Confirmar drag and drop
    "explorer.confirmDragAndDrop": false,

    // Pastas compactas — mostra parent/child como um único item quando sem irmãos
    "explorer.compactFolders": true,

    // Ordenação dos ficheiros: "default", "mixed", "filesFirst", "type", "modified", "foldersNestsFiles"
    "explorer.sortOrder": "default",

    // Número de editores abertos visíveis na secção "Open Editors"
    "explorer.openEditors.visible": 5,

    // Revelar automaticamente o ficheiro ativo na sidebar
    "explorer.autoReveal": true,

    // Incremento de numeração para cópia de ficheiros (ex: "file (1).txt")
    // (comportamento built-in, sem setting)

    // Arrastar para fora do VS Code: copiar o ficheiro
    "explorer.dragAndDropAcrossWindows": true,

    // Decorações git no explorador
    "explorer.decorations.colors": true,
    "explorer.decorations.badges": true,


    // =========================================================================
    // GIT
    // =========================================================================

    // Fazer commit de todas as alterações quando não há staged changes
    "git.enableSmartCommit": true,

    // Fetch automático periódico
    "git.autofetch": true,

    // Período de autofetch em segundos
    "git.autofetchPeriod": 180,

    // Confirmar antes de sync (push/pull)
    "git.confirmSync": false,

    // Nome do branch padrão ao criar novo repositório
    "git.defaultBranchName": "main",

    // Fazer prune de branches remotos ao fazer fetch
    "git.pruneOnFetch": true,

    // Comando após commit: "none", "push", "sync"
    "git.postCommitCommand": "none",

    // Mostrar decorações git no explorador e tabs
    "git.decorations.enabled": true,

    // Usar o editor como input do commit (em vez de terminal)
    "git.useEditorAsCommitInput": true,

    // Comprimento máximo da mensagem de commit (aviso visual)
    "git.inputValidationLength": 72,

    // Comprimento máximo do subject (primeira linha) do commit
    "git.inputValidationSubjectLength": 50,

    // Abrir diff ao clicar num ficheiro modificado no SCM panel
    "git.openDiffOnClick": true,

    // Mostrar notificação de push bem-sucedido
    "git.showPushSuccessNotification": false,

    // Fetch de submódulos automaticamente
    "git.fetchOnPull": false,

    // Rebase por padrão ao fazer pull (em vez de merge)
    "git.rebaseWhenSync": false,

    // Ignorar extensões ao mostrar status git
    "git.ignoredRepositories": [],

    // Detetar subrepositórios git
    "git.detectSubmodules": true,

    // Limite de subrepositórios detetados
    "git.detectSubmodulesLimit": 10,

    // Blame inline — mostrar quem alterou a linha (built-in desde VS Code 1.90)
    "git.blame.editorDecoration.enabled": false,


    // =========================================================================
    // DIFF EDITOR
    // =========================================================================

    // Mostrar lado a lado (true) ou inline (false)
    "diffEditor.renderSideBySide": true,

    // Ignorar espaços em branco no início/fim nas diffs
    "diffEditor.ignoreTrimWhitespace": true,

    // Mostrar indicadores +/- no gutter
    "diffEditor.renderIndicators": true,

    // Diffs ao nível da palavra (mais granular que linha)
    "diffEditor.wordWrap": "off",

    // Mover para mudança seguinte/anterior com F7/Shift+F7
    // (comportamento built-in)


    // =========================================================================
    // PROBLEMAS E DIAGNÓSTICOS
    // =========================================================================

    // Mostrar problema atual na status bar
    "problems.showCurrentInStatus": true,

    // Ordenar problemas por: "severity", "position"
    "problems.sortOrder": "severity",

    // Decorações inline de erros/avisos no editor
    "editor.hover.enabled": true,


    // =========================================================================
    // EMMET
    // =========================================================================

    // Ativar Emmet em linguagens adicionais
    "emmet.includeLanguages": {
        "javascript": "javascriptreact",
        "typescript": "typescriptreact",
        "vue-html": "html",
        "blade": "html",
        "twig": "html",
        "jinja": "html",
        "django-html": "html",
        "erb": "html"
    },

    // Ativar expansão com Tab (pode conflituar com snippets)
    "emmet.triggerExpansionOnTab": false,

    // Mostrar abreviações Emmet nas sugestões: "never", "inMarkupAndStylesheetFilesOnly", "always"
    "emmet.showExpandedAbbreviation": "always",

    // Mostrar sugestões Emmet como snippets (no topo da lista)
    "emmet.showSuggestionsAsSnippets": false,

    // Variáveis Emmet (usadas em snippets)
    "emmet.variables": {
        "lang": "pt",
        "charset": "UTF-8"
    },

    // Preferências Emmet (formato, etc.)
    "emmet.preferences": {},


    // =========================================================================
    // TELEMETRIA E PRIVACIDADE
    // =========================================================================

    // Nível de telemetria: "all", "error", "crash", "off"
    "telemetry.telemetryLevel": "off",


    // =========================================================================
    // SEGURANÇA
    // =========================================================================

    // Trust de workspaces — pede confirmação ao abrir pastas desconhecidas
    "security.workspace.trust.enabled": true,

    // Quando mostrar o banner de trust: "always", "untilDismissed", "never"
    "security.workspace.trust.banner": "untilDismissed",

    // Confiar em janelas vazias (sem pasta aberta)
    "security.workspace.trust.emptyWindow": true,

    // Quando pedir trust no arranque: "always", "once", "never"
    "security.workspace.trust.startupPrompt": "once",


    // =========================================================================
    // EXTENSÕES
    // =========================================================================

    // Mostrar recomendações de extensões
    "extensions.ignoreRecommendations": false,

    // Auto-update de extensões: "none", "onlyEnabledExtensions", "all"
    "extensions.autoUpdate": "onlyEnabledExtensions",

    // Verificar atualizações ao arrancar
    "extensions.autoCheckUpdates": true,


    // =========================================================================
    // NOTEBOOK (Jupyter)
    // =========================================================================

    // Scroll do output em vez de expandir
    "notebook.output.scrolling": true,

    // Altura máxima do output em píxeis
    "notebook.output.textLineLimit": 30,

    // Números de linha nas células
    "notebook.lineNumbers": "off",

    // Formatar ao executar célula
    "notebook.formatOnCellExecution": false,

    // Mostrar toolbar da célula: "always", "never", "mouseover"
    "notebook.cellToolbarLocation": {
        "default": "right",
        "jupyter-notebook": "left"
    },


    // =========================================================================
    // OVERRIDES POR LINGUAGEM
    // =========================================================================

    // Python — PEP 8 usa 4 espaços
    "[python]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "editor.formatOnSave": false,
        "editor.rulers": [79, 119]
        // "editor.defaultFormatter": "ms-python.black-formatter"
    },

    // JavaScript
    "[javascript]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
    },

    // TypeScript
    "[typescript]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
    },

    // JSX
    "[javascriptreact]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // TSX
    "[typescriptreact]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // HTML
    "[html]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
    },

    // CSS
    "[css]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // SCSS
    "[scss]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // Less
    "[less]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // JSON
    "[json]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.quickSuggestions": {
            "strings": "on"
        }
    },

    // JSONC (JSON with comments)
    "[jsonc]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.quickSuggestions": {
            "strings": "on"
        }
    },

    // Markdown — trailing whitespace é significativo (2 espaços = quebra de linha)
    "[markdown]": {
        "editor.wordWrap": "on",
        "files.trimTrailingWhitespace": false,
        "editor.quickSuggestions": {
            "comments": "off",
            "strings": "off",
            "other": "off"
        }
    },

    // YAML
    "[yaml]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.formatOnSave": false
    },

    // TOML
    "[toml]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // Shell scripts
    "[shellscript]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "files.eol": "\n"
    },

    // Makefile — OBRIGATORIAMENTE tabs (não espaços)
    "[makefile]": {
        "editor.insertSpaces": false,
        "editor.tabSize": 4
    },

    // Go — usa tabs por convenção
    "[go]": {
        "editor.insertSpaces": false,
        "editor.tabSize": 4,
        "editor.formatOnSave": true
    },

    // Rust
    "[rust]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "editor.formatOnSave": true
    },

    // PHP — PSR-12 usa 4 espaços
    "[php]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    },

    // C / C++
    "[c]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    },
    "[cpp]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    },

    // Java
    "[java]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    },

    // XML
    "[xml]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },

    // SQL
    "[sql]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.wordWrap": "on"
    },

    // Dockerfile
    "[dockerfile]": {
        "editor.tabSize": 4,
        "files.eol": "\n"
    },


    // =========================================================================
    // JAVASCRIPT / TYPESCRIPT — DEFINIÇÕES ESPECÍFICAS
    // =========================================================================

    // Atualizar imports automaticamente ao mover ficheiros
    "javascript.updateImportsOnFileMove.enabled": "always",
    "typescript.updateImportsOnFileMove.enabled": "always",

    // Sugestões de auto-import
    "javascript.suggest.autoImports": true,
    "typescript.suggest.autoImports": true,

    // Inlay hints para nomes de parâmetros: "none", "literals", "all"
    "javascript.inlayHints.parameterNames.enabled": "literals",
    "typescript.inlayHints.parameterNames.enabled": "literals",

    // Inlay hints para tipos de variáveis
    "typescript.inlayHints.variableTypes.enabled": false,

    // Inlay hints para tipos de retorno
    "typescript.inlayHints.returnTypes.enabled": false,

    // Inlay hints para tipos de propriedades de objetos
    "typescript.inlayHints.propertyDeclarationTypes.enabled": false,

    // Verificar JavaScript com o compilador TypeScript
    "javascript.validate.enable": true,

    // Usar a versão local do TypeScript (em vez da do VS Code)
    // "typescript.tsdk": "node_modules/typescript/lib",

    // Preferir imports com paths relativos ou não-relativos: "shortest", "relative", "non-relative", "project-relative"
    "typescript.preferences.importModuleSpecifier": "shortest",

    // Aspas nos imports gerados: "single", "double"
    "typescript.preferences.quoteStyle": "single",
    "javascript.preferences.quoteStyle": "single",

    // Ponto e vírgula automático: "insert", "remove", "ignore"
    "typescript.format.semicolons": "insert",

    // Type checking mode para JS: "off", "on" (usa jsconfig/tsconfig)
    "js/ts.implicitProjectConfig.checkJs": false,


    // =========================================================================
    // HTML
    // =========================================================================

    // Fechar tags automaticamente ao escrever "/"
    "html.autoClosingTags": true,

    // Comprimento de linha para formatação HTML
    "html.format.wrapLineLength": 120,

    // Preservar linhas em branco na formatação
    "html.format.preserveNewLines": true,

    // Máximo de linhas em branco preservadas
    "html.format.maxPreserveNewLines": 2,

    // Comportamento de wrap de atributos: "auto", "force", "force-aligned", "force-expand-multiline", "aligned-multiple", "preserve", "preserve-aligned"
    "html.format.wrapAttributes": "auto",

    // Sugestões de nomes de atributos HTML
    "html.suggest.html5": true,


    // =========================================================================
    // CSS / SCSS / LESS
    // =========================================================================

    // Validação de CSS (desativar se usares PostCSS ou outras ferramentas)
    "css.validate": true,
    "scss.validate": true,
    "less.validate": true,

    // Lint: propriedades duplicadas
    "css.lint.duplicateProperties": "warning",
    "scss.lint.duplicateProperties": "warning",

    // Lint: regras vazias
    "css.lint.emptyRules": "warning",

    // Hover com cor para variáveis CSS
    "css.hover.documentation": true,
    "css.hover.references": true,


    // =========================================================================
    // PYTHON (requer extensão ms-python.python)
    // =========================================================================

    // Language server: "Pylance", "Jedi", "None"
    "python.languageServer": "Pylance",

    // Nível de type checking: "off", "basic", "standard", "strict"
    "python.analysis.typeCheckingMode": "basic",

    // Auto-completar imports
    "python.analysis.autoImportCompletions": true,

    // Completar parênteses em chamadas de função
    "python.analysis.completeFunctionParens": false,

    // Path do interpretador Python (ou usar virtual env)
    "python.defaultInterpreterPath": "/usr/bin/python3",

    // Ativar/desativar linting
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": false,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": false,
    "python.linting.ruffEnabled": false,

    // Formatter Python
    "python.formatting.provider": "black",
    // Opções: "autopep8", "black", "yapf", "none"


    // =========================================================================
    // C / C++ (requer extensão ms-vscode.cpptools)
    // =========================================================================

    "C_Cpp.intelliSenseEngine": "default",
    "C_Cpp.formatting": "clangFormat",
    "C_Cpp.clang_format_style": "{ BasedOnStyle: LLVM, IndentWidth: 4 }",
    "C_Cpp.errorSquiggles": "enabled",
    "C_Cpp.codeAnalysis.runAutomatically": false,
    "C_Cpp.default.cppStandard": "c++98",
    "C_Cpp.default.cStandard": "c98",


    // =========================================================================
    // GO (requer extensão golang.go)
    // =========================================================================

    "go.formatTool": "goimports",
    "go.lintTool": "golangci-lint",
    "go.lintOnSave": "package",
    "go.vetOnSave": "package",
    "go.useLanguageServer": true,
    "go.toolsManagement.autoUpdate": true,


    // =========================================================================
    // RUST (requer extensão rust-lang.rust-analyzer)
    // =========================================================================

    "rust-analyzer.checkOnSave.command": "clippy",
    "rust-analyzer.inlayHints.parameterHints.enable": true,
    "rust-analyzer.inlayHints.typeHints.enable": true,
    "rust-analyzer.inlayHints.chainingHints.enable": true,
    "rust-analyzer.cargo.features": "all",
    "rust-analyzer.lens.enable": true,


    // =========================================================================
    // PHP (requer extensão bmewburn.vscode-intelephense-client)
    // =========================================================================

    // Desativar sugestões PHP básicas (usar só o Intelephense)
    "php.suggest.basic": false,
    "intelephense.environment.phpVersion": "8.2",
    "intelephense.files.maxSize": 5000000,
    "intelephense.stubs": [],


    // =========================================================================
    // PRETTIER (requer extensão esbenp.prettier-vscode)
    // =========================================================================

    "prettier.singleQuote": true,
    "prettier.semi": true,
    "prettier.tabWidth": 2,
    "prettier.useTabs": false,
    "prettier.printWidth": 100,
    "prettier.trailingComma": "es5",
    "prettier.bracketSpacing": true,
    "prettier.arrowParens": "always",
    "prettier.endOfLine": "lf",
    "prettier.requireConfig": false,
    "prettier.bracketSameLine": false,


    // =========================================================================
    // ESLINT (requer extensão dbaeumer.vscode-eslint)
    // =========================================================================

    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
    "eslint.run": "onType",
    "eslint.autoFixOnSave": false,
    "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" },
    "eslint.workingDirectories": [],


    // =========================================================================
    // GITLENS (requer extensão eamodio.gitlens)
    // =========================================================================

    "gitlens.currentLine.enabled": true,
    "gitlens.currentLine.format": "${author}, ${agoOrDate} • ${message|50?}",
    "gitlens.hovers.currentLine.over": "line",
    "gitlens.hovers.enabled": true,
    "gitlens.codeLens.enabled": false,
    "gitlens.statusBar.enabled": true,
    "gitlens.blame.format": "${author}, ${agoOrDate}",
    "gitlens.views.commits.avatars": true,


    // =========================================================================
    // VIM (requer extensão vscodevim.vim)
    // =========================================================================

    "vim.enable": true,
    "vim.useSystemClipboard": true,
    "vim.useCtrlKeys": true,
    "vim.hlsearch": true,
    "vim.leader": "<space>",
    "vim.easymotion": false,
    "vim.surround": true,
    "vim.sneak": false,
    "vim.insertModeKeyBindings": [],
    "vim.normalModeKeyBindingsNonRecursive": [
        { "before": ["<leader>", "f"], "commands": ["workbench.action.quickOpen"] },
        { "before": ["<leader>", "e"], "commands": ["workbench.action.toggleSidebarVisibility"] },
        { "before": ["<leader>", "g"], "commands": ["workbench.view.scm"] }
    ],


    // =========================================================================
    // LIVE SHARE (requer extensão MS-vsliveshare.vsliveshare)
    // =========================================================================

    "liveshare.presence": true,
    "liveshare.allowGuestDebugControl": false,
    "liveshare.allowGuestTaskControl": false,
    "liveshare.joinDebugSessionOption": "Prompt",


    // =========================================================================
    // DOCKER (requer extensão ms-azuretools.vscode-docker)
    // =========================================================================

    "docker.showExplorer": true,
    "docker.attachShellCommand.linuxContainer": "/bin/bash",
    "docker.tlsVerify": "",


    // =========================================================================
    // REMOTE DEVELOPMENT (requer extensões ms-vscode-remote.*)
    // =========================================================================

    "remote.SSH.remotePlatform": { "my-server": "linux" },
    "remote.SSH.connectTimeout": 30,
    "remote.SSH.showLoginTerminal": false,
    "remote.SSH.defaultExtensions": [],
    "remote.containers.defaultExtensions": [],


    // =========================================================================
    // SPELL CHECK (requer extensão streetsidesoftware.code-spell-checker)
    // =========================================================================

    "cSpell.language": "en",
    "cSpell.enableFiletypes": ["markdown", "plaintext", "python", "javascript", "typescript"],
    "cSpell.userWords": [],
    "cSpell.diagnosticLevel": "Hint",
    "cSpell.ignorePaths": ["node_modules", ".git", "dist"],


    // =========================================================================
    // MATERIAL ICON THEME (requer extensão PKief.material-icon-theme)
    // =========================================================================

    "material-icon-theme.folders.theme": "specific",
    "material-icon-theme.folders.color": "#90a4ae",
    "material-icon-theme.activeIconPack": "react",
    "material-icon-theme.showWelcomeMessage": false,


    // =========================================================================
    // REST CLIENT (requer extensão humao.rest-client)
    // =========================================================================

    // "rest-client.defaultHeaders": { "Content-Type": "application/json" },
    "rest-client.timeoutInMilliseconds": 30000,
    "rest-client.showResponseInDifferentTab": false,
    "rest-client.previewResponseInUntitledDocument": false,


    // =========================================================================
    // TODO HIGHLIGHT / BETTER COMMENTS (requer extensões)
    // =========================================================================

    "todohighlight.isEnable": true,
    "todohighlight.keywords": ["TODO:", "FIXME:", "HACK:", "NOTE:"],
    "betterComments.tags": [
        { "tag": "!", "color": "#FF2D00", "bold": true },
        { "tag": "?", "color": "#3498DB" },
        { "tag": "//", "color": "#474747" },
        { "tag": "todo", "color": "#FF8C00" },
        { "tag": "*", "color": "#98C379" }
    ]
}
```