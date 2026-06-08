# Shell functions — sourced from .zshrc.
#
# WHEN TO USE A FUNCTION INSTEAD OF AN ALIAS:
#   - The command needs to accept arguments ($1, $2, ...)
#   - The command needs conditional logic (if/case)
#   - The command needs a loop
#   - The command needs to validate its inputs
#   - The command is long enough that reading it inline is confusing
#
# ALL FUNCTIONS ARE COMMENTED OUT BY DEFAULT.
# Uncomment what you use. Each function has:
#   - Purpose
#   - Usage
#   - Explanation of every flag and construct used
#
# FUNCTIONS IN THIS FILE:
#   mkcd        — create directory and cd into it
#   up          — go up N directories
#   ff          — find file by name
#   ffd         — find directory by name
#   backup      — timestamped file backup
#   extract     — decompress any archive
#   portcheck   — check if a TCP port is open
#   hex         — decimal to hexadecimal
#   dec         — hexadecimal to decimal
#   epoch       — show Unix timestamp and human date
#   urlencode   — URL-encode a string
#   urldecode   — URL-decode a string
#   b64encode   — base64 encode
#   b64decode   — base64 decode
#   repeat_cmd  — repeat a command N times
#   manf        — find man page sections for a command
#   sizeof      — show size of file or directory
#   norm_check  — run norminette, show only errors
#   gitignore   — generate .gitignore from gitignore.io API

# ─────────────────────────────────────────────────────────────────
# mkcd — create a directory and immediately cd into it
# ─────────────────────────────────────────────────────────────────
# Usage: mkcd <dirname>
# Example: mkcd myproject
#
# Why:
#   'mkdir newdir && cd newdir' is one of the most common two-command sequences.
#   Combining them avoids the risk of mistyping the directory name in the cd.
#
# mkdir -p: create intermediate parent directories as needed
# cd "$1" || return 1: if cd fails (very rare), return an error code

# mkcd() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: mkcd <directory>" >&2
#         return 1
#     fi
#     mkdir -p "$1" && cd "$1" || return 1
# }

# ─────────────────────────────────────────────────────────────────
# up — go up N directories at once
# ─────────────────────────────────────────────────────────────────
# Usage: up [N]
# Example: up 3  →  equivalent to cd ../../..
#          up    →  equivalent to cd ..
#
# Why:
#   'cd ../../..' is awkward to type and count. 'up 3' is clearer.

# up() {
#     local n="${1:-1}"   # Default to 1 if no argument given
#     local path=""
#     local i=0
#     while [[ $i -lt $n ]]; do
#         path="${path}../"   # Build the relative path by appending ../
#         i=$((i + 1))
#     done
#     cd "${path}" || return 1
# }

# ─────────────────────────────────────────────────────────────────
# ff — find a file by name in the current directory tree
# ─────────────────────────────────────────────────────────────────
# Usage: ff <name>
# Example: ff main.c
#          ff "*.h"    (with quotes to prevent shell glob expansion)
#
# find: search the directory tree starting from . (current directory)
# -iname: case-insensitive name match  *$1*: partial match around the argument
# 2>/dev/null: suppress "Permission denied" errors for directories you cannot read

# ff() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: ff <name>" >&2
#         return 1
#     fi
#     find . -iname "*$1*" 2>/dev/null
# }

# ─────────────────────────────────────────────────────────────────
# ffd — find a directory by name in the current directory tree
# ─────────────────────────────────────────────────────────────────
# Usage: ffd <name>
# Example: ffd src
#
# -type d: match only directories, not files

# ffd() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: ffd <name>" >&2
#         return 1
#     fi
#     find . -type d -iname "*$1*" 2>/dev/null
# }

