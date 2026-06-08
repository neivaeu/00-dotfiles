# Display formatted system information.
# Shows CPU, memory, disk, network, and development tool versions.
#
# USAGE:
#   ./system-info.sh
#
# OUTPUT SECTIONS:
#   System    — OS, kernel, hostname, uptime
#   CPU       — model, cores, architecture
#   Memory    — total, used, available
#   Disk      — filesystem usage
#   Network   — local and external IP
#   Toolchain — versions of installed development tools

#!/usr/bin/env bash

set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# COLOURS
# ─────────────────────────────────────────────────────────────────

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────

# Print a section header
section() {
    echo ""
    echo -e "${CYAN}${BOLD}── $1 ──────────────────────────────${RESET}"
}

# Print a key-value pair
kv() {
    printf "  ${YELLOW}%-20s${RESET} %s\n" "$1" "$2"
}

# Get version of a tool or "not installed"
tool_version() {
    local cmd="$1"
    local flag="${2:---version}"
    if command -v "${cmd}" &>/dev/null; then
        "${cmd}" "${flag}" 2>&1 | head -n 1
    else
        echo "not installed"
    fi
}

# ─────────────────────────────────────────────────────────────────
# HEADER
# ─────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}System Information${RESET}"
echo -e "Generated: $(date '+%Y-%m-%d %H:%M:%S')"

# ─────────────────────────────────────────────────────────────────
# SYSTEM
# ─────────────────────────────────────────────────────────────────

section "System"
kv "Hostname"  "$(hostname -f 2>/dev/null || hostname)"
kv "OS"        "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -s)"
kv "Kernel"    "$(uname -r)"
kv "Arch"      "$(uname -m)"
kv "Uptime"    "$(uptime -p 2>/dev/null || uptime)"
kv "Shell"     "${SHELL}"
kv "User"      "$(whoami)"

# ─────────────────────────────────────────────────────────────────
# CPU
# ─────────────────────────────────────────────────────────────────

section "CPU"
if [[ -f /proc/cpuinfo ]]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d: -f2 | sed 's/^ //')
    CPU_CORES=$(nproc)
    CPU_THREADS=$(grep -c "processor" /proc/cpuinfo)
    kv "Model"   "${CPU_MODEL}"
    kv "Cores"   "${CPU_CORES}"
    kv "Threads" "${CPU_THREADS}"
fi

# ─────────────────────────────────────────────────────────────────
# MEMORY
# ─────────────────────────────────────────────────────────────────

section "Memory"
if command -v free &>/dev/null; then
    MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
    MEM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')
    SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
    kv "Total"     "${MEM_TOTAL}"
    kv "Used"      "${MEM_USED}"
    kv "Available" "${MEM_AVAIL}"
    kv "Swap"      "${SWAP_TOTAL}"
fi

# ─────────────────────────────────────────────────────────────────
# DISK
# ─────────────────────────────────────────────────────────────────

section "Disk"
df -h --output=target,size,used,avail,pcent 2>/dev/null | \
    grep -vE "^(tmpfs|devtmpfs|udev|/dev/loop)" | \
    awk 'NR==1 {printf "  %-20s %-8s %-8s %-8s %s\n", $1,$2,$3,$4,$5}
         NR>1  {printf "  %-20s %-8s %-8s %-8s %s\n", $1,$2,$3,$4,$5}'

# ─────────────────────────────────────────────────────────────────
# NETWORK
# ─────────────────────────────────────────────────────────────────

section "Network"
# Local IP addresses (IPv4 only, exclude loopback)
LOCAL_IPS=$(ip -4 addr show 2>/dev/null | grep inet | grep -v "127.0.0.1" | awk '{print $2}' | tr '\n' ' ' || echo "unavailable")
kv "Local IP" "${LOCAL_IPS}"

# External IP (with timeout to avoid hanging if offline)
EXTERNAL_IP=$(curl -s --connect-timeout 3 https://ipinfo.io/ip 2>/dev/null || echo "unavailable")
kv "External IP" "${EXTERNAL_IP}"

# ─────────────────────────────────────────────────────────────────
# TOOLCHAIN
# ─────────────────────────────────────────────────────────────────

section "Toolchain"
kv "bash"        "$(tool_version bash)"
kv "zsh"         "$(tool_version zsh)"
kv "git"         "$(tool_version git)"
kv "vim"         "$(tool_version vim)"
kv "gcc"         "$(tool_version gcc)"
kv "clang"       "$(tool_version clang)"
kv "make"        "$(tool_version make)"
kv "python3"     "$(tool_version python3)"
kv "pip3"        "$(tool_version pip3)"
kv "valgrind"    "$(tool_version valgrind)"
kv "norminette"  "$(tool_version norminette)"

echo ""