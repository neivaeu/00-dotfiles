#!/usr/bin/env bash

# =============================================================================
# red-recon.sh — Full Local Security Audit (Personal/Defensive Use)
# Version: 3.0 Elite
# Goal: Identify privilege escalation vectors and misconfigurations
#       on YOUR OWN system so you can fix them.
# Usage: sudo bash red-recon.sh | tee audit-$(hostname)-$(date +%F).log
# =============================================================================

set -uo pipefail

# ─────────────────────────────────────────────────────────────────
# COLOURS
# ─────────────────────────────────────────────────────────────────
BOLD='\033[1m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
RESET='\033[0m'

SCORE=0
WARNINGS=0
REPORT=()

log_critical() { echo -e "  ${RED}${BOLD}[CRITICAL]${RESET} $1"; ((SCORE++)); REPORT+=("CRITICAL: $1"); }
log_warn()     { echo -e "  ${YELLOW}[WARNING]${RESET}  $1"; ((WARNINGS++)); REPORT+=("WARNING: $1"); }
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
echo -e "${CYAN} Host: ${WHITE}${HOSTNAME}${RESET} | ${CYAN}User: ${WHITE}${CURRENT_USER}${RESET} | ${CYAN}Date: ${WHITE}${TIMESTAMP}${RESET}"
echo -e "${YELLOW} WARNING: This tool is for auditing YOUR OWN system. Use responsibly.${RESET}\n"

if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}${BOLD}[!] Running without root. Some checks will be limited. Recommended: sudo bash $0${RESET}\n"
fi

# =============================================================================
# SECTION 1 — Operating System & Kernel
# =============================================================================
section "1. Operating System & Kernel"

KERNEL=$(uname -r)
ARCH=$(uname -m)
OS_NAME=$(grep -oP '(?<=^NAME=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "Unknown")
OS_VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "?")

log_info "Kernel: ${KERNEL} | Arch: ${ARCH}"
log_info "OS: ${OS_NAME} ${OS_VERSION}"
log_info "Uptime: $(uptime -p 2>/dev/null || uptime)"

KERNEL_MAJOR=$(echo "$KERNEL" | cut -d. -f1)
KERNEL_MINOR=$(echo "$KERNEL" | cut -d. -f2)

if [[ "$KERNEL_MAJOR" -lt 4 ]] || { [[ "$KERNEL_MAJOR" -eq 4 ]] && [[ "$KERNEL_MINOR" -lt 15 ]]; }; then
    log_critical "Kernel ${KERNEL} is old. Vulnerable to DirtyCow, PTRACE, Spectre/Meltdown and others."
fi

declare -A KERNEL_CVES=(
    ["5.8"]="CVE-2021-3490 (eBPF OOB Write)"
    ["5.7"]="CVE-2021-22555 (Netfilter heap overflow)"
    ["4.4"]="CVE-2016-5195 (DirtyCow), CVE-2017-7308"
    ["3."]="CVE-2016-5195 (DirtyCow), multiple PTR derefs"
)
for ver in "${!KERNEL_CVES[@]}"; do
    if [[ "$KERNEL" == *"${ver}"* ]]; then
        log_warn "Kernel ${KERNEL} possibly affected by: ${KERNEL_CVES[$ver]}"
    fi
done

if [[ -f /sys/kernel/debug/x86/pti_enabled ]]; then
    PTI=$(cat /sys/kernel/debug/x86/pti_enabled 2>/dev/null || echo "?")
    [[ "$PTI" == "1" ]] && log_ok "PTI (Meltdown mitigation) active." || log_warn "PTI disabled! Vulnerable to Meltdown."
fi

ASLR=$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo "?")
case "$ASLR" in
    2) log_ok "Full ASLR active (randomize_va_space=2)." ;;
    1) log_warn "Partial ASLR (=1). Recommended =2 in /etc/sysctl.conf." ;;
    0) log_critical "ASLR DISABLED! Stack/heap are predictable. Facilitates exploits." ;;
    *) log_info "ASLR: unknown state." ;;
esac

DMESG_VAL=$(cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo "?")
[[ "$DMESG_VAL" == "1" ]] && log_ok "dmesg_restrict=1 (restriction active)." \
    || log_warn "dmesg_restrict=0. Non-root users can read dmesg (kernel info leak)."

