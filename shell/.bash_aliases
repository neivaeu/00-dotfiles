# Shell aliases — sourced from .bashrc.
#
# PHILOSOPHY:
#   This file is intentionally minimal.
#   ALL aliases are commented out by default.
#   Uncomment only what you actually use daily.
#
#   Before uncommenting any alias, ask:
#     "Do I type this exact command 10+ times per day?"
#     "Will this alias confuse me or a teammate reading my commands?"
#     "Does this alias hide important information?"
#
#   If the answer to the last two is yes, leave it commented.
#
# SAFETY NOTE ON ALIASING BUILT-INS:
#   Aliasing cp, mv, rm changes behaviour that scripts and teammates expect.
#   The aliases below are commented — use the flags explicitly when you need them.
#   It builds better habits and avoids surprises.
#
# ORGANISATION:
#   1. Navigation
#   2. File listing
#   3. File operations (SAFETY — read before uncommenting)
#   4. Grep
#   5. Git
#   6. C development (42 School)
#   7. Make
#   8. System information
#   9. Convenience

# ─────────────────────────────────────────────────────────────────
# 1. NAVIGATION
# ─────────────────────────────────────────────────────────────────

# Go up one directory.
# Default: you must type 'cd ..'
# Uncomment if you navigate directory trees constantly.
# alias ..='cd ..'

# Go up two directories.
# alias ...='cd ../..'

# Go up three directories.
# alias ....='cd ../../..'

# Go to home directory.
# Alternative: just type 'cd' with no arguments (always works, no alias needed).
# alias ~='cd ~'

# Go to previous directory.
# 'cd -' already works without an alias — this is only for shorter typing.
# alias -- -='cd -'

# ─────────────────────────────────────────────────────────────────
# 2. FILE LISTING
# ─────────────────────────────────────────────────────────────────

# Colourised ls with file type indicators (/ for dirs, * for executables).
# NOTE: --color=auto only adds colour when output is a terminal, not a pipe.
#       This is safe. -F adds the type indicator suffix.
# alias ls='ls --color=auto -F'

# Long format listing with human-readable sizes.
# -l: long format  -h: human-readable sizes  -F: type indicators
# alias ll='ls -lhF --color=auto'

# Long format including hidden files (dotfiles).
# -a: include entries starting with .
# alias la='ls -lahF --color=auto'

# List only hidden files in the current directory.
# -d: list directory entries themselves, not their contents
# alias l.='ls -d .* --color=auto'

# Sort by modification time, newest first.
# -t: sort by time  -l: long format
# alias lt='ls -ltF --color=auto'

# Sort by size, largest first.
# -S: sort by file size
# alias lS='ls -lSF --color=auto'

# ─────────────────────────────────────────────────────────────────
# 3. FILE OPERATIONS — READ BEFORE UNCOMMENTING
# ─────────────────────────────────────────────────────────────────
#
# WARNING:
#   Aliasing cp/mv/rm to add -i (interactive) changes the behaviour of
#   these commands globally. This can cause issues when:
#     - You run a script that calls cp/mv/rm and expects non-interactive mode
#     - A teammate reads your command history and expects standard behaviour
#     - You switch to a machine without these aliases and forget to add -i
#
#   Better habit: use -i explicitly when you are unsure.
#   Use rm -i when deleting something important.
#   Use cp -i when overwriting would be dangerous.
#
# RECOMMENDATION: Leave these commented. Type the flags when you need them.

# Prompt before overwrite/delete.
# -i: interactive (ask before each operation)
# -v: verbose (show what is being done)
# alias cp='cp -iv'
# alias mv='mv -iv'
# alias rm='rm -iv'

# Create parent directories automatically and show what was created.
# -p: create parents  -v: verbose
# This one is reasonably safe to uncomment — mkdir -p is almost always
# what you want, and the verbose output is informative.
# alias mkdir='mkdir -pv'

# Human-readable disk usage.
# -h: human-readable sizes (KB, MB, GB)
# alias df='df -h'
# alias du='du -h'

# Show disk usage of items in current directory, sorted largest first.
# -s: summary (one line per argument)  -h: human-readable  sort -rh: reverse human sort
# alias dut='du -sh * | sort -rh'

# ─────────────────────────────────────────────────────────────────
# 4. GREP
# ─────────────────────────────────────────────────────────────────

# Colourised grep — only adds colour when output goes to a terminal.
# --color=auto is safe (does not affect piped output).
# Uncomment if you grep frequently and want visual feedback.
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'

# Recursive grep with line numbers — the most common grep use case.
# -r: recursive  -n: show line numbers
# alias rgrep='grep -rn'

# ─────────────────────────────────────────────────────────────────
# 5. GIT
# ─────────────────────────────────────────────────────────────────
#
# NOTE:
#   Git aliases defined here (shell aliases) are different from
#   git aliases defined in ~/.gitconfig.
#   Prefer git aliases in ~/.gitconfig for git subcommands.
#   Use shell aliases here only for the highest-frequency operations.
#
#   'gs' conflicts with the Ghostscript command on some systems.
#   Be aware of this if you use PostScript/PDF tools.

