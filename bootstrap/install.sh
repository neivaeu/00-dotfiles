#!/usr/bin/env bash
# Dotfiles installation script.
# Creates symbolic links from this repository to the correct locations
# in your home directory.
#
# USAGE:
#   ./bootstrap/install.sh              # Normal install
#   ./bootstrap/install.sh --dry-run   # Preview without making changes
#   ./bootstrap/install.sh --force     # Overwrite existing files (backup first)
#   ./bootstrap/install.sh --help      # Show this help
#
# WHAT IT DOES:
#   1. Reads bootstrap/symlinks.conf
#   2. For each source → destination pair, creates a symbolic link
#   3. Creates parent directories if they do not exist
#   4. Backs up existing files before overwriting (with --force)
#
# WHAT IT DOES NOT DO:
#   - Install any packages
#   - Require sudo or root access
#   - Modify your shell or change defaults
#   - Download anything from the internet
#
# SAFE TO RE-RUN:
#   Running this script multiple times is safe.
#   Already-correct symlinks are skipped without touching them.
#
# REQUIREMENTS:
#   - Bash 4.0+ (standard on any modern Linux)
#   - Standard POSIX tools: ln, mkdir, mv, dirname, readlink
#     All are part of coreutils — always present on Linux.
#
# EXIT CODES:
#   0 — success (all symlinks created or already correct)
#   1 — one or more errors occurred (source not found, etc.)

# ─────────────────────────────────────────────────────────────────
# STRICT MODE
# ─────────────────────────────────────────────────────────────────

# -e: exit immediately if any command fails
# -u: treat unset variables as an error
# -o pipefail: a pipeline fails if any command in it fails
#              (without this, 'false | true' succeeds)
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# PATHS
# ─────────────────────────────────────────────────────────────────

# Absolute path to the repository root.
# BASH_SOURCE[0]: path to this script file.
# dirname: strip the filename, keep the directory.
# cd ..: go up one level from bootstrap/ to the repo root.
# pwd: print the resolved absolute path.
# This works correctly regardless of where the script is called from.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Symlinks configuration file.
SYMLINKS_CONF="${DOTFILES_DIR}/bootstrap/symlinks.conf"

# ─────────────────────────────────────────────────────────────────
# FLAGS
# ─────────────────────────────────────────────────────────────────

# Whether to run in dry-run mode (print actions without executing them).
DRY_RUN=false

# Whether to overwrite existing files (backup made first).
FORCE=false

# ─────────────────────────────────────────────────────────────────
# COUNTERS
# ─────────────────────────────────────────────────────────────────

# Track results for the summary at the end.
COUNT_LINKED=0
COUNT_SKIPPED=0
COUNT_BACKED=0
COUNT_ERRORS=0

# ─────────────────────────────────────────────────────────────────
# COLOUR OUTPUT
# ─────────────────────────────────────────────────────────────────

# Only use colours if:
#   - stdout is a terminal (not a pipe or file)
#   - tput is available (provides colour codes)
#   - the terminal supports colours
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
    C_RED="$(tput setaf 1)"
    C_GREEN="$(tput setaf 2)"
    C_YELLOW="$(tput setaf 3)"
    C_CYAN="$(tput setaf 6)"
    C_BOLD="$(tput bold)"
    C_RESET="$(tput sgr0)"
else
    # No colour support — use empty strings so printf calls still work.
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_CYAN=""
    C_BOLD=""
    C_RESET=""
fi

# ─────────────────────────────────────────────────────────────────
# LOGGING FUNCTIONS
# ─────────────────────────────────────────────────────────────────

# Each log function prints a labelled, coloured line.
# >&2 for errors sends them to stderr (not stdout) so they can be
# redirected or filtered independently.

log_info()  { printf "%s[info]%s  %s\n"  "${C_CYAN}"   "${C_RESET}" "$*"; }
log_ok()    { printf "%s[ok]%s    %s\n"  "${C_GREEN}"  "${C_RESET}" "$*"; }
log_warn()  { printf "%s[warn]%s  %s\n"  "${C_YELLOW}" "${C_RESET}" "$*"; }
log_error() { printf "%s[error]%s %s\n"  "${C_RED}"    "${C_RESET}" "$*" >&2; }
log_skip()  { printf "%s[skip]%s  %s\n"  "${C_YELLOW}" "${C_RESET}" "$*"; }
log_dry()   { printf "%s[dry]%s   %s\n"  "${C_CYAN}"   "${C_RESET}" "$*"; }

# Print a section header to visually separate output.
log_section() {
    printf "\n%s── %s %s\n" "${C_BOLD}" "$*" "${C_RESET}"
}

# ─────────────────────────────────────────────────────────────────
# ARGUMENT PARSING
# ─────────────────────────────────────────────────────────────────

