# Bash Cheatsheet — built-in features and core shell tools.
# Native Linux tools. No external dependencies beyond standard coreutils.
# Every section includes fallbacks for when tools are missing or broken.

---

## Navigation

| Command | Action |
|---------|--------|
| `cd /path/to/dir` | Change directory |
| `cd` or `cd ~` | Go to home directory |
| `cd -` | Go to previous directory (`$OLDPWD`) |
| `cd ..` | Go up one directory |
| `pwd` | Print current directory |
| `pushd /path` | Change to directory and push current onto stack |
| `popd` | Return to directory on top of stack |
| `dirs -v` | Show directory stack with indices |

```bash
# pwd fallback
echo $PWD

# cd fallback (if cd is somehow broken — use the builtin explicitly)
builtin cd /path/to/dir
```

---

## Keyboard shortcuts

These use the default Emacs readline key bindings active in bash.

| Shortcut | Action |
|----------|--------|
| `Ctrl-a` | Move cursor to beginning of line |
| `Ctrl-e` | Move cursor to end of line |
| `Ctrl-f` | Move cursor forward one character |
| `Ctrl-b` | Move cursor backward one character |
| `Alt-f` | Move forward one word |
| `Alt-b` | Move backward one word |
| `Ctrl-d` | Delete character under cursor, or send EOF if line is empty |
| `Ctrl-h` | Delete character before cursor (backspace) |
| `Ctrl-w` | Delete word before cursor |
| `Alt-d` | Delete word after cursor |
| `Ctrl-k` | Delete from cursor to end of line |
| `Ctrl-u` | Delete from cursor to beginning of line |
| `Ctrl-y` | Paste (yank) last killed text |
| `Ctrl-t` | Transpose two characters around cursor |
| `Ctrl-l` | Clear screen (same as `clear`) |
| `Ctrl-c` | Interrupt (kill) current command |
| `Ctrl-z` | Suspend current command — resume with `fg` or `bg` |
| `Ctrl-r` | Reverse history search — type to filter |
| `Ctrl-s` | Forward history search (may need `stty -ixon` to enable) |
| `Ctrl-g` | Cancel history search without running anything |
| `Ctrl-p` | Previous command in history |
| `Ctrl-n` | Next command in history |
| `Ctrl-_` | Undo last edit (also `Ctrl-/` on some terminals) |
| `Alt-.` | Insert last argument of previous command |
| `Alt-u` | Uppercase from cursor to end of word |
| `Alt-l` | Lowercase from cursor to end of word |
| `Alt-r` | Revert all changes to a line pulled from history |
| `Tab` | Complete command or filename |
| `Tab Tab` | Show all possible completions |
| `Ctrl-x Ctrl-e` | Open current command in `$EDITOR` for editing |

---

## History

| Command | Action |
|---------|--------|
| `history` | Show command history with line numbers |
| `history N` | Show last N commands |
| `history -c` | Clear the history list |
| `!N` | Run command number N from history |
| `!!` | Run the previous command |
| `!string` | Run the most recent command starting with string |
| `!?string?` | Run the most recent command containing string |
| `!$` | Last argument of the previous command |
| `!*` | All arguments of the previous command |
| `!^` | First argument of the previous command |
| `^old^new` | Repeat previous command replacing old with new |

```bash
# Persist large history across sessions — add to ~/.bashrc
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# history fallback: read the file directly
cat ~/.bash_history
tail -50 ~/.bash_history
```

---

## Listing files and directories

```bash
# Standard
ls
ls -l
ls -la               # Include hidden files
ls -lh               # Human-readable sizes
ls -lt               # Sort by modification time, newest first
ls -lS               # Sort by size, largest first
ls -R                # Recursive listing

# ── ls fallbacks ─────────────────────────────────────────────────────────────

# List all files and directories in current directory
echo *
echo .*              # Hidden files only
printf "%s\n" *      # One per line
printf "%s\n" * .*   # All including hidden, one per line

# Distinguish files from directories
for f in * .*; do
    [ -d "$f" ] && echo "DIR  $f" || echo "FILE $f"
done

# List only directories
for d in */; do echo "$d"; done
# Or with find:
find . -maxdepth 1 -type d

# List only regular files
for f in *; do [ -f "$f" ] && echo "$f"; done
# Or with find:
find . -maxdepth 1 -type f

# List hidden files only
for f in .*; do echo "$f"; done

# List with sizes (bytes)
find . -maxdepth 1 -type f -exec wc -c {} \; | awk '{print $1, $2}'

# List with modification time
find . -maxdepth 1 -printf "%TY-%Tm-%Td %TH:%TM  %p\n" | sort

# dir command — GNU coreutils alternative to ls, usually installed alongside it
dir
dir -la
```

---

## Directory tree

```bash
# tree — if installed
tree
tree -L 2            # Limit depth to 2 levels
tree -d              # Directories only
tree -a              # Include hidden files

# ── tree fallbacks ────────────────────────────────────────────────────────────

# Basic tree using find and sed
find . | sed -e 's|[^/]*/|- |g'

# Better indentation
find . | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"

# Directories only (like tree -d)
find . -type d | sed -e 's|[^/]*/|- |g'

# Limit depth (like tree -L 2)
find . -maxdepth 2 | sed -e 's|[^/]*/|- |g'

# Tree with awk — shows indentation proportional to depth
find . | awk -F/ '{
    indent=""
    for (i = 2; i < NF; i++) indent = indent "  "
    print indent $NF
}'

# Tree using ls -R
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'

# Tree with file sizes
find . -type f | while IFS= read -r f; do
    depth=$(echo "$f" | tr -cd '/' | wc -c)
    pad=$(printf "%$((depth * 2))s")
    size=$(wc -c < "$f" 2>/dev/null)
    printf "%s%s [%d bytes]\n" "$pad" "$(basename "$f")" "$size"
done
```

