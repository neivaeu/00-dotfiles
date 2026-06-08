# Zsh environment file.
#
# WHEN THIS FILE IS SOURCED:
#   - EVERY time zsh starts: login shells, interactive shells, scripts,
#     and non-interactive shells spawned by editors (vim, VS Code terminal, etc.)
#
# STRICT RULES FOR THIS FILE:
#   1. Never print anything — output here breaks scp, sftp, rsync, and git over SSH.
#   2. Never run interactive commands.
#   3. Never load aliases or functions — they are not needed in scripts.
#   4. Keep it small and fast — it runs on every single shell invocation.
#
# WHAT BELONGS HERE:
#   - EDITOR, VISUAL, PAGER (needed by non-interactive tools)
#   - Core PATH additions that must be available everywhere (scripts, editors)
#   - XDG base directory variables
#   - LANG, LC_ALL
#
# WHAT DOES NOT BELONG HERE:
#   - Aliases → put in .zshrc or aliases.zsh
#   - Functions → put in .zshrc or functions.zsh
#   - Prompt → put in .zshrc
#   - Plugin loading → put in .zshrc
#   - Anything that prints output

# ─────────────────────────────────────────────────────────────────
# XDG BASE DIRECTORY SPECIFICATION
# ─────────────────────────────────────────────────────────────────
#
# The XDG Base Directory Specification defines standard locations for
# application files. Many tools respect these variables. Setting them
# explicitly keeps your HOME directory clean.
#
# XDG_CONFIG_HOME: per-user configuration files (default: ~/.config)
# XDG_DATA_HOME:   per-user data files (default: ~/.local/share)
# XDG_CACHE_HOME:  per-user cache files, safe to delete (default: ~/.cache)
# XDG_STATE_HOME:  per-user state files (logs, history) (default: ~/.local/state)

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"

# ─────────────────────────────────────────────────────────────────
# EDITOR AND PAGER
# ─────────────────────────────────────────────────────────────────

# EDITOR: used by git commit, crontab -e, sudo visudo, and other tools.
# Must be a terminal (non-graphical) editor for correct behaviour in scripts.
export EDITOR="vim"

# VISUAL: used by some programs to open a "visual" (full-screen) editor.
# Usually the same as EDITOR. Some programs fall back to EDITOR if VISUAL fails.
export VISUAL="vim"

# PAGER: used by man, git log, and other commands that produce paginated output.
export PAGER="less"

# LESS options applied globally to all programs that use less as a pager:
#   -F  quit immediately if output fits on one screen (no paging needed)
#   -R  render ANSI colour escape codes (coloured output works correctly)
#   -X  do not clear the screen when less exits (output stays visible)
export LESS="-FRX"

# ─────────────────────────────────────────────────────────────────
# LOCALE
# ─────────────────────────────────────────────────────────────────

# UTF-8 locale ensures correct handling of unicode characters.
# LANG: default locale (affects all LC_* categories not explicitly set)
# LC_ALL: overrides all LC_* variables (set this to enforce UTF-8 everywhere)
# Change en_GB to en_US if you prefer American English conventions.
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# ─────────────────────────────────────────────────────────────────
# CORE PATH
# ─────────────────────────────────────────────────────────────────

# Add ~/.local/bin to PATH so user-installed tools (pip install --user,
# cargo install, etc.) are available in all contexts including scripts.
# The check prevents duplicating the entry if already present.
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi