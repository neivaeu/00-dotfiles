# Vim Cheatsheet — vanilla Vim only, no plugins.
# No external dependencies. Works on any system with a standard Vim installation.
# Uses: vim, ctags (optional), make (optional).

---

## Modes

| Mode | How to enter | Status line shows |
|------|-------------|-------------------|
| Normal | `Esc` or `Ctrl-[` from any mode | (nothing) |
| Insert | `i`, `a`, `o`, `I`, `A`, `O`, `s`, `S` | `-- INSERT --` |
| Replace | `R` from Normal | `-- REPLACE --` |
| Visual char | `v` from Normal | `-- VISUAL --` |
| Visual line | `V` from Normal | `-- VISUAL LINE --` |
| Visual block | `Ctrl-v` from Normal | `-- VISUAL BLOCK --` |
| Command | `:` from Normal | `:` at bottom |

---

## Opening and quitting

```vim
vim filename          " Open file
vim +42 filename      " Open file at line 42
vim +/pattern file    " Open file at first match of pattern
vim -O file1 file2    " Open files in vertical splits
vim -p file1 file2    " Open files in tabs

:w                    " Save (write)
:w filename           " Save as filename
:wq                   " Save and quit
:x                    " Save and quit (only writes if modified)
:q                    " Quit (fails if unsaved changes)
:q!                   " Quit and discard changes
:qa                   " Quit all windows
:qa!                  " Quit all, discard all changes
ZZ                    " Save and quit (Normal mode)
ZQ                    " Quit without saving (Normal mode)

Entering Insert mode
Key	Action
i	Insert before cursor
a	Append after cursor
I	Insert at start of line (first non-blank)
A	Append at end of line
o	Open new line below, enter Insert
O	Open new line above, enter Insert
s	Delete character under cursor, enter Insert
S	Delete entire line, enter Insert (same as cc)
gi	Return to last Insert position and enter Insert
Esc or Ctrl-[	Return to Normal mode
Navigation — Normal mode
Character and line
Key	Action
h j k l	Left, down, up, right
0	Start of line (column 0)
^	First non-blank character of line
$	End of line
g_	Last non-blank character of line
g0	Start of screen line (when wrap is on)
g$	End of screen line
+ or Enter	First non-blank char of next line
-	First non-blank char of previous line
N|	Column N of current line
Word movement
Key	Action
w	Next word start — punctuation counts as word boundary
W	Next WORD start — only whitespace is a boundary
e	Next word end
E	Next WORD end
b	Previous word start
B	Previous WORD start
ge	Previous word end
gE	Previous WORD end
File and screen
Key	Action
gg	First line of file
G	Last line of file
NG or :N	Go to line N
N%	Go to N percent through file
H	Move cursor to top of screen
M	Move cursor to middle of screen
L	Move cursor to bottom of screen
Ctrl-f	Scroll down one full page
Ctrl-b	Scroll up one full page
Ctrl-d	Scroll down half page
Ctrl-u	Scroll up half page
Ctrl-e	Scroll screen down one line (cursor stays)
Ctrl-y	Scroll screen up one line (cursor stays)
zz	Centre screen on cursor line
zt	Scroll cursor line to top of screen
zb	Scroll cursor line to bottom of screen
Within a line
Key	Action
f{char}	Jump forward to next {char} on line
F{char}	Jump backward to previous {char} on line
t{char}	Jump forward to just before {char}
T{char}	Jump backward to just after {char}
;	Repeat last f/F/t/T forward
,	Repeat last f/F/t/T backward
Between functions (C code)
Key	Action
]]	Next { at column 0 — next function start
[[	Previous { at column 0 — previous function start
][	Next } at column 0 — next function end
[]	Previous } at column 0 — previous function end
Matching and jumping
Key	Action
%	Jump to matching () [] {}
gd	Go to local definition of word under cursor
gD	Go to global definition of word under cursor
gf	Open file whose name is under cursor
Ctrl-o	Jump to previous location in jump list
Ctrl-i	Jump to next location in jump list
''	Jump to line of last jump
``	Jump to exact position of last jump
'.	Jump to last edited line
Marks
Key	Action
ma	Set mark a at cursor (local to file)
mA	Set mark A at cursor (global — works across files)
`a	Jump to exact position of mark a
'a	Jump to start of line of mark a
`[	Start of last changed or yanked text
`]	End of last changed or yanked text
`<	Start of last visual selection
`>	End of last visual selection
:marks	List all marks
:jumps	Show jump list
['	Jump to previous mark
]'	Jump to next mark
Operators and motions

Vim commands follow: [count] operator [motion] or operator operator (current line).

Operators:
Operator	Action
d	Delete (cut to register)
c	Change (delete + enter Insert)
y	Yank (copy)
>	Indent right
<	Indent left
=	Auto-indent
gU	Uppercase
gu	Lowercase
g~	Toggle case
!	Filter through external command

Motions (work with any operator):

text

w b e W B E          word/WORD forward/backward/end
0 ^ $ g_             line start/first-nonblank/end/last-nonblank
gg G                 file start/end
{ }                  paragraph backward/forward
( )                  sentence backward/forward
f{c} F{c}            find character on line
t{c} T{c}            till character on line
%                    matching bracket
/pattern ?pattern    search forward/backward

Text objects (operator + text object):

Vim

iw / aw     " inner word / a word (includes surrounding space)
iW / aW     " inner WORD / a WORD
is / as     " inner sentence / a sentence
ip / ap     " inner paragraph / a paragraph (ap includes blank lines)
i" / a"     " inside double quotes / with quotes
i' / a'     " inside single quotes / with quotes
i` / a`     " inside backticks / with backticks
i( / a(     " inside parentheses / with parentheses (same as ib/ab)
i[ / a[     " inside square brackets / with brackets
i{ / a{     " inside curly braces / with braces (same as iB/aB)
i< / a<     " inside angle brackets / with brackets
it / at     " inside HTML tag / with tags

" Examples:
diw         " Delete inner word (word under cursor)
daw         " Delete word + surrounding space
ci(         " Change inside parentheses
ca{         " Change block including the braces
yi"         " Yank text inside double quotes
da[         " Delete including square brackets
cit         " Change inside HTML tag

Deleting
Key	Action
x	Delete character under cursor
X	Delete character before cursor
dd	Delete current line
D	Delete from cursor to end of line
d0	Delete from cursor to start of line
dw	Delete to next word start
de	Delete to end of word
dG	Delete from current line to end of file
dgg	Delete from current line to start of file
d{	Delete to previous empty line
d}	Delete to next empty line
diw	Delete inner word
daw	Delete word + surrounding space
di"	Delete inside double quotes
di(	Delete inside parentheses
diB	Delete inside curly braces
dip	Delete inner paragraph
dap	Delete paragraph including surrounding blank lines
Changing (delete + Insert)
Key	Action
cc	Change entire line
C	Change from cursor to end of line
cw	Change to next word start
ciw	Change inner word
caw	Change word + surrounding space
ci"	Change inside double quotes
ci(	Change inside parentheses
ci{	Change inside curly braces
ci[	Change inside square brackets
cit	Change inside HTML tag
cis	Change inner sentence
r{char}	Replace character under cursor with {char}
R	Enter Replace mode (overtype)
s	Delete character, enter Insert
S	Delete line, enter Insert
Copying and pasting
Key	Action
yy or Y	Yank current line
yw	Yank to next word start
y$	Yank to end of line
y0	Yank to start of line
yiw	Yank inner word
yi"	Yank inside double quotes
yip	Yank inner paragraph
Nyy	Yank N lines
p	Paste after cursor / below current line
P	Paste before cursor / above current line
gp	Paste after cursor, leave cursor after pasted text
gP	Paste before cursor, leave cursor after pasted text
"0p	Paste from yank register (not overwritten by delete)
"ap	Paste from named register a
"ayy	Yank line into register a
"+y	Yank to system clipboard
"+p	Paste from system clipboard
:reg	Show all registers
Undo, redo, repeat
Key	Action
u	Undo last change
U	Undo all changes on current line
Ctrl-r	Redo
.	Repeat last change — the most powerful key in Vim
:earlier 5m	Revert file to state 5 minutes ago
:later 5m	Move forward 5 minutes in undo history
Indentation
Key	Action
>>	Indent current line one shiftwidth
<<	Dedent current line one shiftwidth
N>>	Indent N lines
>j	Indent current line and line below
>%	Indent to matching bracket
>}	Indent to end of paragraph
=	Auto-indent (using cindent)
==	Auto-indent current line
=G	Auto-indent from cursor to end of file
gg=G	Auto-indent entire file
Case
Key	Action
~	Toggle case of character under cursor
g~iw	Toggle case of word under cursor
gUiw	Uppercase word
guiw	Lowercase word
gUU	Uppercase entire line
guu	Lowercase entire line
gU$	Uppercase to end of line
gu$	Lowercase to end of line
Search and replace

Vim

/pattern        " Search forward
?pattern        " Search backward
n               " Next match (same direction)
N               " Previous match (opposite direction)
*               " Search for word under cursor (forward, whole word)
#               " Search for word under cursor (backward, whole word)
g*              " Search for word under cursor (forward, partial match)
g#              " Search for word under cursor (backward, partial match)

:nohlsearch     " Clear search highlighting (also mapped to Esc in .vimrc)

" Substitute — the most important Ex command
:s/old/new/           " Replace first match on current line
:s/old/new/g          " Replace all on current line
:%s/old/new/g         " Replace all in entire file
:%s/old/new/gc        " Replace all with confirmation
:5,10s/old/new/g      " Replace in lines 5 to 10
:'<,'>s/old/new/g     " Replace in visual selection

" Flags
" g  global (all matches per line)
" c  confirm each replacement
" i  case-insensitive
" I  case-sensitive
" e  do not error if no match

" Whole-word match only
:%s/\<word\>/new/g

" Capture groups and back-references
:%s/\(foo\) \(bar\)/\2 \1/g    " Swap 'foo bar' to 'bar foo'

" Special replacements
:%s/\s\+$//e          " Remove trailing whitespace
:%s/\t/    /g         " Replace tabs with 4 spaces
:%s/\r//g             " Remove Windows CRLF (^M)
:%s/^/\=line('.').'. '/ " Number all lines

" Count matches without replacing
:%s/pattern//gn

Visual mode
Key	Action
v	Start character-wise visual
V	Start line-wise visual
Ctrl-v	Start block-wise visual
gv	Reselect last visual selection
o	Move to other end of selection
O	Move to other corner (block mode only)

Operations on selection:
Key	Action
d or x	Delete selection
y	Yank selection
c	Change selection
>	Indent selection
<	Dedent selection
=	Auto-indent selection
U	Uppercase selection
u	Lowercase selection
~	Toggle case of selection
!{cmd}	Filter selection through shell command
I	Insert at start of each line (block mode)
A	Append at end of each line (block mode)
Registers
Register	Contents
""	Unnamed — last delete or yank
"0	Last yank — not overwritten by delete
"1 to "9	Last 9 deletions (rotating history)
"a to "z	Named — you control these explicitly
"A to "Z	Append to named register
"+	System clipboard
"*	Primary selection (Linux middle-click)
"%	Current filename
".	Last inserted text
":	Last command-line command
"/	Last search pattern
"=	Expression register

Vim

:registers          " Show all registers
:reg a              " Show register a

" In Insert or Command mode:
Ctrl-r a            " Insert contents of register a
Ctrl-r "            " Insert contents of unnamed register
Ctrl-r +            " Insert system clipboard
Ctrl-r =            " Insert result of expression (type expression, press Enter)

Macros

Vim

qa          " Start recording macro into register a
q           " Stop recording
@a          " Play back macro a
@@          " Replay last macro
10@a        " Play macro a 10 times
@:          " Repeat last command-line command

" Edit a macro:
" 1. Paste it: "ap
" 2. Edit the text
" 3. Yank it back: "ayy

" Apply macro to lines 5-10:
:5,10normal @a

Buffers

Vim

:e filename     " Open file in current window
:ls             " List all open buffers
:buffers        " Same as :ls
:b N            " Switch to buffer number N
:b filename     " Switch to buffer by name (Tab completes)
:bn             " Next buffer
:bp             " Previous buffer
:b#             " Alternate (last used) buffer
:bd             " Close (delete) current buffer
:bd N           " Close buffer N
:bufdo cmd      " Run command on all open buffers

Windows (splits)

Vim

:sp filename        " Horizontal split, open filename
:vsp filename       " Vertical split, open filename
Ctrl-w s            " Split horizontally
Ctrl-w v            " Split vertically
Ctrl-w w            " Cycle to next window
Ctrl-w p            " Jump to previous window
Ctrl-w c            " Close current window (buffer stays open)
Ctrl-w o            " Close all other windows (:only)
Ctrl-w q            " Quit current window

" Move focus
Ctrl-w h            " Left window
Ctrl-w j            " Window below
Ctrl-w k            " Window above
Ctrl-w l            " Right window

" Move the window itself
Ctrl-w H            " Move window to far left
Ctrl-w J            " Move window to bottom
Ctrl-w K            " Move window to top
Ctrl-w L            " Move window to far right
Ctrl-w x            " Exchange with next window
Ctrl-w T            " Move window to new tab

" Resize
Ctrl-w =            " Make all windows equal size
Ctrl-w _            " Maximise height
Ctrl-w |            " Maximise width
Ctrl-w +            " Increase height by 1
Ctrl-w -            " Decrease height by 1
Ctrl-w >            " Increase width by 1
Ctrl-w <            " Decrease width by 1

Tabs

Vim

:tabnew filename    " Open file in new tab
:tabe filename      " Same as :tabnew
:tabn               " Next tab
:tabp               " Previous tab
gt                  " Next tab (Normal mode)
gT                  " Previous tab (Normal mode)
Ngt                 " Go to tab number N
:tabclose           " Close current tab
:tabonly            " Close all other tabs
:tabs               " List all tabs
:tabm N             " Move current tab to position N
:tab split          " Open current buffer in new tab
:tab drop filename  " Jump to file if already open, otherwise new tab
:tab ball           " Open all buffers in tabs

Built-in file explorer (netrw)

Vim

:Explore            " Open netrw in current window (:E also works)
:Sexplore           " Open in horizontal split
:Vexplore           " Open in vertical split

" Inside netrw:
Enter               " Open file or directory
-                   " Go up one directory
d                   " Create new directory
%                   " Create new file
D                   " Delete file or directory
R                   " Rename file or directory
p                   " Preview file in split
i                   " Cycle view style: thin / long / wide / tree
I                   " Toggle hidden files

:find with path+=**

When set path+=** is in your .vimrc, Vim searches recursively.

Vim

:find filename      " Find and open file anywhere in path
:find *.c           " Find any .c file
:find main*         " Find files starting with "main"
Tab                 " Autocomplete filename after :find

Quickfix and make

Vim

:make               " Run make (uses &makeprg setting)
:make re            " Run 'make re'
:make clean         " Run 'make clean'

:copen              " Open quickfix window
:cclose             " Close quickfix window
:cnext              " Jump to next error
:cprevious          " Jump to previous error
:cfirst             " Jump to first error
:clast              " Jump to last error
:cc N               " Jump to error number N

Ctags

Bash

# Generate tag file from terminal
ctags -R .
ctags -R --languages=C .

Vim

Ctrl-]              " Jump to definition of word under cursor
Ctrl-t              " Return from tag jump
:tag name           " Jump to tag 'name'
g]                  " List all tags for word (pick from list)
:tnext              " Next matching tag
:tprevious          " Previous matching tag
:tselect            " Select from tag list

Spell checking

Vim

:set spell                  " Enable spell checking
:set nospell                " Disable spell checking
:set spelllang=en_gb        " British English
:set spelllang=en_us        " American English

]s                          " Next misspelled word
[s                          " Previous misspelled word
z=                          " Show correction suggestions for word under cursor
zg                          " Add word to dictionary (mark as correct)
zw                          " Mark word as wrong
zug                         " Undo zg (remove word from dictionary)

Folding

Vim

za                  " Toggle fold under cursor
zo                  " Open fold
zc                  " Close fold
zO                  " Open fold and all sub-folds recursively
zC                  " Close fold and all parent folds
zR                  " Open all folds in file
zM                  " Close all folds in file
zj                  " Move to next fold
zk                  " Move to previous fold
[z                  " Move to start of current fold
]z                  " Move to end of current fold
zf{motion}          " Create a fold over motion (manual foldmethod)

Global command

Vim

:g/pattern/command        " Run command on every line matching pattern
:g!/pattern/command       " Run command on lines NOT matching pattern
:v/pattern/command        " Same as :g! (v = vglobal)

" Examples:
:g/^$/d               " Delete all blank lines
:g/TODO/p             " Print all TODO lines
:g/^#/d               " Delete all comment lines
:g/^\s*$/d            " Delete all blank or whitespace-only lines
:v/pattern/d          " Delete all lines NOT containing pattern
:g/pattern/y A        " Append all matching lines to register a

Filtering and external commands

Vim

:!command             " Run shell command and show output
:!make                " Run make
:r !command           " Insert output of command into buffer at cursor
:r !date              " Insert current date
:.!command            " Replace current line with output of command
:%!command            " Filter entire file through command
:'<,'>!command        " Filter visual selection through command
:%!sort               " Sort entire file
:%!python3 -m json.tool  " Format entire file as JSON

K                     " Look up word under cursor in man pages (very useful for C)

Insert mode completions
Key	Action
Ctrl-n	Next keyword completion
Ctrl-p	Previous keyword completion
Ctrl-x Ctrl-f	Filename completion
Ctrl-x Ctrl-l	Whole line completion
Ctrl-x Ctrl-]	Tag completion (requires ctags file)
Ctrl-x Ctrl-k	Dictionary completion
Ctrl-x Ctrl-n	Keyword completion (local buffer)
Ctrl-x Ctrl-o	Omni completion
Insert mode — other keys
Key	Action
Ctrl-o	Execute one Normal command then return to Insert
Ctrl-w	Delete word before cursor
Ctrl-u	Delete all characters on current line before cursor
Ctrl-r a	Insert contents of register a
Ctrl-r "	Insert unnamed register
Ctrl-r +	Insert system clipboard
Ctrl-r =	Insert result of expression
Ctrl-t	Indent current line one shiftwidth
Ctrl-d	Dedent current line one shiftwidth
Ctrl-v {char}	Insert character literally (e.g. Ctrl-v Tab inserts a real tab)
Ctrl-v {nnn}	Insert character by decimal ASCII code
Ctrl-v x{nn}	Insert character by hex code
Useful Ex commands

Vim

:sort               " Sort all lines
:sort u             " Sort and remove duplicates
:sort n             " Sort numerically
:sort!              " Sort in reverse

:retab              " Convert between tabs and spaces (uses current tabstop settings)
:retab!             " Force conversion

gq{motion}          " Reflow text to textwidth
gqq                 " Reflow current line
gqG                 " Reflow from cursor to end of file

Ctrl-a              " Increment number under cursor
Ctrl-x              " Decrement number under cursor

J                   " Join current line with line below (single space)
gJ                  " Join lines without adding space

ga                  " Show ASCII/Unicode code of character under cursor
g8                  " Show UTF-8 encoding of character under cursor

:set ff=unix        " Convert line endings to Unix (LF)
:set ff=dos         " Convert line endings to DOS (CRLF)

:%!xxd              " View file as hex dump
:%!xxd -r           " Convert hex dump back to binary

Settings — on the fly

Vim

:set number             " Show line numbers
:set nonumber           " Hide line numbers
:set relativenumber     " Show relative line numbers
:set number?            " Show current value of 'number'
:set all                " Show all settings and their values

:set wrap               " Wrap long lines
:set nowrap             " Do not wrap

:set hlsearch           " Highlight search results
:set nohlsearch         " No highlight
:set incsearch          " Show matches as you type

:set ignorecase         " Case-insensitive search
:set smartcase          " Case-insensitive unless pattern has uppercase

:set spell              " Enable spell checking
:set nospell            " Disable spell checking

:set list               " Show invisible characters (tabs, trailing spaces)
:set nolist             " Hide invisible characters

:set paste              " Enter paste mode (disables auto-indent)
:set nopaste            " Exit paste mode

:set tabstop=4          " Tab width
:set shiftwidth=4       " Indent width
:set expandtab          " Use spaces instead of tabs
:set noexpandtab        " Use real tabs

:syntax on              " Enable syntax highlighting
:syntax off             " Disable syntax highlighting

:help — built-in documentation

Vim

:help                   " Open help contents
:help {topic}           " Open help for topic
:help Ctrl-r            " Help for Normal mode Ctrl-r
:help i_Ctrl-r          " Help for Insert mode Ctrl-r
:help :substitute       " Help for :s command
:help text-objects      " Text object reference
:help motion            " Motion reference
:help operator          " Operator reference
:help registers         " Register reference
:help pattern           " Regex pattern reference
:help usr_41            " VimScript reference

" Inside help:
Ctrl-]                  " Follow link (tag jump)
Ctrl-o                  " Go back
:q                      " Close help window

Quick reference

text

OPEN/QUIT   vim file        :w   :wq   :q!   ZZ   ZQ

MODES       i/a/o/I/A/O    Esc    v/V/Ctrl-v    :

NAVIGATE    hjkl            w/b/e/W/B/E
            0/^/$           gg/G/NG         %
            f/t/F/T + ;/,   {/}  (/)        Ctrl-d/u

MARKS       ma  `a  'a      Ctrl-o/Ctrl-i   :jumps

DELETE      x  dd  D        dw  de  diw  di(  dip
CHANGE      cc  C  cw       ciw  ci(  ci"  ci{
YANK        yy  Y  yw       yiw  yi"
PASTE       p / P           "0p  "+p
UNDO        u / Ctrl-r      .  (repeat)

CASE        ~   gUiw  guiw  gUU  guu
INDENT      >>  <<  ==  gg=G

SEARCH      /pat  ?pat  n/N  *  #
REPLACE     :%s/old/new/g   :%s/old/new/gc  :s/old/new/g

VISUAL      v/V/Ctrl-v  o   d/y/c/>/</=  I/A (block)

TEXT OBJ    iw/aw  i(/a(  i{/a{  i[/a[  i"/a"  ip/ap  it/at

BUFFERS     :ls  :b N  :bn  :bp  :bd
WINDOWS     :sp  :vsp  Ctrl-w hjkl  Ctrl-w =/+/-
TABS        :tabnew  gt/gT  Ngt  :tabclose
EXPLORE     :E  :Sex  :Vex

MAKE        :make   :copen  :cnext  :cprev
TAGS        Ctrl-]  Ctrl-t  g]
SPELL       ]s  [s  z=  zg
FOLDS       za  zo  zc  zR  zM
MACROS      qa...q  @a  @@  10@a

COMPLETE    Ctrl-n/p   Ctrl-x Ctrl-f   Ctrl-x Ctrl-l
REGISTERS   :reg   "ayy  "ap   "+y  "+p   Ctrl-r a (Insert)
GLOBAL      :g/pat/d   :g/pat/p   :v/pat/d
EXTERNAL    :!cmd   :r !cmd   :%!cmd   K (man)

HELP        :help {topic}    :help text-objects    :help motion