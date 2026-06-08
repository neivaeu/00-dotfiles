" Vim configuration — vanilla only.
" No plugins. No plugin manager. No external dependencies.
" Works on any machine with a standard Vim installation.
"
" PHILOSOPHY:
"   Every setting uses only built-in Vim features.
"   If Vim is installed, this file works. No exceptions.
"   Every option is commented with what it does and why.
"   Options that change behaviour in surprising ways are commented out.
"
" HOW TO USE:
"   Active settings are uncommented — they apply immediately.
"   Commented settings explain what is possible — uncomment to enable.
"   To check any option: :help option-name
"   To check current value: :set option?
"   To reload without restarting: :source ~/.vimrc
"
" SECTIONS:
"   1. Core behaviour
"   2. Display
"   3. Search
"   4. Indentation (42 Norm compliant)
"   5. File handling and navigation
"   6. Clipboard
"   7. Splits
"   8. Status line
"   9. Skeletons (file templates)
"  10. Key mappings
"  11. Autocommands
"  12. Functions

" ─────────────────────────────────────────────────────────────────
" 1. CORE BEHAVIOUR
" ─────────────────────────────────────────────────────────────────

" Disable Vi compatibility mode.
" Must be first — changes other options as a side effect.
" Without this, many modern Vim features are unavailable.
set nocompatible

" Enable file type detection, filetype-specific plugins, and indentation rules.
" These are built-in to Vim — no external plugins needed.
"   filetype on:        detect type from file extension and content
"   plugin on:          load filetype plugins from $VIMRUNTIME/ftplugin/
"   indent on:          load filetype indentation from $VIMRUNTIME/indent/
filetype plugin indent on

" Enable syntax highlighting using Vim's built-in syntax rules.
" 'syntax enable' preserves your colour settings; 'syntax on' overrides them.
syntax enable

" Allow switching between buffers without saving first.
" Without this, Vim refuses to open another file if the current one is modified.
set hidden

" Do not create swap files.
" Swap files save recovery data but clutter the directory and interfere with git.
" If you work on large files without saving, comment this out.
set noswapfile

" Do not create backup files (filename~).
" Use git for version history instead.
set nobackup
set nowritebackup

" Allow Vim to read modelines embedded in files.
" A modeline is a special comment that sets Vim options for that file.
" Example: /* vim: set ts=2 sw=2: */
" 'modelines=5' checks the first and last 5 lines of the file.
set modeline
set modelines=5

" How long to wait for a mapped key sequence to complete (milliseconds).
" 500ms is comfortable — long enough to type sequences, short enough to feel responsive.
set timeoutlen=500

" How long to wait for a terminal key sequence (e.g. Escape followed by [).
" Keep this short — a long value causes a noticeable delay after pressing Escape.
set ttimeoutlen=50

" Automatically re-read the file if it changes on disk and has no unsaved changes.
" Useful when another process writes to the file (build system, formatter).
set autoread

" Show incomplete commands in the bottom-right corner of the screen.
" Example: if you type 'd', Vim shows 'd' until you complete the command.
set showcmd

" Number of commands and searches to keep in history.
" Default is 50 — increase for better history navigation with q:.
set history=1000

" Number of undo steps to remember.
" Large number uses more memory but lets you undo further back.
set undolevels=1000

" Persist undo history across sessions.
" After closing and reopening a file, you can still undo changes from before.
" Requires: mkdir -p ~/.vim/undodir
" Commented because it requires the directory to exist — the autocommand below
" creates it, but only if you uncomment that section.
" if has('persistent_undo')
"     set undofile
"     set undodir=~/.vim/undodir
"     silent! call mkdir(expand('~/.vim/undodir'), 'p')
" endif

" Allow backspace to delete:
"   indent — autoindented whitespace at the start of a line
"   eol    — the end-of-line character (joins lines)
"   start  — characters before the cursor's insert-start position
" Without this, backspace behaves unexpectedly in insert mode on some systems.
set backspace=indent,eol,start

" Enable mouse support in all modes.
" Allows click-to-position, visual selection with mouse, and scroll.
" Remove or comment out if you want to force keyboard-only navigation.
set mouse=a

" Do not redraw the screen while executing macros or commands.
" Makes long macros faster. The screen is redrawn when the macro finishes.
set lazyredraw

" ─────────────────────────────────────────────────────────────────
" 2. DISPLAY
" ─────────────────────────────────────────────────────────────────

" Show absolute line numbers in the gutter.
set number

" Show relative line numbers for all lines except the current one.
" Relative numbers make vertical motion counts obvious: 5j goes down 5 lines.
" Combined with 'number', the current line shows its absolute number.
set relativenumber

" Always show a status line at the bottom of each window.
" 0=never, 1=only if more than one window, 2=always
set laststatus=2

" Show the cursor position (line and column) in the status line.
set ruler

" Show the current mode in the status line (-- INSERT --, -- VISUAL --).
set showmode

" Show matching bracket/parenthesis/brace when cursor is on one.
" The cursor briefly jumps to the matching bracket.
set showmatch

" Duration (in tenths of a second) to show the matching bracket.
" 2 = 0.2 seconds.
set matchtime=2

" Number of screen lines to keep above and below the cursor.
" Prevents editing at the very top or bottom of the visible area.
set scrolloff=8

" Number of screen columns to keep left and right of the cursor.
set sidescrolloff=5

" Do not wrap long lines.
" Long lines scroll horizontally. Use colorcolumn to enforce a limit instead.
set nowrap

" Show invisible whitespace characters.
" Makes trailing spaces and tab/space mixing immediately visible.
set list

" Define what invisible characters look like.
"   tab:→·   — tab shown as arrow + middle dot
"   trail:·  — trailing space shown as middle dot
"   nbsp:␣   — non-breaking space shown as open box
"   extends:› — line continues past right edge
"   precedes:‹ — line continues past left edge
set listchars=tab:→\ ,trail:·,nbsp:␣,extends:›,precedes:‹

" Draw a vertical ruler at column 80.
" 42 School Norm: maximum 80 characters per line.
" The ruler is a visual guide — Vim does not enforce it.
set colorcolumn=80

" Use colours appropriate for a dark background terminal.
" If your terminal has a light background, change to: set background=light
set background=dark

" Enable 256-colour mode if the terminal supports it.
" Most modern terminals support this.
if &term =~# '256color' || &term ==# 'xterm-256color'
    set t_Co=256
endif

" Enable true colour (24-bit) if the terminal supports it.
" Uncomment if your terminal supports true colour and you want richer colours.
" if has('termguicolors')
"     set termguicolors
" endif

" ─────────────────────────────────────────────────────────────────
" 3. SEARCH
" ─────────────────────────────────────────────────────────────────

" Highlight all matches of the current search pattern.
" Clear highlights with: :nohlsearch  (or the mapping below)
set hlsearch

" Show matches as you type, before pressing Enter.
" The view jumps to each match incrementally.
set incsearch

" Case-insensitive search when the pattern is all lowercase.
set ignorecase

" Switch to case-sensitive search if the pattern contains any uppercase letter.
" Works together with ignorecase:
"   /word  → case-insensitive (matches Word, WORD, word)
"   /Word  → case-sensitive (matches only Word)
set smartcase

" ─────────────────────────────────────────────────────────────────
" 4. INDENTATION — 42 NORM COMPLIANT
" ─────────────────────────────────────────────────────────────────

" Copy indentation from the current line when starting a new line.
set autoindent

" Use smart C-style indentation (adjusts after { and }).
set smartindent

" Display width of a tab character.
" 42 Norm: tabs are displayed as 4 columns wide.
set tabstop=4

" Number of columns used for each step of >> and << indentation.
set shiftwidth=4

" Use hard tab characters for indentation (NOT spaces).
" 42 Norm requires hard tabs. This is the most important indentation setting.
" If you work on a project that uses spaces: set expandtab
set noexpandtab

" Round indentation to the nearest multiple of shiftwidth with >> and <<.
set shiftround

" ─────────────────────────────────────────────────────────────────
" 5. FILE HANDLING AND NAVIGATION
" ─────────────────────────────────────────────────────────────────

" Add all subdirectories to the search path.
" Allows :find filename to search recursively from the current directory.
" The ** means: search recursively.
" Usage: :find main.c  (finds any main.c in the project)
set path+=**

" Enable the wildmenu — a visual completion menu for : commands.
" When you press Tab after a :command, a menu appears with options.
set wildmenu

" Completion mode: complete to the longest common string, then show the menu.
set wildmode=list:longest,full

" Ignore these file patterns when completing filenames and in the wildmenu.
" These are compiled output or cache files that you never want to edit.
set wildignore=*.o,*.a,*.so,*.pyc,*/__pycache__/*,*.swp,tags,TAGS

" Character encoding for new files.
set encoding=utf-8
set fileencoding=utf-8

" ─────────────────────────────────────────────────────────────────
" 6. CLIPBOARD
" ─────────────────────────────────────────────────────────────────

" Use the system clipboard for all yank, delete, and paste operations.
" unnamedplus uses the '+' clipboard register (Ctrl+C/Ctrl+V in other apps).
"
" Requirements:
"   Linux:  Vim compiled with +clipboard (vim-gtk3 has it)
"           AND xclip or xsel installed (for X11)
"   Check:  vim --version | grep clipboard
"           '+clipboard' = supported, '-clipboard' = not supported
"
" If +clipboard is not available, this silently does nothing.
" But sometimes it work without +clipboard"
set clipboard=unnamedplus

" ─────────────────────────────────────────────────────────────────
" 7. SPLITS
" ─────────────────────────────────────────────────────────────────

" Open new vertical splits to the right of the current window.
" Default behaviour opens splits to the left, which feels backwards.
set splitright

" Open new horizontal splits below the current window.
" Default behaviour opens splits above, which feels backwards.
set splitbelow

" ─────────────────────────────────────────────────────────────────
" 8. STATUS LINE
" ─────────────────────────────────────────────────────────────────

" Custom status line using only built-in Vim variables.
" No plugin needed. Shows:
"   left side:  current mode | file path | modified flag | read-only flag
"   right side: file type | encoding | format | line:column | percentage
"
" Format codes:
"   %{mode()}    current mode (n, i, v, etc.)
"   %f           file path relative to cwd
"   %m           [+] if modified, [-] if modifiable is off
"   %r           [RO] if read-only
"   %=           switch to right-aligned content
"   %y           file type in brackets [c], [python], etc.
"   %{&fileencoding} file encoding (utf-8, latin1, etc.)
"   %{&fileformat}   line ending format (unix, dos, mac)
"   %l:%c        line number:column number
"   %p%%         percentage through the file
set statusline=
set statusline+=\ %{mode()}        " Current mode
set statusline+=\ \|\ %f           " File path
set statusline+=\ %m               " Modified flag
set statusline+=\ %r               " Read-only flag
set statusline+=%=                 " Right-align everything after this
set statusline+=\ %y               " File type
set statusline+=\ %{&fileencoding} " Encoding
set statusline+=\ [%{&fileformat}] " Line ending format
set statusline+=\ %l:%c            " Line:Column
set statusline+=\ %p%%             " Percentage
set statusline+=\ 

" ─────────────────────────────────────────────────────────────────
" 9. SKELETONS — FILE TEMPLATES
" ─────────────────────────────────────────────────────────────────
" Skeletons are template files inserted at the cursor position.
" They save typing the same boilerplate for every new file.
"
" How :-1read works:
"   :read FILE    inserts FILE contents below the current line
"   :-1read FILE  inserts FILE contents above the current line
"                 (the -1 means: go to the line above first)
"
" The key sequence after <CR> positions the cursor usefully after insertion.

" ,c — insert C main() skeleton
" After insertion, moves cursor to the end of the return line.
nnoremap ,c :-1read $HOME/.vim/skeletons/.skeleton.c<CR>4j$

" ,h — insert C header skeleton (include guard + basic structure)
" After insertion, moves cursor to after the #define line.
nnoremap ,h :-1read $HOME/.vim/skeletons/.skeleton.h<CR>2j$

" ,html — insert HTML5 skeleton
" After insertion, moves cursor inside the <title> tag.
nnoremap ,html :-1read $HOME/.vim/skeletons/.skeleton.html<CR>3jwf>a

" ─────────────────────────────────────────────────────────────────
" 10. KEY MAPPINGS
" ─────────────────────────────────────────────────────────────────
"
" MAPPING TYPES:
"   nnoremap — normal mode, non-recursive (use this for most mappings)
"   inoremap — insert mode, non-recursive
"   vnoremap — visual mode, non-recursive
"   cnoremap — command mode, non-recursive
"
" Non-recursive (noremap) means the right-hand side is not expanded
" through other mappings. Always use noremap unless you explicitly
" need recursive expansion.
"
" LEADER KEY:
"   <leader> is a configurable prefix for custom mappings.
"   Space is used here — it is reachable with both thumbs and
"   rarely used in normal mode.
let mapleader = ' '

" ── ESSENTIAL ────────────────────────────────────────────────────

" Clear search highlighting without clearing the search pattern.
" The pattern remains in / so n and N still work after clearing.
" <leader>l: 'l' for 'light' (turn off the highlight light)
nnoremap <leader>l :nohlsearch<CR>

" Flash the cursor position — briefly show crosshair to find cursor.
" Useful after scrolling a large file.
" <Ctrl-a> is used because it is otherwise only bound to 'increment number'.
nnoremap <C-a> :call FlashCursor()<CR>

" ── FILE OPERATIONS ──────────────────────────────────────────────

" Save the current file.
" <Ctrl-s> is familiar from other editors.
" The insert mode version returns to insert mode after saving.
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" ── NAVIGATION ───────────────────────────────────────────────────

" Navigate between splits without pressing <C-w> first.
" <Ctrl-h/j/k/l> — move to the left/down/up/right window.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Keep the cursor centred vertically when jumping between search results.
" zz: scroll so the current line is centred.
" zv: open any folds that contain the cursor.
nnoremap n nzzzv
nnoremap N Nzzzv

" Move by visual lines, not logical lines.
" Matters when 'wrap' is on: a long line that wraps across multiple
" screen lines is treated as one logical line.
" j goes to the next visual line, not the next file line.
nnoremap j gj
nnoremap k gk

" ── VISUAL MODE ──────────────────────────────────────────────────

" Stay in visual mode after indenting with > or <.
" Without this, Vim deselects after one indent step and you must reselect.
vnoremap < <gv
vnoremap > >gv

" ── COMMAND MODE TYPO CORRECTIONS ────────────────────────────────

" Map common typos to the correct command.
" Without these, :W gives "Not an editor command: W".
command! W  write
command! Q  quit
command! Wq wq
command! WQ wq

" ─────────────────────────────────────────────────────────────────
" 11. AUTOCOMMANDS
" ─────────────────────────────────────────────────────────────────
"
" Autocommands run automatically when specific events occur.
"
" augroup: groups autocommands together so they can be cleared
"          with 'autocmd!' before re-adding them.
"          Without the group, reloading .vimrc would duplicate every autocmd.
"
" autocmd EVENT PATTERN COMMAND
"   EVENT:   when to trigger (FileType, BufWritePre, BufReadPost, etc.)
"   PATTERN: which files to match (*.c, *, gitcommit, etc.)
"   COMMAND: what to do

augroup vimrc_autocmds
    " Clear all autocmds in this group before re-adding them.
    " This prevents duplicates when :source ~/.vimrc is run.
    autocmd!

    " ── C FILES ──────────────────────────────────────────────────

    " Apply 42 Norm settings to C source and header files.
    " tabstop=4 noexpandtab: hard tabs, 4 columns wide.
    " cindent: C-style smart indentation.
    " colorcolumn=80: show the 80-character limit visually.
    autocmd FileType c,cpp
        \ setlocal tabstop=4 shiftwidth=4 noexpandtab |
        \ setlocal cindent |
        \ setlocal colorcolumn=80

    " ── MAKEFILE ─────────────────────────────────────────────────

    " Makefiles MUST use hard tabs — spaces cause "missing separator" errors.
    " This overrides any expandtab setting from the global config.
    autocmd FileType make
        \ setlocal noexpandtab tabstop=4 shiftwidth=4

    " ── SHELL SCRIPTS ────────────────────────────────────────────

    " Shell scripts use 4-space indentation.
    " autocmd FileType sh,bash,zsh
    "     \ setlocal tabstop=4 shiftwidth=4 expandtab

    " ── GIT COMMIT MESSAGES ──────────────────────────────────────

    " Git convention: wrap commit messages at 72 characters.
    " colorcolumn at 50 (subject limit) and 72 (body limit).
    " expandtab: commit messages always use spaces.
    " spell: enable spell checking for commit messages.
    autocmd FileType gitcommit
        \ setlocal textwidth=72 |
        \ setlocal colorcolumn=50,72 |
        \ setlocal expandtab |
        \ setlocal spell spelllang=en_gb

    " ── MARKDOWN ─────────────────────────────────────────────────

    " Wrap markdown lines for readability.
    " linebreak: wrap at word boundaries, not mid-word.
    " spell: enable spell checking for prose files.
    " No colorcolumn — markdown is not code.
    autocmd FileType markdown
        \ setlocal wrap linebreak |
        \ setlocal colorcolumn= |
        \ setlocal spell spelllang=en_gb

    " ── TRAILING WHITESPACE ──────────────────────────────────────

    " Remove trailing whitespace on save for C source and shell files.
    " This is active because trailing whitespace is almost always a mistake
    " and creates noisy diffs.
    "
    " Implementation:
    "   b:pos = save cursor position before substitution
    "   %s/\s\+$//e — substitute trailing whitespace at end of any line
    "                  /e — do not error if no match found
    "   setpos('.', b:pos) — restore cursor position after substitution
    autocmd BufWritePre *.c,*.h,*.sh
        \ let b:pos = getpos('.') |
        \ %s/\s\+$//e |
        \ call setpos('.', b:pos)

    " ── CURSOR POSITION ──────────────────────────────────────────

    " Restore the cursor to where it was when the file was last closed.
    " Uses the ' mark which Vim saves in ~/.viminfo.
    " The condition checks that the mark position is valid (> 1 line, within file).
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \     execute "normal! g'\"" |
        \ endif

augroup END

" ─────────────────────────────────────────────────────────────────
" 12. FUNCTIONS
" ─────────────────────────────────────────────────────────────────

" FlashCursor — briefly show a crosshair at the cursor position.
"
" How it works:
"   1. Enable cursorline (horizontal highlight) and cursorcolumn (vertical)
"   2. Force a screen redraw so the highlight appears immediately
"   3. Sleep for 100 milliseconds
"   4. Disable both highlights
"
" This is useful after jumping to a different location (search result,
" tag jump, etc.) when you need to find the cursor quickly.
function! FlashCursor()
    set cursorline cursorcolumn
    redraw
    sleep 100m
    set nocursorline nocursorcolumn
endfunction