---

## Viewing files

```bash
# Standard
cat file
cat -n file          # With line numbers
less file
more file
head file            # First 10 lines
head -n N file       # First N lines
tail file            # Last 10 lines
tail -n N file       # Last N lines
tail -f file         # Follow — print new lines as they appear
tail -F file         # Follow and reopen if file is rotated

# ── cat fallbacks ─────────────────────────────────────────────────────────────

# Print entire file without cat
sed -n 'p' file
sed '' file
awk '{print}' file
awk 1 file
while IFS= read -r line; do echo "$line"; done < file

# With line numbers (like cat -n)
awk '{print NR": "$0}' file
grep -n "" file
nl file                    # nl is usually available

# Print file in reverse (like tac)
awk '{lines[NR]=$0} END{for(i=NR;i>=1;i--) print lines[i]}' file
sed -n '1!G;h;$p' file

# ── head fallbacks ────────────────────────────────────────────────────────────

awk 'NR<=10' file
sed -n '1,10p' file

# ── tail fallbacks ────────────────────────────────────────────────────────────

# Last N lines with awk (N=10)
awk '{lines[NR%10]=$0} END{for(i=NR+1;i<=NR+10;i++) print lines[i%10]}' file
# Or simpler with a buffer:
awk 'NR>10{print prev[NR%10]} {prev[NR%10]=$0} END{for(i=1;i<=10;i++) if(prev[(NR+i)%10]) print prev[(NR+i)%10]}' file

# ── less / more fallbacks ────────────────────────────────────────────────────

# Page through file manually
# (outputs 24 lines at a time and waits for Enter)
awk 'NR%24==0{system("read -p \"-- more --\""); printf "\r            \r"} {print}' file

# Print a specific line number
awk 'NR==42' file
sed -n '42p' file

# Print lines between two patterns
sed -n '/START/,/END/p' file
awk '/START/,/END/' file

# Print without first line
awk 'NR>1' file
sed '1d' file

# Print without last line
awk 'NR>1{print prev} {prev=$0}' file
sed '$d' file
```

**less key bindings:**

| Key | Action |
|-----|--------|
| `q` | Quit |
| `Space` / `f` | Next page |
| `b` | Previous page |
| `g` | First line |
| `G` | Last line |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `-N` | Toggle line numbers |
| `-i` | Toggle case-insensitive search |

---

## Searching text

```bash
# Standard grep
grep "pattern" file
grep -r "pattern" .              # Recursive
grep -i "pattern" file           # Case-insensitive
grep -n "pattern" file           # Show line numbers
grep -v "pattern" file           # Lines NOT matching
grep -l "pattern" *.c            # Filenames with matches
grep -L "pattern" *.c            # Filenames WITHOUT matches
grep -c "pattern" file           # Count matching lines
grep -w "word" file              # Whole word match
grep -E "foo|bar" file           # Extended regex
grep -F "literal.string" file    # Fixed string — no regex
grep -A 3 "pattern" file         # 3 lines after match
grep -B 3 "pattern" file         # 3 lines before match
grep -C 3 "pattern" file         # 3 lines around match
grep -q "pattern" file && echo "found"
grep -rn "pattern" . --include="*.c"
grep -rn "pattern" . --exclude-dir=".git"

# ── grep fallbacks ────────────────────────────────────────────────────────────

# Print matching lines with awk
awk '/pattern/' file

# Print matching lines with line numbers
awk '/pattern/{print NR": "$0}' file

# Print matching lines with sed
sed -n '/pattern/p' file

# Invert match (like grep -v)
awk '!/pattern/' file
sed -n '/pattern/!p' file

# Count occurrences (like grep -c)
awk '/pattern/{count++} END{print count}' file

# Case-insensitive match with awk
awk 'tolower($0) ~ /pattern/' file

# Print filename and line number across multiple files
find . -name "*.c" -exec awk '/pattern/{print FILENAME":"NR": "$0}' {} \;

# Search and print 2 lines of context (poor man's grep -A 2)
awk '/pattern/{print; for(i=1;i<=2;i++) {if((getline line)>0) print line}}' file

# Find files containing pattern without grep -l
find . -type f | while IFS= read -r f; do
    grep -q "pattern" "$f" 2>/dev/null && echo "$f"
done
```

---

## Finding files

```bash
# Standard find
find . -name "*.c"
find . -iname "readme.md"        # Case-insensitive
find . -type f                   # Regular files only
find . -type d                   # Directories only
find . -type l                   # Symbolic links only
find . -mtime -1                 # Modified in last 24 hours
find . -mtime +7                 # Modified more than 7 days ago
find . -mmin -30                 # Modified in last 30 minutes
find . -newer reference.c        # Newer than a reference file
find . -size +1M                 # Larger than 1 MB
find . -size -100k               # Smaller than 100 KB
find . -perm /111                # Any execute bit set
find . -name "*.c" -not -path "./.git/*"
find . -name "*.o" -delete
find . -name "*.c" -exec grep -l "malloc" {} +
find . -name "*.o" -exec rm {} +
find . -maxdepth 2 -name "*.c"
find . -mindepth 1 -maxdepth 1 -type d
find . -empty -type f
find . -name "*.c" | wc -l

# ── find fallbacks ────────────────────────────────────────────────────────────

# List all files recursively when find is missing
# Requires: shopt -s globstar (bash 4+)
shopt -s globstar
for f in **/*; do echo "$f"; done
for f in **/*.c; do echo "$f"; done

# Find files by extension using shell glob recursion
for f in **/*.c; do
    grep -q "malloc" "$f" && echo "$f"
done

# Find files modified in last 24h using stat and awk
for f in $(find . -type f 2>/dev/null); do
    modified=$(stat -c%Y "$f" 2>/dev/null)
    now=$(date +%s)
    [ $((now - modified)) -lt 86400 ] && echo "$f"
done
```

