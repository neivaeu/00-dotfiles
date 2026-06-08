#!/usr/bin/env bash

# =============================================================================
# shadow-hunter.sh — Caça a Segredos, Credenciais e Dados Sensíveis (Defensivo)
# Versão: 3.0 Elite
# Objetivo: Encontrar credenciais, tokens e segredos expostos no TUU PRÓPRIO
#            sistema para que os possas remover ou proteger.
# Uso: bash shadow-hunter.sh | tee secrets-$(hostname)-$(date +%F).log
# =============================================================================

set -uo pipefail

BOLD='\033[1m'; CYAN='\033[0;36m'; RED='\033[0;31m'
YELLOW='\033[1;33m'; GREEN='\033[0;32m'; MAGENTA='\033[0;35m'
BLUE='\033[0;34m'; WHITE='\033[1;37m'; RESET='\033[0m'

SCORE=0; WARNINGS=0
REPORT=()

log_critical() { echo -e "  ${RED}${BOLD}[CRÍTICO]${RESET} $1"; ((SCORE++)); REPORT+=("CRÍTICO: $1"); }
log_warn()     { echo -e "  ${YELLOW}[ALERTA]${RESET}  $1"; ((WARNINGS++)); REPORT+=("ALERTA: $1"); }
log_ok()       { echo -e "  ${GREEN}[OK]${RESET}      $1"; }
log_info()     { echo -e "  ${CYAN}[INFO]${RESET}    $1"; }
section()      { echo -e "\n${BLUE}${BOLD}══════════════════════════════════════════════════════${RESET}"; \
                 echo -e "${WHITE}${BOLD} ▶ $1${RESET}"; \
                 echo -e "${BLUE}${BOLD}══════════════════════════════════════════════════════${RESET}"; }

# Máscara: mostra só os primeiros 4 chars de um segredo
mask() { local s="$1"; echo "${s:0:4}$(printf '*%.0s' {1..8})"; }

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

echo -e "${MAGENTA}${BOLD}"
cat << 'EOF'
 ███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
 ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
 ███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
 ╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
 ███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝
  ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗
  ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
  ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
  ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
  ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
echo -e "${RESET}"
echo -e "${CYAN} Host: ${WHITE}${HOSTNAME}${RESET} | ${CYAN}Data: ${WHITE}${TIMESTAMP}${RESET}"
echo -e "${YELLOW} Esta ferramenta procura segredos expostos no TEU sistema para os protegeres.${RESET}\n"

# =============================================================================
# SECÇÃO 1 — Chaves SSH
# =============================================================================
section "1. Auditoria de Chaves SSH"

SSH_DIR="$HOME/.ssh"
if [[ -d "$SSH_DIR" ]]; then
    SSH_DIR_PERMS=$(stat -c "%a" "$SSH_DIR")
    [[ "$SSH_DIR_PERMS" == "700" ]] && log_ok "$HOME.ssh dir permissões: ${SSH_DIR_PERMS} (correto)." || log_warn "$HOME.ssh dir permissões: ${SSH_DIR_PERMS} (deveria ser 700)."

    # Verificar cada chave
    while IFS= read -r keyfile; do
        KPERMS=$(stat -c "%a" "$keyfile" 2>/dev/null || echo "?")
        KNAME=$(basename "$keyfile")

        if [[ "$keyfile" == *.pub ]]; then
            [[ "$KPERMS" == "644" || "$KPERMS" == "600" ]] && log_ok "${KNAME}: ${KPERMS} (chave pública OK)." || log_warn "${KNAME}: permissões ${KPERMS} (chave pública, esperado 644)."
        else
            # Chave privada
            if [[ "$KPERMS" != "600" ]]; then
                log_critical "${KNAME}: permissões ${KPERMS}! Chave privada EXPOSTA (devia ser 600)."
            else
                log_ok "${KNAME}: 600 (chave privada OK)."
            fi

            # Verificar se chave está encriptada (tem passphrase)
            if ssh-keygen -y -P "" -f "$keyfile" &>/dev/null; then
                log_warn "${KNAME}: chave privada SEM PASSPHRASE! Se roubada, é utilizável imediatamente."
            else
                log_ok "${KNAME}: protegida com passphrase."
            fi

            # Verificar tipo e tamanho de chave
            KEY_TYPE=$(ssh-keygen -l -f "$keyfile" 2>/dev/null | awk '{print $2, $4}' || echo "?")
            KEY_BITS=$(ssh-keygen -l -f "$keyfile" 2>/dev/null | awk '{print $1}' || echo "0")
            log_info "${KNAME}: tipo ${KEY_TYPE}"
            if echo "$KEY_TYPE" | grep -q "RSA" && [[ "$KEY_BITS" -lt 4096 ]]; then
                log_warn "${KNAME}: RSA < 4096 bits (${KEY_BITS}). Considera regenerar com 4096 ou migrar para Ed25519."
            fi
            if echo "$KEY_TYPE" | grep -q "DSA"; then
                log_critical "${KNAME}: tipo DSA! Algoritmo quebrado. Remove e gera Ed25519."
            fi
        fi
    done < <(find "$SSH_DIR" -type f -name "id_*" 2>/dev/null)

    # known_hosts
    if [[ -f "$SSH_DIR/known_hosts" ]]; then
        KH_PERMS=$(stat -c "%a" "$SSH_DIR/known_hosts")
        [[ "$KH_PERMS" == "600" || "$KH_PERMS" == "644" ]] && log_ok "known_hosts: ${KH_PERMS}." || log_warn "known_hosts: permissões ${KH_PERMS}."
        KH_LINES=$(wc -l < "$SSH_DIR/known_hosts" 2>/dev/null || echo "0")
        log_info "known_hosts: ${KH_LINES} entradas de hosts conhecidos."
        # HashKnownHosts?
        if head -1 "$SSH_DIR/known_hosts" 2>/dev/null | grep -q "^|1|"; then
            log_ok "known_hosts usa hashing (HashKnownHosts yes)."
        else
            log_warn "known_hosts em plaintext. Considera HashKnownHosts yes em $HOME.ssh/config."
        fi
    fi

    # authorized_keys - entradas suspeitas
    if [[ -f "$SSH_DIR/authorized_keys" ]]; then
        AK_COUNT=$(wc -l < "$SSH_DIR/authorized_keys" 2>/dev/null || echo "0")
        log_info "authorized_keys: ${AK_COUNT} chave(s) autorizada(s)."
        # Verificar command= restrito
        while IFS= read -r akline; do
            if echo "$akline" | grep -q "no-pty\|command=\|restrict"; then
                log_ok "Entrada restricted: $(echo "$akline" | cut -c1-60)..."
            elif echo "$akline" | grep -qE "^(ssh-|ecdsa-|sk-)"; then
                log_info "Chave não restrita: $(echo "$akline" | awk '{print $3}' | cut -c1-30)..."
            fi
        done < "$SSH_DIR/authorized_keys"
    fi
