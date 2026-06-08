# GDB — GNU Debugger Cheatsheet.
# Native tool. No plugins. Works on any Linux system with gdb installed.
# Uses: gdb (debugger), cc (compiler), core dumps, signals, threads.

---

## Compiling for debugging

Always compile with debug information before using GDB.
Without debug info, GDB cannot show source code or variable names.

```bash
# Minimum: include debug symbols
cc -g source.c -o program

# Recommended: maximum debug info, no optimisation
cc -g3 -O0 source.c -o program

# -g3  includes macro definitions (visible in GDB with 'macro expand')
# -O0  disables optimisation so variables are never "optimised out"
# -ggdb3 produces debug info specifically tuned for GDB

# With sanitisers — catches bugs at runtime, GDB still works
cc -g3 -O0 -fsanitize=address,undefined source.c -o program

# Check what debug info is present in a binary
readelf --debug-dump=info ./program | head -40
objdump --syms ./program | head -20
file ./program

Starting GDB

Bash

# Start GDB with a program
gdb ./program

# Start GDB quietly (suppress the startup banner)
gdb -q ./program
gdb --quiet ./program

# Start GDB with a program and pass arguments
gdb --args ./program arg1 arg2

# Start GDB and run a single command immediately
gdb -ex "run" ./program
gdb -ex "break main" -ex "run" ./program

# Start GDB with a core dump
gdb ./program core
gdb ./program core.12345

# Attach to a running process by PID
gdb -p 12345
# Or inside GDB:
# (gdb) attach 12345

# Start GDB in batch mode (run a script, then exit — no interaction)
gdb -batch -x commands.gdb ./program
gdb -batch -ex "run" -ex "backtrace" ./program

# Start GDB with Text User Interface (source + command window side by side)
gdb -tui ./program

Basic workflow

gdb

# Inside GDB — all commands are typed at the (gdb) prompt

# Run the program (with optional arguments)
run
run arg1 arg2
run < input.txt
run arg1 > output.txt

# Most commands have short abbreviations
r                   # run
c                   # continue
n                   # next
s                   # step
q                   # quit
b main              # break main
p variable          # print variable
bt                  # backtrace
l                   # list

# Repeat the last command by pressing Enter on a blank line

# Get help on any command
help
help breakpoints
help print
help run

Running the program
Command	Short	Action
run	r	Start the program from the beginning
run arg1 arg2	r arg1 arg2	Start with arguments
run < file		Start with stdin redirected from a file
continue	c	Continue execution after a breakpoint
kill	k	Kill the running program
quit	q	Exit GDB
Breakpoints

gdb

# Set a breakpoint at a function
break main
break ft_strlen
b ft_strlen

# Set a breakpoint at a specific line
break 42
break source.c:42
b main.c:100

# Set a breakpoint at a specific line in another file
break utils.c:57

# Set a conditional breakpoint (only stops when condition is true)
break 42 if i == 10
break ft_strlen if len > 100
break main.c:57 if ptr == NULL

# Add a condition to an existing breakpoint (by number)
condition 1 i == 10

# Set a temporary breakpoint (auto-deleted after the first hit)
tbreak main
tbreak 42

# List all breakpoints
info breakpoints
info b

# Disable a breakpoint by number (it is kept but not active)
disable 1
disable 1 2 3

# Enable a disabled breakpoint
enable 1

# Delete a breakpoint by number
delete 1
delete 1 2 3

# Delete all breakpoints
delete

# Skip a breakpoint N times before stopping
ignore 1 5          # Skip breakpoint 1 five times, then stop on the sixth

# Set a breakpoint matching all functions that contain a pattern
rbreak .*alloc.*    # Matches malloc, ft_calloc, realloc, etc.

Watchpoints

Watchpoints stop execution when a variable's value changes.

gdb

# Stop when a variable is written (value changes)
watch variable
watch *ptr
watch array[5]

# Stop when a variable is read or written
awatch variable

# Stop when a variable is read only
rwatch variable

# List all watchpoints
info watchpoints
info b              # Watchpoints appear here too

# Delete a watchpoint by number (same as deleting a breakpoint)
delete 2

Stepping through code
Command	Short	Action
continue	c	Run until the next breakpoint or program end
next	n	Execute the next source line, step OVER function calls
next N	n N	Step over N lines
step	s	Execute the next source line, step INTO function calls
step N	s N	Step into N lines
finish	fin	Run until the current function returns
until	u	Run until the current loop exits
until N	u N	Run until line N
advance func		Run until a specific function is called
jump N		Skip to line N (dangerous — may corrupt state)
stepi	si	Execute one machine instruction, step into calls
nexti	ni	Execute one machine instruction, step over calls
Inspecting variables and memory
Printing values

gdb

# Print a variable or expression
print variable
p variable

# Print expressions
p a + b
p array[5]
p *ptr
p ptr->member
p my_struct.field
p (int)some_void_ptr

# Print with a format specifier
p/x variable      # hexadecimal
p/d variable      # signed decimal (default)
p/u variable      # unsigned decimal
p/o variable      # octal
p/t variable      # binary
p/c variable      # character
p/f variable      # floating point
p/s ptr           # string (null-terminated)
p/a address       # as an address

# Print multiple array elements
p *array@10       # 10 elements starting at array[0]
p array[0]@10     # Same

# Print full struct contents
p my_struct
p *ptr_to_struct

# Automatically print an expression after every step
display variable
display/x variable
display *ptr

# List all active display expressions
info display

# Remove a display expression by number
undisplay 1

Examining memory

gdb

# x/[count][format][size] address
#
# format:  x=hex  d=decimal  u=unsigned  o=octal  t=binary
#          c=char  s=string  i=instruction  f=float
# size:    b=byte(1)  h=halfword(2)  w=word(4)  g=giant(8)

x/10d &array          # 10 signed decimals starting at array
x/20x 0xffffcf00      # 20 hex values at address
x/s ptr               # Null-terminated string at ptr
x/i $rip              # Disassemble one instruction at the instruction pointer
x/10i main            # Disassemble 10 instructions from main
x/4xw &variable       # 4 hex words (4 bytes each) at variable
x/10x $sp             # 10 hex words at the stack pointer

Inspecting types and symbols

gdb

# Show the type of an expression
whatis variable
whatis *ptr

# Show the full struct, union, or enum definition
ptype struct MyStruct
ptype variable

# Show all local variables in the current stack frame
info locals

# Show all arguments of the current function
info args

# Show all CPU registers
info registers
info registers rsp rbp rip     # Specific registers only

# List all functions matching a pattern
info functions ft_

# List all global and static variables
info variables

# Find the symbol at a given address
info symbol 0x401234

Call stack (backtrace)

gdb

# Print the full call stack
backtrace
bt

# Print the call stack with local variables at each frame
backtrace full
bt full

# Print only the top N frames
backtrace 5
bt 5

# Move to a specific frame by number
frame 2
f 2

# Move up one frame (toward the caller)
up

# Move up N frames
up 3

# Move down one frame (toward the callee)
down

# Show information about the current frame
info frame

# Show source code around the current position
list
l

Source code

gdb

# Show source lines around the current position
list
l

# Show lines around a specific function
list main
list ft_strlen

# Show lines around a specific line in a file
list utils.c:50

# Show a range of lines
list 10,30

# Set how many lines to show per 'list' command
set listsize 20

TUI — Text User Interface

GDB's built-in visual mode. Shows source code and the command prompt side by side.

gdb

# Choose a layout
layout src          # Source code + command window
layout asm          # Assembly + command window
layout split        # Source + assembly + command
layout regs         # Registers + source or assembly

# Switch focus between windows (so scrolling works in the right window)
focus src
focus cmd
focus asm
focus regs

# Refresh the display (fixes corrupted output)
refresh

# Toggle TUI on and off
Ctrl-x a

# Switch to the next layout
Ctrl-x 2

Disassembly

gdb

# Disassemble the current function
disassemble
disas

# Disassemble a specific function
disassemble main
disassemble ft_strlen

# Disassemble with source lines interleaved
disassemble /s main

# Disassemble with raw opcodes shown
disassemble /r main

# Show the instruction at the current program counter
x/i $rip

# Show N instructions from the program counter
x/10i $rip

Core dumps

A core dump is a snapshot of program memory at crash time.
GDB can load it to show exactly where and why the program crashed.

Bash

# Enable core dumps in the current shell session
ulimit -c unlimited

# Check the current limit
ulimit -c

# Run the program — a core file is created on crash
./program

# On modern Linux, core dumps may go to the journal instead
coredumpctl list
coredumpctl dump ./program -o core

# Load a core dump in GDB
gdb ./program core
gdb ./program core.12345

gdb

# Inside GDB with a core dump loaded

# See where the program crashed
backtrace
bt full

# Move to the crash frame and inspect
frame 0
info locals
print ptr

# Check all threads at crash time
thread apply all backtrace

Signals

gdb

# List all signals and how GDB currently handles them
info signals

# Change how GDB handles a signal
# Keywords: stop / nostop   print / noprint   pass / nopass
handle SIGPIPE nostop noprint pass    # Ignore SIGPIPE (common for pipes)
handle SIGUSR1 stop print pass        # Stop and print on SIGUSR1
handle SIGINT  stop print nopass      # Intercept Ctrl-c, do not pass to program

# Send a signal to the running program from GDB
signal SIGUSR1
signal SIGTERM

Threads

gdb

# List all threads
info threads

# Switch to a specific thread by number
thread 2
t 2

# Apply a GDB command to all threads
thread apply all backtrace
thread apply all info locals

# Apply a command to specific threads
thread apply 1 2 3 backtrace

# Set a breakpoint only in a specific thread
break 42 thread 2

# Control which threads run when you 'continue'
set scheduler-locking on    # Only the current thread runs
set scheduler-locking off   # All threads run (default)

Modifying state at runtime

gdb

# Change a variable's value
set variable i = 10
set var ptr = NULL
set variable array[3] = 99

# Change a register
set $rax = 0
set $rip = 0x401234

# Call a function from GDB
call malloc(100)
call free(ptr)
call ft_strlen(str)
call printf("hello from gdb\n")

# Call a function and print its return value
p (int)strlen(str)
p (char *)malloc(64)

# Allocate and use memory from within GDB
set $buf = (char *)malloc(64)
set $buf[0] = 'H'
set $buf[1] = 'i'
set $buf[2] = '\0'
p (char *)$buf

Convenience variables

GDB lets you define your own $variables for use in expressions.

gdb

# Define a convenience variable
set $i = 0
set $ptr = array

# Use them in expressions
p array[$i]
p *($ptr + $i)

# GDB also sets these automatically:
# $     — result of the last print command
# $$    — result of the second-to-last print
# $_    — last address examined with x/
# $__   — value at that address

Pretty printing

gdb

# Print structs with one field per line (much more readable)
set print pretty on

# Print array elements one per line
set print array on

# Show array indexes alongside values
set print array-indexes on

# Do not print trailing null bytes in strings
set print null-stop on

# Set the maximum number of array elements to print
set print elements 100

# Set the maximum string length to print
set print characters 200

# Set maximum depth for nested structures
set print max-depth 5

GDB scripts and automation

Bash

# Run GDB commands from a script file, then exit
gdb -batch -x commands.gdb ./program

# Run a sequence of commands inline
gdb -batch -ex "break main" -ex "run" -ex "backtrace" ./program

gdb

# commands.gdb — example script
set pagination off
set print pretty on
break main
run arg1 arg2
next
print argc
backtrace
quit

gdb

# ~/.gdbinit — loaded automatically by GDB at startup
# Place project-specific .gdbinit in the project directory.

set pagination off
set print pretty on
set print array on
set print array-indexes on
set print null-stop on
set history save on
set history size 10000
set disassembly-flavor intel

Common debugging workflows
Find a segfault

Bash

cc -g3 -O0 source.c -o program
gdb -q ./program

gdb

run
# Program crashes: "Program received signal SIGSEGV"
backtrace                # Where did it crash?
frame 0                  # Go to the crash frame
info locals              # What are the local variables?
print ptr                # Inspect the likely null or invalid pointer
print *ptr               # Dereference it (GDB will tell you if it is invalid)

Debug an infinite loop

gdb

run
# Program is hanging — press Ctrl-c to interrupt
backtrace                # Where is it stuck?
list                     # Show the code
print i                  # Check loop variable

Break only on a specific loop iteration

gdb

break source.c:42 if i == 99
run

Debug memory allocation

gdb

break malloc
run
backtrace                # Who called malloc?
finish                   # Return from malloc
print $rax               # Return value on x86-64: the allocated address

Debug with Valgrind and GDB together

Bash

# Terminal 1: run program under Valgrind with vgdb enabled
valgrind --vgdb=yes --vgdb-error=0 ./program

# Terminal 2: connect GDB to Valgrind
gdb ./program

gdb

target remote | vgdb
continue

Use AddressSanitizer with GDB

Bash

# Compile with ASAN — most memory errors are caught without GDB
cc -g3 -O0 -fsanitize=address,undefined source.c -o program
./program

# To get GDB to stop at the ASAN error rather than exiting
ASAN_OPTIONS=abort_on_error=1 gdb ./program

gdb

run
# GDB stops at the ASAN abort
backtrace

Debugging Makefile projects

Bash

# Always rebuild with debug flags before debugging
make fclean
make CFLAGS="-Wall -Wextra -g3 -O0"
gdb -q ./program

Common errors and solutions
Error	Cause	Solution
No symbol table	Compiled without -g	Recompile with -g3 -O0
value has been optimised out	Compiled with -O2 or higher	Recompile with -O0
No source file named ...	Source file moved after compile	Use directory /path/to/src
Cannot find bounds of current function	No debug info in that frame	Recompile the relevant file with -g3
SIGSEGV at address 0x0	Null pointer dereference	Check what was NULL with info locals and backtrace
SIGABRT	assert() fired or heap corruption	Check assert condition; run under Valgrind or ASAN
Remote connection closed	vgdb disconnected	Restart both Valgrind and GDB
Quick reference

text

START        gdb ./program               gdb --args ./program arg1
             gdb -q ./program            gdb ./program core

BREAKPOINT   b main                      b file.c:42
             b func if cond              tbreak main
             info b                      delete N            disable N

WATCHPOINT   watch var                   awatch var          rwatch var

RUN          r                           r arg1 arg2         r < input.txt

STEP         n  (next — step over)       s  (step — step into)
             finish  (step out)          until N  (run to line)

CONTINUE     c                           u 50                jump 50

PRINT        p var                       p/x var             p *ptr@10
             display var                 info locals         info args

MEMORY       x/10x &var                  x/s ptr             x/i $rip

STACK        bt                          bt full             frame N
             up                          down                info frame

REGISTERS    info registers              info registers rsp rbp rip

MODIFY       set var i = 5              set $rax = 0        call malloc(100)

THREADS      info threads               thread N            thread apply all bt

SIGNALS      info signals               handle SIGPIPE nostop noprint pass

QUIT         q

