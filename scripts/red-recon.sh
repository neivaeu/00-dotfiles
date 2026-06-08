#!/usr/bin/env bash
# =============================================================================
# red-recon.sh — Auditoria Completa de Segurança Local (Uso Pessoal/Defensivo)
# Versão: 3.0 Elite
# Objetivo: Identificar vetores de escalada de privilégios e misconfigurações
#            no TEU PRÓPRIO sistema para que os possas corrigir.
# Uso: sudo bash red-recon.sh | tee audit-$(hostname)-$(date +%F).log
# =============================================================================

set -uo pipefail

# ─────────────────────────────────────────────────────────────────
# CORES
# ─────────────────────────────────────────────────────────────────
BOLD='\033[1m'; CYAN='\033[0;36m'; RED='\033[0;31m'
YELLOW='\033[1;33m'; GREEN='\033[0;32m'; MAGENTA='\033[0;35m'
BLUE='\033[0;34m'; WHITE='\033[1;37m'; RESET='\033[0m'

SCORE=0          # Contador de achados críticos
WARNINGS=0       # Contador de alertas médios
REPORT=()        # Array de sumário final

log_critical() { echo -e "  ${RED}${BOLD}[CRÍTICO]${RESET} $1"; ((SCORE++)); REPORT+=("CRÍTICO: $1"); }
log_warn()     { echo -e "  ${YELLOW}[ALERTA]${RESET}  $1"; ((WARNINGS++)); REPORT+=("ALERTA: $1"); }
log_ok()       { echo -e "  ${GREEN}[OK]${RESET}      $1"; }
log_info()     { echo -e "  ${CYAN}[INFO]${RESET}    $1"; }
section()      { echo -e "\n${BLUE}${BOLD}══════════════════════════════════════════════════════${RESET}"; \
                 echo -e "${WHITE}${BOLD} ▶ $1${RESET}"; \
                 echo -e "${BLUE}${BOLD}══════════════════════════════════════════════════════${RESET}"; }

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)

echo -e "${RED}${BOLD}"
cat << 'EOF'
 ██████╗ ███████╗██████╗       ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
 ██╔══██╗██╔════╝██╔══██╗      ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
 ██████╔╝█████╗  ██║  ██║█████╗██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
 ██╔══██╗██╔══╝  ██║  ██║╚════╝██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
 ██║  ██║███████╗██████╔╝      ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
 ╚═╝  ╚═╝╚══════╝╚═════╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
EOF
echo -e "${RESET}"
echo -e "${CYAN} Host: ${WHITE}${HOSTNAME}${RESET} | ${CYAN}Utilizador: ${WHITE}${CURRENT_USER}${RESET} | ${CYAN}Data: ${WHITE}${TIMESTAMP}${RESET}"
echo -e "${YELLOW} AVISO: Esta ferramenta é para auditar o TUU PRÓPRIO sistema. Usa com responsabilidade.${RESET}\n"

# Verificar se corre como root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}${BOLD}[!] A correr sem root. Algumas verificações serão limitadas. Recomendado: sudo bash $0${RESET}\n"
fi

# =============================================================================
# SECÇÃO 1 — Sistema Operativo & Kernel
# =============================================================================
section "1. Sistema Operativo & Kernel"

KERNEL=$(uname -r)
ARCH=$(uname -m)
OS_NAME=$(grep -oP '(?<=^NAME=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "Desconhecido")
OS_VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "?")

log_info "Kernel: ${KERNEL} | Arch: ${ARCH}"
log_info "SO: ${OS_NAME} ${OS_VERSION}"
log_info "Uptime: $(uptime -p 2>/dev/null || uptime)"

# Verificar kernels antigos/vulneráveis
KERNEL_MAJOR=$(echo "$KERNEL" | cut -d. -f1)
KERNEL_MINOR=$(echo "$KERNEL" | cut -d. -f2)

if [[ "$KERNEL_MAJOR" -lt 4 ]] || { [[ "$KERNEL_MAJOR" -eq 4 ]] && [[ "$KERNEL_MINOR" -lt 15 ]]; }; then
    log_critical "Kernel ${KERNEL} é antigo. Vulnerável a DirtyCow, PTRACE, Spectre/Meltdown e outros."
fi

# CVEs conhecidos do kernel por versão
declare -A KERNEL_CVES=(
    ["5.8"]="CVE-2021-3490 (eBPF OOB Write)"
    ["5.7"]="CVE-2021-22555 (Netfilter heap overflow)"
    ["4.4"]="CVE-2016-5195 (DirtyCow), CVE-2017-7308"
    ["3."]="CVE-2016-5195 (DirtyCow), múltiplos PTR derefs"
)
for ver in "${!KERNEL_CVES[@]}"; do
    if [[ "$KERNEL" == *"${ver}"* ]]; then
        log_warn "Kernel ${KERNEL} possivelmente afetado por: ${KERNEL_CVES[$ver]}"
    fi
done

# Verificar PTI (Meltdown mitigation)
if [[ -f /sys/kernel/debug/x86/pti_enabled ]]; then
    PTI=$(cat /sys/kernel/debug/x86/pti_enabled 2>/dev/null || echo "?")
    [[ "$PTI" == "1" ]] && log_ok "PTI (Meltdown mitigation) ativo." || log_warn "PTI desativado! Vulnerável a Meltdown."
