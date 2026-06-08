```markdown
# dotfiles

Personal development environment configuration for Linux.

Vanilla Vim. Bash. Zsh. Git. VS Code. No plugins required to get started.
No external dependencies for the core configuration.

---

## Repository structure

```text
dotfiles/
├── .github/
│   ├── workflows/
│   │   └── ci-validate-syntax.yml   CI — syntax checks on every push
│   └── ISSUE_TEMPLATE/
│       └── broken-config.md         Template for reporting broken configs
├── bootstrap/
│   ├── install.sh                   Symlink installer (run this first)
│   ├── packages.txt           Reference list of packages (not auto-installed)
│   └── symlinks.conf                Source → destination mapping
├── cheatsheets/
│   ├── bash.md                      Bash scripting and interactive use
│   ├── cc-and-make.md               GCC flags, sanitisers, Makefile patterns
│   ├── gdb.md                       GDB — breakpoints, memory, core dumps
│   ├── git.md                       Git — all commands, workflows, history
│   ├── valgrind.md                  Valgrind — memcheck, reading output
│   ├── vim.md                       Vim — motions, splits, search, netrw
│   └── vscode.md                    VS Code — shortcuts, built-in features
├── editors/
│   ├── vim/
│   │   ├── .vimrc                   Vim configuration (vanilla, no plugins)
│   │   └── skeletons/
│   │       ├── .skeleton.c          C source file template (,c in Vim)
│   │       └── .skeleton.h          C header file template (,h in Vim)
│   └── vscode/
│       ├── settings.json            Editor settings
│       ├── keybindings.json         Custom key bindings
│       └── extensions.md            Recommended extensions (reference only)
├── git/
│   ├── .gitconfig                   Global Git configuration
│   ├── .gitignore_global            Patterns ignored in every repository
│   └── .gitmessage                  Commit message template (Conventional Commits)
├── scripts/
│   ├── system-info.sh               Show installed tool versions
│   ├── red-recon.sh                 Network reconnaissance helper
│   └── shadow-hunter.sh             Process and file inspection helper
├── shell/
│   ├── .bash_aliases                Bash aliases (all commented out)
│   ├── .bash_profile                Bash login shell configuration
│   ├── .bashrc                      Bash interactive shell configuration
│   ├── .inputrc                     GNU Readline configuration
│   ├── .zshenv                      Zsh environment (sourced for every shell)
│   ├── .zshrc                       Zsh interactive shell configuration
│   ├── aliases.zsh                  Zsh aliases (all commented out)
│   ├── custom.zsh-theme             Standalone Zsh prompt (built-ins only)
│   └── functions.zsh                Zsh functions (all commented out)
├── system/
│   ├── .curlrc                      Default curl options
│   ├── .editorconfig                Universal editor formatting rules
│   └── .wgetrc                      Default wget options
└── README.md                        This file
```

---

## Quick start

```sh
git clone https://github.com/yourname/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap/install.sh
./bootstrap/install.sh
```

Then set your Git identity — the config file intentionally leaves this blank:

```sh
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

Then reload your shell:

```sh
source ~/.bashrc   # if using Bash
source ~/.zshrc    # if using Zsh
```

---

## Installation options

```sh
./bootstrap/install.sh             # Normal install
./bootstrap/install.sh --dry-run   # Preview — no changes made
./bootstrap/install.sh --force     # Overwrite existing files (backup first)
```

The installer reads `bootstrap/symlinks.conf` and creates one symbolic link
per entry. It does nothing else — no packages are installed, no shell is
changed, no network requests are made.

---

## What gets symlinked

