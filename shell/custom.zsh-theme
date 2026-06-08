# Custom Zsh prompt theme — pure built-ins, no external dependencies.
#
# USAGE:
#   This file is NOT sourced automatically.
#   To use it, add this line to your .zshrc (after the prompt section):
#     source "${HOME}/.config/zsh/themes/custom.zsh-theme"
#
#   If you are already using the vcs_info prompt in .zshrc, you do not
#   need this file — they do the same thing. This file exists as a
#   standalone, more fully commented reference.
#
# WHAT THIS PROMPT SHOWS:
#   - Username and hostname (only when connected via SSH — local is obvious)
#   - Current directory (truncated to 3 levels deep)
#   - Git branch and status (dirty/clean, staged, unstaged)
#   - Active Python virtualenv name
#   - Exit code of last command (right-side prompt, only when non-zero)
#   - Prompt character: › (green) for success, › (red) for failure
#
# REQUIREMENTS:
#   - zsh vcs_info module (built into zsh, no installation needed)
#   - Terminal with basic colour support
#
# COLOUR SYNTAX:
#   %F{colour}...%f  — set/reset foreground colour
#   %B...%b          — bold text
#   %U...%u          — underline text
#   Colours: black red green yellow blue magenta cyan white
#   Numbers: 0-255 for 256-colour terminals
#
# PROMPT ESCAPE SEQUENCES:
#   %n    — username
#   %m    — hostname (short, up to first dot)
#   %~    — current directory (~ for home, truncated by PROMPT_SUBST rules)
#   %3~   — current directory truncated to 3 components
#   %#    — $ for regular user, # for root
#   %?    — exit code of last command
#   %(X.true.false) — conditional based on X

# ─────────────────────────────────────────────────────────────────
# VCS INFO SETUP
# ─────────────────────────────────────────────────────────────────

# Load the vcs_info module (built into zsh).
autoload -Uz vcs_info

# Enable only git — checking svn, hg, etc. slows down the prompt.
zstyle ':vcs_info:*' enable git

# Format for the git information when no action is in progress.
# %b: current branch name
# ' on %F{magenta}%b%f': shows ' on main' with branch in magenta
zstyle ':vcs_info:git:*' formats ' on %F{magenta}%b%f%c%u'

# Format when an action is in progress (merge, rebase, cherry-pick, bisect).
# %a: action name
zstyle ':vcs_info:git:*' actionformats ' on %F{magenta}%b%f %F{red}(%a)%f'

# Enable checking for staged and unstaged changes.
# This makes the prompt check the working tree state each time.
# NOTE: In very large repositories, this can slow down the prompt.
#       Comment out these two lines if the prompt feels sluggish.
zstyle ':vcs_info:git:*' check-for-changes true

# Marker shown in the prompt when there are STAGED changes (git add has been run).
# %c: staged marker  (displayed by the %c in the formats string)
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'

# Marker shown in the prompt when there are UNSTAGED changes.
# %u: unstaged marker
zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}●%f'

# Run vcs_info before each prompt draw so git info stays current.
# precmd_functions: list of functions called before every prompt.
precmd_functions+=(vcs_info)

# Allow variable substitution in the PROMPT string.
# Required for ${vcs_info_msg_0_} to expand correctly.
setopt PROMPT_SUBST

# ─────────────────────────────────────────────────────────────────
# PYTHON VIRTUALENV
# ─────────────────────────────────────────────────────────────────

# Tell the virtualenv system not to modify the prompt itself.
# We handle the virtualenv display below.
VIRTUAL_ENV_DISABLE_PROMPT=1

# Function: return the virtualenv name if one is active.
# VIRTUAL_ENV: set by 'source venv/bin/activate' to the venv path.
# basename: extracts just the directory name from the full path.
# Returns empty string if no virtualenv is active.
_theme_venv() {
    if [[ -n "${VIRTUAL_ENV}" ]]; then
        echo " %F{cyan}($(basename "${VIRTUAL_ENV}"))%f"
    fi
}

# ─────────────────────────────────────────────────────────────────
# SSH INDICATOR
# ─────────────────────────────────────────────────────────────────

# Function: show user@host only when connected via SSH.
# SSH_CONNECTION: set by SSH to the client IP, server IP, and ports.
# When working locally, user@host wastes prompt space since it is obvious.
# When connected via SSH, it is essential to know which machine you are on.
_theme_ssh() {
    if [[ -n "${SSH_CONNECTION}" ]]; then
        echo "%F{yellow}%n%f%F{white}@%f%F{green}%m%f "
    fi
}

# ─────────────────────────────────────────────────────────────────
# PROMPT DEFINITION
# ─────────────────────────────────────────────────────────────────

# RPROMPT: right-side prompt — shows exit code when last command failed.
# %(?...) — conditional: if exit code is 0 (success), show nothing.
#            if exit code is non-zero, show [code] in red.
# %(?..<content>): %(?.true_if_zero.false_if_nonzero)
# %?: expands to the exit code of the last command.
RPROMPT='%(?.. %F{red}[%?]%f)'

# PROMPT: main left-side prompt (two lines).
#
# Line 1 components (left to right):
#   $(_theme_ssh)           — user@host if SSH, empty if local
#   $(_theme_venv)          — (venvname) if virtualenv active, empty otherwise
#   %F{blue}%3~%f           — current directory, max 3 levels, ~ for home
#   ${vcs_info_msg_0_}      — git branch, staged/unstaged markers from vcs_info
#
# Line 2:
#   %(?. . )%F{...}›%f  — prompt character colour based on exit code
#     %(?.<true>.<false>): if exit code 0 use green, otherwise use red
PROMPT='$(_theme_ssh)$(_theme_venv)%F{blue}%3~%f${vcs_info_msg_0_}
%(?. %F{green}›%f. %F{red}›%f) '

# ─────────────────────────────────────────────────────────────────
# ALTERNATIVE PROMPT STYLES (COMMENTED OUT)
# ─────────────────────────────────────────────────────────────────
# Uncomment ONE of these blocks and comment out the PROMPT above to try it.

# ── Minimal single-line prompt ───────────────────────────────────
# Shows only the directory and prompt character. Very clean.
# Loses git info and SSH indicator.
# PROMPT='%F{blue}%3~%f %(?.%F{green}.%F{red})›%f '

# ── Classic user@host:dir$ format ────────────────────────────────
# Traditional Unix prompt style with git branch added.
# PROMPT='%F{green}%n@%m%f:%F{blue}%~%f${vcs_info_msg_0_} %# '

# ── Two-line with time ────────────────────────────────────────────
# Adds current time to the right of the directory.
# Useful if you want a timestamp on every command.
# PROMPT='%F{blue}%3~%f${vcs_info_msg_0_} %F{240}[%D{%H:%M:%S}]%f
# %(?. %F{green}›%f. %F{red}›%f) '