KPTR=$(cat /proc/sys/kernel/kptr_restrict 2>/dev/null || echo "?")
if [[ "$KPTR" =~ ^[0-9]+$ ]] && [[ "$KPTR" -ge 1 ]]; then
    log_ok "kptr_restrict=${KPTR} (kernel pointers hidden)."
else
    log_warn "kptr_restrict=0. Kernel addresses visible in /proc/kallsyms."
fi

# =============================================================================
# SECTION 2 — User, Groups and Sudo
# =============================================================================
section "2. User, Groups and Sudo Configuration"

log_info "Identity: $(id)"
log_info "Shell: ${SHELL}"

GROUPS_LIST=$(id -Gn)
DANGER_GROUPS=("docker" "lxd" "lxc" "disk" "adm" "shadow" "wheel" "sudo" "video" "plugdev" "kvm" "libvirt" "vboxusers")
for grp in "${DANGER_GROUPS[@]}"; do
    if echo "$GROUPS_LIST" | grep -qw "$grp"; then
        case "$grp" in
            docker|lxd|lxc) log_critical "Member of group '${grp}'! Trivial root escalation via containers." ;;
            disk)            log_critical "Member of group 'disk'! Direct access to raw devices (/dev/sdX)." ;;
            shadow)          log_critical "Member of group 'shadow'! Can read /etc/shadow and dump hashes." ;;
            sudo|wheel)      log_warn    "Member of group '${grp}'. Check entries in /etc/sudoers." ;;
            adm)             log_warn    "Member of group 'adm'. Access to system logs (/var/log)." ;;
            *)               log_info    "Member of group '${grp}'." ;;
        esac
    fi
done

echo -e "\n  ${CYAN}${BOLD}[*] Testing sudo rules...${RESET}"
if command -v sudo &>/dev/null; then
    SUDO_VER=$(sudo -V 2>/dev/null | grep "Sudo version" | awk '{print $3}')
    log_info "Sudo version: ${SUDO_VER}"

    if echo "${SUDO_VER}" | grep -qE "^1\.(8\.|9\.[0-4]|9\.5p1)"; then
        log_critical "CVE-2021-3156 (Baron Samedit): version ${SUDO_VER} is vulnerable! Buffer overflow → root."
    fi
    if echo "${SUDO_VER}" | grep -qE "^1\.(8\.[0-9]\.|8\.[12][0-9]\.)"; then
        log_warn "CVE-2019-14287: sudo < 1.8.28 may allow root execution with 'sudo -u#-1'."
    fi
    if echo "${SUDO_VER}" | grep -qE "^1\.9\.(1[0-2]|[0-9])\."; then
        log_warn "CVE-2023-22809 (sudoedit): versions 1.9.0-1.9.12 vulnerable to editor escape."
    fi

    SUDO_L=$(sudo -ln 2>/dev/null || true)
    if echo "$SUDO_L" | grep -qi "NOPASSWD"; then
        log_warn "NOPASSWD entries in sudo! Commands executable without password:"
        echo "$SUDO_L" | grep -i "NOPASSWD" | awk '{print "    → " $0}'
    fi
    if echo "$SUDO_L" | grep -qE "\(ALL.*\).*ALL|NOPASSWD.*ALL"; then
        log_critical "Sudo with (ALL) ALL permission! Immediate root escalation."
    fi
    if sudo -ln 2>/dev/null | grep -q "env_keep"; then
        log_warn "sudo env_keep configured. Environment variables may be preserved (LD_PRELOAD, etc.)."
    fi
fi

if [[ -r /etc/sudoers ]]; then
    log_warn "/etc/sudoers is READABLE by current user."
    grep -vE "^#|^Defaults|^$" /etc/sudoers 2>/dev/null | grep -v "^%" | awk '{print "    > " $0}'
fi

# =============================================================================
# SECTION 3 — PATH Hijacking
# =============================================================================
section "3. PATH Hijacking & Binary Injection"

IFS=':' read -ra PATH_DIRS <<< "$PATH"
PATH_VULN=0
for dir in "${PATH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        PERMS=$(stat -c "%a" "$dir" 2>/dev/null || echo "?")
        if [[ -w "$dir" ]]; then
            log_critical "PATH dir WRITABLE: '${dir}' (perms: ${PERMS}) — can inject malicious binaries!"
            PATH_VULN=1
        fi
        if [[ "$dir" == "." ]] || [[ "$dir" == "" ]]; then
            log_critical "PATH contains relative directory '${dir}'! Any working directory is searched."
            PATH_VULN=1
        fi
    else
        log_info "PATH dir does not exist: '${dir}' (could be created and exploited)."
    fi