else
    log_info "Diretório $HOME.ssh não encontrado."
fi

# Verificar chaves SSH noutros locais
echo -e "\n  ${CYAN}[*] A procurar chaves privadas SSH noutros locais...${RESET}"
find /home /root /tmp /var /opt 2>/dev/null -type f \
    \( -name "id_rsa" -o -name "id_ed25519" -o -name "id_ecdsa" -o -name "id_dsa" -o -name "*.pem" -o -name "*.key" \) \
    ! -path "$HOME/.ssh/*" 2>/dev/null | while read -r f; do
    if file "$f" 2>/dev/null | grep -q "private key"; then
        log_critical "Chave privada fora de $HOME.ssh: ${f}"
    else
        log_warn "Ficheiro de chave suspeito: ${f}"
    fi
done

# =============================================================================
# SECÇÃO 2 — Tokens e Credenciais em Ficheiros
# =============================================================================
section "2. Varrimento de Tokens & Credenciais em Ficheiros"

# Patterns de segredos conhecidos
declare -A TOKEN_PATTERNS=(
    # Cloud
    ["AWS Access Key"]='AKIA[0-9A-Z]{16}'
    ["AWS Secret Key"]='(?i)aws.{0,20}secret.{0,20}[=:]["\s]*[A-Za-z0-9/+=]{40}'
    ["GCP API Key"]='AIza[0-9A-Za-z\-_]{35}'
    ["Azure Storage Key"]='DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[A-Za-z0-9+/=]{88}'
    # Version Control
    ["GitHub PAT"]='ghp_[0-9a-zA-Z]{36}'
    ["GitHub OAuth"]='gho_[0-9a-zA-Z]{36}'
    ["GitHub App Token"]='(ghu|ghs)_[0-9a-zA-Z]{36}'
    ["GitLab Token"]='glpat-[0-9a-zA-Z\-_]{20}'
    # Serviços
    ["Slack Token"]='xox[baprs]-[0-9A-Za-z\-]+'
    ["Slack Webhook"]='https://hooks.slack.com/services/T[a-zA-Z0-9_]+'
    ["Stripe Live Key"]='sk_live_[0-9a-zA-Z]{24,}'
    ["Stripe Test Key"]='sk_test_[0-9a-zA-Z]{24,}'
    ["Twilio"]='SK[0-9a-fA-F]{32}'
    ["SendGrid"]='SG\.[a-zA-Z0-9_\-]{22}\.[a-zA-Z0-9_\-]{43}'
    ["Mailgun"]='key-[0-9a-zA-Z]{32}'
    ["NPM Token"]='npm_[A-Za-z0-9]{36}'
    ["PyPI Token"]='pypi-[A-Za-z0-9_\-]{50,}'
    ["Docker Hub"]='dckr_pat_[A-Za-z0-9_\-]{27}'
    # Crypto
    ["Ethereum Private Key"]='0x[0-9a-fA-F]{64}'
    # Genérico
    ["JWT Token"]='eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}'
    ["Generic Bearer"]='(?i)bearer\s+[A-Za-z0-9_\-\.]{20,}'
    ["Generic Password"]='(?i)(password|passwd|pwd|secret)\s*[=:]\s*["\047]?[^\s"047]{8,}'
    ["Database URL"]='(?i)(mysql|postgres|mongodb|redis|amqp)://[^@\s]+@[^\s]+'
)