| Source in repository | Destination |
|---|---|
| `editors/vim/.vimrc` | `~/.vimrc` |
| `editors/vim/skeletons/.skeleton.c` | `~/.vim/skeletons/.skeleton.c` |
| `editors/vim/skeletons/.skeleton.h` | `~/.vim/skeletons/.skeleton.h` |
| `editors/vim/skeletons/.skeleton.html` | `~/.vim/skeletons/.skeleton.html` |
| `editors/vscode/settings.json` | `~/.config/Code/User/settings.json` |
| `editors/vscode/keybindings.json` | `~/.config/Code/User/keybindings.json` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `git/.gitmessage` | `~/.gitmessage` |
| `shell/.bashrc` | `~/.bashrc` |
| `shell/.bash_profile` | `~/.bash_profile` |
| `shell/.bash_aliases` | `~/.bash_aliases` |
| `shell/.inputrc` | `~/.inputrc` |
| `shell/.zshrc` | `~/.zshrc` |
| `shell/.zshenv` | `~/.zshenv` |
| `shell/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `shell/functions.zsh` | `~/.config/zsh/functions.zsh` |
| `shell/custom.zsh-theme` | `~/.config/zsh/themes/custom.zsh-theme` |
| `system/.curlrc` | `~/.curlrc` |
| `system/.wgetrc` | `~/.wgetrc` |
| `system/.editorconfig` | `~/.editorconfig` |

---

## Design principles

### No plugins required

Every active setting uses only tools that are part of a standard Linux
installation. The Vim configuration uses no plugin manager. The shell
configuration uses no framework. This means the configuration works on
any machine where the base tools are installed — including 42 School
machines where you cannot install software.

Tools that require installation (fzf, zsh-syntax-highlighting, starship)
are supported but everything referencing them is commented out. Uncomment
when installed.

### Everything is commented

Every option in every file has a comment explaining:
- What it does
- Why it is on or off by default
- When it would make sense to change it

You can read any file in this repository and understand the full
configuration without searching documentation.

### Minimal active configuration

The principle is: start from the standard defaults, add only what has a
clear and necessary reason to exist, comment out everything else with an
explanation.

Active settings that differ from defaults are listed in the section
headers below.

### Symlinks, not copies

Every file is symlinked so that editing the file in the repository is
immediately reflected without a sync step. Edits in `~/dotfiles/` take
effect the next time the tool reads its config file.

### No aliases by default

All aliases in `.bash_aliases` and `aliases.zsh` are commented out.
Full commands work on every machine, in every shell, in scripts, in
documentation, and on colleagues' machines. Aliases only work after your
dotfiles are installed. Uncomment the ones you actively use.

---

## Section details

### shell/

Shell configuration for Bash and Zsh.

**Active non-default settings:**

| File | Setting | Reason |
|---|---|---|
| `.bashrc` / `.zshrc` | History append on every command | Prevents history loss on crash |
| `.bashrc` / `.zshrc` | Timestamps in history | Useful for debugging and auditing |
| `.bashrc` / `.zshrc` | Ignore commands starting with space | Keeps sensitive commands out of history |
| `.zshrc` | Share history between sessions | No lost commands across terminal windows |
| `.zshrc` | Confirm history expansion before running | Prevents accidental execution |
| `.bashrc` / `.zshrc` | Git branch in prompt | Avoids running `git status` constantly |
| `.bashrc` / `.zshrc` | Exit code in prompt | Immediately visible when a command fails |
| `.zshrc` | `NO_BEEP` | The bell is universally disruptive |
| `.zshrc` | `NO_FLOW_CONTROL` | Ctrl+S/Q is a legacy serial terminal feature |
| `.zshrc` | `INTERACTIVE_COMMENTS` | Allows `# comments` in interactive shell |
| `.inputrc` | History search with arrow keys | Type prefix + Up to find matching commands |
| `.inputrc` | Case-insensitive completion | `dow` completes to `Downloads` |
| `.inputrc` | Show completions on first Tab | Saves one Tab press constantly |
| `.inputrc` | Coloured completion list | Faster to scan than plain text |
| `.inputrc` | No terminal bell | Consistent with `NO_BEEP` in Zsh |

**Machine-specific overrides (not tracked in git):**
- Bash: `~/.bashrc.local`
- Zsh: `~/.zshrc.local`

Both are sourced automatically if they exist. Use them for API keys,
work-specific paths, and anything that should not be committed.

---

### git/

Global Git configuration applied to every repository.

**You must set your identity after installing:**

```sh
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

These are left blank in `.gitconfig` because this repository is shared
and personal data must not be committed.

**Active non-default settings:**

| Setting | Value | Reason |
|---|---|---|
| `core.autocrlf` | `input` | Prevents Windows line endings entering repositories |
| `core.whitespace` | `trailing-space,space-before-tab` | Highlights whitespace mistakes in diffs |
| `push.default` | `simple` | Never accidentally pushes all branches |
| `push.autoSetupRemote` | `true` | Eliminates the "set upstream" error on first push |
| `pull.rebase` | `false` | Git default — merge on pull, no history rewriting |
| `fetch.prune` | `true` | Keeps the local branch list clean automatically |
| `merge.conflictstyle` | `diff3` | Shows the common ancestor in conflicts — easier to resolve |
| `diff.algorithm` | `histogram` | More readable diffs when code is restructured |
| `status.showUntrackedFiles` | `all` | Shows individual files, not just directory names |
| `branch.sort` | `-committerdate` | Most recently used branches appear first |
| `commit.verbose` | `true` | Shows the staged diff inside the commit editor |
| `commit.template` | `~/.gitmessage` | Loads the Conventional Commits template on every commit |
| `rerere.enabled` | `true` | Remembers conflict resolutions for repeated rebases |
| `tag.sort` | `version:refname` | `v1.2.10` sorts after `v1.2.9` (not before) |

**No aliases are active by default.** All aliases are listed in the
`[alias]` section with comments. Uncomment the ones your team agrees to use.

**Commit message format:**

```text
type(scope): short description

Optional body explaining what and why.

Optional footer: Closes #123
```

The template is shown automatically when you run `git commit`.
See `git/.gitmessage` for the full type reference and examples.

---

### editors/vim/

Vanilla Vim — no plugins, no plugin manager.

The configuration works on any machine where Vim is installed, including
42 School machines where you cannot install software.

**Skeleton shortcuts** (in normal mode):

| Key | Inserts |
|---|---|
| `,c` | C source file with `main()` and includes |
| `,h` | C header file with include guard |
| `,html` | HTML5 boilerplate |

**Active settings:**

| Setting | Value | Reason |
|---|---|---|
| `syntax enable` | on | Syntax colour using built-in rules |
| `filetype plugin indent on` | on | Built-in file type detection and indentation |
| `mouse=a` | all modes | Click-to-position and scroll |
| `noswapfile` | off | No swap file clutter |
| `number` + `relativenumber` | both | Absolute current line, relative for jump counts |
| `scrolloff=8` | 8 lines | Always see context above and below cursor |
| `nowrap` | off | Horizontal scroll rather than line wrapping |
| `list` + `listchars` | on | Invisible characters visible (trailing spaces, tabs) |
| `colorcolumn=80` | column 80 | Visual marker for 42 Norm line length limit |
| `noexpandtab` + `tabstop=4` | hard tabs | 42 Norm requires hard tabs |
| `path+=**` | recursive | `:find` searches all subdirectories |
| `wildmenu` | on | Tab completion shows a visual menu |
| `hlsearch` + `incsearch` | both | Highlight matches as you type |
| `clipboard=unnamedplus` | system | Yank goes to the system clipboard (requires vim-gtk3) |

**Key mappings:**

| Key | Mode | Action |
|---|---|---|
| `Space` | Normal | Leader key |
| `<leader>l` | Normal | Clear search highlights |
| `<Ctrl-a>` | Normal | Flash cursor position (find cursor quickly) |
| `<Ctrl-s>` | Normal/Insert | Save file |
| `<Ctrl-h/j/k/l>` | Normal | Navigate between splits |
| `n` / `N` | Normal | Next/previous match, cursor centred |
| `j` / `k` | Normal | Move by visual line (not logical line) |
| `<` / `>` | Visual | Indent and stay in visual mode |
| `,c` / `,h` / `,html` | Normal | Insert file skeleton |

---

### editors/vscode/

VS Code settings, key bindings, and a reference extension list.

**Key active settings:**

| Setting | Value | Reason |
|---|---|---|
| `editor.rulers` | `[80]` | 42 Norm line length limit |
| `files.trimTrailingWhitespace` | `true` | Prevents noisy diffs |
| `files.insertFinalNewline` | `true` | POSIX standard |
| `files.autoSave` | `off` | Manual save prevents accidental writes |
| `editor.formatOnSave` | commented | Requires a formatter configured per project |
| `git.enableSmartCommit` | `false` | Requires explicit staging before commit |
| `[c].editor.insertSpaces` | `false` | 42 Norm requires hard tabs in C files |
| `[markdown].files.trimTrailingWhitespace` | `false` | Two trailing spaces = line break in Markdown |
| `diffEditor.ignoreTrimWhitespace` | `false` | Whitespace changes must be visible in diffs |

**Installing extensions:**

```sh
grep -v '^#' editors/vscode/extensions.md | \
grep -v '^$' | \
xargs -L1 code --install-extension
```

---

### system/

Per-user configuration for system tools.

**Active settings:**

| File | Setting | Reason |
|---|---|---|
| `.curlrc` | `tlsv1.2` | TLS 1.0/1.1 are broken — never connect to servers that only support them |
| `.curlrc` | `show-error` | Without this, `curl -s` in scripts silently swallows error messages |
| `.wgetrc` | `check-certificate = on` | TLS verification must never be disabled |
| `.wgetrc` | `tries = 3` | wget is used for file downloads — retrying on network errors is correct |
| `.editorconfig` | All file type rules | Consistent formatting across editors with no manual configuration |

---

### cheatsheets/

Reference documents for every tool in this environment.
Plain Markdown — readable in any editor or on GitHub.

| File | Covers |
|---|---|
| `bash.md` | Bash — navigation, shortcuts, scripting, redirection |
| `cc-and-make.md` | GCC flags, sanitisers, Makefile syntax, 42 templates |
| `gdb.md` | GDB — breakpoints, stepping, memory inspection, core dumps |
| `git.md` | Git — all commands, branching, history, conflict resolution |
| `valgrind.md` | Valgrind — memcheck, reading output, all error types |
| `vim.md` | Vim — motions, operators, splits, macros, search, netrw |
| `vscode.md` | VS Code — shortcuts, built-in features, settings reference |

---

### scripts/

Utility scripts. All are executable after installation.

| Script | Purpose |
|---|---|
| `system-info.sh` | Print installed versions of all tools in this environment |
| `red-recon.sh` | Network reconnaissance helper |
| `shadow-hunter.sh` | Process and file inspection helper |

---

### .github/

**CI pipeline** runs on every push and pull request:

| Job | Checks |
|---|---|
| `shell-syntax` | `bash -n` and `shellcheck` on all `*.sh` files |
| `zsh-syntax` | `zsh -n` on all `.zsh` and `.zshrc` files |
| `symlinks-conf` | Every source declared in `symlinks.conf` exists in the repo |
| `required-files` | All core dotfiles are present |
| `gitconfig-syntax` | `git/.gitconfig` is parseable by `git config` |
| `bootstrap-dry-run` | `install.sh --dry-run` completes without errors |

**Run the same checks locally:**

```sh
bash -n bootstrap/install.sh
shellcheck bootstrap/install.sh
zsh -n shell/.zshrc
git config --file git/.gitconfig --list
./bootstrap/install.sh --dry-run
```

**Reporting a broken configuration:**

1. Go to the [Issues](../../issues) tab
2. Click **New issue**
3. Choose the **Broken Configuration** template
4. Fill in the file, expected behaviour, actual behaviour, steps to reproduce, and the exact error output

---

## Setting up on a 42 School machine

```sh
# 1. Clone
git clone https://github.com/yourname/dotfiles.git ~/dotfiles

# 2. Install (no sudo required)
cd ~/dotfiles
chmod +x bootstrap/install.sh
./bootstrap/install.sh

# 3. Set your identity
git config --global user.name  "yourlogin"
git config --global user.email "yourlogin@student.42campus.org"

# 4. Reload shell
source ~/.bashrc

# 5. Generate SSH key if needed
ssh-keygen -t ed25519 -C "yourlogin@student.42campus.org"
cat ~/.ssh/id_ed25519.pub
# Paste the output into: 42 Intra → Settings → SSH Keys
```

---

## Packages

`bootstrap/packages.txt` is a reference document, not an install script.
Nothing is installed automatically.

**Minimum required to use this environment:**

```sh
sudo apt install git vim curl wget make gcc valgrind gdb python3 python3-pip
```

**42 School code style checker:**

```sh
pip3 install norminette
norminette --version
```

**Vim clipboard support** (required for `clipboard=unnamedplus` in `.vimrc`):

```sh
sudo apt install vim-gtk3
vim --version | grep clipboard   # Should show +clipboard
```

---

## Keeping the repository up to date

```sh
cd ~/dotfiles
git pull
# Symlinks already point here — no reinstall needed
```

---

## Troubleshooting

**Symlink not created:**
```sh
ls -la ~/.vimrc          # Check it exists and points to the right place
./bootstrap/install.sh --dry-run   # Preview what would happen
./bootstrap/install.sh --force     # Recreate all symlinks
```

**Vim clipboard not working:**
```sh
vim --version | grep clipboard
# -clipboard = not supported
sudo apt install vim-gtk3          # Install the version with clipboard
```

**Vim skeleton not found (`E484: Can't open file ~/.vim/skeletons/.skeleton.c`):**
```sh
ls ~/.vim/skeletons/               # Check directory exists
./bootstrap/install.sh             # Re-run the installer to create the symlinks
```

**Git commit template not loading:**
```sh
git config --global commit.template
# Should output: /home/you/.gitmessage
ls -la ~/.gitmessage               # Check the symlink exists
```

**Zsh prompt showing no git branch:**
```sh
# The prompt uses vcs_info which is built into Zsh
# Check you are inside a git repository:
git rev-parse --is-inside-work-tree
```

**History not persisting between sessions:**
```sh
# Check HISTFILE is set
echo $HISTFILE
# Should output: /home/you/.zsh_history or /home/you/.bash_history
# Check the file exists and is writable
ls -la ~/.zsh_history
```