done
[[ $PATH_VULN -eq 0 ]] && log_ok "No writable or relative directories in \$PATH."

if sudo -V 2>/dev/null | grep -q "secure_path"; then
    log_ok "sudo uses secure_path (PATH isolated during sudo execution)."
else
    log_warn "sudo may not use secure_path — user PATH may be inherited."
fi

# =============================================================================
# SECTION 4 — SUID / SGID
# =============================================================================
section "4. SUID / SGID Binaries"

WHITELIST_SUID="ping|ping6|su|sudo|passwd|chsh|chfn|newgrp|mount|umount|pkexec|dbus-daemon-launch-helper|ssh-keysign|polkit-agent-helper-1|Xorg|at|crontab|wall|write|fusermount|fusermount3|unix_chkpwd|pam_timestamp_check|gpasswd|newuidmap|newgidmap|snap"

GTFOBINS="nmap|vim|vi|find|bash|sh|more|less|nano|cp|mv|awk|python|python3|ruby|php|perl|tar|zip|unzip|wget|curl|nc|netcat|socat|tee|dd|scp|rsync|env|node|lua|ftp|tftp|ssh|as|ar|base32|base64|busybox|cat|chmod|chown|column|comm|cpio|csh|cut|date|diff|dmesg|docker|ed|emacs|expand|expect|file|fmt|fold|gawk|gcc|git|grep|head|install|ionice|jjs|journalctl|jq|kill|ld|logsave|look|ltrace|make|mawk|minicom|msgattrib|msgcat|msgconv|msgfilter|msgmerge|msguniq|mysql|nice|nl|nohup|od|openssl|pg|pico|pip|rpm|rpmquery|run-parts|rvim|sed|setarch|shuf|sort|sqlite3|ss|stdbuf|strace|tail|taskset|timeout|ul|unexpand|uniq|unshare|update-alternatives|uudecode|uuencode|valgrind|watch|xargs|xxd|xz|zip|zsh"

echo ""
SUID_FOUND=0
while IFS= read -r bin; do
    BASENAME=$(basename "$bin")
    if ! echo "$BASENAME" | grep -qE "^(${WHITELIST_SUID})$"; then
        if echo "$BASENAME" | grep -qE "^(${GTFOBINS})$"; then
            log_critical "GTFOBins SUID: ${bin} → Documented privilege escalation at gtfobins.github.io"
        else
            OWNER=$(stat -c "%U" "$bin" 2>/dev/null || echo "?")
            PERMS=$(stat -c "%a" "$bin" 2>/dev/null || echo "?")
            log_warn "Suspicious SUID/SGID: ${bin} (owner: ${OWNER}, perms: ${PERMS})"
        fi
        SUID_FOUND=1
    fi
done < <(find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt \
         -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null)

[[ $SUID_FOUND -eq 0 ]] && log_ok "No anomalous SUID/SGID found."

# =============================================================================
# SECTION 5 — Linux Capabilities
# =============================================================================
section "5. Linux Capabilities (Stealthy Vector)"

if command -v getcap &>/dev/null; then
    CAPS=$(getcap -r / 2>/dev/null | grep -v "^getcap:" || true)
    if [[ -n "$CAPS" ]]; then
        DANGER_CAPS="cap_setuid|cap_setgid|cap_dac_override|cap_dac_read_search|cap_sys_admin|cap_sys_ptrace|cap_net_admin|cap_net_raw|cap_sys_rawio|cap_sys_module|cap_chown|cap_fowner"
        while IFS= read -r line; do
            CAP=$(echo "$line" | awk '{print $2}')
            if echo "$CAP" | grep -qE "${DANGER_CAPS}"; then
                log_critical "Dangerous capability: ${line} → Possible privilege escalation."
            else
                log_warn "Capability: ${line}"
            fi
        done <<< "$CAPS"
    else
        log_ok "No anomalous capabilities found."
    fi
else
    log_warn "'getcap' not installed. Install with: apt install libcap2-bin"
fi

# =============================================================================
# SECTION 6 — Cron Jobs
# =============================================================================
section "6. Cron Jobs & Scheduled Tasks"

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
        if [[ -w "$loc" ]]; then
            log_critical "Cron WRITABLE: ${loc} → can inject commands to run as root!"
        fi
        if [[ -f "$loc" ]]; then
            while IFS= read -r line; do
                SCRIPT=$(echo "$line" | grep -oP '(/[^ ]+\.(sh|py|rb|pl|bash))' | head -1 || true)
                if [[ -n "$SCRIPT" ]] && [[ -f "$SCRIPT" ]] && [[ -w "$SCRIPT" ]]; then
                    log_critical "Writable cron script: ${SCRIPT} (referenced in ${loc})"
                fi
                if echo "$line" | grep -qE "^\s*[*0-9]" && \
                   echo "$line" | grep -qP "\s+[^/\s][^\s]*(\.sh|python|perl|ruby|bash|sh)\b"; then
                    log_warn "Possible relative path in cron: ${line}"
                fi
            done < <(grep -vE "^#|^$" "$loc" 2>/dev/null || true)
        fi
    fi
done

echo -e "\n  ${CYAN}[*] Checking systemd timers...${RESET}"
if command -v systemctl &>/dev/null; then
    TIMERS=$(systemctl list-timers --all 2>/dev/null | grep -v "^0 timers" | head -20 || true)
    if [[ -n "$TIMERS" ]]; then
        log_info "Active systemd timers (check associated scripts):"
        echo "$TIMERS" | head -10 | awk '{print "    " $0}'
    fi
fi

# =============================================================================
# SECTION 7 — SSH Configuration
# =============================================================================
section "7. SSH Configuration (sshd_config)"

