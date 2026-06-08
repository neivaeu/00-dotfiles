# Bash configuration — sourced for every interactive Bash shell.
#
# WHEN THIS FILE IS SOURCED:
#   - Every time you open a new terminal window or tab
#   - NOT when running a shell script (scripts are non-interactive)
#   - NOT for login shells unless .bash_profile sources it (which it does)
#
# DESIGN PRINCIPLE:
#   This file is kept minimal. Every option that is not strictly necessary
#   is commented out with an explanation of what it does and why it is off.
#   Uncomment only what you understand and actively want.
#
# SECTIONS:
#   1. Guard — exit early for non-interactive shells
#   2. History
#   3. Shell options
#   4. Prompt (PS1)
#   5. Completion
#   6. Source .bash_aliases
#   7. Functions
#   8. Local overrides

# ─────────────────────────────────────────────────────────────────
# 1. GUARD — non-interactive shells must not load this file
# ─────────────────────────────────────────────────────────────────

# When bash runs a script, it is non-interactive.
# Loading aliases, prompts, and functions in scripts causes unexpected
# behaviour and can break them.
# This check is the correct POSIX way to detect interactive mode.
case $- in
    *i*) ;;       # Interactive shell — continue loading
    *)   return;; # Non-interactive — stop here immediately
esac

# ─────────────────────────────────────────────────────────────────
# 2. HISTORY
# ─────────────────────────────────────────────────────────────────

# Number of commands to keep in memory during the session.
HISTSIZE=10000

# Number of commands to keep in the history file on disk.
HISTFILESIZE=20000

# Ignore duplicate consecutive commands and commands starting with a space.
# ignoredups: skip if same as previous command
# ignorespace: skip if command starts with a space (useful for secrets)
# ignoreboth: enables both of the above
HISTCONTROL=ignoreboth

# Append to the history file when the shell exits, instead of overwriting.
# Without this, the last shell to exit wins and overwrites history from others.
# This is one of the few options active by default — it prevents history loss.
shopt -s histappend

# Store the timestamp of each history entry.
# Format: YYYY-MM-DD HH:MM:SS followed by two spaces.
# Useful when investigating what was run and when.
HISTTIMEFORMAT="%F %T  "

# Write each command to the history file immediately after it runs.
# Without this, history is only saved when the shell exits.
# history -a: append new entries to the history file now
# This line is prepended to any existing PROMPT_COMMAND value.
#
# NOTE: This is ACTIVE because losing history when a terminal crashes
#       is a real and common problem. The cost is negligible.
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Commands to exclude from history — trivial commands not worth saving.
# These add noise when you search history later.
# HISTIGNORE="ls:ll:la:cd:pwd:clear:exit:history"

# ─────────────────────────────────────────────────────────────────
# 3. SHELL OPTIONS
# ─────────────────────────────────────────────────────────────────

# Update LINES and COLUMNS variables when the terminal window is resized.
# Without this, some programs (like vim) may not resize correctly.
# This is active — it has no downside and fixes a real usability issue.
shopt -s checkwinsize

# Append ** in a glob pattern to match files in subdirectories recursively.
# Example: ls **/*.c lists all .c files in the current tree.
# Safe to uncomment — only changes glob behaviour when you explicitly use **.
# shopt -s globstar

# Enable extended glob patterns: ?(pattern), *(pattern), +(pattern), etc.
# Useful for complex filename matching. No downside if enabled.
# shopt -s extglob

# Automatically correct minor spelling mistakes in 'cd' arguments.
# Example: cd Dekstop → cd Desktop
# Uncomment if you frequently mistype directory names.
# shopt -s cdspell

# Automatically cd when you type a directory name as a command.
# Example: typing 'Downloads' is equivalent to 'cd Downloads'.
# WARNING: Can cause confusion when a directory name matches a concept
#          you might expect to be a command. Off by default for clarity.
# shopt -s autocd

# Case-insensitive glob matching.
# Example: ls *.C matches both .C and .c files.
# Uncomment if your filesystem is case-insensitive or you mix cases.
# shopt -s nocaseglob

# Prevent accidental file overwrite with redirection (>).
# To force overwrite when this is on, use >| instead of >.
# WARNING: Changes standard shell behaviour. Off by default.
# set -o noclobber

# ─────────────────────────────────────────────────────────────────
# 4. PROMPT (PS1)
# ─────────────────────────────────────────────────────────────────
#
# The prompt is the text shown before each command.
# The default bash prompt is usually just '\s-\v\$ ' which shows
# the shell name and version.
#
# This section builds a more informative prompt that shows:
#   - username@hostname
#   - current directory (~ for home)
#   - current git branch (if inside a git repository)
#   - exit code of the last command (if non-zero)
#
# Prompt escape sequences:
#   \u   — current username
#   \h   — hostname (short, up to the first dot)
#   \w   — current working directory (~ for home)
#   \$   — $ for regular user, # for root
#
# Colour sequences must be wrapped in \[ and \] so bash does not count
# them as visible characters when calculating line length.
# Without \[ \], the cursor position becomes wrong on long commands.