---

## Disk usage

```bash
# Standard
du -sh .             # Total size of current directory
du -sh */            # Size of each subdirectory
du -ah . | sort -rh | head -20   # Top 20 largest items
df -h                # Free disk space on all filesystems
df -i                # Inode usage

# ── du fallbacks ─────────────────────────────────────────────────────────────

# Size of a single file in bytes
wc -c < filename
stat -c%s filename
find . -name "filename" -printf "%s\n"

# Total size of all .c files
find . -name "*.c" -exec wc -c {} + | tail -1

# Size of all files in current directory, sorted
find . -maxdepth 1 -type f -exec wc -c {} + | sort -n

# Find files larger than 10MB without du
find . -type f -size +10M

# Find largest files with sizes (bytes)
find . -type f -printf "%s\t%p\n" | sort -rn | head -20

# Find empty files
find . -type f -empty

# ── df fallbacks ──────────────────────────────────────────────────────────────

# Read disk info from /proc
cat /proc/mounts
# Sizes are in 512-byte blocks — multiply block count by 512 for bytes
awk 'NR>1{print $1, $2, $3}' /proc/mounts
```

---

## Processes

```bash
# Standard
ps aux
ps aux --sort=-%cpu  # Sort by CPU usage
ps aux --sort=-%mem  # Sort by memory usage
ps axjf              # Process tree
ps -u $USER          # Processes for current user only
top

# ── ps / top fallbacks ────────────────────────────────────────────────────────

# List all running processes from /proc (no ps needed)
for pid in /proc/[0-9]*/; do
    pid="${pid%/}"
    pid="${pid##*/}"
    cmd=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')
    [ -n "$cmd" ] && echo "$pid  $cmd"
done

# Show a specific process
cat /proc/PID/status
cat /proc/PID/cmdline | tr '\0' ' '

# Show all open file descriptors for a process
ls /proc/PID/fd

# Poor man's top (refreshes every 2 seconds)
while true; do
    clear
    # Read CPU stats from /proc/stat
    echo "=== $(date) ==="
    grep "cpu " /proc/stat
    echo ""
    # Show top processes by reading /proc
    for pid in /proc/[0-9]*/; do
        pid="${pid%/}"; pid="${pid##*/}"
        cmd=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | cut -c1-50)
        mem=$(awk '/VmRSS/{print $2}' /proc/$pid/status 2>/dev/null)
        [ -n "$cmd" ] && printf "%6s %8s KB  %s\n" "$pid" "$mem" "$cmd"
    done | sort -k2 -rn | head -20
    sleep 2
done

# Kill by name without killall
ps aux | awk '/processname/ && !/awk/{print $2}' | xargs kill

# Check if process is running
ps aux | grep -q "processname" && echo "running" || echo "not running"
# Or from /proc:
for pid in /proc/[0-9]*/cmdline; do
    grep -q "processname" "$pid" 2>/dev/null && echo "running: $pid"
done
```

| Command | Action |
|---------|--------|
| `kill PID` | Send SIGTERM — ask process to stop |
| `kill -9 PID` | Send SIGKILL — force terminate |
| `kill -l` | List all signal names and numbers |
| `pkill name` | Kill by process name |
| `pgrep name` | Find PIDs by process name |
| `jobs` | List background jobs in current shell |
| `fg` | Bring most recent background job to foreground |
| `fg %N` | Bring job number N to foreground |
| `bg` | Resume most recent suspended job in background |
| `command &` | Run command in background |
| `disown` | Remove most recent job from job table |
| `disown PID` | Remove specific job — keeps running after logout |
| `nohup command &` | Run immune to hangup signal |
| `Ctrl-z` | Suspend current foreground job |
| `wait` | Wait for all background jobs to finish |
| `wait PID` | Wait for a specific process |
| `echo $$` | PID of current shell |
| `echo $!` | PID of last background command |

---

## Redirection and pipes

| Syntax | Action |
|--------|--------|
| `command > file` | Redirect stdout to file (overwrite) |
| `command >> file` | Redirect stdout to file (append) |
| `command < file` | Read stdin from file |
| `command 2> file` | Redirect stderr to file |
| `command 2>&1` | Redirect stderr to same place as stdout |
| `command > file 2>&1` | Redirect both stdout and stderr to file |
| `command &> file` | Redirect both stdout and stderr (bash shorthand) |
| `command > /dev/null` | Discard stdout |
| `command > /dev/null 2>&1` | Discard all output |
| `cmd1 \| cmd2` | Pipe stdout of cmd1 to stdin of cmd2 |
| `cmd1 \|& cmd2` | Pipe stdout and stderr of cmd1 to cmd2 |
| `tee file` | Write stdin to file AND stdout simultaneously |
| `tee -a file` | Same but append to file |
| `cmd 2>&1 \| tee file` | Log to file and display on screen |
| `diff <(cmd1) <(cmd2)` | Process substitution — compare outputs |

```bash
# tee fallback
command | while IFS= read -r line; do
    echo "$line"
    echo "$line" >> file
done

# Here document — write multiline input to a command
cat > file.txt << 'EOF'
line 1
line 2
line 3
EOF

# Here string — pass a string as stdin
grep "pattern" <<< "some string to search"
awk '{print $1}' <<< "hello world"
```

---

## Variables and expansions

| Syntax | Action |
|--------|--------|
| `VAR=value` | Assign variable — no spaces around `=` |
| `export VAR=value` | Assign and export to child processes |
| `unset VAR` | Remove variable |
| `echo $VAR` | Print variable value |
| `echo "${VAR}"` | Print value — always quote to avoid word splitting |
| `${VAR:-default}` | Use default if VAR is unset or empty |
| `${VAR:=default}` | Assign default and use it if VAR is unset |
| `${VAR:?message}` | Print message and exit if VAR is unset |
| `${VAR:+word}` | Return word if VAR is set, otherwise empty |
| `${#VAR}` | Length of VAR |
| `${VAR:N:M}` | Substring: M characters starting at position N |
| `${VAR#pattern}` | Remove shortest prefix match |
| `${VAR##pattern}` | Remove longest prefix match |
| `${VAR%pattern}` | Remove shortest suffix match |
| `${VAR%%pattern}` | Remove longest suffix match |
| `${VAR/old/new}` | Replace first occurrence |
| `${VAR//old/new}` | Replace all occurrences |
| `${VAR^^}` | Convert to uppercase (bash 4+) |
| `${VAR,,}` | Convert to lowercase (bash 4+) |
| `$(command)` | Command substitution — preferred |
| `` `command` `` | Command substitution — legacy |
| `$((expr))` | Arithmetic expansion |
| `$((16#FF))` | Convert hex FF to decimal |
| `$((2#1111))` | Convert binary to decimal |

**Special variables:**

| Variable | Value |
|----------|-------|
| `$0` | Script name |
| `$1` … `$9` | Positional parameters |
| `$#` | Number of arguments |
| `$@` | All arguments as separate words |
| `$*` | All arguments as a single string |
| `$?` | Exit code of last command |
| `$$` | PID of current shell |
| `$!` | PID of last background command |
| `$HOME` | Home directory |
| `$PWD` | Current directory |
| `$OLDPWD` | Previous directory |
| `$PATH` | Command search path |
| `$SHELL` | Current shell |
| `$USER` | Current username |
| `$HOSTNAME` | Machine hostname |
| `$SECONDS` | Seconds since shell started |
| `$LINENO` | Current line number in script |
| `$BASH_SOURCE` | Path to current script file |

---

## Arrays

```bash
# Indexed array
arr=("a" "b" "c")
arr[3]="d"
echo ${arr[0]}            # First element
echo ${arr[-1]}           # Last element (bash 4.3+)
echo ${arr[@]}            # All elements
echo ${#arr[@]}           # Number of elements
arr+=("e")                # Append
unset arr[1]              # Remove element at index 1
echo "${arr[@]:1:2}"      # Slice: 2 elements from index 1

# Iterate
for item in "${arr[@]}"; do echo "$item"; done

# Split string into array on delimiter
IFS=',' read -ra parts <<< "a,b,c,d"

# Join array with delimiter
IFS=','; echo "${arr[*]}"

# Associative array (bash 4+)
declare -A map
map["key"]="value"
echo ${map["key"]}
echo ${!map[@]}           # All keys
echo ${map[@]}            # All values
```

---

## Arithmetic

```bash
# Integer arithmetic — bash built-in
echo $((2 + 3))
echo $((10 / 3))          # Integer division
echo $((10 % 3))          # Modulo
echo $((2 ** 8))          # Power: 256
((var++))
((var--))
((var += 5))

# Floating point — awk (no bc needed)
awk 'BEGIN { print 10 / 3 }'
awk 'BEGIN { printf "%.4f\n", 10 / 3 }'
awk 'BEGIN { print sqrt(144) }'
awk 'BEGIN { print 2 ^ 10 }'
awk 'BEGIN { print sin(3.14159 / 2) }'
awk 'BEGIN { print log(100) }'

# ── bc fallbacks ─────────────────────────────────────────────────────────────

# If bc is missing, use awk for all floating-point calculations
awk "BEGIN { printf \"%.2f\n\", $a + $b }"
awk "BEGIN { print $x * $y }"

# Convert between bases
printf "%x\n" 255          # Decimal to hex: ff
printf "%d\n" 0xFF         # Hex to decimal: 255
echo $((16#FF))            # Hex to decimal (bash): 255
echo $((2#11111111))       # Binary to decimal: 255
# Decimal to binary without bc:
n=255
for i in 7 6 5 4 3 2 1 0; do
    printf "%d" $(( (n >> i) & 1 ))
done
echo
```

---

## Control flow

```bash
# if / elif / else
if [[ condition ]]; then
    commands
elif [[ condition ]]; then
    commands
else
    commands
fi

# Inline
[[ -f file ]] && echo "exists" || echo "missing"

# for loop
for i in 1 2 3; do echo "$i"; done
for i in {1..10}; do echo "$i"; done
for f in *.c; do echo "$f"; done

# C-style for loop
for ((i = 0; i < 10; i++)); do echo "$i"; done

# while loop
while IFS= read -r line; do echo "$line"; done < file

# Read multiple fields per line
while IFS=: read -r user pass uid gid info home shell; do
    echo "$user -> $shell"
done < /etc/passwd

# until loop
until [[ condition ]]; do commands; done

# case statement
case "$variable" in
    "option1")
        echo "option 1" ;;
    "option2" | "option3")
        echo "option 2 or 3" ;;
    *.c)
        echo "C source file" ;;
    *)
        echo "default" ;;
esac

# Loop with break and continue
for i in {1..10}; do
    [ $i -eq 5 ] && continue   # Skip 5
    [ $i -eq 8 ] && break      # Stop at 8
    echo $i
done

# Loop over output of a command
while IFS= read -r line; do
    echo "Processing: $line"
done < <(find . -name "*.c")

# select menu
select choice in "Option A" "Option B" "Quit"; do
    case $choice in
        "Option A") echo "A" ;;
        "Quit") break ;;
    esac
done
```

---

## Test conditions

```bash
# String tests
[[ -z "$s" ]]        # Empty string
[[ -n "$s" ]]        # Non-empty string
[[ "$a" == "$b" ]]   # Equal
[[ "$a" != "$b" ]]   # Not equal
[[ "$a" < "$b" ]]    # Lexicographically less
[[ "$s" == *glob* ]] # Glob match
[[ "$s" =~ regex ]]  # Regex match

# Integer tests
[[ "$a" -eq "$b" ]]  # Equal
[[ "$a" -ne "$b" ]]  # Not equal
[[ "$a" -lt "$b" ]]  # Less than
[[ "$a" -le "$b" ]]  # Less than or equal
[[ "$a" -gt "$b" ]]  # Greater than
[[ "$a" -ge "$b" ]]  # Greater than or equal

# File tests
[[ -e "file" ]]   # Exists
[[ -f "file" ]]   # Regular file
[[ -d "file" ]]   # Directory
[[ -L "file" ]]   # Symbolic link
[[ -r "file" ]]   # Readable
[[ -w "file" ]]   # Writable
[[ -x "file" ]]   # Executable
[[ -s "file" ]]   # Non-empty (size > 0)
[[ -p "file" ]]   # Named pipe

# Compound
[[ cond1 && cond2 ]]
[[ cond1 || cond2 ]]
[[ ! condition ]]

# Test if a command exists
command -v gcc > /dev/null 2>&1 && echo "gcc available"
type -t ls           # Returns: file, alias, function, or builtin

# Test if a function is defined
declare -f function_name > /dev/null && echo "function exists"

# Test if a variable is set
[[ -v VAR ]] && echo "VAR is set"
```

---

## Functions

```bash
# Define a function
my_function() {
    local arg1="$1"
    local arg2="${2:-10}"    # Default value if not provided
    echo "Got: ${arg1}, ${arg2}"
    return 0                 # 0 = success, non-zero = error
}

my_function "hello" "world"
result=$(my_function "hello")

# Pass all arguments to another command
wrapper() { some_command "$@"; }

# Remove a function
unset -f my_function

# List all defined functions
declare -f     # With bodies
declare -F     # Names only
```

---

## Script best practices

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Get the directory where the script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cleanup on exit
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

# Die with a message
die() { echo "ERROR: $*" >&2; exit 1; }

# Require a command — check before using any external tool
require() {
    command -v "$1" > /dev/null 2>&1 || die "Required command not found: $1"
}

require gcc
require make

# Debug mode
set -x       # Print each command before executing
set +x       # Stop debug mode
bash -n script.sh   # Check syntax only, do not run
bash -x script.sh   # Run with full trace
```

---

## Signals and traps

```bash
trap "rm -f /tmp/myfile" EXIT         # Run on any exit
trap "echo 'Interrupted'; exit 1" INT # Run on Ctrl-c
trap 'echo "Error on line $LINENO"' ERR
trap "" PIPE                           # Ignore SIGPIPE
trap - INT                             # Reset to default

# Send a signal
kill -TERM PID
kill -9 PID
kill -l                                # List all signals
```

---

## sed

```bash
sed 's/old/new/' file            # Replace first occurrence per line
sed 's/old/new/g' file           # Replace all occurrences
sed -i 's/old/new/g' file        # Edit file in place
sed -i.bak 's/old/new/g' file    # In place with backup
sed 's|/old/path|/new/path|g' file   # Alternative delimiter
sed '/pattern/d' file            # Delete matching lines
sed '/^$/d' file                 # Delete blank lines
sed '/^#/d' file                 # Delete comment lines
sed -n '5p' file                 # Print line 5 only
sed -n '5,10p' file              # Print lines 5 to 10
sed -n '/START/,/END/p' file     # Between two patterns
sed '5i\new line before' file    # Insert before line 5
sed '5a\new line after' file     # Insert after line 5
sed 's/^[[:space:]]*//' file     # Remove leading whitespace
sed 's/[[:space:]]*$//' file     # Remove trailing whitespace
sed 's/\r$//' file               # Remove Windows CRLF
sed -e 's/foo/bar/g' -e 's/baz/qux/g' file   # Multiple operations
sed 's/^/PREFIX: /' file         # Prepend to every line
sed 's/$/ SUFFIX/' file          # Append to every line

# ── sed fallbacks (pure bash) ─────────────────────────────────────────────────

# Replace string in variable
echo "${var//old/new}"

# Replace in file using bash read loop (slow but zero dependencies)
while IFS= read -r line; do
    echo "${line//old/new}"
done < file > file.new && mv file.new file

# Delete blank lines using awk
awk 'NF' file
awk NF file
```

---

## awk

```bash
awk '{print $1}' file            # First field (space-separated)
awk '{print $NF}' file           # Last field
awk -F: '{print $1}' /etc/passwd # Custom separator
awk -F: 'BEGIN{OFS="|"} {print $1,$3}' /etc/passwd
awk '{print NR, $0}' file        # With line numbers
awk '$3 > 100' file              # Conditional
awk '$1 == "ERROR" {print NR, $0}' log.txt
awk '{sum += $1} END {print sum}' file        # Sum
awk '{sum += $1; n++} END {print sum/n}' file # Average
awk '/pattern/{count++} END{print count}' file
awk '/START/,/END/' file         # Between two patterns
awk 'NR > 1' file                # Skip header
awk '!seen[$0]++' file           # Remove duplicates (preserve order)
awk '{count[$1]++} END{for(w in count) print count[w], w}' file
awk '{printf "%-20s %5d\n", $1, $2}' file

# ── awk fallbacks ─────────────────────────────────────────────────────────────
# If awk is missing, use bash read loops

# Print first field
while IFS=' ' read -ra fields; do echo "${fields[0]}"; done < file

# Print with line numbers
i=0; while IFS= read -r line; do ((i++)); echo "$i: $line"; done < file

# Sum first column
sum=0
while IFS= read -r line; do
    num="${line%% *}"
    sum=$((sum + num))
done < file
echo $sum
```

---

## sort, cut, tr, uniq

```bash
# sort
sort file                         # Alphabetical
sort -r file                      # Reverse
sort -n file                      # Numeric
sort -rn file                     # Reverse numeric
sort -k2 file                     # By field 2
sort -k2n file                    # By field 2 numerically
sort -t: -k3n /etc/passwd         # By field 3, colon separator
sort -u file                      # Remove duplicates
sort -h file                      # Human-readable sizes (1K, 10M)
sort --check file                 # Check if already sorted

# cut
cut -c1-10 file                   # Characters 1 to 10
cut -d: -f1 /etc/passwd           # First field, colon separator
cut -d: -f1,3 /etc/passwd         # Fields 1 and 3
cut -d: -f2- /etc/passwd          # From field 2 to end
cut -d, -f2 file.csv

# ── cut fallbacks ─────────────────────────────────────────────────────────────
awk -F: '{print $1}' /etc/passwd        # cut -d: -f1
awk '{print substr($0,1,10)}' file      # cut -c1-10
awk '{print $2}' file                   # cut -d' ' -f2

# tr
tr 'a-z' 'A-Z' < file
tr '[:lower:]' '[:upper:]' < file
tr -d '\n' < file                 # Remove newlines
tr -d '[:space:]' < file          # Remove all whitespace
tr -s ' ' < file                  # Collapse multiple spaces
tr '\n' ' ' < file                # Newlines to spaces

# ── tr fallbacks ──────────────────────────────────────────────────────────────
# Uppercase with bash parameter expansion (bash 4+)
echo "${var^^}"
# Uppercase with awk
awk '{print toupper($0)}' file
# Remove characters with sed
sed 's/[0-9]//g' file             # Remove digits
sed 's/[[:space:]]//g' file       # Remove all whitespace

# uniq
sort file | uniq                  # Remove consecutive duplicates
sort file | uniq -d               # Duplicate lines only
sort file | uniq -u               # Unique lines only
sort file | uniq -c               # Count occurrences
sort file | uniq -c | sort -rn    # Most frequent first

# ── uniq fallbacks ────────────────────────────────────────────────────────────
# Remove duplicates preserving order (no sort needed)
awk '!seen[$0]++' file
# Count occurrences without uniq
awk '{count[$0]++} END{for(l in count) print count[l], l}' file | sort -rn
```

---

## xargs

```bash
find . -name "*.o" | xargs rm
find . -name "*.c" | xargs -L 1 wc -l
find . -name "*.c" | xargs -P 4 -L 1 gcc -c
find . -name "*.c" | xargs -I{} cp {} /backup/
find . -name "*.c" -print0 | xargs -0 rm       # Safe for spaces in names
find . -name "*.o" | xargs -t rm               # Dry run — show commands

# ── xargs fallbacks ───────────────────────────────────────────────────────────
# Use a while loop instead
find . -name "*.c" | while IFS= read -r f; do
    wc -l "$f"
done

find . -name "*.c" | while IFS= read -r f; do
    cp "$f" /backup/
done
```

---

## tar and compression

```bash
# Create archives
tar -czf archive.tar.gz  directory/   # gzip
tar -cjf archive.tar.bz2 directory/  # bzip2
tar -cJf archive.tar.xz  directory/  # xz (best compression)
tar -cf  archive.tar     directory/   # uncompressed

# Extract archives
tar -xzf archive.tar.gz
tar -xjf archive.tar.bz2
tar -xJf archive.tar.xz
tar -xf  archive.tar
tar -xzf archive.tar.gz -C /dest/    # Extract to specific directory

# List contents without extracting
tar -tzf archive.tar.gz

# ── compression fallbacks ─────────────────────────────────────────────────────

# cpio — very native, usually available even when tar is not
find . | cpio -o > archive.cpio       # Create
cpio -i < archive.cpio                # Extract

# split large files without compression tools
split -b 100M largefile part_
cat part_* > largefile                # Rejoin

# gzip a single file
gzip file                 # Replaces file with file.gz
gzip -k file              # Keep original
gzip -d file.gz           # Decompress
zcat file.gz              # Read without decompressing

# View compressed without extracting
zcat file.gz
bzcat file.bz2
```

---

## Networking

```bash
# ss — socket statistics (replaces netstat)
ss -tulpn                  # TCP+UDP listening, numeric, with process
ss -tn state established   # Established connections
ss -s                      # Summary statistics

# ── ss / netstat fallbacks ────────────────────────────────────────────────────

# Read raw socket info from /proc (always available)
cat /proc/net/tcp          # TCP connections (hex format)
cat /proc/net/tcp6         # TCP6
cat /proc/net/udp          # UDP

# Decode hex ports from /proc/net/tcp
awk 'NR>1 {print $2}' /proc/net/tcp | awk -F: '{printf "%d\n", "0x"$2}' | sort -nu

# Find listening ports from /proc/net/tcp
# State 0A = LISTEN in hex
awk '$4 == "0A" {print $2}' /proc/net/tcp | awk -F: '{printf "%d\n", "0x"$2}' | sort -nu

# Check if a port is open — bash /dev/tcp (no nmap, nc, or ss needed)
(echo > /dev/tcp/host/port) 2>/dev/null && echo "open" || echo "closed"
(echo > /dev/tcp/localhost/8080) 2>/dev/null && echo "open"

# Make an HTTP request — bash /dev/tcp (no curl or wget needed)
exec 3<>/dev/tcp/example.com/80
printf "GET / HTTP/1.0\r\nHost: example.com\r\nConnection: close\r\n\r\n" >&3
cat <&3
exec 3>&-

# Check connectivity without ping
(echo > /dev/tcp/8.8.8.8/53) 2>/dev/null && echo "network ok"

# DNS lookup without dig or nslookup
getent hosts google.com
cat /etc/hosts

# Network interfaces without ip or ifconfig
cat /proc/net/dev              # Interface statistics
cat /proc/net/if_inet6         # IPv6 addresses
cat /proc/net/fib_trie         # Routing info (hard to read)

# curl
curl https://example.com
curl -o file https://example.com/file
curl -O https://example.com/file.tar.gz
curl -L https://example.com                # Follow redirects
curl -I https://example.com                # Headers only
curl -v https://example.com                # Verbose
curl -s https://example.com                # Silent
curl -C - -O https://example.com/file      # Resume download
curl --limit-rate 1M https://example.com/file
curl -u user:pass https://example.com
curl -H "Authorization: Bearer TOKEN" https://api.example.com
curl -k https://self-signed.example.com    # Skip TLS check (INSECURE)
curl -X POST -H "Content-Type: application/json" \
     -d '{"key":"value"}' https://api.example.com/endpoint
curl -w "\nHTTP: %{http_code}  Time: %{time_total}s\n" -s -o /dev/null https://example.com

# wget
wget https://example.com/file.zip
wget -O output.zip https://example.com/file.zip
wget -q https://example.com/file.zip        # Quiet
wget -c https://example.com/file.zip        # Resume
wget --tries=10 https://example.com/file
wget -i url_list.txt                         # Download from file of URLs
```

---

## System information

```bash
# Hardware and OS
uname -a                      # Kernel version and architecture
cat /etc/os-release           # Distribution info
cat /proc/version             # Kernel and compiler info
cat /proc/cpuinfo             # CPU details
grep -c "processor" /proc/cpuinfo   # CPU count
cat /proc/meminfo             # Memory details
free -h                       # Memory usage — human-readable

# ── free / memory fallbacks ───────────────────────────────────────────────────
# Always available via /proc
awk '/MemTotal/{print "Total:", $2/1024, "MB"}
     /MemAvailable/{print "Available:", $2/1024, "MB"}
     /SwapTotal/{print "Swap total:", $2/1024, "MB"}' /proc/meminfo

# ── uptime fallbacks ──────────────────────────────────────────────────────────
uptime
cat /proc/uptime              # Seconds since boot (raw)
awk '{print int($1/86400)"d", int(($1%86400)/3600)"h", int(($1%3600)/60)"m"}' /proc/uptime

# ── date fallbacks ────────────────────────────────────────────────────────────
date
date +"%Y-%m-%d %H:%M:%S"
date +%s                      # Unix timestamp
# Read from /proc (shows boot time offset, not wall clock)
cat /proc/driver/rtc 2>/dev/null || cat /proc/rtc 2>/dev/null

# Disk
df -h
df -i                         # Inode usage
# Fallback via /proc/mounts:
cat /proc/mounts

# Logged-in users
whoami
who
w
last
id
# Fallback — read passwd directly
awk -F: '{print $1}' /etc/passwd
```

---

## File comparison

```bash
# Standard diff
diff file1 file2
diff -u file1 file2           # Unified format (more readable)
diff -y file1 file2           # Side by side
diff -r dir1/ dir2/           # Compare directories

# ── diff fallbacks ────────────────────────────────────────────────────────────

# Check if two files are identical
cmp -s file1 file2 && echo "identical" || echo "different"
md5sum file1 file2            # Compare checksums

# Lines in file2 not in file1
awk 'NR==FNR{a[$0]; next} !($0 in a)' file1 file2

# Lines common to both files
awk 'NR==FNR{a[$0]=1; next} a[$0]' file1 file2

# Lines only in file1
awk 'NR==FNR{a[$0]=1; next} !a[$0]' file2 file1
```

---

## Permissions and ownership

```bash
chmod 755 file
chmod +x file
chmod -R 644 directory/
chown user:group file
chown -R user:group directory/

# View permissions in octal
stat -c "%a %n" *
find . -maxdepth 1 -exec stat -c "%a %n" {} \;

# Find files with specific permissions
find . -perm 777
find . -perm -u+x
find . -perm /o+w             # World writable

# Find SUID/SGID files
find / -perm -4000 2>/dev/null   # SUID
find / -perm -2000 2>/dev/null   # SGID

# Make all shell scripts executable
find . -name "*.sh" -exec chmod +x {} +
```

---

## Text editing without an editor

```bash
# Write to a file with echo
echo "content" > file.txt
echo "more content" >> file.txt

# Write multiline with printf
printf "line1\nline2\nline3\n" > file.txt

# Write with heredoc — most powerful native method
cat > file.txt << 'EOF'
line 1
line 2
line 3
EOF

# Append with heredoc
cat >> file.txt << 'EOF'
appended line
EOF

# Replace a line with sed
sed -i 's/old_text/new_text/g' file.txt
sed -i '5s/.*/replacement line/' file.txt   # Replace line 5 entirely

# In-place editing without -i (portable)
sed 's/old/new/g' file.txt > tmp && mv tmp file.txt

# Add line at the beginning
{ echo "first line"; cat file.txt; } > tmp && mv tmp file.txt

# Add line at the end
echo "last line" >> file.txt

# Remove blank lines
sed '/^$/d' file.txt
awk 'NF' file.txt

# Remove trailing whitespace
sed 's/[[:space:]]*$//' file.txt

# Interactive multi-line input to a file
while true; do
    printf "> "
    IFS= read -r line
    [ "$line" = "quit" ] && break
    echo "$line" >> file.txt
done
```

---

## Colours and terminal output

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

printf "${GREEN}Success${RESET}\n"
printf "${RED}${BOLD}Error:${RESET} something went wrong\n"

# Terminal dimensions
echo "$COLUMNS"
echo "$LINES"
tput cols
tput lines
stty size              # Outputs: rows cols

# ── tput fallbacks ────────────────────────────────────────────────────────────
# If tput is missing, use ANSI codes directly
printf "\033[2J\033[H"     # Clear screen
printf "\033[?25l"          # Hide cursor
printf "\033[?25h"          # Show cursor
printf "\033[s"             # Save cursor position
printf "\033[u"             # Restore cursor position

# Print separator line
printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'

# Simple progress bar (pure bash)
for i in $(seq 1 50); do
    printf "\r[%-50s] %d%%" "$(printf '%*s' "$i" | tr ' ' '#')" "$((i*2))"
    sleep 0.05
done
echo
```