fi

# Verificar ASLR
ASLR=$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo "?")
case "$ASLR" in
    2) log_ok "ASLR completo ativo (randomize_va_space=2)." ;;
    1) log_warn "ASLR parcial (=1). Recomendado =2 em /etc/sysctl.conf." ;;
    0) log_critical "ASLR DESATIVADO! Stack/heap previsíveis. Facilita exploits." ;;
    *) log_info "ASLR: estado desconhecido." ;;
esac

# Verificar dmesg restrito
DMESG=$(cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo "?")
[[ "$DMESG" == "1" ]] && log_ok "dmesg_restrict=1 (restrição ativa)." || log_warn "dmesg_restrict=0. Utilizadores não-root podem ler dmesg (vazamento de info do kernel)."

# Verificar kptr_restrict
KPTR=$(cat /proc/sys/kernel/kptr_restrict 2>/dev/null || echo "?")
[[ "$KPTR" -ge 1 ]] 2>/dev/null && log_ok "kptr_restrict=${KPTR} (ponteiros do kernel ocultos)." || log_warn "kptr_restrict=0. Endereços do kernel visíveis em /proc/kallsyms."

# =============================================================================
# SECÇÃO 2 — Utilizador, Grupos e Sudo
# =============================================================================
section "2. Utilizador, Grupos e Configuração Sudo"

log_info "Identidade: $(id)"
log_info "Shell: ${SHELL}"

# Grupos perigosos
GROUPS_LIST=$(id -Gn)
DANGER_GROUPS=("docker" "lxd" "lxc" "disk" "adm" "shadow" "wheel" "sudo" "video" "plugdev" "kvm" "libvirt" "vboxusers")
for grp in "${DANGER_GROUPS[@]}"; do
    if echo "$GROUPS_LIST" | grep -qw "$grp"; then
        case "$grp" in
            docker|lxd|lxc) log_critical "Membro do grupo '${grp}'! Escalada para root trivial via containers." ;;
            disk)           log_critical "Membro do grupo 'disk'! Acesso direto a raw devices (/dev/sdX)." ;;
            shadow)         log_critical "Membro do grupo 'shadow'! Podes ler /etc/shadow e fazer hash dumping." ;;
            sudo|wheel)     log_warn    "Membro do grupo '${grp}'. Verifica entradas em /etc/sudoers." ;;
            adm)            log_warn    "Membro do grupo 'adm'. Acesso a logs do sistema (/var/log)." ;;
            *)              log_info    "Membro do grupo '${grp}'." ;;
        esac
    fi
done

# Sudo sem password
echo -e "\n  ${CYAN}${BOLD}[*] A testar regras sudo...${RESET}"
if command -v sudo &>/dev/null; then
    # Versão
    SUDO_VER=$(sudo -V 2>/dev/null | grep "Sudo version" | awk '{print $3}')
    log_info "Sudo versão: ${SUDO_VER}"

    # CVE-2021-3156 Baron Samedit
    if echo "${SUDO_VER}" | grep -qE "^1\.(8\.|9\.[0-4]|9\.5p1)"; then
        log_critical "CVE-2021-3156 (Baron Samedit): versão ${SUDO_VER} vulnerável! Buffer overflow → root."
    fi
    # CVE-2019-14287
    if echo "${SUDO_VER}" | grep -qE "^1\.(8\.[0-9]\.|8\.[12][0-9]\.)"; then
        log_warn "CVE-2019-14287: sudo < 1.8.28 pode permitir execução como root com 'sudo -u#-1'."
    fi
    # CVE-2023-22809 (sudoedit)
    if echo "${SUDO_VER}" | grep -qE "^1\.9\.(1[0-2]|[0-9])\."; then
        log_warn "CVE-2023-22809 (sudoedit): versões 1.9.0-1.9.12 vulneráveis a escape de editor."
    fi

    SUDO_L=$(sudo -ln 2>/dev/null || true)
    if echo "$SUDO_L" | grep -qi "NOPASSWD"; then
        log_warn "Entradas NOPASSWD em sudo! Comandos executáveis sem password:"
        echo "$SUDO_L" | grep -i "NOPASSWD" | awk '{print "    → " $0}'
    fi
    if echo "$SUDO_L" | grep -qE "\(ALL.*\).*ALL|NOPASSWD.*ALL"; then
        log_critical "Sudo com permissão (ALL) ALL! Escalada para root imediata."
    fi
    # Verificar sudo com env_keep perigoso
    if sudo -ln 2>/dev/null | grep -q "env_keep"; then
        log_warn "sudo env_keep configurado. Variáveis de ambiente podem ser preservadas (LD_PRELOAD, etc.)."
    fi
fi

# /etc/sudoers legível
if [[ -r /etc/sudoers ]]; then
    log_warn "/etc/sudoers é LEGÍVEL pelo utilizador atual."
    # Procurar entradas perigosas
    grep -vE "^#|^Defaults|^$" /etc/sudoers 2>/dev/null | grep -v "^%" | awk '{print "    > " $0}'