# Detect whether the terminal supports colour.
if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    _COLOUR_SUPPORTED=true
else
    _COLOUR_SUPPORTED=false
fi

if [ "$_COLOUR_SUPPORTED" = true ]; then
    _C_RESET='\[\e[0m\]'
    _C_GREEN='\[\e[32m\]'
    _C_BLUE='\[\e[34m\]'
    _C_YELLOW='\[\e[33m\]'
    _C_RED='\[\e[31m\]'
    _C_BOLD='\[\e[1m\]'
else
    _C_RESET=''
    _C_GREEN=''
    _C_BLUE=''
    _C_YELLOW=''
    _C_RED=''
    _C_BOLD=''
fi

# Function: show the current git branch in the prompt.
# Returns empty string when not inside a git repository.
# git symbolic-ref: reads the name of the current HEAD reference.
# --short: strips the refs/heads/ prefix, leaving just the branch name.
# 2>/dev/null: suppress error output when not in a git repo.
_prompt_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    printf " (%s)" "$branch"
}

# Function: show exit code of last command if it was non-zero.
# Called inside PS1 so $? must be captured immediately.
# A non-zero exit code means the last command failed.
_prompt_exit_code() {
    local code=$?
    if [ "$code" -ne 0 ]; then
        printf " [%s]" "$code"
    fi
}

# Build the prompt string.
# The prompt is evaluated each time it is displayed (via single quotes
# or by using command substitution inside the string).
#
# Active components:
#   user@host    in green
#   :            separator
#   ~/directory  in blue
#   (branch)     in yellow, shown only inside git repos
#   [code]       in red, shown only when last command failed
#   $            in bold, the actual prompt character
if [ "$_COLOUR_SUPPORTED" = true ]; then
    PS1="${_C_GREEN}\u@\h${_C_RESET}:${_C_BLUE}\w${_C_RESET}"
    PS1="${PS1}${_C_YELLOW}\$(_prompt_git_branch)${_C_RESET}"
    PS1="${PS1}${_C_RED}\$(_prompt_exit_code)${_C_RESET}"
    PS1="${PS1} ${_C_BOLD}\\\$${_C_RESET} "
else
    PS1='\u@\h:\w$(_prompt_git_branch)$(_prompt_exit_code) \$ '
fi

# Secondary prompt — shown when a command spans multiple lines.
# '> ' is the standard default.
PS2='> '

# ─────────────────────────────────────────────────────────────────
# 5. COMPLETION
# ─────────────────────────────────────────────────────────────────

# Load the system-wide bash completion scripts.
# These provide tab completion for git, ssh, make, and many other commands.
# The guard (!shopt -oq posix) prevents loading in POSIX-mode shells
# where the completion system may not work correctly.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # Debian/Ubuntu location
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # Older or alternative location
        source /etc/bash_completion
    fi
fi

# Case-insensitive tab completion.
# 'hello' completes to 'Hello', 'HELLO', etc.
# Safe to uncomment — only affects completion, not command execution.
# bind 'set completion-ignore-case on'

# Show all completions on the first Tab press instead of requiring a second Tab.
# Without this: first Tab completes as far as possible, second Tab shows list.
# With this: first Tab immediately shows the list if ambiguous.
# Uncomment if you prefer immediate feedback.
# bind 'set show-all-if-ambiguous on'

# ─────────────────────────────────────────────────────────────────
# 6. SOURCE .bash_aliases
# ─────────────────────────────────────────────────────────────────

# Load aliases from a separate file.
# Keeping aliases in their own file makes it easier to manage and share them.
# The -f check prevents an error if the file does not exist.
if [ -f "$HOME/.bash_aliases" ]; then
    source "$HOME/.bash_aliases"
fi

# ─────────────────────────────────────────────────────────────────
# 7. FUNCTIONS
# ─────────────────────────────────────────────────────────────────
#
# Functions go here when they are too complex for an alias.
# Each function is commented out — uncomment what you use.
#
# Why functions instead of aliases for complex operations:
#   - Functions can accept arguments ($1, $2, ...)
#   - Functions can use conditionals and loops
#   - Functions can return error codes
#   - Functions are easier to read and debug

# mkcd — create a directory and cd into it in one command.
# Usage: mkcd <dirname>
# Why: 'mkdir newdir && cd newdir' is extremely common. This saves typing
#      and avoids the error of mistyping the name in the cd part.
#
# mkcd() {
#     if [ $# -ne 1 ]; then
#         echo "Usage: mkcd <directory>" >&2
#         return 1
#     fi
#     mkdir -p "$1" && cd "$1" || return 1
# }

# up — go up N directories at once.
# Usage: up [N]
# Example: up 3  →  equivalent to cd ../../..
# Why: cd ../../.. is awkward and error-prone for deep directory trees.
#
# up() {
#     local n="${1:-1}"
#     local path=""
#     local i
#     for (( i = 0; i < n; i++ )); do
#         path="${path}../"
#     done
#     cd "$path" || return 1
# }

