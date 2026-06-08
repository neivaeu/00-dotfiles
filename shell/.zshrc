# Main Zsh configuration — sourced for every interactive Zsh session.
#
# WHEN THIS FILE IS SOURCED:
#   - Every time you open a terminal window or tab
#   - When you run 'zsh' interactively
#   - NOT when running zsh scripts (scripts are non-interactive)
#   - NOT for non-interactive shells
#
# DESIGN PRINCIPLE:
#   Keep active configuration minimal. Every option is commented with:
#     - What it does
#     - Why it is on or off by default
#   Uncomment only what you understand and actively want.
#
# SECTIONS:
#   1. History
#   2. Zsh options
#   3. Completion system
#   4. Key bindings
#   5. Prompt
#   6. Source external files
#   7. Tool integrations (commented — uncomment for installed tools)
#   8. Local overrides

# ─────────────────────────────────────────────────────────────────
# 1. HISTORY
# ─────────────────────────────────────────────────────────────────

# File where history is persisted between sessions.
HISTFILE="${HOME}/.zsh_history"

# Number of history entries to keep in memory during the session.
HISTSIZE=10000

# Number of history entries to save to HISTFILE when the shell exits.
SAVEHIST=10000

# Write the timestamp and duration of each command to history.
# Format: ': 1704067200:5;git status' (colon, timestamp, duration, semicolon, command)
# ACTIVE: Timestamps in history are invaluable for debugging and auditing.
setopt EXTENDED_HISTORY

# Do not save consecutive duplicate commands.
# Example: running 'ls' 10 times in a row only saves it once.
# ACTIVE: Reduces noise in history without losing useful entries.
setopt HIST_IGNORE_DUPS

# Do not save commands that start with a space.
# Use a leading space for commands you intentionally want excluded from history,
# such as commands containing passwords or API keys.
# ACTIVE: Essential for security — keeps sensitive commands out of history.
setopt HIST_IGNORE_SPACE

# Share history between all running zsh sessions.
# New commands in one terminal are immediately available in others.
# ACTIVE: Prevents the frustration of not finding a command you just ran
#         in a different terminal window.
setopt SHARE_HISTORY

# Append to the history file incrementally as commands are run,
# not only when the shell exits.
# Combined with SHARE_HISTORY, this ensures no history is lost on crash.
# ACTIVE: Prevents history loss when terminals crash.
setopt INC_APPEND_HISTORY

# When searching history, do not show duplicate entries.
# Even if duplicates exist in the file, searching shows each command once.
# ACTIVE: Cleaner history search results.
setopt HIST_FIND_NO_DUPS

# Show the expanded command before executing it when using history expansion.
# Example: typing '!git' shows the expanded command and waits for Enter.
# Without this: the command runs immediately which can be dangerous.
# ACTIVE: Prevents accidental execution of the wrong command.
setopt HIST_VERIFY

# ─────────────────────────────────────────────────────────────────
# 2. ZSH OPTIONS
# ─────────────────────────────────────────────────────────────────

# NAVIGATION
# ─────────

# Type a directory name to cd into it without typing 'cd'.
# Example: typing 'Downloads' is equivalent to 'cd Downloads'.
# WARNING: Can cause confusion when a directory has the same name as a
#          concept you might expect to be a command. Off by default.
# setopt AUTO_CD

# Make cd push the previous directory onto the directory stack.
# Use 'dirs' to see the stack, 'popd' to return to the previous directory.
# Useful for navigating between multiple work directories.
# setopt AUTO_PUSHD

# Do not push duplicate directories onto the stack (works with AUTO_PUSHD).
# setopt PUSHD_IGNORE_DUPS

# Do not print the directory stack after pushd/popd (less noise).
# setopt PUSHD_SILENT

# Allow 'cd varname' when varname is a shell variable containing a directory path.
# setopt CDABLE_VARS


# GLOBBING
# ────────

# Enable extended glob operators: #, ^, ~
# Example: ls ^*.o  lists everything except .o files
#          ls *~*.bak  lists files without .bak extension
# Powerful but rarely needed. Uncomment if you use these patterns.
# setopt EXTENDED_GLOB

# Include dotfiles (hidden files) when matching glob patterns.
# Without this: '*' does not match '.bashrc', '.gitignore', etc.
# With this: '*' matches all files including hidden ones.
# WARNING: Can produce unexpected results. Off by default.
# setopt GLOB_DOTS