SSHD_CONFIG="/etc/ssh/sshd_config"
if [[ -f "$SSHD_CONFIG" ]]; then
    check_ssh() {
        local key="$1" good="$2" msg_bad="$3"
        local val
        val=$(grep -iE "^${key}\s+" "$SSHD_CONFIG" 2>/dev/null \
              | tail -1 | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
        if [[ -z "$val" ]]; then
            log_info "${key}: not set (uses default). Check man sshd_config."
        elif [[ "$val" == "$good" ]]; then
            log_ok "${key}: ${val}"
        else
            log_warn "${msg_bad} (current: ${val})"
        fi
    }

    check_ssh "PermitRootLogin"       "no"  "PermitRootLogin is not 'no'! Root login via SSH possible."
    check_ssh "PasswordAuthentication" "no" "PasswordAuthentication enabled! Allows password brute-force."
    check_ssh "PermitEmptyPasswords"  "no"  "PermitEmptyPasswords enabled! Login without password possible."
    check_ssh "X11Forwarding"         "no"  "X11Forwarding enabled! Possible graphical session hijacking."
    check_ssh "UsePAM"                "yes" "UsePAM disabled. Reduces authentication control."
    check_ssh "StrictModes"           "yes" "StrictModes disabled! SSH does not check file permissions."

    if grep -qiE "^Protocol\s+1" "$SSHD_CONFIG" 2>/dev/null; then
        log_critical "SSH Protocol 1 active! Highly vulnerable (MITM, etc.). Use Protocol 2 only."
    fi

    MAX_AUTH=$(grep -iE "^MaxAuthTries\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
    if [[ -z "$MAX_AUTH" ]]; then
        log_warn "MaxAuthTries not set (default=6). Recommended: MaxAuthTries 3."
    elif [[ "$MAX_AUTH" -gt 4 ]]; then
        log_warn "MaxAuthTries=${MAX_AUTH}. Recommended ≤3 to hinder brute-force."
    else
        log_ok "MaxAuthTries=${MAX_AUTH}."
    fi

    SSH_PORT=$(grep -iE "^Port\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}' || echo "22")
    [[ "$SSH_PORT" == "22" ]] \
        && log_warn "SSH on default port 22. Consider changing to reduce automated scanning." \
        || log_ok "SSH on non-default port: ${SSH_PORT}."

    if grep -qiE "^HostKey.*ecdsa|^HostKey.*dsa" "$SSHD_CONFIG" 2>/dev/null; then
        log_warn "ECDSA/DSA host keys configured. Consider using Ed25519 and RSA ≥4096 only."
    fi

    if ! grep -qiE "^(AllowUsers|AllowGroups)\s+" "$SSHD_CONFIG" 2>/dev/null; then
        log_warn "AllowUsers/AllowGroups not set. Any system user can attempt SSH login."
    else
        log_ok "AllowUsers/AllowGroups configured (access restriction active)."
    fi
else
    log_info "sshd_config not found (SSH possibly not installed)."
fi

if [[ -f "$HOME/.ssh/authorized_keys" ]]; then
    AK_PERMS=$(stat -c "%a" "$HOME/.ssh/authorized_keys" 2>/dev/null)
    if [[ "$AK_PERMS" == "600" || "$AK_PERMS" == "644" ]]; then
        log_ok "$HOME/.ssh/authorized_keys permissions OK (${AK_PERMS})."
    else
        log_warn "$HOME/.ssh/authorized_keys permissions ${AK_PERMS} (should be 600)."
    fi
fi

# =============================================================================
# SECTION 8 — Critical System Files
# =============================================================================
section "8. Critical File Permissions"

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
            log_critical "${file} IS WRITABLE by current user! (perms: ${ACTUAL}, owner: ${OWNER})"
        elif [[ "$ACTUAL" != "$EXPECTED" ]]; then
            log_warn "${file}: permissions ${ACTUAL} (expected: ${EXPECTED}, owner: ${OWNER})"
        else
            log_ok "${file}: permissions ${ACTUAL} OK."
        fi

        if [[ "$file" == "/etc/shadow" ]] && [[ -r "$file" ]]; then
            log_critical "/etc/shadow READABLE! Hash dumping possible → offline cracking with hashcat/john."
        fi
    fi
done

echo -e "\n  ${CYAN}[*] Searching for world-writable files in critical locations...${RESET}"
WW_FILES=$(find /etc /usr/bin /usr/sbin /bin /sbin -type f -perm -0002 2>/dev/null || true)
if [[ -n "$WW_FILES" ]]; then
    log_critical "World-writable files found:"
    echo "$WW_FILES" | awk '{print "    > " $0}'
else
    log_ok "No world-writable files in /etc, /bin, /sbin, /usr."
fi

TMP_PERMS=$(stat -c "%a" /tmp 2>/dev/null || echo "?")
[[ "$TMP_PERMS" == "1777" ]] && log_ok "/tmp has sticky bit (1777)." \
    || log_warn "/tmp permissions: ${TMP_PERMS} (expected: 1777 with sticky bit)."

# =============================================================================
# SECTION 9 — Sockets, Docker & NFS
# =============================================================================
section "9. Exposed Sockets, Docker & NFS"

if [[ -S "/var/run/docker.sock" ]]; then
    if [[ -w "/var/run/docker.sock" ]]; then
        log_critical "/var/run/docker.sock is WRITABLE! Root escalation in 1 command:
    docker run -v /:/mnt --rm -it alpine chroot /mnt"
    else
        log_warn "Docker socket present but protected. Check who is in the 'docker' group."
    fi
fi

if [[ -S "/run/podman/podman.sock" ]] || [[ -S "${XDG_RUNTIME_DIR:-}/podman/podman.sock" ]]; then
    log_warn "Podman socket detected. Check permissions."
fi

if [[ -f "/etc/exports" ]]; then
    log_info "NFS configuration found in /etc/exports:"
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        if echo "$line" | grep -q "no_root_squash"; then
            log_critical "NFS no_root_squash: '${line}' → remote root retains root privileges."
        elif echo "$line" | grep -q "no_all_squash"; then
            log_warn "NFS no_all_squash: '${line}' → remote UIDs are not mapped."
        elif echo "$line" | grep -q "rw"; then
            log_warn "NFS share with write access: '${line}'"
        else
            log_ok "NFS: ${line}"
        fi
    done < /etc/exports
fi

echo -e "\n  ${CYAN}[*] Locally listening ports...${RESET}"
if command -v ss &>/dev/null; then
    ss -tlnpu 2>/dev/null | tail -n +2 | awk '{print "    " $0}' | head -20
elif command -v netstat &>/dev/null; then
    netstat -tlnpu 2>/dev/null | tail -n +2 | awk '{print "    " $0}' | head -20
fi

# =============================================================================
# SECTION 10 — Processes & Services
# =============================================================================
section "10. Processes Running as Root & Services"

echo -e "  ${CYAN}[*] Root processes exposed to network:${RESET}"
ps aux 2>/dev/null \
    | awk '$1=="root" && $11!="[" {print "    " $0}' \
    | grep -vE "kthread|ksoftirq|migration|watchdog|cpuhp|idle|kworker" \
    | head -20

RISKY_SERVICES=("telnet" "rsh" "rlogin" "ftp" "tftp" "rexec" "rcp" "finger" "talk" "ntalk" "inetd" "xinetd")
echo -e "\n  ${CYAN}[*] Checking insecure/legacy services...${RESET}"
for svc in "${RISKY_SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        log_critical "Insecure service ACTIVE: ${svc}! Disable with: systemctl disable --now ${svc}"
    fi
    if command -v "$svc" &>/dev/null; then
        SVC_PATH=$(command -v "$svc")
        log_warn "Insecure binary installed: ${svc} (${SVC_PATH})"
    fi
done

# =============================================================================
# SECTION 11 — Firewall & Network
# =============================================================================
section "11. Firewall & Network Configuration"

if command -v iptables &>/dev/null && [[ $EUID -eq 0 ]]; then
    RULES=$(iptables -L 2>/dev/null | grep -cE "ACCEPT|DROP|REJECT" || echo "0")
    DEFAULT_INPUT=$(iptables -L INPUT 2>/dev/null | head -1 | grep -o "policy [A-Z]*" || echo "unknown")
    log_info "iptables INPUT policy: ${DEFAULT_INPUT} (${RULES} total rules)"
    if echo "$DEFAULT_INPUT" | grep -q "ACCEPT"; then
        log_warn "Default INPUT policy=ACCEPT. Consider DROP by default with explicit rules."
    fi
fi

if command -v nft &>/dev/null && [[ $EUID -eq 0 ]]; then
    NFT_RULES=$(nft list ruleset 2>/dev/null | wc -l || echo "0")
    log_info "nftables: ${NFT_RULES} lines of rules."
fi

if command -v ufw &>/dev/null; then
    UFW_STATUS=$(ufw status 2>/dev/null | head -1)
    if echo "$UFW_STATUS" | grep -qi "inactive"; then
        log_warn "UFW is INACTIVE. Firewall is not filtering traffic."
    else
        log_ok "UFW: ${UFW_STATUS}"
    fi
fi

IPV4_FWD=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "0")
[[ "$IPV4_FWD" == "1" ]] \
    && log_warn "IPv4 forwarding active. Machine may act as a router." \
    || log_ok "IPv4 forwarding disabled."

IPV6_DISABLED=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null || echo "0")
[[ "$IPV6_DISABLED" == "0" ]] \
    && log_info "IPv6 active. Verify firewall rules cover IPv6." \
    || log_ok "IPv6 disabled."

echo -e "\n  ${CYAN}[*] Network interfaces:${RESET}"
ip addr 2>/dev/null | grep -E "^[0-9]+:|inet " | awk '{print "    " $0}'

# =============================================================================
# SECTION 12 — AppArmor / SELinux
# =============================================================================
section "12. Mandatory Access Control (AppArmor / SELinux)"

if command -v aa-status &>/dev/null || [[ -d /sys/kernel/security/apparmor ]]; then
    log_ok "AppArmor present."
    if aa-status 2>/dev/null | grep -q "0 profiles are in complain mode" && \
       aa-status 2>/dev/null | grep -q "0 profiles are in enforce mode"; then
        log_warn "AppArmor has no active profiles (loaded but no effective protection)."
    fi
elif [[ -d /etc/apparmor.d ]]; then
    log_warn "AppArmor installed but possibly inactive."
else
    log_warn "AppArmor not found. Consider enabling for process confinement."
fi

if command -v getenforce &>/dev/null; then
    SE_STATUS=$(getenforce 2>/dev/null)
    case "$SE_STATUS" in
        Enforcing)  log_ok "SELinux: Enforcing (active protection)." ;;
        Permissive) log_warn "SELinux: Permissive (logging but no blocking)." ;;
        Disabled)   log_warn "SELinux: Disabled." ;;
    esac