---

## Debugging scripts

```bash
set -x             # Print each command before executing
set +x             # Stop debug mode
bash -n script.sh  # Check syntax only — do not run
bash -v script.sh  # Print lines as they are read
bash -x script.sh  # Run with full trace

echo "DEBUG: var=$var" >&2    # Print debug messages to stderr

# Inspect a process via /proc (no strace or lsof needed)
cat /proc/PID/status
cat /proc/PID/cmdline | tr '\0' ' '
ls /proc/PID/fd               # Open file descriptors
cat /proc/PID/environ | tr '\0' '\n'
cat /proc/PID/maps            # Memory maps

# Check what a binary is
file ./program
ldd ./program                 # Shared library dependencies
nm ./program                  # Symbol table
nm -u ./program               # Undefined symbols (dependencies)
strings ./program             # Readable strings in binary
readelf -d ./program | grep NEEDED   # Shared library dependencies (no ldd)
objdump -p ./program | grep NEEDED   # Alternative to readelf

# Check exit code
echo $?
```

---

## Useful one-liners and tricks

```bash
# Quick backup
cp file.c file.c.$(date +%Y%m%d_%H%M%S).bak
cp file.c{,.bak}

# Run previous command with sudo
sudo !!

# Fix a typo in the previous command
^old^new

# Run command in a different directory without cd
(cd /other/dir && make)

# Time a command
time ./program

# Measure elapsed time in a script
start=$SECONDS
# ... work ...
echo "Elapsed: $((SECONDS - start)) seconds"

# Count lines of C code in the project
find . -name "*.c" -o -name "*.h" | xargs wc -l | tail -1

# Print PATH entries one per line
echo "$PATH" | tr ':' '\n'

# Check if a tool exists before using it, fall back to alternative
if command -v tree > /dev/null 2>&1; then
    tree
else
    find . | sed -e 's|[^/]*/|- |g'
fi

# Find the most frequently used commands
history | awk '{a[$2]++} END{for(i in a){print a[i], i}}' | sort -rn | head -10

# Watch a log file, filter for pattern
tail -f logfile | grep --line-buffered "ERROR"

# Remove duplicate lines preserving order (no sort needed)
awk '!seen[$0]++' file

# Print file without comments and blank lines
grep -v "^#\|^$" file
awk '!/^#/ && NF' file

# Swap two files
mv file1 _tmp && mv file2 file1 && mv _tmp file2

# Quickly empty a file without deleting it
> file
truncate -s 0 file

# Source a file if it exists
[[ -f ~/.bash_local ]] && source ~/.bash_local
```

---

## Quick reference — native fallbacks

| Need | Primary | Fallback |
|------|---------|----------|
| List files | `ls` | `printf "%s\n" *` / `echo *` / `find . -maxdepth 1` |
| List with type | `ls -F` | `for f in *; do [ -d "$f" ] && echo "DIR $f" \|\| echo "FILE $f"; done` |
| Directory tree | `tree` | `find . \| sed 's\|[^/]*/\|- \|g'` |
| Print file | `cat` | `sed -n 'p' file` / `awk 1 file` / `while IFS= read -r l; do echo "$l"; done < file` |
| First N lines | `head -n N` | `awk 'NR<=N' file` / `sed -n '1,Np' file` |
| Last N lines | `tail -n N` | `awk '{a[NR%N]=$0} END{for(i=NR+1;i<=NR+N;i++) print a[i%N]}' file` |
| Reverse file | `tac` | `awk '{a[NR]=$0} END{for(i=NR;i>=1;i--) print a[i]}' file` |
| Search text | `grep` | `awk '/pattern/' file` / `sed -n '/pattern/p' file` |
| Count lines | `wc -l` | `awk 'END{print NR}' file` |
| Count words | `wc -w` | `awk '{w+=NF} END{print w}' file` |
| File size | `du -sh` / `wc -c` | `stat -c%s file` / `find . -name "file" -printf "%s\n"` |
| Disk free | `df -h` | `cat /proc/mounts` |
| Memory info | `free -h` | `awk '/MemTotal/{print $2}' /proc/meminfo` |
| Process list | `ps aux` | `for p in /proc/[0-9]*/cmdline; do cat "$p"; echo; done` |
| Process info | `ps` / `top` | `cat /proc/PID/status` |
| Open files | `lsof` | `ls /proc/PID/fd` |
| Port list | `ss -tulpn` | `awk '$4=="0A"{print $2}' /proc/net/tcp` |
| Port check | `nc` / `nmap` | `(echo>/dev/tcp/host/port) 2>/dev/null && echo open` |
| HTTP request | `curl` / `wget` | `/dev/tcp` bash redirect |
| Duplicates | `uniq` | `awk '!seen[$0]++'` |
| Float math | `bc` | `awk 'BEGIN{print expr}'` |
| Replace text | `sed` | `echo "${var//old/new}"` (variables) / awk |
| Field extract | `cut -d: -f1` | `awk -F: '{print $1}'` |
| Sort unique | `sort -u` | `sort \| uniq` |
| Uptime | `uptime` | `awk '{print $1}' /proc/uptime` |
| OS info | `lsb_release` | `cat /etc/os-release` |
| CPU info | `nproc` | `grep -c "processor" /proc/cpuinfo` |
| DNS lookup | `dig` / `nslookup` | `getent hosts domain` / `cat /etc/hosts` |
| Watch command | `watch` | `while true; do clear; cmd; sleep 2; done` |
| Kill by name | `killall` | `ps aux \| awk '/name/{print $2}' \| xargs kill` |
| Keep running | `nohup` | `command & disown` |
| Archive | `tar` | `find . \| cpio -o > archive.cpio` |
| Diff files | `diff` | `cmp -s f1 f2` / `awk` comparison |