SCAN_DIRS=("$HOME" "/etc" "/opt" "/srv" "/var/www")
SCAN_EXTENSIONS=("*.env" "*.env.*" ".env" "*.yml" "*.yaml" "*.json" "*.toml" "*.ini" "*.cfg" "*.conf" "*.config" "*.properties" "*.xml" "*.sh" "*.bash" "*.py" "*.js" "*.ts" "*.rb" "*.php" "*.go" "*.java" "*.gradle" "*.tf" "*.tfvars" "*.pkr.hcl" "Makefile" "Dockerfile" "*.dockerfile")

echo -e "  ${CYAN}[*] A varrer ficheiros de configuração (maxdepth 5)...${RESET}"
FIND_ARGS=()
for ext in "${SCAN_EXTENSIONS[@]}"; do
    FIND_ARGS+=(-o -name "$ext")
done

SCANNED=0
LEAKS_FOUND=0

while IFS= read -r file; do
    [[ ! -f "$file" ]] && continue
    [[ ! -r "$file" ]] && continue
    # Ignorar binários
    if file "$file" 2>/dev/null | grep -qE "binary|ELF|executable"; then continue; fi
    ((SCANNED++))

    for label in "${!TOKEN_PATTERNS[@]}"; do
        pattern="${TOKEN_PATTERNS[$label]}"
        if grep -qP "$pattern" "$file" 2>/dev/null; then
            # Extrair valor (mascarado)
            MATCH=$(grep -oP "$pattern" "$file" 2>/dev/null | head -1 || true)
            MASKED=$(mask "$MATCH")
            log_critical "LEAK ${label}: ${file} → valor: ${MASKED}"
            ((LEAKS_FOUND++))
        fi
    done
done < <(find "${SCAN_DIRS[@]}" -maxdepth 5 \( "${FIND_ARGS[@]:1}" \) -type f 2>/dev/null)

[[ $LEAKS_FOUND -eq 0 ]] && log_ok "Nenhum token/credencial detetado nos ${SCANNED} ficheiros varridos." || log_warn "${LEAKS_FOUND} leak(s) encontrados em ${SCANNED} ficheiros."

# =============================================================================
# SECÇÃO 3 — Variáveis de Ambiente em Processos (/proc)
# =============================================================================
section "3. Segredos em Memória de Processos (/proc/PID/environ)"

echo -e "  ${CYAN}[*] A analisar variáveis de ambiente de processos ativos...${RESET}"

PROC_PATTERNS=(
    "PASSWORD" "PASSWD" "PWD" "SECRET" "TOKEN" "API_KEY" "APIKEY"
    "AWS_SECRET" "AWS_ACCESS" "GITHUB_TOKEN" "SLACK_TOKEN"
    "DATABASE_URL" "DB_PASS" "DB_PASSWORD" "REDIS_URL"
    "PRIVATE_KEY" "ENCRYPTION_KEY" "JWT_SECRET" "AUTH_TOKEN"
    "STRIPE_SECRET" "SENDGRID_API" "TWILIO_AUTH"
)

FOUND_ENV=0
for pid in /proc/[0-9]*/environ; do
    [[ ! -r "$pid" ]] && continue
    PROC_NAME=$(cat "/proc/$(echo $pid | cut -d/ -f3)/comm" 2>/dev/null || echo "?")
    ENV_CONTENT=$(tr '\0' '\n' < "$pid" 2>/dev/null || true)
    for pattern in "${PROC_PATTERNS[@]}"; do
        MATCH=$(echo "$ENV_CONTENT" | grep -i "^${pattern}=" | head -1 || true)
        if [[ -n "$MATCH" ]]; then
            KEY=$(echo "$MATCH" | cut -d= -f1)
            VAL=$(echo "$MATCH" | cut -d= -f2-)
            MASKED=$(mask "$VAL")
            log_critical "Segredo em /proc (PID $(echo $pid | cut -d/ -f3), proc: ${PROC_NAME}): ${KEY}=${MASKED}"
            ((FOUND_ENV++))
        fi
    done
done