fi

# =============================================================================
# SECÇÃO 3 — PATH Hijacking
# =============================================================================
section "3. PATH Hijacking & Injeção de Binários"

IFS=':' read -ra PATH_DIRS <<< "$PATH"
PATH_VULN=0
for dir in "${PATH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        PERMS=$(stat -c "%a" "$dir" 2>/dev/null || echo "?")
        if [[ -w "$dir" ]]; then
            log_critical "PATH dir WRITABLE: '${dir}' (perms: ${PERMS}) — podes injetar binários maliciosos!"
            PATH_VULN=1
        fi
        # Verificar se é diretório relativo (perigosíssimo)
        if [[ "$dir" == "." ]] || [[ "$dir" == "" ]]; then
            log_critical "PATH contém diretório relativo '${dir}'! Qualquer diretório de trabalho é pesquisado."
            PATH_VULN=1
        fi
    else
        log_info "PATH dir não existente: '${dir}' (pode ser criada e explorada)."
    fi
done
[[ $PATH_VULN -eq 0 ]] && log_ok "Nenhum diretório writable ou relativo no \$PATH."

# Verificar PATH em sudoers (secure_path)
if sudo -V 2>/dev/null | grep -q "secure_path"; then
    log_ok "sudo usa secure_path (PATH isolado durante execução sudo)."
else
    log_warn "sudo pode não usar secure_path — PATH do utilizador pode ser herdado."
fi

# =============================================================================
# SECÇÃO 4 — SUID / SGID
# =============================================================================
section "4. Binários SUID / SGID"

WHITELIST_SUID="ping|ping6|su|sudo|passwd|chsh|chfn|newgrp|mount|umount|pkexec|dbus-daemon-launch-helper|ssh-keysign|polkit-agent-helper-1|Xorg|at|crontab|wall|write|fusermount|fusermount3|unix_chkpwd|pam_timestamp_check|gpasswd|newuidmap|newgidmap|snap"

GTFOBINS="nmap|vim|vi|find|bash|sh|more|less|nano|cp|mv|awk|python|python3|ruby|php|perl|tar|zip|unzip|wget|curl|nc|netcat|socat|tee|dd|scp|rsync|env|node|lua|ftp|tftp|ssh|as|ar|base32|base64|busybox|cat|chmod|chown|column|comm|cpio|csh|cut|date|diff|dmesg|docker|ed|emacs|expand|expect|file|fmt|fold|gawk|gcc|git|grep|head|install|ionice|jjs|journalctl|jq|kill|ld|ld.so|logsave|look|ltrace|make|mawk|minicom|msgattrib|msgcat|msgconv|msgfilter|msgmerge|msguniq|mv|mysql|nice|nl|nohup|od|openssl|pg|pico|pip|rpm|rpmquery|run-parts|rvim|sed|setarch|shuf|sort|sqlite3|ss|stdbuf|strace|tail|taskset|timeout|ul|unexpand|uniq|unshare|update-alternatives|uudecode|uuencode|valgrind|watch|xargs|xxd|xz|zip|zsh"

echo ""
SUID_FOUND=0
while IFS= read -r bin; do
    BASENAME=$(basename "$bin")
    if ! echo "$BASENAME" | grep -qE "^(${WHITELIST_SUID})$"; then
        if echo "$BASENAME" | grep -qE "^(${GTFOBINS})$"; then
            log_critical "GTFOBins SUID: ${bin} → Escalada de privilégios documentada em gtfobins.github.io"
        else
            OWNER=$(stat -c "%U" "$bin" 2>/dev/null || echo "?")
            PERMS=$(stat -c "%a" "$bin" 2>/dev/null || echo "?")
            log_warn "SUID/SGID suspeito: ${bin} (dono: ${OWNER}, perms: ${PERMS})"
        fi
        SUID_FOUND=1
    fi
done < <(find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt 2>/dev/null \
         -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null)

[[ $SUID_FOUND -eq 0 ]] && log_ok "Nenhum SUID/SGID anómalo encontrado."

# =============================================================================
# SECÇÃO 5 — Linux Capabilities
# =============================================================================
section "5. Linux Capabilities (Vetor Furtivo)"

if command -v getcap &>/dev/null; then
    CAPS=$(getcap -r / 2>/dev/null | grep -v "^getcap:" || true)
    if [[ -n "$CAPS" ]]; then
        DANGER_CAPS="cap_setuid|cap_setgid|cap_dac_override|cap_dac_read_search|cap_sys_admin|cap_sys_ptrace|cap_net_admin|cap_net_raw|cap_sys_rawio|cap_sys_module|cap_chown|cap_fowner"
        while IFS= read -r line; do
            BIN=$(echo "$line" | awk '{print $1}')
            CAP=$(echo "$line" | awk '{print $2}')
            if echo "$CAP" | grep -qE "${DANGER_CAPS}"; then
                log_critical "Capability perigosa: ${line} → Possível escalada de privilégios."
            else
                log_warn "Capability: ${line}"
            fi
        done <<< "$CAPS"
    else
        log_ok "Nenhuma capability anómala encontrada."
    fi