parse_args() {
    # Loop over every argument passed to the script.
    for arg in "$@"; do
        case "$arg" in
            --dry-run | -n)
                DRY_RUN=true
                log_info "Dry-run mode — no changes will be made"
                ;;
            --force | -f)
                FORCE=true
                log_warn "Force mode — existing files will be backed up and replaced"
                ;;
            --help | -h)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown argument: $arg"
                print_usage
                exit 1
                ;;
        esac
    done
}

print_usage() {
    # cat <<EOF: heredoc — prints everything until the closing EOF.
    # Indentation is preserved exactly as written.
    cat <<EOF

${C_BOLD}Usage:${C_RESET}
    $(basename "$0") [options]

${C_BOLD}Options:${C_RESET}
    --dry-run, -n    Preview what would happen without making any changes
    --force,   -f    Overwrite existing files (backs them up first)
    --help,    -h    Show this help message

${C_BOLD}Examples:${C_RESET}
    ./bootstrap/install.sh
    ./bootstrap/install.sh --dry-run
    ./bootstrap/install.sh --force

EOF
}

# ─────────────────────────────────────────────────────────────────
# SYMLINK CREATION
# ─────────────────────────────────────────────────────────────────

# create_symlink SOURCE TARGET
#
# Creates a symbolic link at TARGET pointing to SOURCE.
#
# Decision logic:
#   1. Source must exist — error if not.
#   2. If dry-run, print what would happen and return.
#   3. Create the target's parent directory if it does not exist.
#   4. If target already exists:
#      a. If it is already a correct symlink → skip.
#      b. If force mode → back up and overwrite.
#      c. Otherwise → warn and skip.
#   5. Create the symlink.
create_symlink() {
    local source="$1"   # Absolute path to the dotfile in the repository
    local target="$2"   # Absolute path to the symlink destination in $HOME

    # ── Check source exists ──────────────────────────────────────

    # -e: exists (file, directory, or symlink)
    if [ ! -e "$source" ]; then
        log_error "Source not found: $source"
        COUNT_ERRORS=$((COUNT_ERRORS + 1))
        return 1
    fi

    # ── Dry run mode ─────────────────────────────────────────────

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would link: $target → $source"
        return 0
    fi

    # ── Create parent directory ──────────────────────────────────

    local target_dir
    # dirname: strip the filename from the path, keep the directory part.
    target_dir="$(dirname "$target")"

    # -d: is a directory
    if [ ! -d "$target_dir" ]; then
        # -p: create all intermediate parents without error if they exist
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi

    # ── Handle existing target ───────────────────────────────────

    # -e checks regular files and directories.
    # -L checks symbolic links (even broken ones that -e misses).
    if [ -e "$target" ] || [ -L "$target" ]; then

        # Check if the existing symlink already points to the correct source.
        # readlink: print the value of a symbolic link.
        # If readlink output matches source, the link is already correct.
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            log_skip "Already correct: $target"
            COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
            return 0
        fi

        # Target exists but is wrong. Handle based on --force flag.
        if [ "$FORCE" = true ]; then
            # Create a timestamped backup so data is never lost.
            # date +%Y%m%d_%H%M%S: format like 20240115_143022
            local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target" "$backup"
            log_warn "Backed up: $target → $backup"
            COUNT_BACKED=$((COUNT_BACKED + 1))
        else
            log_warn "Already exists (use --force to overwrite): $target"
            COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
            return 0
        fi
    fi

    # ── Create the symbolic link ─────────────────────────────────

    # ln -s: create a symbolic link (not a hard link)
    # -s is the only flag needed — we already handled the backup above.
    ln -s "$source" "$target"
    log_ok "Linked: $target → $source"
    COUNT_LINKED=$((COUNT_LINKED + 1))
}

# ─────────────────────────────────────────────────────────────────
# PARSE SYMLINKS.CONF AND CREATE ALL LINKS
# ─────────────────────────────────────────────────────────────────