# alias g='git'
# alias gs='git status'
# alias ga='git add'
# alias gaa='git add --all'
# alias gc='git commit'
# alias gp='git push'
# alias gl='git pull'
# alias gd='git diff'
# alias gds='git diff --staged'
# alias glo='git log --oneline'
# alias glg='git log --oneline --graph --decorate'
# alias gb='git branch'
# alias gco='git checkout'
# alias gcb='git checkout -b'

# ─────────────────────────────────────────────────────────────────
# 6. C DEVELOPMENT (42 SCHOOL)
# ─────────────────────────────────────────────────────────────────

# Standard 42 compilation flags.
# -Wall: all warnings  -Wextra: extra warnings  -Werror: treat warnings as errors
# alias cc42='cc -Wall -Wextra -Werror'

# Compile with debug info and sanitisers (development only, never submit).
# -g3: maximum debug info  -O0: no optimisation  -fsanitize: runtime error detection
# alias ccdbg='cc -Wall -Wextra -Werror -g3 -O0 -fsanitize=address,undefined'

# Run norminette on all C and H files in current directory.
# norminette must be installed separately (42 tool).
# alias norm='norminette *.c *.h 2>/dev/null || norminette . 2>/dev/null'

# Valgrind — full memory error and leak detection.
# --leak-check=full: detailed leak report
# --show-leak-kinds=all: show all categories of leaks
# --track-origins=yes: show where uninitialised values came from (slower)
# alias vg='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes'

# Valgrind with exit code — useful in Makefiles or CI scripts.
# --error-exitcode=1: exit with code 1 if errors found
# alias vgc='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --error-exitcode=1'

# ─────────────────────────────────────────────────────────────────
# 7. MAKE
# ─────────────────────────────────────────────────────────────────

# Run make with parallel jobs (one per CPU core).
# -j: parallel jobs  $(nproc): number of processors
# alias mkj='make -j$(nproc)'

# Full rebuild target.
# alias mkre='make re'

# Clean build artifacts.
# alias mkclean='make fclean'

# ─────────────────────────────────────────────────────────────────
# 8. SYSTEM INFORMATION
# ─────────────────────────────────────────────────────────────────

# Memory usage in human-readable format.
# -h: human-readable (MB, GB)
# alias free='free -h'

# Show PATH entries one per line — easier to read than the colon-separated value.
# tr ':' '\n' splits on colon and puts each entry on its own line
# alias path='echo $PATH | tr ":" "\n"'

# Show listening network ports.
# ss replaces the deprecated netstat.
# -t: TCP  -u: UDP  -l: listening  -p: show process  -n: numeric (no DNS lookup)
# alias ports='ss -tulpn'

# Show all active connections.
# -t: TCP  -u: UDP  -p: process  -n: numeric
# alias conns='ss -tupn'

# Processes sorted by CPU usage, top 20.
# --sort=-%cpu: descending CPU sort
# alias pscpu='ps aux --sort=-%cpu | head -20'

# Processes sorted by memory usage, top 20.
# alias psmem='ps aux --sort=-%mem | head -20'

# Find a process by name.
# grep -v grep: exclude the grep process itself from results
# alias psg='ps aux | grep -v grep | grep'

# ─────────────────────────────────────────────────────────────────
# 9. CONVENIENCE
# ─────────────────────────────────────────────────────────────────

# Clear the screen.
# Note: Ctrl+L already does this in any terminal — no alias needed.
# Only uncomment if you prefer typing 'c' over pressing Ctrl+L.
# alias c='clear'

# Use vim when vi is typed — ensures full Vim, not a minimal vi.
# Safe to uncomment if vim is installed and you use it.
# alias vi='vim'

# Show command history with line numbers.
# 'history' already does this — this is just shorter.
# alias h='history'

# Search history.
# Usage: hs searchterm
# Alternative: Ctrl+R in the terminal for interactive reverse search.
# alias hs='history | grep'

# Reload .bashrc without restarting the shell.
# alias reload='source ~/.bashrc && echo "Shell reloaded"'

# Count files in current directory (non-hidden).
# ls -1: one file per line  wc -l: count lines
# alias count='ls -1 | wc -l'

# Show file permissions in octal format.
# Useful when setting chmod values.
# stat -c "%a %n": octal permissions and filename
# alias perms='stat -c "%a %n" *'

# Quick edit common config files.
# These open the file in vim and source it after saving.
# Only safe if you trust your .bashrc not to break the shell on save.
# alias bashrc='vim ~/.bashrc && source ~/.bashrc'
# alias aliases='vim ~/.bash_aliases && source ~/.bash_aliases'
# alias vimrc='vim ~/.vimrc'
# alias gitconfig='vim ~/.gitconfig'

# ─────────────────────────────────────────────────────────────────
# 42-SCHOOL SPECIFIC
# ─────────────────────────────────────────────────────────────────

# Full pre-submission check: rebuild, norminette, then remind about valgrind.
# alias check42='make re && norminette *.c *.h && echo "Run: valgrind ./program"'

# Check for lines over 80 characters (Norm violation).
# awk checks length of each line; FILENAME:NR shows location.
# alias normlen='awk "length > 80 {print FILENAME \":\" NR \" (\" length \" chars)\"}" *.c *.h 2>/dev/null'

# Check for spaces used as indentation instead of tabs (Norm violation).
# The Norm requires tabs; spaces for indentation are a violation.
# alias normtabs='grep -Pn "^\t* {4}" *.c *.h 2>/dev/null && echo "Spaces found" || echo "Tabs OK"'