# ─────────────────────────────────────────────────────────────────
# backup — create a timestamped backup copy of a file
# ─────────────────────────────────────────────────────────────────
# Usage: backup <file>
# Example: backup Makefile  →  creates Makefile.2024-01-15_14:30:00.bak
#
# Why:
#   Before editing a critical file, a timestamped backup prevents data loss.
#   Using a timestamp ensures you never accidentally overwrite a previous backup.
#
# date '+%Y-%m-%d_%H:%M:%S': formats the date as 2024-01-15_14:30:00
# cp -v: verbose copy (shows source → destination)

# backup() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: backup <file>" >&2
#         return 1
#     fi
#     if [[ ! -f "$1" ]]; then
#         echo "Error: '$1' is not a file." >&2
#         return 1
#     fi
#     local timestamp
#     timestamp="$(date '+%Y-%m-%d_%H:%M:%S')"
#     cp -v "$1" "$1.${timestamp}.bak"
# }

# ─────────────────────────────────────────────────────────────────
# extract — decompress any common archive format
# ─────────────────────────────────────────────────────────────────
# Usage: extract <archive>
# Example: extract archive.tar.gz
#
# Why:
#   Each archive format uses different tools and flags:
#     tar.gz  → tar -xzf
#     zip     → unzip
#     7z      → 7z x
#   This function removes the need to remember which tool to use.
#
# Note: 7z and unrar must be installed separately if needed.
#       The tar, gunzip, bunzip2, and unxz tools are standard on Linux.

# extract() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: extract <archive>" >&2
#         return 1
#     fi
#     if [[ ! -f "$1" ]]; then
#         echo "Error: '$1' is not a file." >&2
#         return 1
#     fi
#     case "$1" in
#         *.tar.gz|*.tgz)   tar -xzf "$1" ;;   # -x extract -z gunzip -f file
#         *.tar.bz2|*.tbz2) tar -xjf "$1" ;;   # -j bzip2
#         *.tar.xz|*.txz)   tar -xJf "$1" ;;   # -J xz
#         *.tar.zst)        tar -I zstd -xf "$1" ;; # zstd via -I (external decompressor)
#         *.tar)            tar -xf  "$1" ;;
#         *.gz)             gunzip   "$1" ;;
#         *.bz2)            bunzip2  "$1" ;;
#         *.xz)             unxz     "$1" ;;
#         *.zip)            unzip    "$1" ;;
#         *.7z)             7z x     "$1" ;;   # Requires p7zip-full
#         *.rar)            unrar x  "$1" ;;   # Requires unrar
#         *)
#             echo "Unknown archive format: '$1'" >&2
#             echo "Supported: tar.gz tar.bz2 tar.xz tar.zst tar gz bz2 xz zip 7z rar" >&2
#             return 1
#             ;;
#     esac
# }

# ─────────────────────────────────────────────────────────────────
# portcheck — test if a TCP port is open on a host
# ─────────────────────────────────────────────────────────────────
# Usage: portcheck <host> <port>
# Example: portcheck localhost 8080
#          portcheck 192.168.1.1 22
#
# Why:
#   Quick way to verify if a service is reachable on a port.
#   Uses bash's built-in /dev/tcp — no netcat or nmap needed.
#
# timeout 3: wait at most 3 seconds (prevents hanging on firewalled ports)
# bash -c "echo >/dev/tcp/$host/$port": opens a TCP connection
# /dev/tcp is a bash feature, not an actual device file

# portcheck() {
#     if [[ $# -ne 2 ]]; then
#         echo "Usage: portcheck <host> <port>" >&2
#         return 1
#     fi
#     local host="$1"
#     local port="$2"
#     if ! [[ "${port}" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
#         echo "Error: '$port' is not a valid port number (1-65535)." >&2
#         return 1
#     fi
#     if timeout 3 bash -c "echo >/dev/tcp/${host}/${port}" 2>/dev/null; then
#         echo "OPEN: ${host}:${port}"
#         return 0
#     else
#         echo "CLOSED or unreachable: ${host}:${port}"
#         return 1
#     fi
# }