else
    log_warn "'getcap' não instalado. Instala com: apt install libcap2-bin"
fi

# =============================================================================
# SECÇÃO 6 — Cron Jobs (Sistema e Utilizador)
# =============================================================================
section "6. Cron Jobs & Tarefas Agendadas"

CRON_LOCATIONS=(
    "/etc/crontab"
    "/etc/cron.d"
    "/etc/cron.daily"
    "/etc/cron.weekly"
    "/etc/cron.monthly"
    "/etc/cron.hourly"
    "/var/spool/cron"
    "/var/spool/cron/crontabs"
)

for loc in "${CRON_LOCATIONS[@]}"; do
    if [[ -e "$loc" ]]; then
        # Verificar writable
        if [[ -w "$loc" ]]; then
            log_critical "Cron WRITABLE: ${loc} → podes injetar comandos a correr como root!"
        fi
        # Verificar scripts referenciados que são writable
        if [[ -f "$loc" ]]; then
            while IFS= read -r line; do
                # Extrair caminhos de scripts da linha de cron
                SCRIPT=$(echo "$line" | grep -oP '(/[^ ]+\.(sh|py|rb|pl|bash))' | head -1 || true)
                if [[ -n "$SCRIPT" ]] && [[ -f "$SCRIPT" ]] && [[ -w "$SCRIPT" ]]; then
                    log_critical "Script de cron WRITABLE: ${SCRIPT} (referenciado em ${loc})"
                fi
                # Verificar se usa caminhos relativos
                if echo "$line" | grep -qE "^\s*[*0-9]" && echo "$line" | grep -qP "\s+[^/\s][^\s]*(\.sh|python|perl|ruby|bash|sh)\b"; then
                    log_warn "Possível caminho relativo em cron: ${line}"
                fi
            done < <(grep -vE "^#|^$" "$loc" 2>/dev/null || true)
        fi
    fi
done

# systemd timers (equivalente moderno de cron)
echo -e "\n  ${CYAN}[*] Verificando systemd timers...${RESET}"
if command -v systemctl &>/dev/null; then
    TIMERS=$(systemctl list-timers --all 2>/dev/null | grep -v "^0 timers" | head -20 || true)
    if [[ -n "$TIMERS" ]]; then
        log_info "Timers systemd ativos (verifica os scripts associados):"
        echo "$TIMERS" | head -10 | awk '{print "    " $0}'
    fi
fi

# =============================================================================
# SECÇÃO 7 — Configuração SSH
# =============================================================================
section "7. Configuração SSH (sshd_config)"

SSHD_CONFIG="/etc/ssh/sshd_config"
if [[ -f "$SSHD_CONFIG" ]]; then
    check_ssh() {
        local key="$1" good="$2" msg_bad="$3"
        local val
        val=$(grep -iE "^${key}\s+" "$SSHD_CONFIG" 2>/dev/null | tail -1 | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
        if [[ -z "$val" ]]; then
            log_info "${key}: não definido (usa default). Verifica man sshd_config."
        elif [[ "$val" == "$good" ]]; then
            log_ok "${key}: ${val}"
        else
            log_warn "${msg_bad} (atual: ${val})"
        fi
    }

    check_ssh "PermitRootLogin"      "no"        "PermitRootLogin não é 'no'! Login root via SSH possível."
    check_ssh "PasswordAuthentication" "no"      "PasswordAuthentication ativo! Permite brute-force de passwords."
    check_ssh "PermitEmptyPasswords"  "no"        "PermitEmptyPasswords ativo! Login sem password possível."
    check_ssh "X11Forwarding"         "no"        "X11Forwarding ativo! Possível hijacking de sessão gráfica."
    check_ssh "UsePAM"               "yes"        "UsePAM desativado. Reduz controlo de autenticação."
    check_ssh "StrictModes"          "yes"        "StrictModes desativado! SSH não verifica permissões de ficheiros."
    check_ssh "Protocol"             ""           "" # informativo apenas

    # Protocolo SSH1
    if grep -qiE "^Protocol\s+1" "$SSHD_CONFIG" 2>/dev/null; then
        log_critical "SSH Protocol 1 ativo! Altamente vulnerável (MITM, etc.). Usa apenas Protocol 2."
    fi

    # MaxAuthTries baixo?
    MAX_AUTH=$(grep -iE "^MaxAuthTries\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
    if [[ -z "$MAX_AUTH" ]]; then
        log_warn "MaxAuthTries não definido (default=6). Recomendado: MaxAuthTries 3."
    elif [[ "$MAX_AUTH" -gt 4 ]]; then
        log_warn "MaxAuthTries=${MAX_AUTH}. Recomendado ≤3 para dificultar brute-force."
    else
        log_ok "MaxAuthTries=${MAX_AUTH}."
    fi

    # Port padrão?
    SSH_PORT=$(grep -iE "^Port\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}' || echo "22")
    [[ "$SSH_PORT" == "22" ]] && log_warn "SSH na porta padrão 22. Considera mudar para reduzir scan automatizado." || log_ok "SSH na porta não-padrão: ${SSH_PORT}."

    # Chaves de host fracas
    if grep -qiE "^HostKey.*ecdsa|^HostKey.*dsa" "$SSHD_CONFIG" 2>/dev/null; then
        log_warn "Chaves ECDSA/DSA configuradas. Considera usar apenas Ed25519 e RSA ≥4096."
    fi

    # AllowUsers / AllowGroups definidos?
    if ! grep -qiE "^(AllowUsers|AllowGroups)\s+" "$SSHD_CONFIG" 2>/dev/null; then
        log_warn "AllowUsers/AllowGroups não definidos. Qualquer utilizador do sistema pode tentar login SSH."
    else
        log_ok "AllowUsers/AllowGroups configurados (restrição de acesso ativa)."
    fi
else
    log_info "sshd_config não encontrado (SSH possivelmente não instalado)."
fi

# Authorized keys com permissões erradas
if [[ -f "$HOME/.ssh/authorized_keys" ]]; then
    AK_PERMS=$(stat -c "%a" "$HOME/.ssh/authorized_keys" 2>/dev/null)
    [[ "$AK_PERMS" == "600" || "$AK_PERMS" == "644" ]] && log_ok "$HOME/.ssh/authorized_keys permissões OK (${AK_PERMS})." || log_warn "$HOME/.ssh/authorized_keys permissões ${AK_PERMS} (deveria ser 600)."
fi

# =============================================================================
# SECÇÃO 8 — Ficheiros Críticos do Sistema
# =============================================================================
section "8. Permissões em Ficheiros Críticos"

declare -A CRITICAL_FILES=(
    ["/etc/passwd"]="644"
    ["/etc/shadow"]="640"
    ["/etc/group"]="644"
    ["/etc/gshadow"]="640"
    ["/etc/sudoers"]="440"
    ["/etc/crontab"]="644"
    ["/etc/hosts"]="644"
    ["/etc/hostname"]="644"
    ["/etc/fstab"]="644"
    ["/boot/grub/grub.cfg"]="600"
    ["/etc/ssh/sshd_config"]="600"
    ["/etc/pam.d/su"]="644"
)

for file in "${!CRITICAL_FILES[@]}"; do
    EXPECTED="${CRITICAL_FILES[$file]}"
    if [[ -e "$file" ]]; then
        ACTUAL=$(stat -c "%a" "$file" 2>/dev/null || echo "?")
        OWNER=$(stat -c "%U:%G" "$file" 2>/dev/null || echo "?")

        if [[ -w "$file" ]]; then
            log_critical "${file} TEM PERMISSÃO DE ESCRITA pelo utilizador atual! (perms: ${ACTUAL}, dono: ${OWNER})"
        elif [[ "$ACTUAL" != "$EXPECTED" ]]; then
            log_warn "${file}: permissões ${ACTUAL} (esperado: ${EXPECTED}, dono: ${OWNER})"
        else
            log_ok "${file}: permissões ${ACTUAL} OK."
        fi

        # Shadow legível por não-root
        if [[ "$file" == "/etc/shadow" ]] && [[ -r "$file" ]]; then
            log_critical "/etc/shadow LEGÍVEL! Hash dumping possível → cracking offline com hashcat/john."
        fi
    fi
done

# World-writable em /etc e /usr
echo -e "\n  ${CYAN}[*] A procurar ficheiros world-writable em locais críticos...${RESET}"
WW_FILES=$(find /etc /usr/bin /usr/sbin /bin /sbin -type f -perm -0002 2>/dev/null || true)
if [[ -n "$WW_FILES" ]]; then
    log_critical "Ficheiros world-writable encontrados:"
    echo "$WW_FILES" | awk '{print "    > " $0}'
else
    log_ok "Nenhum ficheiro world-writable em /etc, /bin, /sbin, /usr."
fi

# Sticky bit em /tmp?
TMP_PERMS=$(stat -c "%a" /tmp 2>/dev/null || echo "?")
[[ "$TMP_PERMS" == "1777" ]] && log_ok "/tmp tem sticky bit (1777)." || log_warn "/tmp permissões: ${TMP_PERMS} (esperado: 1777 com sticky bit)."

# =============================================================================
# SECÇÃO 9 — Sockets, Docker & NFS
# =============================================================================
section "9. Sockets Expostos, Docker & NFS"

# Docker socket
if [[ -S "/var/run/docker.sock" ]]; then
    if [[ -w "/var/run/docker.sock" ]]; then
        log_critical "/var/run/docker.sock é WRITABLE! Escalada para root em 1 comando:
    docker run -v /:/mnt --rm -it alpine chroot /mnt"
    else
        log_warn "Docker socket presente mas protegido. Verifica quem está no grupo 'docker'."
    fi
fi

# Podman socket
if [[ -S "/run/podman/podman.sock" ]] || [[ -S "$XDG_RUNTIME_DIR/podman/podman.sock" ]]; then
    log_warn "Podman socket detetado. Verifica permissões."
fi

# NFS
if [[ -f "/etc/exports" ]]; then
    log_info "Configuração NFS encontrada em /etc/exports:"
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        if echo "$line" | grep -q "no_root_squash"; then
            log_critical "NFS no_root_squash: '${line}' → root remoto mantém privilégios de root."
        elif echo "$line" | grep -q "no_all_squash"; then
            log_warn "NFS no_all_squash: '${line}' → UIDs remotos não são mapeados."
        elif echo "$line" | grep -q "rw"; then
            log_warn "NFS share com escrita: '${line}'"
        else
            log_ok "NFS: ${line}"
        fi
    done < /etc/exports
fi

# Portas abertas (serviços expostos localmente)
echo -e "\n  ${CYAN}[*] Portas em escuta localmente...${RESET}"
if command -v ss &>/dev/null; then
    ss -tlnpu 2>/dev/null | tail -n +2 | awk '{print "    " $0}' | head -20
elif command -v netstat &>/dev/null; then
    netstat -tlnpu 2>/dev/null | tail -n +2 | awk '{print "    " $0}' | head -20
fi

# =============================================================================
# SECÇÃO 10 — Processos & Serviços
# =============================================================================
section "10. Processos a Correr como Root & Serviços"

echo -e "  ${CYAN}[*] Processos de root expostos à rede:${RESET}"
ps aux 2>/dev/null | awk '$1=="root" && $11!="[" {print "    " $0}' | grep -vE "kthread|ksoftirq|migration|watchdog|cpuhp|idle|kworker" | head -20

# Serviços desnecessários
RISKY_SERVICES=("telnet" "rsh" "rlogin" "ftp" "tftp" "rexec" "rcp" "finger" "talk" "ntalk" "inetd" "xinetd")
echo -e "\n  ${CYAN}[*] A verificar serviços inseguros/legacy...${RESET}"
for svc in "${RISKY_SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        log_critical "Serviço inseguro ATIVO: ${svc}! Desativa com: systemctl disable --now ${svc}"
    fi
    if command -v "$svc" &>/dev/null; then
        log_warn "Binário inseguro instalado: ${svc} ($(which $svc))"
    fi
done

# =============================================================================
# SECÇÃO 11 — Firewall & Rede
# =============================================================================
section "11. Firewall & Configuração de Rede"

# iptables
if command -v iptables &>/dev/null && [[ $EUID -eq 0 ]]; then
    RULES=$(iptables -L 2>/dev/null | grep -cE "ACCEPT|DROP|REJECT" || echo "0")
    DEFAULT_INPUT=$(iptables -L INPUT 2>/dev/null | head -1 | grep -o "policy [A-Z]*" || echo "desconhecido")
    log_info "iptables INPUT policy: ${DEFAULT_INPUT} (${RULES} regras totais)"
    if echo "$DEFAULT_INPUT" | grep -q "ACCEPT"; then
        log_warn "Política padrão INPUT=ACCEPT. Considera DROP por padrão com regras explícitas."
    fi
fi

# nftables
if command -v nft &>/dev/null && [[ $EUID -eq 0 ]]; then
    NFT_RULES=$(nft list ruleset 2>/dev/null | wc -l || echo "0")
    log_info "nftables: ${NFT_RULES} linhas de regras."
fi

# UFW
if command -v ufw &>/dev/null; then
    UFW_STATUS=$(ufw status 2>/dev/null | head -1)
    if echo "$UFW_STATUS" | grep -qi "inactive"; then
        log_warn "UFW está INATIVO. Firewall não está a filtrar tráfego."
    else
        log_ok "UFW: ${UFW_STATUS}"
    fi
fi

# Forwarding ativo?
IPV4_FWD=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "0")
[[ "$IPV4_FWD" == "1" ]] && log_warn "IPv4 forwarding ativo. Máquina pode funcionar como router." || log_ok "IPv4 forwarding desativado."

# IPv6 desativado?
IPV6_DISABLED=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null || echo "0")
[[ "$IPV6_DISABLED" == "0" ]] && log_info "IPv6 ativo. Verifica se as regras de firewall cobrem IPv6." || log_ok "IPv6 desativado."

# Interfaces de rede
echo -e "\n  ${CYAN}[*] Interfaces de rede:${RESET}"
ip addr 2>/dev/null | grep -E "^[0-9]+:|inet " | awk '{print "    " $0}'

# =============================================================================
# SECÇÃO 12 — AppArmor / SELinux
# =============================================================================
section "12. Controlo de Acesso Mandatório (AppArmor / SELinux)"

# AppArmor
if command -v aa-status &>/dev/null || [[ -d /sys/kernel/security/apparmor ]]; then
    AA_STATUS=$(aa-status 2>/dev/null | head -5 || cat /sys/kernel/security/apparmor/profiles 2>/dev/null | wc -l)
    log_ok "AppArmor presente."
    if aa-status 2>/dev/null | grep -q "0 profiles are in complain mode" && \
       aa-status 2>/dev/null | grep -q "0 profiles are in enforce mode"; then
        log_warn "AppArmor sem perfis ativos (em uso mas sem proteção efetiva)."
    fi
elif [[ -f /etc/apparmor.d ]]; then
    log_warn "AppArmor instalado mas possivelmente inativo."
else
    log_warn "AppArmor não encontrado. Considera ativar para confinamento de processos."
fi

# SELinux
if command -v getenforce &>/dev/null; then
    SE_STATUS=$(getenforce 2>/dev/null)
    case "$SE_STATUS" in
        Enforcing) log_ok "SELinux: Enforcing (proteção ativa)." ;;
        Permissive) log_warn "SELinux: Permissive (logging mas sem bloqueio)." ;;
        Disabled)   log_warn "SELinux: Disabled." ;;
    esac
