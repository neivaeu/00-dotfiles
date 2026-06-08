# Shell aliases — sourced from .zshrc.
#
# PHILOSOPHY:
#   This file contains NO active aliases by default.
#   Everything is commented out with a full explanation.
#
#   An alias is worth having if:
#     - You type it more than 10 times per day
#     - It does not change the meaning of an existing command
#     - A teammate reading your shell session would understand it
#
#   An alias should be avoided if:
#     - It shadows an existing command name with different behaviour
#     - It adds flags that scripts might not expect
#     - It requires an external tool to be installed
#
# ORGANISATION:
#   1. Navigation
#   2. File listing
#   3. File operations (safety)
#   4. Grep
#   5. Git
#   6. C development (42 School)
#   7. Make
#   8. System
#   9. Convenience

# ─────────────────────────────────────────────────────────────────
# 1. NAVIGATION
# ─────────────────────────────────────────────────────────────────

# Go up one directory.
# 'cd ..' already works without an alias.
# Only worth having if you navigate directory trees many times per day.
# alias ..='cd ..'

# Go up two directories.
# alias ...='cd ../..'

# Go up three directories.
# alias ....='cd ../../..'

# Go up four directories.
# alias .....='cd ../../../..'

# Go to home directory.
# 'cd' with no arguments already goes home — no alias needed.
# alias home='cd ${HOME}'

# Go to common development directory.
# Adjust the path to your actual development root.
# alias dev='cd ${HOME}/dev'

# Show the real path with symlinks resolved.
# pwd -P is already a built-in option; this is purely convenience.
# alias pwd='pwd -P'

# ─────────────────────────────────────────────────────────────────
# 2. FILE LISTING
# ─────────────────────────────────────────────────────────────────
#
# NOTE on ls aliases:
#   Adding --color=auto is safe (colour only in terminal, not pipe).
#   Adding -F (type indicators) is safe and informative.
#   Aliasing 'ls' itself changes the default for all ls usage — think carefully.

# Colourised ls with type indicators.
# --color=auto: only colour in terminal output, not when piped.
# -F: append indicator to each entry (/ dir, * executable, @ symlink, etc.)
# alias ls='ls --color=auto -F'

# Long format listing.
# -l: long format  -h: human-readable sizes  -F: type indicators
# alias ll='ls -lhF --color=auto'

# Long format including hidden files.
# -a: include entries starting with .  (includes . and ..)
# -A: include hidden but exclude . and ..
# alias la='ls -lAhF --color=auto'

# Sort by modification time, newest first.
# -t: sort by modification time  -l: long format
# alias lt='ls -ltF --color=auto'

# Sort by size, largest first.
# -S: sort by size  -l: long format
# alias lS='ls -lSF --color=auto'

# List only directories.
# -d: list directories themselves  */: glob matches only directories
# alias ld='ls -d */ --color=auto'

# ─────────────────────────────────────────────────────────────────
# 3. FILE OPERATIONS — SAFETY
# ─────────────────────────────────────────────────────────────────
#
# These aliases add -i (interactive prompt) and -v (verbose) to
# file operation commands. Read the warning before uncommenting.
#
# WARNING:
#   Aliasing cp/mv/rm changes their global behaviour. Problems arise when:
#   - A script calls these commands expecting non-interactive behaviour
#   - You move to a machine without these aliases and rely on the protection
#   - A teammate reads your history and does not know about the alias
#
#   Better practice: use -i explicitly when you need it.
#   Use 'rm -i file' when you want confirmation.
#   Do not rely on an alias for safety — build the habit instead.

# Prompt before overwriting (cp) — asks if destination exists.
# -i: interactive  -v: verbose (shows what is being copied)
# alias cp='cp -iv'

# Prompt before overwriting (mv).
# alias mv='mv -iv'

# Prompt before deleting (rm).
# NOTE: rm -i is famously annoying. Consider using 'trash' or moving to
#       a trash directory instead of rm for interactive use.
# alias rm='rm -iv'