# ─────────────────────────────────────────────────────────────────
# hex — convert a decimal integer to hexadecimal
# ─────────────────────────────────────────────────────────────────
# Usage: hex <decimal>
# Example: hex 255  →  0xFF
#
# printf '0x%X': format as uppercase hex with 0x prefix
# %x would give lowercase hex without prefix

# hex() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: hex <decimal>" >&2
#         return 1
#     fi
#     printf "0x%X\n" "$1"
# }

# ─────────────────────────────────────────────────────────────────
# dec — convert a hexadecimal number to decimal
# ─────────────────────────────────────────────────────────────────
# Usage: dec <hex>
# Example: dec FF    →  255
#          dec 0xFF  →  255
#
# ${1#0x}: removes the '0x' prefix if present (parameter expansion)
# ${val#0X}: removes '0X' prefix if present
# printf "%d" "0x${val}": interpret as hex and print as decimal

# dec() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: dec <hex>" >&2
#         return 1
#     fi
#     local val="${1#0x}"   # Remove 0x prefix
#     val="${val#0X}"        # Remove 0X prefix
#     printf "%d\n" "0x${val}"
# }

# ─────────────────────────────────────────────────────────────────
# epoch — show current Unix timestamp and its human-readable equivalent
# ─────────────────────────────────────────────────────────────────
# Usage: epoch
#        epoch <timestamp>   (convert a past timestamp)
# Example: epoch             →  shows current time
#          epoch 1704067200  →  shows what that timestamp represents
#
# date +%s: current Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
# date -d "@${ts}": convert Unix timestamp to human date (Linux only)
# Note: on macOS, use 'date -r "${ts}"' instead of 'date -d "@${ts}"'

# epoch() {
#     if [[ $# -eq 0 ]]; then
#         local ts
#         ts="$(date +%s)"
#         echo "Unix timestamp : ${ts}"
#         echo "Human-readable : $(date -d "@${ts}" '+%Y-%m-%d %H:%M:%S %Z')"
#     else
#         echo "Unix timestamp : $1"
#         echo "Human-readable : $(date -d "@$1" '+%Y-%m-%d %H:%M:%S %Z')"
#     fi
# }

# ─────────────────────────────────────────────────────────────────
# urlencode — URL-encode a string
# ─────────────────────────────────────────────────────────────────
# Usage: urlencode <string>
# Example: urlencode "hello world"  →  hello%20world
#
# Uses Python's urllib.parse.quote for reliable encoding.
# Requires Python 3 (standard on modern Linux systems).

# urlencode() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: urlencode <string>" >&2
#         return 1
#     fi
#     python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1"
# }

# ─────────────────────────────────────────────────────────────────
# urldecode — URL-decode a string
# ─────────────────────────────────────────────────────────────────
# Usage: urldecode <encoded-string>
# Example: urldecode "hello%20world"  →  hello world

# urldecode() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: urldecode <encoded-string>" >&2
#         return 1
#     fi
#     python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1"
# }

# ─────────────────────────────────────────────────────────────────
# b64encode — base64 encode a string
# ─────────────────────────────────────────────────────────────────
# Usage: b64encode <string>
# Example: b64encode "secret"  →  c2VjcmV0
#
# echo -n: no trailing newline (important — newline changes the encoded output)
# base64: standard tool, available on all Linux systems

# b64encode() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: b64encode <string>" >&2
#         return 1
#     fi
#     echo -n "$1" | base64
# }

# ─────────────────────────────────────────────────────────────────
# b64decode — base64 decode a string
# ─────────────────────────────────────────────────────────────────
# Usage: b64decode <encoded-string>
# Example: b64decode "c2VjcmV0"  →  secret
#
# --decode: decode mode (some systems accept -d instead)
# echo "": adds a newline after the decoded output (base64 output has none)

# b64decode() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: b64decode <encoded-string>" >&2
#         return 1
#     fi
#     echo -n "$1" | base64 --decode
#     echo ""   # Add newline since base64 output does not include one
# }

# ─────────────────────────────────────────────────────────────────
# repeat_cmd — repeat a command N times
# ─────────────────────────────────────────────────────────────────
# Usage: repeat_cmd <N> <command> [args...]
# Example: repeat_cmd 5 echo "hello"
#          repeat_cmd 10 ./test_program
#
# Why:
#   Useful for stress testing, reproducing flaky behaviour, or running
#   a benchmark multiple times.
#
# shift: removes the first argument ($1) so "$@" becomes the command
# "$@": expands to all remaining arguments, properly quoted

# repeat_cmd() {
#     if [[ $# -lt 2 ]]; then
#         echo "Usage: repeat_cmd <N> <command> [args...]" >&2
#         return 1
#     fi
#     local n="$1"
#     shift   # Remove N from arguments so "$@" is now the command
#     local i=0
#     while [[ $i -lt $n ]]; do
#         i=$((i + 1))
#         echo "--- Run ${i}/${n} ---"
#         "$@"   # Execute the command with all its arguments
#     done
# }

# ─────────────────────────────────────────────────────────────────
# manf — show which manual sections contain an entry for a command
# ─────────────────────────────────────────────────────────────────
# Usage: manf <command>
# Example: manf printf  →  shows printf(1) and printf(3)
#
# Why:
#   'man printf' shows section 1 (shell command). But for C, you want
#   section 3 (library function). manf shows all available sections.
#
# man -f: equivalent to 'whatis', one-line description per section
# whatis: fallback if 'man -f' is not available

# manf() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: manf <command>" >&2
#         return 1
#     fi
#     man -f "$1" 2>/dev/null || whatis "$1" 2>/dev/null || \
#         echo "No manual entry for: $1"
# }

# ─────────────────────────────────────────────────────────────────
# sizeof — show the size of a file or directory
# ─────────────────────────────────────────────────────────────────
# Usage: sizeof <path>
# Example: sizeof my_project/
#
# du -sh: disk usage summary (-s) in human-readable format (-h)
# This is just a memorable wrapper around 'du -sh'.

# sizeof() {
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: sizeof <file|directory>" >&2
#         return 1
#     fi
#     du -sh "$1"
# }

# ─────────────────────────────────────────────────────────────────
# norm_check — run norminette and show only errors (not OK lines)
# ─────────────────────────────────────────────────────────────────
# Usage: norm_check [file ...]
#        norm_check *.c *.h
#
# Why:
#   norminette prints 'OK!' for every file that passes.
#   When you have 30 files, the OK lines bury the errors you need to fix.
#   This function filters to show only the lines that matter.
#
# grep -v "^OK!": -v inverts the match, showing lines NOT starting with OK!
# "$@": passes all arguments to norminette

# norm_check() {
#     norminette "$@" 2>&1 | grep -v "^OK!"
# }

# ─────────────────────────────────────────────────────────────────
# gitignore — fetch a .gitignore template from gitignore.io
# ─────────────────────────────────────────────────────────────────
# Usage: gitignore <type1> [type2] ...
# Example: gitignore c linux vim
#          gitignore python vscode macos
#
# Why:
#   Writing .gitignore from scratch is tedious and error-prone.
#   gitignore.io maintains community-maintained templates for hundreds
#   of languages, tools, and operating systems.
#
# curl -fsSL: download quietly (-s), follow redirects (-L), fail on error (-f)
# printf "%s," "$@" | sed 's/,$//': join arguments with commas, remove trailing comma
# >>: APPEND to existing .gitignore (does not overwrite)

# gitignore() {
#     if [[ $# -eq 0 ]]; then
#         echo "Usage: gitignore <type1> [type2] ..." >&2
#         echo "Browse: https://www.toptal.com/developers/gitignore/api/list" >&2
#         return 1
#     fi
#     local types
#     types=$(printf "%s," "$@" | sed 's/,$//')
#     curl -fsSL "https://www.toptal.com/developers/gitignore/api/${types}" >> .gitignore
#     echo "Appended gitignore rules for: ${types}"
# }