# ff — find a file by name (case-insensitive) in the current directory tree.
# Usage: ff <filename>
# Example: ff main.c
# find: searches the directory tree
# -iname: case-insensitive name match  *$1*: matches partial names
# 2>/dev/null: suppress permission errors
#
# ff() {
#     find . -iname "*$1*" 2>/dev/null
# }

# ffd — find a directory by name in the current directory tree.
# Usage: ffd <dirname>
#
# ffd() {
#     find . -type d -iname "*$1*" 2>/dev/null
# }

# backup — create a timestamped copy of a file.
# Usage: backup <file>
# Example: backup config.h  →  config.h.2024-01-15_14:30:00.bak
# Why: Before editing a file, a quick backup prevents data loss.
#      Using a timestamp ensures you never overwrite a previous backup.
#
# backup() {
#     if [ $# -ne 1 ]; then
#         echo "Usage: backup <file>" >&2
#         return 1
#     fi
#     if [ ! -f "$1" ]; then
#         echo "Error: '$1' is not a file." >&2
#         return 1
#     fi
#     local timestamp
#     timestamp="$(date '+%Y-%m-%d_%H:%M:%S')"
#     cp -v "$1" "$1.${timestamp}.bak"
# }

# extract — decompress any common archive format.
# Usage: extract <archive>
# Why: tar, gunzip, unzip, 7z all have different syntax.
#      This function wraps them so you only need to remember one command.
#
# extract() {
#     if [ $# -ne 1 ]; then
#         echo "Usage: extract <archive>" >&2
#         return 1
#     fi
#     if [ ! -f "$1" ]; then
#         echo "Error: '$1' is not a file." >&2
#         return 1
#     fi
#     case "$1" in
#         *.tar.gz|*.tgz)   tar -xzf "$1" ;;
#         *.tar.bz2|*.tbz)  tar -xjf "$1" ;;
#         *.tar.xz)         tar -xJf "$1" ;;
#         *.tar)            tar -xf  "$1" ;;
#         *.gz)             gunzip   "$1" ;;
#         *.bz2)            bunzip2  "$1" ;;
#         *.xz)             unxz     "$1" ;;
#         *.zip)            unzip    "$1" ;;
#         *.7z)             7z x     "$1" ;;
#         *.rar)            unrar x  "$1" ;;
#         *)  echo "Unknown archive format: $1" >&2; return 1 ;;
#     esac
# }

# norm_check — run norminette and show only errors, not OK lines.
# Usage: norm_check [file ...]
# Why: norminette prints OK! for every passing file. When you have many files,
#      the OK lines bury the actual errors you need to fix.
#
# norm_check() {
#     norminette "$@" 2>&1 | grep -v "^OK!"
# }

# portcheck — test whether a TCP port is open on a host.
# Usage: portcheck <host> <port>
# Example: portcheck localhost 8080
# Uses bash's built-in /dev/tcp virtual filesystem — no netcat needed.
# timeout: wait at most 3 seconds before giving up.
#
# portcheck() {
#     if [ $# -ne 2 ]; then
#         echo "Usage: portcheck <host> <port>" >&2
#         return 1
#     fi
#     if timeout 3 bash -c "echo >/dev/tcp/$1/$2" 2>/dev/null; then
#         echo "OPEN: $1:$2"
#     else
#         echo "CLOSED or unreachable: $1:$2"
#         return 1
#     fi
# }

# hex — convert a decimal number to hexadecimal.
# Usage: hex <decimal>
# Example: hex 255  →  0xFF
# printf format 0x%X: uppercase hex with 0x prefix.
#
# hex() {
#     printf "0x%X\n" "$1"
# }

# dec — convert a hexadecimal number to decimal.
# Usage: dec <hex>
# Example: dec FF  →  255  or  dec 0xFF  →  255
#
# dec() {
#     local val="${1#0x}"   # Remove 0x prefix if present
#     val="${val#0X}"       # Remove 0X prefix if present
#     printf "%d\n" "0x${val}"
# }

# manf — show which manual section(s) a command appears in.
# Usage: manf <command>
# Example: manf printf  →  shows printf (1) and printf (3)
# man -f: equivalent to 'whatis', shows a one-line summary per section.
#
# manf() {
#     man -f "$1" 2>/dev/null || whatis "$1" 2>/dev/null || \
#         echo "No manual entry for: $1"
# }

# ─────────────────────────────────────────────────────────────────
# 8. LOCAL OVERRIDES
# ─────────────────────────────────────────────────────────────────

# Source machine-specific configuration that is NOT tracked in git.
# Use this file for:
#   - API keys and tokens (never commit these)
#   - Work-specific paths or aliases
#   - Machine-specific overrides
#
# Create it with: touch ~/.bashrc.local
# It is intentionally not created automatically.
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi