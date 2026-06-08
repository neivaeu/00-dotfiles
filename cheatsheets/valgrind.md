# Valgrind Cheatsheet — memory error detection and profiling.
# Works on any Linux system with valgrind installed.
# Uses: valgrind (memcheck, massif, callgrind, helgrind), cc, gdb.

---

## What Valgrind is

Valgrind runs your program inside a synthetic CPU that intercepts every memory
access. This makes it 10–50x slower than normal execution but allows it to
detect bugs that are invisible at runtime.

**No source changes are required.** Recompiling with `-g3 -O0` gives better
output but is not mandatory.

---

## Installing Valgrind

```bash
sudo apt install valgrind

# Verify
valgrind --version
```

---

## Compiling for Valgrind

```bash
# Recommended: maximum debug info, no optimisation
cc -g3 -O0 -Wall -Wextra source.c -o program

# -g3  includes macro definitions and full line number information
# -O0  disables optimisation — variables are never "optimised out"
#      and the generated code maps 1:1 to your source lines
```

---

## Basic usage

```bash
# Run under Valgrind — Memcheck is the default tool
valgrind ./program

# With program arguments
valgrind ./program arg1 arg2

# With stdin
valgrind ./program < input.txt

# Standard leak check — use this for all 42 projects
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./program

# Same but save output to a file (Valgrind writes to stderr)
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
    ./program 2> valgrind.log

# Save to file and display on screen at the same time
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
    ./program 2>&1 | tee valgrind.log

# Use Valgrind's own log file option
valgrind --leak-check=full --log-file=valgrind.log ./program
```

---

## All flags — complete reference

### Tool selection

| Flag | Effect |
|------|--------|
| `--tool=memcheck` | Memory error detector (default) |
| `--tool=massif` | Heap memory profiler |
| `--tool=callgrind` | Call graph and instruction counter |
| `--tool=helgrind` | Thread error detector |
| `--tool=drd` | Alternative thread error detector |
| `--tool=cachegrind` | Cache usage simulator |

### Leak checking

| Flag | Effect |
|------|--------|
| `--leak-check=no` | Do not check for leaks |
| `--leak-check=summary` | Print totals only (default) |
| `--leak-check=yes` | Print details for each leak (same as `full`) |
| `--leak-check=full` | Print full stack trace for each individual leak |
| `--show-leak-kinds=definite` | Show only definitely-lost blocks |
| `--show-leak-kinds=indirect` | Show indirectly-lost blocks |
| `--show-leak-kinds=possible` | Show possibly-lost blocks |
| `--show-leak-kinds=reachable` | Show still-reachable blocks |
| `--show-leak-kinds=all` | Show all four leak categories |
| `--errors-for-leak-kinds=all` | Count all leak kinds as errors |
| `--leak-resolution=low` | Merge stack traces aggressively |
| `--leak-resolution=med` | Default merging |
| `--leak-resolution=high` | Keep stack traces separate |

### Error tracking

| Flag | Effect |
|------|--------|
| `--track-origins=yes` | Show where uninitialised values were created. Slow but essential. |
| `--track-fds=yes` | Report file descriptors still open at exit |
| `--undef-value-errors=yes` | Detect use of uninitialised values (on by default) |
| `--partial-loads-ok=no` | Treat partial memory reads as errors |
| `--error-exitcode=N` | Exit with code N if any errors found — use `1` for CI |

### Output control

| Flag | Effect |
|------|--------|
| `--verbose` or `-v` | More detailed output |
| `--quiet` or `-q` | Only print errors — suppress summary |
| `--log-file=filename` | Write all output to file |
| `--xml=yes --xml-file=file` | Output as XML (for tools and CI) |
| `--num-callers=N` | Show N frames in stack traces (default: 12, max: 50) |
| `--fullpath-name=yes` | Show full file paths in output |
| `--error-limit=no` | Do not stop reporting after 300 errors |
| `--time-stamp=yes` | Add timestamps to output lines |

### Memory fill — helps reveal hidden bugs

| Flag | Effect |
|------|--------|
| `--malloc-fill=0xAA` | Fill freshly allocated memory with 0xAA — reveals reads of uninit memory |
| `--free-fill=0xBB` | Fill freed memory with 0xBB — reveals use-after-free bugs |

### Suppression

| Flag | Effect |
|------|--------|
| `--gen-suppressions=all` | Print suppression rules for every error found |
| `--suppressions=file.supp` | Load a suppression file — ignore known false positives |

### GDB integration

| Flag | Effect |
|------|--------|
| `--vgdb=yes` | Enable GDB server inside Valgrind |
| `--vgdb-error=0` | Stop at the first error and wait for GDB |
| `--vgdb-error=N` | Stop after N errors |

---

## Full recommended command

```bash
# Development — catch everything
valgrind \
    --tool=memcheck \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --track-fds=yes \
    --error-exitcode=1 \
    --errors-for-leak-kinds=all \
    --num-callers=20 \
    ./program [args]

# 42 School standard
valgrind \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    ./program [args]
```

---

## Understanding Valgrind output

### Overall structure

```text
==12345== Memcheck, a memory error detector
==12345== Command: ./program
==12345==
==12345== ERROR MESSAGE
==12345==    at 0x401234: function_name (file.c:42)     ← where it happened
==12345==    by 0x401300: caller_function (main.c:10)   ← who called it
==12345==
==12345== HEAP SUMMARY:
==12345==     in use at exit: 40 bytes in 1 blocks
==12345==   total heap usage: 3 allocs, 2 frees, 1,064 bytes allocated
==12345==
==12345== LEAK SUMMARY:
==12345==    definitely lost: 40 bytes in 1 blocks
==12345==    indirectly lost: 0 bytes in 0 blocks
==12345==      possibly lost: 0 bytes in 0 blocks
==12345==    still reachable: 0 bytes in 0 blocks
==12345==         suppressed: 0 bytes in 0 blocks
==12345==
==12345== ERROR SUMMARY: 1 errors from 1 contexts (suppressed: 0 from 0)
```

`==12345==` is the process ID — it appears on every line of Valgrind output.

### Reading the heap summary

```text
HEAP SUMMARY:
    in use at exit: 40 bytes in 1 blocks    ← should be 0 in a clean program
  total heap usage: 3 allocs, 2 frees, 1,064 bytes allocated
                    ↑                  ↑
                    allocs - frees should equal 0 in a clean program
```

### Clean output — what you want to see

```text
All heap blocks were freed -- no leaks are possible

ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

---

## All error types — full explanation

### 1. Invalid read / Invalid write

```text
==1234== Invalid read of size 4
==1234==    at 0x401A23: main (main.c:10)
==1234==  Address 0x5204080 is 0 bytes after a block of size 40 alloc'd
==1234==    at 0x4C2FB0F: malloc (vgpreload_memcheck.so)
==1234==    by 0x401A10: main (main.c:8)
```

**Cause:** Reading or writing outside the bounds of an allocated block.
`0 bytes after a block of size 40` means you went exactly one element past the
end — a classic off-by-one error.

```c
// Causes this error
int *arr = malloc(10 * sizeof(int));
arr[10] = 5;          // Invalid write: index 10 on a 0-9 array
int x = arr[10];      // Invalid read: same issue
free(arr);
```

---

### 2. Use of uninitialised value

```text
==1234== Use of uninitialised value of size 8
==1234==    at 0x401B34: main (main.c:15)
==1234==  Uninitialised value was created by a heap allocation
==1234==    at 0x4C2FB0F: malloc (vgpreload_memcheck.so)
==1234==    by 0x401B10: main (main.c:12)
```

**Cause:** Reading a variable or memory location that was never written.
`malloc` does not zero memory — use `calloc` or `memset` if you need zeroed memory.
Use `--track-origins=yes` to see exactly where the uninitialised memory came from.

```c
// Three common causes

// 1. Uninitialised local variable
int x;
int y = x + 1;        // x was never set

// 2. malloc does not zero memory
char *buf = malloc(100);
printf("%s\n", buf);  // Contents are whatever was in memory before

// 3. Uninitialised struct field
struct s { int a; int b; };
struct s st;
int z = st.a;         // st was never initialised
```

**Fix:** Initialise all variables. Use `calloc` instead of `malloc` for
zero-initialised memory.

---

### 3. Invalid free / double free

```text
==1234== Invalid free() / delete / delete[] / realloc()
==1234==    at 0x4C30D3B: free (vgpreload_memcheck.so)
==1234==    by 0x401C12: main (main.c:20)
==1234==  Address 0x5204040 is 0 bytes inside a block of size 40 free'd
==1234==    at 0x4C30D3B: free (vgpreload_memcheck.so)
==1234==    by 0x401C00: main (main.c:18)
```

**Cause:** Calling `free()` on a pointer that was already freed, on a stack
variable, on a pointer to the middle of a block, or on memory not from malloc.

```c
// Double free
int *ptr = malloc(40);
free(ptr);
free(ptr);            // Undefined behaviour

// Cannot free stack memory
char buf[100];
free(buf);            // Invalid: not heap memory

// Pointer arithmetic loses the original address
int *arr = malloc(40 * sizeof(int));
arr++;                // Pointer no longer at start of block
free(arr);            // Invalid: not the original malloc'd pointer
```

**Fix:** Set pointer to `NULL` immediately after freeing. Check before freeing.

---

### 4. Use after free

```text
==1234== Invalid read of size 4
==1234==    at 0x401D45: main (main.c:25)
==1234==  Address 0x5204040 is 0 bytes inside a block of size 40 free'd
==1234==    at 0x4C30D3B: free (vgpreload_memcheck.so)
==1234==    by 0x401D30: main (main.c:22)
```

The phrase `inside a block of size N free'd` distinguishes use-after-free from
a regular invalid access — the block was valid but has already been freed.

```c
int *ptr = malloc(10 * sizeof(int));
ptr[0] = 42;
free(ptr);
int x = ptr[0];       // Use after free — undefined behaviour
```

**Fix:**

```c
free(ptr);
ptr = NULL;           // Any later access will crash immediately — easier to debug
```

---

### 5. Memory leaks — four categories

```text
LEAK SUMMARY:
   definitely lost: 40 bytes in 1 blocks
   indirectly lost: 24 bytes in 3 blocks
     possibly lost: 0 bytes in 0 blocks
   still reachable: 1,024 bytes in 1 blocks
        suppressed: 0 bytes in 0 blocks
```

#### definitely lost

No pointer to the block exists anywhere at exit. The memory is 100% leaked
and unrecoverable. **Always fix these.**

```c
void func(void)
{
    char *p = malloc(100);
    // p goes out of scope — memory lost forever
}
```

#### indirectly lost

A block is lost because the pointer to it was inside a definitely-lost block.
Fixing the definitely-lost block will automatically fix indirectly-lost blocks.

```c
typedef struct s_node
{
    char            *data;       // Will become indirectly lost
    struct s_node   *next;
}   t_node;

t_node *head = malloc(sizeof(t_node));  // definitely lost
head->data = malloc(100);               // indirectly lost
// Neither is freed
```

#### possibly lost

A pointer to the block exists but points to the middle of the block, not its
start. Often caused by intentional pointer arithmetic — review carefully.

```c
char *buf = malloc(100);
buf += 50;            // Pointer into middle of block
// At exit: "possibly lost"
```

#### still reachable

