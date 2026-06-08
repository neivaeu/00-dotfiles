# editors/vscode/extensions.txt
#
# Recommended VS Code extensions for this environment.
#
# THIS FILE IS A REFERENCE — nothing is installed automatically.
# Install what you need, not everything listed here.
#
# Install all uncommented extensions at once:
#   grep -v '^#' editors/vscode/extensions.txt | \
#   grep -v '^$' | \
#   xargs -L1 code --install-extension
#
# Install a single extension:
#   code --install-extension publisher.extension-name
#
# List currently installed extensions:
#   code --list-extensions
#
# ─────────────────────────────────────────────────────────────────
# ESSENTIAL — these are always worth installing
# ─────────────────────────────────────────────────────────────────

# EditorConfig: reads .editorconfig and applies settings automatically.
# Works with system/.editorconfig in this repository.
# No configuration needed after installation.
EditorConfig.EditorConfig

# ShellCheck: real-time linting for shell scripts.
# Highlights errors and bad practices as you type.
# Requires shellcheck installed: sudo apt install shellcheck
timonwong.shellcheck

# Error Lens: shows errors and warnings inline next to the code.
# Much faster to read than checking the Problems panel.
usernamehw.errorlens

# ─────────────────────────────────────────────────────────────────
# C / C++ DEVELOPMENT
# ─────────────────────────────────────────────────────────────────

# clangd: C/C++ IntelliSense via the clangd language server.
# Provides: completion, go-to-definition, hover docs, diagnostics.
# Faster and more accurate than the default C/C++ extension.
# Requires clangd installed: sudo apt install clangd
# Requires compile_commands.json or .clangd config for best results.
llvm-vs-code-extensions.vscode-clangd

# Makefile Tools: syntax highlighting and IntelliSense for Makefiles.
ms-vscode.makefile-tools

# ─────────────────────────────────────────────────────────────────
# GIT
# ─────────────────────────────────────────────────────────────────

# GitLens: enhanced git integration.
# Most useful feature: inline blame (who changed this line and when).
# Also provides: history, comparisons, and detailed commit info.
eamodio.gitlens

# Git Graph: visual branch graph in a dedicated panel.
# Useful for understanding repository history at a glance.
mhutchie.git-graph

# ─────────────────────────────────────────────────────────────────
# MARKDOWN
# ─────────────────────────────────────────────────────────────────

# markdownlint: style linting for Markdown files.
# Catches: missing blank lines, inconsistent heading levels, etc.
DavidAnson.vscode-markdownlint

# ─────────────────────────────────────────────────────────────────
# OPTIONAL — install only if you actively use these
# ─────────────────────────────────────────────────────────────────

# Python: core Python support (interpreter selection, debugging).
# Install if you write Python code in VS Code.
# ms-python.python

# Pylance: fast Python type checking and completion.
# Requires ms-python.python.
# ms-python.vscode-pylance

# Code Spell Checker: spell checking that understands camelCase.
# Highlights typos in identifiers, comments, and strings.
# streetsidesoftware.code-spell-checker

# Markdown All in One: keyboard shortcuts and table of contents.
# Install if you frequently write documentation in Markdown.
# yzhang.markdown-all-in-one

# Remote SSH: edit files on a remote machine via SSH.
# Useful when working on school machines from your laptop.
# ms-vscode-remote.remote-ssh

# ─────────────────────────────────────────────────────────────────
# NOT RECOMMENDED
# ─────────────────────────────────────────────────────────────────
#
# Avoid:
#   - AI code completion tools (Copilot, Tabnine) when learning —
#     they write the code for you instead of you learning to write it
#   - Multiple competing linters for the same language
#   - Themes and icon packs beyond what you actively use
#   - Extensions installed once to try and never removed
#
# Every extension consumes memory and CPU in the extension host process.
# Fewer extensions = faster VS Code.
#
# Audit extensions occasionally:
#   code --list-extensions | wc -l