# Case-insensitive globbing.
# Example: ls *.C matches both .c and .C files.
# Uncomment if your work involves mixed-case filenames.
# setopt NO_CASE_GLOB

# Do not raise an error when a glob pattern matches nothing.
# Without this: 'ls *.xyz' when no .xyz files exist gives an error.
# With this: returns an empty list silently.
# setopt NULL_GLOB


# JOB CONTROL
# ───────────

# Print job number and PID when a job is suspended (Ctrl+Z).
# More informative than the default output.
# setopt LONG_LIST_JOBS

# Report status of background jobs immediately when they finish,
# rather than waiting for the next prompt.
# setopt NOTIFY


# MISCELLANEOUS
# ─────────────

# Allow # comments in interactive shell.
# Without this, typing a comment in the terminal gives an error.
# ACTIVE: Comments in interactive shells are useful for documentation.
setopt INTERACTIVE_COMMENTS

# Disable the terminal bell (beep) completely.
# The bell fires on failed completion, reaching history boundaries, etc.
# ACTIVE: The bell is almost universally annoying in a development environment.
setopt NO_BEEP

# Disable Ctrl+S / Ctrl+Q flow control.
# By default, Ctrl+S freezes the terminal output and Ctrl+Q unfreezes it.
# This is a legacy feature from serial terminals. Disabling it frees
# Ctrl+S for other uses (e.g. saving in vim, forward history search).
# ACTIVE: Flow control is not useful in modern terminal emulators.
setopt NO_FLOW_CONTROL

# ─────────────────────────────────────────────────────────────────
# 3. COMPLETION SYSTEM
# ─────────────────────────────────────────────────────────────────

# Load the completion system.
# autoload -Uz: load the function lazily, using the Zsh function search path.
# compinit: initialise the completion system, loading completion definitions.
autoload -Uz compinit

# Regenerate the completion dump file at most once per day.
# The dump file caches completion definitions for faster startup.
# -C flag: skip security check on the dump file (safe if you own the file).
# Without this check, compinit regenerates the dump on every shell start (slow).
#
# How this works:
#   ${HOME}/.zcompdump(#qN.mh+24):
#     #q = start glob qualifier
#     N  = nullglob (empty if no match, no error)
#     .  = regular file (not directory)
#     mh+24 = modified more than 24 hours ago
#   If the file is older than 24h, run full compinit; otherwise use the cache.
if [[ -n "${HOME}/.zcompdump"(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Complete from both ends of a partially typed word.
# Example: if you type 'do_thing' with cursor in the middle, completion
# considers both what is before and after the cursor.
# setopt COMPLETE_IN_WORD

# Move cursor to the end of the word after completion.
# Without this: cursor stays where it was when you triggered completion.
# ACTIVE: Cursor position after completion is almost always at the end.
setopt ALWAYS_TO_END

# Show a completion menu when there are multiple matches.
# First Tab: complete common prefix. Second Tab: open interactive menu.
# ACTIVE: The menu makes selecting from multiple options much easier.
setopt AUTO_MENU

# List completions on the first ambiguous Tab press (no need for a second Tab).
# ACTIVE: Immediate feedback is more useful than waiting for a second Tab.
setopt AUTO_LIST

# Add a trailing slash when completing directory names.
# Prevents having to manually type the slash before entering the directory.
# ACTIVE: No downside; the slash is removed automatically if you press Space.
setopt AUTO_PARAM_SLASH

# Completion styling — controls how the completion list looks.

# Use an interactive menu for selecting completions (highlight selection).
zstyle ':completion:*' menu select

# Colour completion entries using the same colours as ls --color.
# LS_COLORS is set by the system or dircolors. If empty, this has no effect.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Case-insensitive matching: 'abc' matches 'ABC', 'Abc', etc.
# The pattern 'm:{a-zA-Z}={A-Za-z}' maps lowercase to uppercase and vice versa.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Group completions by type (files, directories, commands, etc.).
# '' means use the group name as-is.
zstyle ':completion:*' group-name ''

# Format string for group headers in the completion list.
# %F{yellow}...%f: yellow text  -- %d --: group name surrounded by dashes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Warning shown when no completions match.
zstyle ':completion:*:warnings' format '%F{red}No matches: %d%f'

# Automatically detect newly installed commands (rehash the command hash).
# Without this: newly installed programs are not available for completion
# until you start a new shell.
# ACTIVE: Prevents the confusing situation where a just-installed tool
#         does not appear in completion until you restart the shell.
zstyle ':completion:*' rehash true

# ─────────────────────────────────────────────────────────────────
# 4. KEY BINDINGS
# ─────────────────────────────────────────────────────────────────

# Use Emacs-style key bindings.
# Emacs mode: Ctrl+A = start of line, Ctrl+E = end of line,
#             Ctrl+K = cut to end, Ctrl+U = cut to start, Ctrl+W = cut word.
# Alternative: bindkey -v  (vi modal editing — normal/insert mode)
bindkey -e

# History search with Up/Down arrows — search by prefix.
# Type the start of a command, then press Up to find matching past commands.
# Without this: Up/Down cycle through all history unconditionally.
# ACTIVE: This is significantly more useful than unconditional history cycling.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up arrow
bindkey "^[[B" down-line-or-beginning-search # Down arrow

# Ctrl+Left — move backward one word.
# \e[1;5D is the escape sequence most terminals send for Ctrl+Left.
bindkey "^[[1;5D" backward-word

# Ctrl+Right — move forward one word.
# \e[1;5C is the escape sequence most terminals send for Ctrl+Right.
bindkey "^[[1;5C" forward-word

# Home key — move to the beginning of the line.
bindkey "^[[H" beginning-of-line

# End key — move to the end of the line.
bindkey "^[[F" end-of-line

# Delete key — delete the character under the cursor.
# \e[3~ is the standard escape sequence for the Delete key.
bindkey "^[[3~" delete-char

# Ctrl+U — delete from the cursor to the beginning of the line.
# This is the bash default. Zsh default is to delete the whole line.
# Uncomment to use the bash-compatible behaviour.
# bindkey "^U" backward-kill-line

# ─────────────────────────────────────────────────────────────────
# 5. PROMPT
# ─────────────────────────────────────────────────────────────────
#
# The prompt shows context about where you are and what is happening.
# This is a minimal prompt using only zsh built-ins (vcs_info).
#
# vcs_info: built-in zsh module for showing version control information.
# It supports git, svn, hg, and others. We enable only git for performance.
#
# PROMPT_SUBST: allows variables and command substitutions in the prompt.
# Without this, ${vcs_info_msg_0_} would appear literally in the prompt.

# Load the vcs_info module (built into zsh, no installation needed).
autoload -Uz vcs_info

# Run vcs_info before every prompt draw so the branch name stays current.
# precmd_functions: list of functions called before each prompt.
precmd_functions+=(vcs_info)

# Allow variable and command substitution in the PROMPT string.
setopt PROMPT_SUBST

# Enable vcs_info only for git (checking all VCS types is slower).
zstyle ':vcs_info:*' enable git

# Format string for the git information shown in the prompt.
# %b: current branch name
# %F{colour}...%f: set/reset foreground colour
# ' on %F{magenta}%b%f': shows ' on main' in magenta
zstyle ':vcs_info:git:*' formats ' on %F{magenta}%b%f'

# Format when an action is in progress (merge, rebase, cherry-pick, etc.).
# %a: current action name (merge, rebase, etc.)
zstyle ':vcs_info:git:*' actionformats ' on %F{magenta}%b%f %F{red}(%a)%f'

# Build the prompt string.
# %F{colour}...%f: coloured text
# %~: current directory with ~ for home (truncated automatically by zsh)
# ${vcs_info_msg_0_}: git branch info from vcs_info
# %n: username  %m: hostname (short)
# %#: $ for regular user, # for root
#
# Layout:
#   Line 1: username@hostname  ~/current/dir  on branch
#   Line 2: › (prompt character)
#
# The two-line format keeps the actual typing area clean regardless of
# how long the path and branch name are.
PROMPT='%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}
%F{green}›%f '

# Right-side prompt: show exit code of the last command (only if non-zero).
# %(?::...) is a conditional: empty if exit code is 0, shows code if non-zero.
# %(?..) syntax: %(?.<true>.<false>)
RPROMPT='%(?..%F{red}[%?]%f)'

# Suppress the default virtualenv prompt modification.
# Virtualenv adds (envname) to the prompt by modifying PS1.
# Uncomment to handle this yourself in the prompt above.
# VIRTUAL_ENV_DISABLE_PROMPT=1

# ─────────────────────────────────────────────────────────────────
# 6. SOURCE EXTERNAL FILES
# ─────────────────────────────────────────────────────────────────

# Load aliases from a separate file.
# The [[ -f ]] check prevents an error if the file does not exist.
[[ -f "${HOME}/.config/zsh/aliases.zsh" ]] && source "${HOME}/.config/zsh/aliases.zsh"

# Load functions from a separate file.
[[ -f "${HOME}/.config/zsh/functions.zsh" ]] && source "${HOME}/.config/zsh/functions.zsh"

# ─────────────────────────────────────────────────────────────────
# 7. TOOL INTEGRATIONS
# ─────────────────────────────────────────────────────────────────
# All of these require external tools to be installed.
# They are commented out. Uncomment only for tools you have installed.

# fzf — command-line fuzzy finder.
# Ctrl+T: paste selected files into command line
# Ctrl+R: search history with fzf (replaces default Ctrl+R history search)
# Alt+C:  cd into selected directory
# Uncomment if fzf is installed.
#
# if [[ -f "/usr/share/doc/fzf/examples/key-bindings.zsh" ]]; then
#     source "/usr/share/doc/fzf/examples/key-bindings.zsh"
# elif [[ -f "${HOME}/.fzf/shell/key-bindings.zsh" ]]; then
#     source "${HOME}/.fzf/shell/key-bindings.zsh"
# fi
#
# if [[ -f "/usr/share/doc/fzf/examples/completion.zsh" ]]; then
#     source "/usr/share/doc/fzf/examples/completion.zsh"
# elif [[ -f "${HOME}/.fzf/shell/completion.zsh" ]]; then
#     source "${HOME}/.fzf/shell/completion.zsh"
# fi

# zsh-syntax-highlighting — highlights commands as you type.
# Valid commands turn green; invalid commands turn red.
# Must be sourced LAST among all plugins to work correctly.
# Uncomment if installed (via package manager or manually).
#
# ZSH_SYNTAX_HL="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# ZSH_SYNTAX_HL_LOCAL="${HOME}/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# if [[ -f "${ZSH_SYNTAX_HL}" ]]; then
#     source "${ZSH_SYNTAX_HL}"
# elif [[ -f "${ZSH_SYNTAX_HL_LOCAL}" ]]; then
#     source "${ZSH_SYNTAX_HL_LOCAL}"
# fi

# zsh-autosuggestions — shows command suggestions in grey as you type.
# Accept the suggestion with → (right arrow) or Ctrl+F.
# Strategy: try history first, then completion.
# Uncomment if installed.
#
# ZSH_AUTOSUGGEST="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# ZSH_AUTOSUGGEST_LOCAL="${HOME}/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# if [[ -f "${ZSH_AUTOSUGGEST}" ]]; then
#     source "${ZSH_AUTOSUGGEST}"
# elif [[ -f "${ZSH_AUTOSUGGEST_LOCAL}" ]]; then
#     source "${ZSH_AUTOSUGGEST_LOCAL}"
# fi
# ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# pyenv — Python version manager.
# Uncomment if pyenv is installed in ~/.pyenv.
#
# if [[ -d "${HOME}/.pyenv" ]]; then
#     export PYENV_ROOT="${HOME}/.pyenv"
#     export PATH="${PYENV_ROOT}/bin:${PATH}"
#     eval "$(pyenv init -)"
# fi

# nvm — Node.js version manager.
# --no-use: skip auto-selecting a Node version (faster startup).
# Use 'nvm use' manually when working on Node projects.
# Uncomment if nvm is installed.
#
# if [[ -d "${HOME}/.nvm" ]]; then
#     export NVM_DIR="${HOME}/.nvm"
#     [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh" --no-use
# fi

# Starship — cross-shell prompt.
# Replaces the prompt defined in section 5.
# If you use Starship, comment out the entire PROMPT section above
# and uncomment this block.
# Starship config: ~/.config/starship.toml
# Uncomment if starship is installed.
#
# if command -v starship &>/dev/null; then
#     eval "$(starship init zsh)"
# fi

# ─────────────────────────────────────────────────────────────────
# 8. LOCAL OVERRIDES
# ─────────────────────────────────────────────────────────────────

# Source machine-specific configuration that is NOT tracked in git.
# Use this file for:
#   - Work-specific aliases or paths
#   - API keys and tokens (never commit these to git)
#   - Machine-specific tool paths
#   - Anything that should not be shared across machines
#
# Create it with: touch ~/.zshrc.local
if [[ -f "${HOME}/.zshrc.local" ]]; then
    source "${HOME}/.zshrc.local"
fi