fi

# =============================================================================
# SECTION 13 — Users, Accounts & Passwords
# =============================================================================
section "13. System Users & Password Policies"

echo -e "  ${CYAN}[*] Accounts with UID 0 (root equivalent):${RESET}"
UID0=$(awk -F: '$3==0 {print $1}' /etc/passwd 2>/dev/null)
for u in $UID0; do
    [[ "$u" == "root" ]] \
        && log_ok "root: UID 0 (normal)." \
        || log_critical "User '${u}' has UID 0! Undocumented root equivalent."
done

echo -e "\n  ${CYAN}[*] Accounts with empty or locked password:${RESET}"
if [[ $EUID -eq 0 ]]; then
    while IFS=: read -r user pass rest; do
        if [[ -z "$pass" ]]; then
            log_critical "Account '${user}' has no password!"
        fi
    done < /etc/shadow
else
    log_info "(Requires root to check /etc/shadow)"
fi

echo -e "\n  ${CYAN}[*] Accounts with login shell:${RESET}"
VALID_SHELLS=$(cat /etc/shells 2>/dev/null || echo "/bin/bash /bin/sh /bin/zsh /bin/fish")
while IFS=: read -r user _ _ _ _ _ shell; do
    if echo "$VALID_SHELLS" | grep -qw "$shell" 2>/dev/null; then
        log_info "  ${user} → shell: ${shell}"
    fi