[[ $FOUND_ENV -eq 0 ]] && log_ok "Nenhum segredo óbvio encontrado na memória de processos." || log_warn "${FOUND_ENV} variável(is) sensível(eis) em processos ativos."

# =============================================================================
# SECÇÃO 4 — Histórico de Shell (Bash, Zsh, Fish, etc.)
# =============================================================================
section "4. Auditoria de Histórico de Shell"

HIST_FILES=(
    "$HOME/.bash_history"
    "$HOME/.zsh_history"
    "$HOME/.zhistory"
    "$HOME/.sh_history"
    "$HOME/.mysql_history"
    "$HOME/.psql_history"
    "$HOME/.sqlite_history"
    "$HOME/.python_history"
    "$HOME/.node_repl_history"
    "$HOME/.irb_history"
    "$HOME/.lesshst"
)

# Padrões no histórico
HIST_PATTERNS=(
    # curl/wget com credenciais inline
    '(curl|wget)\s+.*(-u|--user)\s+[^$\s][^:]*:[^$\s]+'
    # Headers de autenticação
    'Authorization:\s*(Bearer|Basic)\s+[A-Za-z0-9+/=_\-\.]{10,}'
    # MySQL com password inline
    '(mysql|mysqldump|psql)\s+.*-p[^\s$]{2,}'
    # SSH com password (sshpass)
    'sshpass\s+-p\s*[^\s$]+'
    # Export de variáveis de ambiente com segredos
    'export\s+(PASSWORD|SECRET|TOKEN|API_KEY|AWS_SECRET)[=][^$\s"'"'"'][^\s]+'
    # Docker login
    'docker\s+login.*-p\s+[^\s$]+'
    # git remote com token
    'git\s+remote.*https://[^@\s]+@'
    # curl com header de token
    '-H\s*["\047]?(X-API-Key|Authorization|X-Auth-Token):\s*[^\047"]{10,}'
    # rsync/scp com password
    'rsync.*--password-file'
    # Comandos de criação de utilizadores com passwords
    'useradd.*-p\s+[^\s]+'
    'usermod.*-p\s+[^\s]+'
    'chpasswd.*[^|#]\s*[a-zA-Z0-9]+:[^\s]+'
    # ansible vault password inline
    'ansible.*--vault-password'
    # openssl com chave inline
    'openssl.*-pass\s+pass:[^\s]+'
    # aws configure com keys
    'aws\s+configure\s+set.*key'
    # kubectl com token
    'kubectl.*--token=[^\s]+'
    # Tokens hardcoded em comandos
    'token[=:]["\047]?[A-Za-z0-9_\-\.]{20,}'
)

for hf in "${HIST_FILES[@]}"; do
    [[ ! -f "$hf" ]] && continue
    log_info "A analisar: ${hf} ($(wc -l < "$hf" 2>/dev/null) linhas)"
    FILE_LEAKS=0

    # Remover timestamps do zsh (: TIMESTAMP:0;)
    HIST_CLEAN=$(sed 's/^: [0-9]*:[0-9]*;//' "$hf" 2>/dev/null || cat "$hf" 2>/dev/null)

    for pattern in "${HIST_PATTERNS[@]}"; do
        while IFS= read -r line; do
            # Ignorar linhas de template/placeholder
            if echo "$line" | grep -qE '(TOKEN_|REPLACE_ME|YOUR_|<|>|\$\{|\$\()'; then
                continue
            fi
            SAFE_LINE=$(echo "$line" | cut -c1-100)
            log_critical "Histórico: ${hf}"
            echo -e "    ${YELLOW}→ ${SAFE_LINE}${RESET}"
            ((FILE_LEAKS++))
            ((LEAKS_FOUND++))
        done < <(echo "$HIST_CLEAN" | grep -P "$pattern" 2>/dev/null | head -3 || true)
    done

    [[ $FILE_LEAKS -eq 0 ]] && log_ok "${hf}: sem leaks óbvios detetados."
done

# Tamanho do histórico excessivo?
BASH_HISTSIZE=$(grep -oP '(?<=HISTSIZE=)\d+' "$HOME/.bashrc" "$HOME/.bash_profile" 2>/dev/null | sort -rn | head -1 || echo "1000")
[[ "$BASH_HISTSIZE" -gt 10000 ]] && log_warn "HISTSIZE=${BASH_HISTSIZE}. Histórico muito grande aumenta exposição de segredos. Considera reduzir ou usar HISTCONTROL."

# HISTCONTROL configurado?
if grep -qE "HISTCONTROL=.*ignorespace\|HISTCONTROL=.*ignoreboth" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" 2>/dev/null; then
    log_ok "HISTCONTROL=ignorespace: comandos com espaço inicial não são gravados (útil para comandos com passwords)."