fi

# =============================================================================
# SECÇÃO 13 — Utilizadores, Contas & Passwords
# =============================================================================
section "13. Utilizadores do Sistema & Políticas de Password"

# Utilizadores com UID 0 além de root
echo -e "  ${CYAN}[*] Contas com UID 0 (root equivalente):${RESET}"
UID0=$(awk -F: '$3==0 {print $1}' /etc/passwd 2>/dev/null)
for u in $UID0; do
    [[ "$u" == "root" ]] && log_ok "root: UID 0 (normal)." || log_critical "Utilizador '${u}' tem UID 0! Root equivalente não documentado."
done

# Contas sem password
echo -e "\n  ${CYAN}[*] Contas com password vazia ou bloqueada:${RESET}"
if [[ $EUID -eq 0 ]]; then
    while IFS=: read -r user pass rest; do
        if [[ -z "$pass" || "$pass" == "" ]]; then
            log_critical "Conta '${user}' sem password!"
        fi
    done < /etc/shadow 2>/dev/null
else
    log_info "(Requer root para verificar /etc/shadow)"
fi

# Utilizadores com shell válida (potencialmente interativos)
echo -e "\n  ${CYAN}[*] Contas com shell de login:${RESET}"
VALID_SHELLS=$(cat /etc/shells 2>/dev/null || echo "/bin/bash /bin/sh /bin/zsh /bin/fish")
awk -F: '{print $1 ":" $7}' /etc/passwd 2>/dev/null | while IFS=: read -r user shell; do
    if echo "$VALID_SHELLS" | grep -qw "$shell" 2>/dev/null; then
        log_info "  ${user} → shell: ${shell}"
    fi