done < /etc/passwd

if [[ -f /etc/pam.d/common-password ]]; then
    if grep -q "pam_pwquality\|pam_cracklib" /etc/pam.d/common-password 2>/dev/null; then
        log_ok "Password quality policy active (pam_pwquality/cracklib)."
    else
        log_warn "No password quality policy in /etc/pam.d/common-password."
    fi
fi

# =============================================================================
# SECTION 14 — Disks, Partitions & Mounts
# =============================================================================
section "14. Filesystem Mounts"

echo -e "  ${CYAN}[*] Current mounts:${RESET}"
mount 2>/dev/null | awk '{print "    " $0}' | head -20

if mount 2>/dev/null | grep -qE "\s/tmp\s"; then
    if mount 2>/dev/null | grep -E "\s/tmp\s" | grep -q "noexec"; then
        log_ok "/tmp mounted with noexec."
    else
        log_warn "/tmp does not have 'noexec'. Scripts can be executed directly from /tmp."
    fi
fi

if mount 2>/dev/null | grep -qE "\s/home\s"; then
    if ! mount 2>/dev/null | grep -E "\s/home\s" | grep -q "nosuid"; then
        log_warn "/home does not have 'nosuid'. SUID binaries in /home can be exploited."
    fi
fi

for mnt in /tmp /dev/shm /run/shm; do
    if mount 2>/dev/null | grep -qE "\s${mnt}\s"; then
        if ! mount 2>/dev/null | grep -E "\s${mnt}\s" | grep -q "noexec"; then
            log_warn "${mnt} does not have 'noexec'. Can be used to execute in-memory payloads."
        fi
    fi
done

# =============================================================================
# SECTION 15 — Logs and Auditing
# =============================================================================
section "15. Logging & Audit System"

if systemctl is-active --quiet rsyslog 2>/dev/null || systemctl is-active --quiet syslog 2>/dev/null; then
    log_ok "syslog/rsyslog active."
else
    log_warn "rsyslog not active. System logs may not be saved."
fi

if command -v auditctl &>/dev/null; then
    AUDIT_STATUS=$(auditctl -s 2>/dev/null | grep "enabled" | awk '{print $2}')
    [[ "$AUDIT_STATUS" == "1" ]] \
        && log_ok "auditd active (kernel audit framework)." \
        || log_warn "auditd installed but not active."
else
    log_warn "auditd not installed. Consider installing for privileged action tracking."
fi

if [[ -d /var/log/journal ]]; then
    log_ok "Persistent journald active (logs in /var/log/journal)."
else
    log_warn "Volatile journald (logs lost on reboot). Add Storage=persistent in /etc/systemd/journald.conf."
fi

if [[ -f /var/log/auth.log ]] || [[ -f /var/log/secure ]]; then
    FAIL_COUNT=$(grep -ch "Failed password\|authentication failure" \
                 /var/log/auth.log /var/log/secure 2>/dev/null \
                 | awk '{s+=$1} END {print s+0}')
    [[ "$FAIL_COUNT" -gt 50 ]] \
        && log_warn "Many recent authentication failures: ${FAIL_COUNT}. Possible brute-force." \
        || log_ok "Recent authentication failures: ${FAIL_COUNT}."
fi

if command -v fail2ban-client &>/dev/null; then
    if fail2ban-client status 2>/dev/null | grep -q "Jail list"; then
        log_ok "fail2ban active with configured jails."
    else
        log_warn "fail2ban installed but no active jails."
    fi