install_symlinks() {
    log_section "Creating symlinks"

    # Check the configuration file exists before trying to read it.
    if [ ! -f "$SYMLINKS_CONF" ]; then
        log_error "Symlinks config not found: $SYMLINKS_CONF"
        exit 1
    fi

    # Read the config file line by line.
    # IFS=: set field separator to nothing so leading/trailing whitespace
    #        is preserved (we trim manually with parameter expansion).
    # read -r: raw mode — do not interpret backslashes.
    # || [ -n "$line" ]: handle the case where the last line has no newline.
    while IFS= read -r line || [ -n "$line" ]; do

        # Skip blank lines.
        # -z: true if string is empty.
        [ -z "$line" ] && continue

        # Skip comment lines (lines that start with #).
        # The # must be the very first character (after no indentation).
        case "$line" in
            \#*) continue ;;
        esac

        # ── Parse the line ───────────────────────────────────────

        # Format: "source/path → ~/destination/path"
        # The separator is ' → ' (space + UTF-8 arrow → U+2192 + space).
        #
        # We use parameter expansion to split on the arrow character.
        # ${line%%→*}: everything before the first →  (source, with trailing space)
        # ${line##*→}: everything after the last →   (destination, with leading space)
        #
        # Then we trim whitespace from both ends using echo and xargs.
        # xargs with no arguments trims leading and trailing whitespace.

        local src_rel dst_raw src dst

        # Extract source (left of →) and trim whitespace.
        src_rel="$(printf '%s' "${line%%→*}" | xargs 2>/dev/null || printf '%s' "${line%%→*}")"

        # Extract destination (right of →) and trim whitespace.
        dst_raw="$(printf '%s' "${line##*→}" | xargs 2>/dev/null || printf '%s' "${line##*→}")"

        # Validate: if either side is empty, the line is malformed.
        if [ -z "$src_rel" ] || [ -z "$dst_raw" ]; then
            log_warn "Skipping malformed line: $line"
            continue
        fi

        # Build the absolute source path.
        src="${DOTFILES_DIR}/${src_rel}"

        # Expand ~ to $HOME in the destination path.
        # ${dst_raw/#\~/$HOME}: replace ~ at the start of the string with $HOME.
        # The # means "at the start" and \~ escapes the tilde.
        dst="${dst_raw/#\~/$HOME}"

        # ── Create the symlink ───────────────────────────────────

        create_symlink "$src" "$dst"

    done < "$SYMLINKS_CONF"
}

# ─────────────────────────────────────────────────────────────────
# POST-INSTALL INSTRUCTIONS
# ─────────────────────────────────────────────────────────────────

print_post_install() {
    log_section "Next steps"

    printf "\n"
    printf "%s1.%s Set your Git identity (required — left blank in .gitconfig):\n" \
        "${C_YELLOW}" "${C_RESET}"
    printf "     git config --global user.name  \"Your Name\"\n"
    printf "     git config --global user.email \"you@example.com\"\n"
    printf "\n"
    printf "%s2.%s Reload your shell configuration:\n" \
        "${C_YELLOW}" "${C_RESET}"
    printf "     source ~/.bashrc   # if using bash\n"
    printf "     source ~/.zshrc    # if using zsh\n"
    printf "\n"
    printf "%s3.%s Generate an SSH key if you need one:\n" \
        "${C_YELLOW}" "${C_RESET}"
    printf "     ssh-keygen -t ed25519 -C \"you@example.com\"\n"
    printf "     cat ~/.ssh/id_ed25519.pub   # copy this to GitHub / 42 intra\n"
    printf "\n"
}

# ─────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────

print_summary() {
    log_section "Summary"

    printf "\n"
    printf "  %s✓ Linked:%s  %d\n"  "${C_GREEN}"  "${C_RESET}" "$COUNT_LINKED"
    printf "  %s↷ Skipped:%s %d\n"  "${C_YELLOW}" "${C_RESET}" "$COUNT_SKIPPED"
    printf "  %s⊙ Backed:%s  %d\n"  "${C_YELLOW}" "${C_RESET}" "$COUNT_BACKED"
    printf "  %s✗ Errors:%s  %d\n"  "${C_RED}"    "${C_RESET}" "$COUNT_ERRORS"
    printf "\n"

    if [ "$DRY_RUN" = true ]; then
        printf "%s%sDry run complete — no changes were made.%s\n" \
            "${C_BOLD}" "${C_YELLOW}" "${C_RESET}"
    elif [ "$COUNT_ERRORS" -gt 0 ]; then
        printf "%s%sInstallation finished with errors.%s\n" \
            "${C_BOLD}" "${C_RED}" "${C_RESET}"
    else
        printf "%s%sInstallation complete.%s\n" \
            "${C_BOLD}" "${C_GREEN}" "${C_RESET}"
    fi

    printf "\n"
}

# ─────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────

main() {
    # Parse command-line arguments before doing anything else.
    parse_args "$@"

    # Print a header.
    printf "\n%s%sDotfiles Installer%s\n" "${C_BOLD}" "${C_CYAN}" "${C_RESET}"
    printf "Repository: %s\n" "${DOTFILES_DIR}"
    printf "Config:     %s\n" "${SYMLINKS_CONF}"

    # Run the symlink installation.
    install_symlinks

    # Print post-install instructions (not shown in dry-run).
    if [ "$DRY_RUN" = false ]; then
        print_post_install
    fi

    # Print the result summary.
    print_summary

    # Exit with error code if any symlink failed.
    # This is useful when running the script in CI.
    if [ "$COUNT_ERRORS" -gt 0 ]; then
        exit 1
    fi
}

# Call main with all script arguments.
# "$@": expands to all positional parameters, each separately quoted.
main "$@"