done

# Política de passwords (PAM)
if [[ -f /etc/pam.d/common-password ]]; then
    if grep -q "pam_pwquality\|pam_cracklib" /etc/pam.d/common-password 2>/dev/null; then
        log_ok "Política de qualidade de passwords ativa (pam_pwquality/cracklib)."
    else
        log_warn "Sem política de qualidade de passwords em /etc/pam.d/common-password."
    fi
fi

# =============================================================================
# SECÇÃO 14 — Discos, Partições & Montagens
# =============================================================================
section "14. Montagens de Sistema de Ficheiros"

echo -e "  ${CYAN}[*] Montagens atuais:${RESET}"
mount 2>/dev/null | awk '{print "    " $0}' | head -20

# /tmp montado com noexec?
if mount 2>/dev/null | grep -qE "\s/tmp\s"; then
    if mount 2>/dev/null | grep -E "\s/tmp\s" | grep -q "noexec"; then
        log_ok "/tmp montado com noexec."
    else
        log_warn "/tmp não tem opção 'noexec'. Scripts podem ser executados diretamente em /tmp."
    fi
fi

# /home montado com noexec?
if mount 2>/dev/null | grep -qE "\s/home\s"; then
    if ! mount 2>/dev/null | grep -E "\s/home\s" | grep -q "nosuid"; then
        log_warn "/home não tem opção 'nosuid'. Binários SUID em /home podem ser explorados."
    fi
fi

# Dispositivos montados com exec que deveriam ser noexec
for mnt in /tmp /dev/shm /run/shm; do
    if mount 2>/dev/null | grep -qE "\s${mnt}\s"; then
        if ! mount 2>/dev/null | grep -E "\s${mnt}\s" | grep -q "noexec"; then
            log_warn "${mnt} não tem 'noexec'. Pode ser usado para executar payloads em memória."
        fi
    fi
done

# =============================================================================
# SECÇÃO 15 — Logs e Auditoria
# =============================================================================
section "15. Sistema de Logs & Auditoria"

# rsyslog/syslog
if systemctl is-active --quiet rsyslog 2>/dev/null || systemctl is-active --quiet syslog 2>/dev/null; then
    log_ok "syslog/rsyslog ativo."
else
    log_warn "rsyslog não ativo. Logs do sistema podem não estar a ser guardados."
fi

# auditd
if command -v auditctl &>/dev/null; then
    AUDIT_STATUS=$(auditctl -s 2>/dev/null | grep "enabled" | awk '{print $2}')
    [[ "$AUDIT_STATUS" == "1" ]] && log_ok "auditd ativo (kernel audit framework)." || log_warn "auditd instalado mas não ativo."
else
    log_warn "auditd não instalado. Considera instalar para rastreio de ações privilegiadas."
fi

# journald persistente?
if [[ -d /var/log/journal ]]; then
    log_ok "journald persistente ativo (logs em /var/log/journal)."
else
    log_warn "journald volátil (logs perdem-se no reboot). Adiciona Storage=persistent em /etc/systemd/journald.conf."
fi

# Logs de auth
if [[ -f /var/log/auth.log ]] || [[ -f /var/log/secure ]]; then
    FAIL_COUNT=$(grep -c "Failed password\|authentication failure" /var/log/auth.log /var/log/secure 2>/dev/null | awk -F: '{s+=$2} END {print s}' || echo "0")
    [[ "$FAIL_COUNT" -gt 50 ]] && log_warn "Muitas falhas de autenticação recentes: ${FAIL_COUNT}. Possível brute-force." || log_ok "Falhas de autenticação recentes: ${FAIL_COUNT}."
fi

# fail2ban
if command -v fail2ban-client &>/dev/null; then
    if fail2ban-client status 2>/dev/null | grep -q "Jail list"; then
        log_ok "fail2ban ativo com jails configuradas."
    else
        log_warn "fail2ban instalado mas sem jails ativas."
    fi
else
    log_warn "fail2ban não instalado. Considera instalar para proteção contra brute-force."
fi

# =============================================================================
# SECÇÃO 16 — Software Desatualizado
# =============================================================================
section "16. Software Desatualizado & CVEs de Aplicações"

# OpenSSL
if command -v openssl &>/dev/null; then
    SSL_VER=$(openssl version 2>/dev/null | awk '{print $2}')
    log_info "OpenSSL: ${SSL_VER}"
    if echo "$SSL_VER" | grep -qE "^(1\.0\.|1\.0\.0|0\.)"; then
        log_critical "OpenSSL ${SSL_VER} muito antigo! Vulnerável a HeartBleed (CVE-2014-0160) e outros."
    elif echo "$SSL_VER" | grep -qE "^3\.0\.[0-6]"; then
        log_warn "OpenSSL ${SSL_VER}: verifica CVE-2022-3786/CVE-2022-3602 (buffer overflow em X.509)."
    fi
fi

# OpenSSH cliente
if command -v ssh &>/dev/null; then
    SSH_VER=$(ssh -V 2>&1 | grep -oP 'OpenSSH_\S+' | head -1)
    log_info "OpenSSH: ${SSH_VER}"
fi

# Python
if command -v python3 &>/dev/null; then
    PY_VER=$(python3 --version 2>/dev/null | awk '{print $2}')
    log_info "Python3: ${PY_VER}"
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [[ "$PY_MAJOR" -eq 3 ]] && [[ "$PY_MINOR" -lt 8 ]]; then
        log_warn "Python ${PY_VER} chegou ao fim de vida (EOL). Sem patches de segurança."
    fi
fi

# Verificar pacotes com atualizações pendentes
echo -e "\n  ${CYAN}[*] Atualizações de segurança pendentes...${RESET}"
if command -v apt &>/dev/null; then
    SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "security" || echo "0")
    [[ "$SEC_UPDATES" -gt 0 ]] && log_warn "${SEC_UPDATES} atualizações de SEGURANÇA pendentes! Corre: apt upgrade" || log_ok "Sem atualizações de segurança pendentes (apt)."
elif command -v yum &>/dev/null; then
    SEC_UPDATES=$(yum check-update --security 2>/dev/null | grep -c "^[A-Za-z]" || echo "0")
    [[ "$SEC_UPDATES" -gt 0 ]] && log_warn "${SEC_UPDATES} atualizações de segurança pendentes (yum)." || log_ok "Sem atualizações de segurança pendentes (yum)."
fi

# =============================================================================
# SECÇÃO 17 — LD_PRELOAD & Bibliotecas Dinâmicas
# =============================================================================
section "17. LD_PRELOAD, LD_LIBRARY_PATH & Injeção de Bibliotecas"

# LD_PRELOAD definido?
if [[ -n "${LD_PRELOAD:-}" ]]; then
    log_critical "LD_PRELOAD definido: ${LD_PRELOAD} → Injeção de biblioteca ativa!"
fi
if [[ -n "${LD_LIBRARY_PATH:-}" ]]; then
    log_warn "LD_LIBRARY_PATH definido: ${LD_LIBRARY_PATH}"
fi

# /etc/ld.so.conf e diretórios writable
if [[ -f /etc/ld.so.conf ]]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        if [[ -d "$line" ]] && [[ -w "$line" ]]; then
            log_critical "Diretório de biblioteca WRITABLE: ${line} (em /etc/ld.so.conf) → injeção de .so possível."
        fi
    done < /etc/ld.so.conf
fi

# /etc/ld.so.preload
if [[ -f /etc/ld.so.preload ]]; then
    log_warn "/etc/ld.so.preload existe:"
    cat /etc/ld.so.preload | awk '{print "    > " $0}'
fi

# =============================================================================
# SUMÁRIO FINAL
# =============================================================================
echo -e "\n\n${RED}${BOLD}╔══════════════════════════════════════════════════════════════╗"
echo -e "║              SUMÁRIO DA AUDITORIA DE SEGURANÇA              ║"
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

echo -e "\n${GREEN}${BOLD}Auditoria concluída. Resultados para correção imediata acima.${RESET}"
echo -e "${CYAN}Guarda o output com: sudo bash red-recon.sh | tee audit-$(hostname)-$(date +%F).log${RESET}\n"