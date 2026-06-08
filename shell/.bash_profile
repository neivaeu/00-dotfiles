# Bash login shell configuration.
#
# WHEN THIS FILE IS SOURCED:
#   - When you log in via SSH
#   - When you log in at a TTY (text console)
#   - When you open a terminal that is configured to start a login shell
#   - When you run: bash --login
#
# WHEN IT IS NOT SOURCED:
#   - When you open a normal terminal window (that sources .bashrc directly)
#   - When bash runs a script
#
# THE MOST IMPORTANT RULE:
#   Always source .bashrc from .bash_profile.
#   Many systems only read .bash_profile for login shells and skip .bashrc.
#   Without sourcing .bashrc here, your aliases and functions would be missing
#   when you log in via SSH.
#
# WHAT BELONGS IN .bash_profile vs .bashrc:
#   .bash_profile — things that should run once per LOGIN (PATH, environment vars)
#   .bashrc       — things that should run for every INTERACTIVE shell
#
# SECTIONS:
#   1. Source .bashrc
#   2. PATH
#   3. Environment variables
#   4. Development tool paths (commented — uncomment for tools you use)

# ─────────────────────────────────────────────────────────────────
# 1. SOURCE .bashrc
# ─────────────────────────────────────────────────────────────────

# Source .bashrc so that login shells (SSH, TTY) get the same
# configuration as interactive shells (terminal emulator).
# The -f check prevents an error if .bashrc does not exist.
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# ─────────────────────────────────────────────────────────────────
# 2. PATH
# ─────────────────────────────────────────────────────────────────

# Helper: add a directory to the front of PATH only if:
#   - The directory exists
#   - It is not already in PATH
# Using a function prevents PATH from growing indefinitely when
# .bash_profile is sourced multiple times (e.g. re-login without logout).
_add_to_path() {
    if [ -d "$1" ] && [ "${PATH#*"$1"}" = "$PATH" ]; then
        export PATH="$1:$PATH"
    fi
}

# Local user binaries — installed by pip install --user, npm install -g, etc.
# This directory is the standard location for user-installed executables.
_add_to_path "$HOME/.local/bin"

# Personal scripts directory — for your own scripts.
# Create it with: mkdir -p ~/bin
# _add_to_path "$HOME/bin"

# Dotfiles scripts — if your dotfiles include utility scripts.
# _add_to_path "$HOME/dotfiles/scripts"

# ─────────────────────────────────────────────────────────────────
# 3. ENVIRONMENT VARIABLES
# ─────────────────────────────────────────────────────────────────

# Default text editor.
# Used by: git commit, crontab -e, sudo visudo, and any program that
# needs to open an editor. Must be a terminal-based editor.
export EDITOR='vim'
export VISUAL='vim'

# Default pager — used by man, git log, and other paginated output.
export PAGER='less'

# less options:
#   -F  quit if output fits on one screen (no paging needed for short output)
#   -R  render ANSI colour escape codes (needed for coloured man pages)
#   -X  do not clear the screen when less exits (output remains visible)
#   -i  case-insensitive search within less
#   -M  show detailed prompt with line numbers and percentage
export LESS='-FRX -i -M'

# Locale — use UTF-8 encoding.
# Affects sort order, character classification, and terminal display.
# en_GB.UTF-8: British English with UTF-8. Change to en_US.UTF-8 if preferred.
export LANG='en_GB.UTF-8'
export LC_ALL='en_GB.UTF-8'

# History file location and size.
# These are also set in .bashrc for interactive shells.
# Setting them here ensures login shells have them too.
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000

# Man page section priority.
# Default order prioritises system calls (2) and library functions (3),
# which is more useful for C development than the default order.
# Section meanings: 1=commands 2=syscalls 3=C library 5=file formats 8=admin
export MANSECT='2:3:1:8:5:4:7:6:9'

# Coloured man pages.
# These LESS_TERMCAP variables tell less what terminal sequences to use
# for bold, underline, and standout text in man pages.
# The colours here use ANSI escape codes:
#   \e[1;32m = bold green   \e[1;4;31m = bold underline red
#   \e[0m    = reset        \e[01;33m  = bold yellow
export LESS_TERMCAP_mb=$'\e[1;32m'     # Begin blinking (not often seen)
export LESS_TERMCAP_md=$'\e[1;32m'     # Begin bold (used for section headers)
export LESS_TERMCAP_me=$'\e[0m'        # End bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # End standout (search highlight)
export LESS_TERMCAP_so=$'\e[01;33m'    # Begin standout (search highlight colour)
export LESS_TERMCAP_ue=$'\e[0m'        # End underline
export LESS_TERMCAP_us=$'\e[1;4;31m'   # Begin underline (used for arguments)

# ─────────────────────────────────────────────────────────────────
# 4. DEVELOPMENT TOOL PATHS
# ─────────────────────────────────────────────────────────────────
# These are commented out. Uncomment only for tools you have installed.

# Python pyenv — manage multiple Python versions.
# pyenv init --path adds the shims directory to PATH.
# Only uncomment if pyenv is installed in ~/.pyenv.
#
# if [ -d "$HOME/.pyenv" ]; then
#     export PYENV_ROOT="$HOME/.pyenv"
#     _add_to_path "$PYENV_ROOT/bin"
#     eval "$(pyenv init --path)"
# fi

# Rust cargo — package manager and build tool for Rust.
# cargo install puts binaries in ~/.cargo/bin.
# Only uncomment if Rust is installed.
#
# _add_to_path "$HOME/.cargo/bin"

# Node Version Manager (nvm) — manage multiple Node.js versions.
# --no-use: do not automatically switch to a Node version on startup.
#           This makes shell startup faster. Use 'nvm use' manually.
# Only uncomment if nvm is installed.
#
# if [ -d "$HOME/.nvm" ]; then
#     export NVM_DIR="$HOME/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" --no-use
# fi

# Go — official Go distribution.
# GOPATH is where go install puts binaries.
# Only uncomment if Go is installed.
#
# if [ -d "/usr/local/go" ]; then
#     _add_to_path "/usr/local/go/bin"
#     export GOPATH="$HOME/go"
#     _add_to_path "$GOPATH/bin"
# fi