else
    log_warn "HISTCONTROL não inclui 'ignorespace'. Todos os comandos (incluindo com passwords) são gravados."
fi

# =============================================================================
# SECÇÃO 5 — Ficheiros de Configuração de Base de Dados
# =============================================================================
section "5. Credenciais de Base de Dados"

DB_CONFIG_PATTERNS=(
    "/etc/mysql/my.cnf"
    "/etc/mysql/mysql.conf.d/*.cnf"
    "$HOME/.my.cnf"
    "$HOME/.pgpass"
    "/etc/postgresql/*/main/pg_hba.conf"
    "/var/www/html/wp-config.php"
    "/var/www/*/wp-config.php"
    "/var/www/html/configuration.php"
    "/var/www/html/config/database.php"
    "/var/www/html/.env"
    "$HOME/.config/*/database*"
)

for pattern in "${DB_CONFIG_PATTERNS[@]}"; do
    for file in $pattern; do
        [[ ! -f "$file" ]] && continue
        log_info "Ficheiro de BD encontrado: ${file}"
        FPERMS=$(stat -c "%a" "$file" 2>/dev/null || echo "?")

        if [[ -w "$file" ]]; then
            log_critical "${file}: WRITABLE! (perms: ${FPERMS})"
        fi

        # WordPress
        if echo "$file" | grep -q "wp-config"; then
            for wpkey in "DB_NAME" "DB_USER" "DB_PASSWORD" "DB_HOST" "AUTH_KEY" "SECURE_AUTH_KEY"; do
                VAL=$(grep -oP "(?<='${wpkey}', ')[^']+" "$file" 2>/dev/null | head -1 || true)
                if [[ -n "$VAL" ]]; then
                    log_warn "WP config ${wpkey}: $(mask "$VAL") (em ${file})"
                fi
            done
        fi

        # .my.cnf
        if echo "$file" | grep -q "my.cnf\|.my.cnf"; then
            if grep -qi "password\s*=" "$file" 2>/dev/null; then
                PASS=$(grep -i "password\s*=" "$file" 2>/dev/null | head -1 | cut -d= -f2 | tr -d ' ')
                log_critical "${file}: password MySQL em plaintext: $(mask "$PASS")"
            fi
        fi

        # .pgpass
        if echo "$file" | grep -q "pgpass"; then
            FPERMS_DEC=$(stat -c "%a" "$file" 2>/dev/null || echo "?")
            [[ "$FPERMS_DEC" == "600" ]] && log_ok "${file}: permissões 600 (correto)." || log_warn "${file}: permissões ${FPERMS_DEC} (deveria ser 600)."
            log_warn "$HOME.pgpass contém credenciais PostgreSQL em plaintext (comportamento esperado, mas protege o ficheiro)."
        fi
    done
done

# Procurar ficheiros .env em todo o home
find "$HOME" /var/www /opt /srv -maxdepth 4 -name ".env" -o -name "*.env" 2>/dev/null | while read -r envfile; do
    if [[ -f "$envfile" ]] && [[ -r "$envfile" ]]; then
        CREDS=$(grep -cE '(?i)(password|secret|token|key).*=' "$envfile" 2>/dev/null || echo "0")
        [[ "$CREDS" -gt 0 ]] && log_warn "${CREDS} variáveis sensíveis em ${envfile}. Verifica se este ficheiro está em .gitignore."
    fi
done

# =============================================================================
# SECÇÃO 6 — VPN, Wi-Fi e Configurações de Rede
# =============================================================================
section "6. Credenciais de VPN & Wi-Fi"

# OpenVPN
echo -e "  ${CYAN}[*] A verificar configurações OpenVPN...${RESET}"
for vpndir in /etc/openvpn /etc/openvpn/client /etc/openvpn/server; do
    [[ ! -d "$vpndir" ]] && continue
    find "$vpndir" -type f \( -name "*.conf" -o -name "*.ovpn" \) 2>/dev/null | while read -r f; do
        log_info "Ficheiro OpenVPN: ${f}"
        if grep -q "<cert>\|<key>\|<tls-auth>\|<tls-crypt>" "$f" 2>/dev/null; then
            log_warn "${f}: contém certificados/chaves embutidas no ficheiro."
        fi
        if grep -qi "auth-user-pass\s*$" "$f" 2>/dev/null; then
            log_warn "${f}: credenciais de utilizador configuradas (verifica se há ficheiro de passwords)."
        fi
        PASSFILE=$(grep -oP '(?<=auth-user-pass\s)\S+' "$f" 2>/dev/null | head -1 || true)
        if [[ -n "$PASSFILE" ]] && [[ -f "$PASSFILE" ]]; then
            log_critical "Ficheiro de password OpenVPN em plaintext: ${PASSFILE}"
        fi
    done
done