A pointer to the block exists at program exit — typically in a global variable
or a data structure that was never freed. The OS reclaims the memory, but it
still represents a memory management error in your code. **Fix these in 42
projects — the moulinette checks for them.**

```c
char *global = NULL;

int main(void)
{
    global = malloc(1024);    // Never freed — still reachable
    return 0;
}
```

---

### 6. Conditional jump depends on uninitialised value

```text
==1234== Conditional jump or move depends on uninitialised value(s)
==1234==    at 0x401B60: main (main.c:18)
```

Caused by using an uninitialised value in an `if`, `while`, or comparison.
This is the most common consequence of forgetting to initialise a variable.

```c
int x;
if (x > 0)            // x was never set — behaviour is undefined
    printf("positive\n");
```

---

### 7. Syscall parameter contains uninitialised bytes

```text
==1234== Syscall param write(buf) points to uninitialised byte(s)
==1234==    at 0x4F32F6E: write (libpthread.so)
==1234==    by 0x401F10: main (main.c:35)
```

**Cause:** Passing a buffer containing uninitialised bytes to a system call.

```c
char buf[100];
write(1, buf, 100);   // buf contents are uninitialised
```

---

### 8. File descriptor leak (with `--track-fds=yes`)

```text
==1234== FILE DESCRIPTOR 3 (opened at main.c:40) OPEN AT EXIT
==1234==    open (/path/to/file)
==1234==    by 0x402010: main (main.c:40)
```

**Cause:** A file descriptor was opened but `close()` was never called.

```c
int fd = open("file.txt", O_RDONLY);
// Never close(fd)
```

---

### 9. Mismatched allocation and deallocation (C++)

```text
==1234== Mismatched free() / delete / delete[] etc.
==1234==    at 0x4C30D3B: free (vgpreload_memcheck.so)
==1234==    by 0x401E00: main (main.c:30)
==1234==  Address 0x5204040 was alloc'd with new[]
```

In C++: always pair `new` with `delete`, `new[]` with `delete[]`, and
`malloc` with `free`. In pure C this does not apply.

---

## Common bug patterns

### Forgetting to free in error paths

```c
// WRONG — leaks buf when strdup fails
char *buf = malloc(100);
char *copy = strdup(input);
if (!copy)
    return (NULL);    // buf is never freed

// CORRECT
char *buf = malloc(100);
char *copy = strdup(input);
if (!copy)
{
    free(buf);
    return (NULL);
}
```

### Losing the original pointer through arithmetic

```c
// WRONG — cannot free later
char *str = malloc(100);
while (*str)
    str++;            // str no longer points to the start
free(str);            // Invalid free — middle of block

// CORRECT — keep the original pointer
char *str = malloc(100);
char *ptr = str;
while (*ptr)
    ptr++;
free(str);            // Free the original
```

### Not freeing in all return paths

```c
// WRONG — leaks on early return
int process(void)
{
    char *buf = malloc(100);
    if (condition)
        return (1);   // buf never freed
    free(buf);
    return (0);
}

// CORRECT
int process(void)
{
    char *buf = malloc(100);
    if (condition)
    {
        free(buf);
        return (1);
    }
    free(buf);
    return (0);
}
```

---

## Suppression files

Use suppressions to ignore known false positives from system libraries.

```bash
# Generate suppression rules for all current errors
valgrind --gen-suppressions=all ./program 2>&1 | grep -A 20 "{"

# Save suppression candidates to a file
valgrind --gen-suppressions=all ./program 2> suppression_candidates.log

# Use a suppression file
valgrind --suppressions=my.supp ./program
```

Example suppression format:

```text
{
   ignore_glibc_readline_leak
   Memcheck:Leak
   ...
   obj:/lib/x86_64-linux-gnu/libc.so.6
}
```

---

## Valgrind with GDB

The most powerful combination: Valgrind stops at each error and GDB can
inspect the full program state.