# Create parent directories automatically.
# -p: create parents  -v: verbose (shows each created directory)
# This one is safer to uncomment than rm/cp/mv as mkdir -p is almost
# always what you want, and changing its default is rarely a problem.
# alias mkdir='mkdir -pv'

# ─────────────────────────────────────────────────────────────────
# 4. GREP
# ─────────────────────────────────────────────────────────────────

# Colourised grep.
# --color=auto: only adds colour in terminal output, not when piped.
# Safe to uncomment. Makes it much easier to spot matches.
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'

# Recursive grep with line numbers.
# -r: recursive  -n: show line numbers
# Most commonly used grep pattern for searching source code.
# alias rgrep='grep -rn'

# ─────────────────────────────────────────────────────────────────
# 5. GIT
# ─────────────────────────────────────────────────────────────────
#
# These are shell aliases, not git aliases.
# Consider using git aliases in ~/.gitconfig instead — they work in any shell.
#
# Conflicts to be aware of:
#   'gs' conflicts with Ghostscript (gs command) on some systems.
#   'gb' may conflict with other tools.

# Short form for git.
# alias g='git'

# Status with branch info in compact format.
# --short: compact format  --branch: include branch info
# alias gs='git status --short --branch'

# Stage changes.
# alias ga='git add'

# Stage all changes including untracked files.
# alias gaa='git add --all'

# Commit (opens editor for message).
# alias gc='git commit'

# Commit with inline message (skips editor).
# alias gcm='git commit --message'

# Amend the last commit (useful for fixing the commit message or adding forgotten files).
# alias gca='git commit --amend'

# Amend without changing the commit message.
# Useful when you just want to add a forgotten file to the last commit.
# alias gcane='git commit --amend --no-edit'

# Branch operations.
# alias gb='git branch'
# alias gba='git branch --all'

# Checkout.
# alias gco='git checkout'

# Create and switch to new branch.
# alias gcb='git checkout -b'

# Fetch all remotes and remove stale tracking branches.
# --prune: remove local tracking branches that no longer exist on the remote
# alias gf='git fetch --all --prune'

# Pull.
# alias gl='git pull'

# Push.
# alias gp='git push'

# Safer force push — fails if the remote has commits you have not seen.
# Use instead of --force to avoid overwriting others' work.
# alias gpf='git push --force-with-lease'

# Diff unstaged changes.
# alias gd='git diff'

# Diff staged changes (what will be committed).
# alias gds='git diff --staged'

# Compact graph log showing all branches.
# --oneline: one line per commit  --graph: ASCII graph  --decorate: branch/tag labels
# alias glog='git log --oneline --graph --decorate --all'

# Stash operations.
# alias gst='git stash'
# alias gstp='git stash pop'
# alias gstl='git stash list'

# Unstage all staged changes.
# alias grh='git reset HEAD'

# Discard all uncommitted changes — DESTRUCTIVE, cannot be undone.
# alias grhh='git reset --hard HEAD'

# ─────────────────────────────────────────────────────────────────
# 6. C DEVELOPMENT (42 SCHOOL)
# ─────────────────────────────────────────────────────────────────

# Standard 42 compilation flags.
# -Wall: enable all standard warnings
# -Wextra: enable extra warnings not covered by -Wall
# -Werror: treat all warnings as errors (submission requirement)
# alias cc42='cc -Wall -Wextra -Werror'

# Compile with debug info and runtime error detection.
# -g3: maximum debug information (for gdb)
# -O0: no optimisation (makes debugging predictable)
# -fsanitize=address: detect memory errors (buffer overflows, use-after-free)
# -fsanitize=undefined: detect undefined behaviour
# Note: do NOT submit code compiled with sanitisers — they add overhead.
# alias ccdbg='cc -Wall -Wextra -Werror -g3 -O0 -fsanitize=address,undefined'

# Run norminette (42 code style checker).
# norminette must be installed separately.
# alias norm='norminette'

# Run norminette on all C and H files in the current directory.
# alias normall='norminette *.c *.h 2>/dev/null || norminette . 2>/dev/null'

# Valgrind — memory error detector and leak checker.
# --leak-check=full: detailed report of all leaks
# --show-leak-kinds=all: include all categories (definitely, indirectly, possibly lost)
# --track-origins=yes: track where uninitialised values came from (slower but useful)
# --verbose: show extra information
# alias val='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose'