else
    log_warn "fail2ban not installed. Consider installing for brute-force protection."
fi

# =============================================================================
# SECTION 16 — Outdated Software
# =============================================================================
section "16. Outdated Software & Application CVEs"

if command -v openssl &>/dev/null; then
    SSL_VER=$(openssl version 2>/dev/null | awk '{print $2}')
    log_info "OpenSSL: ${SSL_VER}"
    if echo "$SSL_VER" | grep -qE "^(1\.0\.|1\.0\.0|0\.)"; then
        log_critical "OpenSSL ${SSL_VER} is very old! Vulnerable to HeartBleed (CVE-2014-0160) and others."
    elif echo "$SSL_VER" | grep -qE "^3\.0\.[0-6]"; then
        log_warn "OpenSSL ${SSL_VER}: check CVE-2022-3786/CVE-2022-3602 (X.509 buffer overflow)."
    fi
fi

if command -v ssh &>/dev/null; then
    SSH_VER=$(ssh -V 2>&1 | grep -oP 'OpenSSH_\S+' | head -1)
    log_info "OpenSSH: ${SSH_VER}"
fi

if command -v python3 &>/dev/null; then
    PY_VER=$(python3 --version 2>/dev/null | awk '{print $2}')
    log_info "Python3: ${PY_VER}"
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [[ "$PY_MAJOR" -eq 3 ]] && [[ "$PY_MINOR" -lt 8 ]]; then
        log_warn "Python ${PY_VER} has reached end-of-life (EOL). No more security patches."
    fi
fi

echo -e "\n  ${CYAN}[*] Checking pending security updates...${RESET}"
if command -v apt &>/dev/null; then
    SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "security" || echo "0")
    [[ "$SEC_UPDATES" -gt 0 ]] \
        && log_warn "${SEC_UPDATES} pending SECURITY updates! Run: apt upgrade" \
        || log_ok "No pending security updates (apt)."
elif command -v yum &>/dev/null; then
    SEC_UPDATES=$(yum check-update --security 2>/dev/null | grep -c "^[A-Za-z]" || echo "0")
    [[ "$SEC_UPDATES" -gt 0 ]] \
        && log_warn "${SEC_UPDATES} pending security updates (yum)." \
        || log_ok "No pending security updates (yum)."
fi

# =============================================================================
# SECTION 17 — LD_PRELOAD & Dynamic Libraries
# =============================================================================
section "17. LD_PRELOAD, LD_LIBRARY_PATH & Library Injection"

if [[ -n "${LD_PRELOAD:-}" ]]; then
    log_critical "LD_PRELOAD set: ${LD_PRELOAD} → Active library injection!"
fi
if [[ -n "${LD_LIBRARY_PATH:-}" ]]; then
    log_warn "LD_LIBRARY_PATH set: ${LD_LIBRARY_PATH}"
fi

if [[ -f /etc/ld.so.conf ]]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        if [[ -d "$line" ]] && [[ -w "$line" ]]; then
            log_critical "WRITABLE library directory: ${line} (in /etc/ld.so.conf) → .so injection possible."
        fi
    done < /etc/ld.so.conf
fi

if [[ -f /etc/ld.so.preload ]]; then
    log_warn "/etc/ld.so.preload exists:"
    awk '{print "    > " $0}' /etc/ld.so.preload
fi

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo -e "\n\n${RED}${BOLD}╔══════════════════════════════════════════════════════════════╗"
echo -e "║                   SECURITY AUDIT SUMMARY                    ║"
echo -e "╚══════════════════════════════════════════════════════════════╝${RESET}"
echo -e "  ${RED}${BOLD}Critical: ${SCORE}${RESET}    ${YELLOW}Warnings: ${WARNINGS}${RESET}"
echo ""
if [[ ${#REPORT[@]} -gt 0 ]]; then
    echo -e "${BOLD}Key findings:${RESET}"
    for item in "${REPORT[@]}"; do
        if [[ "$item" == CRITICAL* ]]; then
            echo -e "  ${RED}• ${item}${RESET}"
        else
            echo -e "  ${YELLOW}• ${item}${RESET}"
        fi
    done
fi

echo -e "\n${GREEN}${BOLD}Audit complete. Address the findings above immediately.${RESET}"
echo -e "${CYAN}Save output with: sudo bash red-recon.sh | tee audit-$(hostname)-$(date +%F).log${RESET}\n"