```bash
# Terminal 1: start Valgrind with GDB server
valgrind --vgdb=yes --vgdb-error=0 ./program

# Terminal 2: connect GDB to Valgrind
gdb ./program
```

```gdb
target remote | vgdb
continue
# Valgrind stops at first error
backtrace
info locals
print *ptr
```

---

## Other Valgrind tools

### Massif — heap profiler

Shows how much memory your program uses over time and which functions
allocated it.

```bash
valgrind --tool=massif ./program
# Creates: massif.out.PID

# Read the output as text
ms_print massif.out.12345

# Visualise (if massif-visualizer is installed)
massif-visualizer massif.out.12345

# Include memory from mmap and brk (full picture)
valgrind --tool=massif --pages-as-heap=yes ./program

# Change the time unit to bytes allocated (easier to read)
valgrind --tool=massif --time-unit=B ./program
```

### Callgrind — call graph and performance profiler

Counts instructions executed per function. Shows which functions are most
expensive without requiring any timing-based profiling.

```bash
valgrind --tool=callgrind ./program
# Creates: callgrind.out.PID

# Read the output
callgrind_annotate callgrind.out.12345

# Visualise with kcachegrind (if installed)
kcachegrind callgrind.out.12345

# Include cache simulation
valgrind --tool=callgrind --cache-sim=yes ./program

# Include branch prediction simulation
valgrind --tool=callgrind --branch-sim=yes ./program
```

### Helgrind — thread error detector

Detects data races, misuse of POSIX mutex API, and lock ordering problems.

```bash
valgrind --tool=helgrind ./threaded_program
```

### DRD — alternative thread checker

Different algorithm from Helgrind. Use both if debugging thread issues.

```bash
valgrind --tool=drd ./threaded_program
```

### Cachegrind — cache profiler

Simulates L1, L2, and last-level cache behaviour.

```bash
valgrind --tool=cachegrind ./program
cg_annotate cachegrind.out.12345
```

---

## Quick reference

```bash
# Basic run
valgrind ./program

# Standard leak check — use for all 42 projects
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./program

# Full — catch everything including fd leaks, fail on any error
valgrind \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --track-fds=yes \
    --error-exitcode=1 \
    --errors-for-leak-kinds=all \
    --num-callers=20 \
    ./program

# Save output to file
valgrind --leak-check=full --log-file=valgrind.log ./program

# Save and display simultaneously
valgrind --leak-check=full ./program 2>&1 | tee valgrind.log

# Debug with GDB at first error
valgrind --vgdb=yes --vgdb-error=0 ./program
# then in another terminal: gdb ./program → target remote | vgdb

# Heap profiling
valgrind --tool=massif ./program
ms_print massif.out.*

# Call graph profiling
valgrind --tool=callgrind ./program
callgrind_annotate callgrind.out.*

# Thread race detection
valgrind --tool=helgrind ./program
```

---

## Error quick reference

| Valgrind message | What it means | Typical cause |
|-----------------|---------------|---------------|
| `Invalid read of size N` | Read outside allocated bounds | Off-by-one, use-after-free |
| `Invalid write of size N` | Write outside allocated bounds | Buffer overflow, off-by-one |
| `Use of uninitialised value` | Variable read before written | Missing initialisation, malloc not zeroed |
| `Conditional jump depends on uninitialised` | `if`/`while` on uninit variable | Same as above |
| `Invalid free()` | free() on wrong address | Double-free, free of stack/middle of block |
| `definitely lost: N bytes` | Pointer to block lost forever | Missing free(), lost pointer |
| `indirectly lost: N bytes` | Block inside a lost block | Fix the definitely-lost block first |
| `still reachable: N bytes` | Pointer exists but block not freed | Missing free() at program end |
| `FILE DESCRIPTOR N OPEN AT EXIT` | fd never closed | Missing close() |
| `Syscall param ... uninitialised` | Uninit memory passed to kernel | Missing initialisation before syscall |