# Valgrind with exit code for scripting.
# --error-exitcode=1: return exit code 1 if any errors found (useful in Makefiles)
# alias valc='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --error-exitcode=1'

# ─────────────────────────────────────────────────────────────────
# 7. MAKE
# ─────────────────────────────────────────────────────────────────

# Run make.
# alias mk='make'

# Run make with parallel jobs (one per CPU core).
# -j: parallel jobs  $(nproc): number of available processors
# WARNING on macOS: nproc is not available, use sysctl -n hw.ncpu instead.
# alias mkj='make -j$(nproc)'

# Run the clean target.
# alias mkc='make clean'

# Run the fclean target (42 full clean).
# alias mkfc='make fclean'

# Run the re target (fclean + all).
# alias mkre='make re'

# ─────────────────────────────────────────────────────────────────
# 8. SYSTEM
# ─────────────────────────────────────────────────────────────────

# Memory usage in human-readable format.
# -h: human-readable (MB, GB)
# alias free='free -h'

# Disk free in human-readable format.
# -h: human-readable
# alias df='df -h'

# Disk usage — human-readable.
# alias du='du -h'

# Disk usage of current directory contents, sorted by size.
# -s: summary  -h: human-readable  sort -rh: reverse human-sort (largest first)
# alias duh='du -sh * | sort -rh'

# Process list.
# aux: show all processes with full information
# f: show process tree (forest view)
# alias ps='ps auxf'

# Find a process by name.
# grep -v grep: exclude the grep process itself
# Usage: psg nginx
# alias psg='ps aux | grep -v grep | grep'

# Show listening ports (TCP and UDP).
# ss: socket statistics (modern replacement for netstat)
# -t: TCP  -u: UDP  -l: listening only  -p: show process  -n: numeric (no DNS)
# alias ports='ss -tulpn'

# External IP address.
# Uses a public API to return your current public IP.
# Requires internet access and curl.
# alias myip='curl -s https://ipinfo.io/ip'

# Local IP addresses.
# -4: IPv4 only  addr show: show addresses  grep inet: show IP lines
# alias localip='ip -4 addr show | grep inet'

# System update (Debian/Ubuntu only).
# alias update='sudo apt update && sudo apt upgrade -y'

# Show PATH one entry per line.
# tr ':' '\n': replace colons with newlines
# alias path='echo $PATH | tr ":" "\n"'

# ─────────────────────────────────────────────────────────────────
# 9. CONVENIENCE
# ─────────────────────────────────────────────────────────────────

# Clear the screen.
# Ctrl+L already does this — no alias needed.
# Uncomment only if you prefer typing 'c'.
# alias c='clear'

# Exit the shell.
# alias q='exit'

# Exit for Vim users who type :q by habit.
# alias :q='exit'

# Use vim when vi is typed.
# Ensures you get full Vim, not a stripped-down vi.
# Safe if vim is installed.
# alias vi='vim'

# Reload zsh configuration without restarting the shell.
# alias reload='source ~/.zshrc && echo "zshrc reloaded"'

# Shorter vim invocation.
# alias v='vim'

# Count files in current directory (non-hidden).
# ls -1: one file per line  wc -l: count lines
# alias count='ls -1 | wc -l'

# Show file permissions in octal format.
# Useful when setting chmod values.
# stat -c "%a %n": print octal permissions and filename
# alias perms='stat -c "%a %n" *'

# Quick HTTP server in the current directory.
# python3 -m http.server: serves files over HTTP on port 8000
# Useful for testing web pages locally or sharing files on a local network.
# alias serve='python3 -m http.server 8000'

# Generate a cryptographically secure random password.
# openssl rand -base64 32: generates 32 random bytes encoded as base64 (~43 chars)
# alias genpass='openssl rand -base64 32'

# Check SSL certificate for a domain.
# Usage: sslcheck domain.com:443
# echo |: sends empty input so openssl does not wait for stdin
# alias sslcheck='echo | openssl s_client -connect'