# WireGuard
echo -e "\n  ${CYAN}[*] A verificar configurações WireGuard...${RESET}"
wgdir="/etc/wireguard"
if [[ -d "$wgdir" ]]; then
    while IFS= read -r f; do
        FPERMS=$(stat -c "%a" "$f" 2>/dev/null || echo "?")
        log_info "Ficheiro WireGuard: ${f} (perms: ${FPERMS})"
        if [[ "$FPERMS" != "600" ]]; then
            log_critical "${f}: permissões ${FPERMS}! Chave privada WireGuard exposta (devia ser 600)."
        fi
        if grep -q "PrivateKey" "$f" 2>/dev/null; then
            PRIVKEY=$(grep "PrivateKey" "$f" | head -1 | awk '{print $3}')
            log_warn "${f}: chave privada presente: $(mask "$PRIVKEY")"
        fi
    done < <(find "$wgdir" -maxdepth 1 -name "*.conf" -type f 2>/dev/null)
fi

# NetworkManager Wi-Fi
echo -e "\n  ${CYAN}[*] A verificar passwords Wi-Fi guardadas (NetworkManager)...${RESET}"
NM_DIR="/etc/NetworkManager/system-connections"
if [[ -d "$NM_DIR" ]]; then
    find "$NM_DIR" -type f 2>/dev/null | while read -r nmfile; do
        NMPERMS=$(stat -c "%a" "$nmfile" 2>/dev/null || echo "?")
        SSID=$(grep -oP '(?<=^ssid=).+' "$nmfile" 2>/dev/null | head -1 || echo "?")
        if [[ -r "$nmfile" ]]; then
            log_warn "Perfil Wi-Fi legível: ${nmfile} (SSID: ${SSID}, perms: ${NMPERMS})"
            WIFI_PASS=$(grep -oP '(?<=^psk=).+' "$nmfile" 2>/dev/null | head -1 || true)
            if [[ -n "$WIFI_PASS" ]]; then
                log_critical "Password Wi-Fi em plaintext (SSID: ${SSID}): $(mask "$WIFI_PASS")"
            fi
            # 802.1X EAP (enterprise)
            if grep -q "identity=\|password=" "$nmfile" 2>/dev/null; then
                EAP_PASS=$(grep "^password=" "$nmfile" 2>/dev/null | head -1 | cut -d= -f2 || true)
                [[ -n "$EAP_PASS" ]] && log_critical "Credenciais Wi-Fi Enterprise (EAP) em plaintext em ${nmfile}."
            fi
        fi
        if [[ "$NMPERMS" != "600" ]]; then
            log_warn "${nmfile}: permissões ${NMPERMS} (deveria ser 600 ou 640)."
        fi
    done
else
    log_info "NetworkManager connections dir não encontrada (${NM_DIR})."
fi

# wpa_supplicant
if [[ -f /etc/wpa_supplicant/wpa_supplicant.conf ]]; then
    WPA_PERMS=$(stat -c "%a" /etc/wpa_supplicant/wpa_supplicant.conf)
    log_info "wpa_supplicant.conf encontrado (perms: ${WPA_PERMS})"
    if [[ -r /etc/wpa_supplicant/wpa_supplicant.conf ]]; then
        WPAS_SSIDS=$(grep -c "ssid=" /etc/wpa_supplicant/wpa_supplicant.conf 2>/dev/null || echo "0")
        log_warn "/etc/wpa_supplicant/wpa_supplicant.conf legível! ${WPAS_SSIDS} rede(s) guardada(s) com passwords."
    fi
fi

# =============================================================================
# SECÇÃO 7 — Credenciais de Cloud & DevOps
# =============================================================================
section "7. Configurações Cloud & DevOps"

# AWS credentials
echo -e "  ${CYAN}[*] AWS...${RESET}"
for awsfile in "$HOME/.aws/credentials" "$HOME/.aws/config"; do
    if [[ -f "$awsfile" ]]; then
        AWSPERMS=$(stat -c "%a" "$awsfile")
        log_info "${awsfile} encontrado (perms: ${AWSPERMS})"
        [[ "$AWSPERMS" != "600" ]] && log_warn "${awsfile}: perms ${AWSPERMS} (deveria ser 600)."
        PROFILES=$(grep -c "^\[" "$awsfile" 2>/dev/null || echo "0")
        log_info "${awsfile}: ${PROFILES} perfil(is) AWS configurado(s)."
    fi
done

# GCP
echo -e "\n  ${CYAN}[*] Google Cloud (gcloud)...${RESET}"
GCP_CRED_DIR="$HOME/.config/gcloud"
if [[ -d "$GCP_CRED_DIR" ]]; then
    log_info "gcloud credentials em ${GCP_CRED_DIR}."
    find "$GCP_CRED_DIR" -name "*.json" 2>/dev/null | while read -r f; do
        if grep -q "private_key\|client_secret" "$f" 2>/dev/null; then
            log_warn "Service account key GCP: ${f}"
        fi
    done
fi

# Azure
echo -e "\n  ${CYAN}[*] Azure...${RESET}"
AZURE_CRED_DIR="$HOME/.azure"
if [[ -d "$AZURE_CRED_DIR" ]]; then
    log_info "Azure credentials em ${AZURE_CRED_DIR}."
    find "$AZURE_CRED_DIR" -name "*.json" 2>/dev/null | while read -r f; do
        if grep -q "accessToken\|clientSecret" "$f" 2>/dev/null; then
            log_warn "Token Azure encontrado: ${f}"
        fi
    done
fi

# kubectl / kubeconfig
echo -e "\n  ${CYAN}[*] Kubernetes (kubectl)...${RESET}"
KUBECONFIG_FILE="${KUBECONFIG:-$HOME/.kube/config}"
if [[ -f "$KUBECONFIG_FILE" ]]; then
    KPERMS=$(stat -c "%a" "$KUBECONFIG_FILE")
    log_info "kubeconfig encontrado: ${KUBECONFIG_FILE} (perms: ${KPERMS})"
    [[ "$KPERMS" != "600" ]] && log_warn "kubeconfig perms ${KPERMS} (deveria ser 600)."
    if grep -q "token:" "$KUBECONFIG_FILE" 2>/dev/null; then
        log_warn "kubeconfig contém tokens de acesso ao cluster Kubernetes."
    fi
fi

# Docker config (tokens de registry)
if [[ -f "$HOME/.docker/config.json" ]]; then
    DPERMS=$(stat -c "%a" "$HOME/.docker/config.json")
    log_info "Docker config: ${HOME}/.docker/config.json (perms: ${DPERMS})"
    if grep -q '"auth"' "$HOME/.docker/config.json" 2>/dev/null; then
        AUTH=$(python3 -c "import json,base64,sys; d=json.load(open('$HOME/.docker/config.json')); [print(k) for k in d.get('auths',{}).keys()]" 2>/dev/null || grep -oP '"https://[^"]*"' "$HOME/.docker/config.json" || true)
        log_warn "Docker config contém credenciais de registry: ${AUTH}. Considera usar credential store."
    fi
fi

# Terraform state (pode conter segredos)
find "$HOME" /opt /srv -maxdepth 5 -name "terraform.tfstate" -o -name "*.tfstate" 2>/dev/null | while read -r tsf; do
    if grep -qi "password\|secret\|private_key\|access_key" "$tsf" 2>/dev/null; then
        log_critical "terraform.tfstate com segredos: ${tsf} — State files não devem ser commitados!"
    fi
done

# =============================================================================
# SECÇÃO 8 — Git: Repositórios & Commits
# =============================================================================
section "8. Repositórios Git & Segredos Commitados"

# Ficheiros .git com credenciais
find "$HOME" /var/www /opt -maxdepth 5 -name ".git" -type d 2>/dev/null | while read -r gitdir; do
    REPO=$(dirname "$gitdir")
    log_info "Repositório git: ${REPO}"

    # Verificar credenciais em .git/config (remotes com tokens)
    if grep -qE "https://[^@\s]+@" "${gitdir}/config" 2>/dev/null; then
        log_critical "Credentials no git remote URL: $(grep 'url = https://' "${gitdir}/config" | head -1 | sed 's/.*= //')"
    fi

    # .gitignore existe?
    if [[ ! -f "${REPO}/.gitignore" ]]; then
        log_warn "Sem .gitignore em ${REPO}."
    else
        # Ficheiros sensíveis não cobertos pelo .gitignore?
        for sensitive in ".env" "*.pem" "*.key" "credentials.json" "secrets.yml" "config/secrets*"; do
            if ! grep -q "^${sensitive%.*}\|${sensitive}" "${REPO}/.gitignore" 2>/dev/null; then
                if find "$REPO" -maxdepth 2 -name "$sensitive" 2>/dev/null | grep -q .; then
                    log_warn "${REPO}: '${sensitive}' existe mas pode não estar em .gitignore."
                fi
            fi
        done
    fi
done

# git credential store (credenciais em plaintext)
if [[ -f "$HOME/.git-credentials" ]]; then
    GITCRED_COUNT=$(wc -l < "$HOME/.git-credentials" 2>/dev/null || echo "0")
    log_critical "$HOME.git-credentials existe! ${GITCRED_COUNT} credencial(ais) em PLAINTEXT."
    echo "  Considera: git config --global credential.helper store → substitui por libsecret/manager."
fi

if git config --global credential.helper 2>/dev/null | grep -q "^store$"; then
    log_warn "git credential.helper=store. Credenciais são guardadas em plaintext em $HOME.git-credentials."
fi

# =============================================================================
# SECÇÃO 9 — GPG & Password Managers
# =============================================================================
section "9. GPG, Password Managers & Wallets"

# GPG
echo -e "  ${CYAN}[*] Chaves GPG...${RESET}"
if command -v gpg &>/dev/null; then
    GPG_KEYS=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -c "sec" || echo "0")
    log_info "${GPG_KEYS} chave(s) privada(s) GPG no keyring."
    # GPG agent socket
    if [[ -S "$HOME/.gnupg/S.gpg-agent" ]]; then
        log_info "GPG agent socket ativo (chaves podem estar em cache)."
    fi
    # trust db
    GPG_DIR_PERMS=$(stat -c "%a" "$HOME/.gnupg" 2>/dev/null || echo "?")
    [[ "$GPG_DIR_PERMS" == "700" ]] && log_ok "$HOME.gnupg: permissões 700 OK." || log_warn "$HOME.gnupg: permissões ${GPG_DIR_PERMS} (deveria ser 700)."
fi

# Password stores
echo -e "\n  ${CYAN}[*] Password stores locais...${RESET}"
[[ -d "$HOME/.password-store" ]] && log_ok "pass (password-store) encontrado em $HOME.password-store. Encriptado com GPG."
[[ -f "$HOME/.config/keepassxc/keepassxc.ini" ]] && log_ok "KeePassXC configurado."
if find "$HOME" -maxdepth 3 -name "*.kdbx" 2>/dev/null | grep -q .; then
    log_ok "Base de dados KeePass (.kdbx) encontrada (encriptada)."
fi

# Keyring GNOME
if [[ -d "$HOME/.local/share/keyrings" ]]; then
    log_info "GNOME Keyring presente. Passwords de apps podem estar guardadas aqui."
fi

# =============================================================================
# SECÇÃO 10 — Browser & Cookies
# =============================================================================
section "10. Credenciais Guardadas em Browsers"

BROWSER_PATHS=(
    "$HOME/.mozilla/firefox"
    "$HOME/.config/google-chrome"
    "$HOME/.config/chromium"
    "$HOME/.config/BraveSoftware"
    "$HOME/.config/microsoft-edge"
)

for bpath in "${BROWSER_PATHS[@]}"; do
    [[ ! -d "$bpath" ]] && continue
    BNAME=$(basename "$bpath")
    log_info "Browser encontrado: ${BNAME} (${bpath})"

    # Procurar ficheiros de passwords
    find "$bpath" -name "Login Data" -o -name "logins.json" 2>/dev/null | while read -r lf; do
        SIZE=$(du -sh "$lf" 2>/dev/null | awk '{print $1}')
        log_warn "Ficheiro de logins do browser: ${lf} (${SIZE}) — pode conter passwords guardadas."
    done

    # Cookies
    find "$bpath" -name "Cookies" -o -name "cookies.sqlite" 2>/dev/null | while read -r cf; do
        SIZE=$(du -sh "$cf" 2>/dev/null | awk '{print $1}')
        log_info "Cookies: ${cf} (${SIZE}) — sessões ativas podem estar aqui."
    done
done

# =============================================================================
# SUMÁRIO FINAL
# =============================================================================
echo -e "\n\n${MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════════╗"
echo -e "║           SUMÁRIO — SHADOW HUNTER AUDIT ELITE               ║"
echo -e "╚══════════════════════════════════════════════════════════════╝${RESET}"
echo -e "  ${RED}${BOLD}Críticos: ${SCORE}${RESET}    ${YELLOW}Alertas: ${WARNINGS}${RESET}"
echo ""

if [[ ${#REPORT[@]} -gt 0 ]]; then
    echo -e "${BOLD}Achados principais:${RESET}"
    for item in "${REPORT[@]}"; do
        if [[ "$item" == CRÍTICO* ]]; then
            echo -e "  ${RED}• ${item}${RESET}"
        else
            echo -e "  ${YELLOW}• ${item}${RESET}"
        fi
    done
fi

echo -e "\n${CYAN}${BOLD}Recomendações gerais:${RESET}"
echo -e "  ${GREEN}•${RESET} Usa um gestor de passwords (KeePassXC, pass, Bitwarden)"
echo -e "  ${GREEN}•${RESET} Armazena segredos em variáveis de ambiente, nunca em ficheiros commitados"
echo -e "  ${GREEN}•${RESET} Usa 'git-secrets' ou 'pre-commit' hooks para prevenir commits de credenciais"
echo -e "  ${GREEN}•${RESET} Configura HISTCONTROL=ignoreboth no teu shell"
echo -e "  ${GREEN}•${RESET} Usa ssh-agent com chaves protegidas por passphrase"
echo -e "\n${BOLD}${MAGENTA}Hunt Elite terminado. Resultados guardados se usaste tee.${RESET}\n"