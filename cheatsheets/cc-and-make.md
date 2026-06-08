# CC and Make Cheatsheet.
# Native tools. No dependencies beyond what is installed with build-essential.
# Uses: cc (C compiler), c++ (C++ compiler), make (build system).
# 'cc' and 'c++' are POSIX-standard aliases — they point to the system compiler.

---

## CC — C Compiler

### What is `cc`?

`cc` is the POSIX-standard name for the system C compiler.
On most Linux systems it points to GCC. On macOS it points to Clang.
Using `cc` instead of `gcc` makes your code more portable.

```bash
# Check what cc actually is on your system
cc --version
ls -la $(which cc)
readlink -f $(which cc)
```

---

### Basic compilation

```bash
# Compile a single file to an executable
cc source.c -o program

# Compile multiple files
cc main.c utils.c parser.c -o program

# Compile to object file only (no linking)
cc -c source.c -o source.o

# Link object files into an executable
cc main.o utils.o -o program

# Compile and link in one step with multiple sources
cc main.c utils.c -o program -lm

# Print the compiler version
cc --version

# Print the default include and library search paths
cc -v -x c /dev/null -o /dev/null 2>&1

# Print the multiarch tuple (useful for finding library paths)
cc -print-multiarch

# Print the default library search paths
cc -print-search-dirs
```

---

### Warning flags

| Flag | What it enables |
|------|----------------|
| `-Wall` | Most useful warnings. Always use this. |
| `-Wextra` | Additional warnings not covered by -Wall. Always use this. |
| `-Werror` | Treat all warnings as errors. Required by 42 School. |
| `-Wpedantic` | Strict ISO C compliance warnings. |
| `-Wshadow` | Warn when a local variable shadows another variable. |
| `-Wconversion` | Warn on implicit type conversions that may change a value. |
| `-Wstrict-overflow=5` | Warn about optimisations that assume no signed overflow. |
| `-Wformat=2` | Extra format string security checks (printf/scanf). |
| `-Wnull-dereference` | Warn when the compiler detects a possible null dereference. |
| `-Wdouble-promotion` | Warn when float is implicitly promoted to double. |
| `-Wwrite-strings` | Warn when a string literal is assigned to a non-const pointer. |
| `-Wmissing-prototypes` | Warn if a global function has no prior prototype declaration. |
| `-Wstrict-prototypes` | Warn if a function is declared without argument types. |
| `-Wunreachable-code` | Warn if code will never be executed. |
| `-Wuninitialized` | Warn about variables used before being initialised. |
| `-Wcast-align` | Warn about casts that increase the required alignment. |
| `-Wcast-qual` | Warn when a cast removes a type qualifier like const. |
| `-Wpointer-arith` | Warn about anything that depends on the size of a function or void. |
| `-Wredundant-decls` | Warn if something is declared more than once. |
| `-Wlogical-op` | Warn about suspicious uses of logical operators (GCC only). |

**42 School standard:**
```bash
cc -Wall -Wextra -Werror source.c -o program
```

**Maximum warning level (development):**
```bash
cc -Wall -Wextra -Werror -Wpedantic -Wshadow -Wconversion \
   -Wformat=2 -Wnull-dereference -Wwrite-strings \
   -Wmissing-prototypes -Wstrict-prototypes source.c -o program
```

---

### C standard flags

| Flag | Standard |
|------|----------|
| `-std=c89` | ANSI C / ISO C 1989 |
| `-std=c90` | Same as c89 |
| `-std=c99` | ISO C 1999 — adds `//` comments, `stdint.h`, VLAs |
| `-std=c11` | ISO C 2011 — adds `_Generic`, `_Static_assert`, atomics |
| `-std=c17` | ISO C 2017 — bug-fix release of c11, most modern stable standard |
| `-std=c23` | ISO C 2023 — adds `bool`, `nullptr`, `#embed` (newer compilers) |
| `-std=gnu11` | C11 with GNU extensions enabled |
| `-std=gnu17` | C17 with GNU extensions enabled (common default) |

```bash
# Compile with a specific C standard
cc -std=c11 -Wall -Wextra source.c -o program
cc -std=c17 -Wall -Wextra source.c -o program

# Check what standard your compiler defaults to
cc -dM -E - < /dev/null | grep "__STDC_VERSION__"
```

---

### Optimisation flags

| Flag | Effect |
|------|--------|
| `-O0` | No optimisation. Best for debugging. The compiler generates code exactly as written. |
| `-O1` | Basic optimisation. Reduces code size and improves speed without major compile time cost. |
| `-O2` | Standard optimisation. Most production code uses this. Enables nearly all safe optimisations. |
| `-O3` | Aggressive optimisation. Enables vectorisation and loop unrolling. May increase binary size. |
| `-Os` | Optimise for smallest binary size. Useful for embedded systems. |
| `-Oz` | Optimise even more aggressively for size (Clang only). |
| `-Og` | Optimise for the debugging experience. Better than `-O0` with GDB — some optimisations that do not interfere with debugging are applied. |
| `-Ofast` | `-O3` plus unsafe floating-point optimisations. Breaks strict IEEE 754 compliance. |
| `-flto` | Link-time optimisation. Allows the compiler to optimise across translation units. |
| `-march=native` | Generate instructions for the current CPU specifically. Not portable to other machines. |
| `-mtune=native` | Tune instruction scheduling for the current CPU but keep code portable. |
| `-funroll-loops` | Unroll loops. Can improve performance but increases binary size. |
| `-ffast-math` | Unsafe floating-point shortcuts. Breaks NaN/Inf handling. Use with care. |
| `-ffunction-sections` | Put each function in its own section. Allows the linker to strip unused functions. |
| `-fdata-sections` | Put each variable in its own section. Works with `--gc-sections`. |

```bash
# Development: no optimisation, full debug info
cc -O0 -g3 source.c -o program

# Release: standard optimisation
cc -O2 -DNDEBUG source.c -o program

# Maximum performance (not always portable)
cc -O3 -march=native -flto -DNDEBUG source.c -o program

# Smallest binary
cc -Os -ffunction-sections -fdata-sections -Wl,--gc-sections source.c -o program
```

---

### Debug flags

| Flag | Effect |
|------|--------|
| `-g` | Include basic DWARF debug information. |
| `-g2` | Default level when `-g` is used. Includes variables, functions, line numbers. |
| `-g3` | Maximum debug information including macro definitions. Always use with GDB. |
| `-ggdb` | Produce debug information specifically optimised for GDB. |
| `-ggdb3` | Maximum GDB-specific debug information including macros. |
| `-fno-omit-frame-pointer` | Keep the frame pointer register. Improves stack traces with sanitisers and profilers. |
| `-fno-inline` | Disable inlining. Makes stack traces easier to read. |
| `-fno-optimize-sibling-calls` | Disable tail call optimisation. Preserves full call stacks. |
| `-fstack-protector-strong` | Add canaries to stack frames to detect stack smashing. |
| `-fstack-protector-all` | Add canaries to every function, including those with no buffers. |
| `-D_FORTIFY_SOURCE=2` | Enable runtime checks for unsafe libc functions (needs `-O1` or higher). |

```bash
# Best combination for GDB debugging
cc -g3 -ggdb3 -O0 -fno-omit-frame-pointer source.c -o program

# Debug with stack protection
cc -g3 -O0 -fstack-protector-strong -D_FORTIFY_SOURCE=2 -O1 source.c -o program
```

---

### Sanitiser flags

Sanitisers instrument the binary to detect bugs at runtime.
They significantly slow down execution — use only during development.
Always compile with `-g3` when using sanitisers to get useful error messages.

| Flag | What it detects |
|------|----------------|
| `-fsanitize=address` | Buffer overflows, heap use-after-free, stack use-after-return, double-free, use-after-scope |
| `-fsanitize=leak` | Memory leaks at program exit. Can be used standalone without AddressSanitizer. |
| `-fsanitize=undefined` | Undefined behaviour: signed integer overflow, null pointer dereference, bad pointer alignment, out-of-bounds array index, invalid shifts |
| `-fsanitize=thread` | Data races in multithreaded programs. Cannot be combined with AddressSanitizer. |
| `-fsanitize=memory` | Use of uninitialised memory. Requires Clang — not available in GCC. |
| `-fsanitize=integer` | Integer overflow and truncation (Clang only). |
| `-fsanitize=bounds` | Array out-of-bounds access. |
| `-fsanitize=float-divide-by-zero` | Division by zero with floating-point numbers. |
| `-fsanitize=float-cast-overflow` | Floating-point to integer conversion overflow. |

```bash
# Most useful combination for 42 projects
cc -Wall -Wextra -Werror -g3 -fsanitize=address,leak,undefined source.c -o program

# Thread debugging (cannot combine with address sanitizer)
cc -g3 -fsanitize=thread source.c -o program -lpthread

# Full UB detection
cc -g3 -fsanitize=undefined -fsanitize=float-divide-by-zero \
   -fsanitize=float-cast-overflow source.c -o program

# Note: -fsanitize=address and -fsanitize=thread CANNOT be used together
# Note: -fsanitize=memory requires clang, not cc/gcc
```

**Sanitiser environment variables:**
```bash
# Halt on first error instead of continuing
ASAN_OPTIONS=halt_on_error=1 ./program

# Show full stack trace on leak
LSAN_OPTIONS=verbosity=1:log_threads=1 ./program

# Make UBSan print a backtrace
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 ./program

# Combine options
ASAN_OPTIONS=halt_on_error=1:detect_stack_use_after_return=1 \
UBSAN_OPTIONS=print_stacktrace=1 ./program
```

---

### Preprocessor

```bash
# Define a macro on the command line
cc -DDEBUG source.c -o program
cc -DMAX_SIZE=1024 source.c -o program
cc -DUSE_COLOR -DVERSION='"1.0.0"' source.c -o program

# Undefine a macro
cc -UDEBUG source.c -o program

# Only run the preprocessor — show the expanded output
cc -E source.c
cc -E source.c -o source_preprocessed.c

# Run the preprocessor and keep comments
cc -E -C source.c

# Show all predefined macros for the current compiler and platform
cc -dM -E - < /dev/null

# Show predefined macros for a specific standard
cc -std=c17 -dM -E - < /dev/null

# Show include paths being searched
cc -v -x c /dev/null -o /dev/null 2>&1 | grep -A 20 "include"

# Show which header file is actually included
cc -H source.c -o /dev/null 2>&1 | head -30

# Add a directory to the include search path
cc -I./include -I/usr/local/include source.c -o program

# Treat a file as if it were the given language
cc -x c header_without_extension -o /dev/null -fsyntax-only
```

---

### Linker flags

```bash
# Link with standard libraries
cc source.c -o program -lm          # Math library (libm)
cc source.c -o program -lpthread    # POSIX threads (libpthread)
cc source.c -o program -lreadline   # GNU readline
cc source.c -o program -lncurses    # Terminal UI
cc source.c -o program -ldl         # Dynamic loading (dlopen/dlsym)

# Add a library search path
cc source.c -o program -L/usr/local/lib -lmylib
cc source.c -o program -L./lib -lmylib

# Add a runtime library search path (rpath)
cc source.c -o program -Wl,-rpath,/usr/local/lib -lmylib

# Link statically (everything bundled into the binary)
cc source.c -o program -static -lm

# Build a shared library
cc -shared -fPIC source.c -o libmylib.so

# Build a static library (use ar, not cc)
cc -c source.c -o source.o
ar rcs libmylib.a source.o

# Pass flags directly to the linker
cc source.c -o program -Wl,--as-needed           # Only link libraries actually used
cc source.c -o program -Wl,--gc-sections          # Remove unused sections
cc source.c -o program -Wl,-Map,output.map        # Generate a link map
cc source.c -o program -Wl,--strip-all            # Strip all symbols
cc source.c -o program -Wl,-z,now                 # Resolve all symbols at load time

# Show all linker steps in detail
cc -v source.c -o program

# Show which libraries are linked
ldd ./program

# Show all symbols in an object or binary
nm ./program
nm -D ./program        # Dynamic symbols only
nm -u ./program        # Undefined symbols (dependencies)

# Show dynamic dependencies
objdump -p ./program | grep NEEDED
readelf -d ./program | grep NEEDED
```

---

### Static analysis and inspection

```bash
# Check syntax without producing any output
cc -fsyntax-only source.c
cc -fsyntax-only -Wall -Wextra source.c

# Generate assembly output
cc -S source.c -o source.s
cc -S -O2 source.c -o source_optimised.s
cc -S -O0 -fverbose-asm source.c -o source_verbose.s   # Comments in assembly

# Inspect a compiled object file
objdump -d source.o                    # Disassemble
objdump -t source.o                    # Symbol table
objdump -r source.o                    # Relocation entries
objdump -S source.o                    # Interleave source with disassembly (needs -g)
readelf -a source.o                    # Full ELF information
size source.o                          # Section sizes
strings program                        # Print readable strings from binary
strip program                          # Remove all debug symbols from binary
file program                           # Show file type and architecture info

# Generate a dependency file (for use with make)
cc -M source.c                         # Print make rule with all dependencies
cc -MM source.c                        # Same but exclude system headers
cc -MMD -MP -c source.c -o source.o   # Write .d file alongside .o during compilation

# Profile-guided optimisation (PGO)
cc -fprofile-generate source.c -o program    # Step 1: compile with instrumentation
./program                                     # Step 2: run the program normally
cc -fprofile-use source.c -o program         # Step 3: recompile using profile data
```

---

### Useful flag combinations

```bash
# 42 School required
cc -Wall -Wextra -Werror source.c -o program

# Development build — maximum error detection, easy debugging
cc -Wall -Wextra -Werror -Wpedantic \
   -g3 -O0 -fno-omit-frame-pointer \
   -fsanitize=address,leak,undefined \
   source.c -o program

# Debug with GDB
cc -g3 -ggdb3 -O0 -fno-omit-frame-pointer source.c -o program

# Release build — maximum performance
cc -O2 -DNDEBUG source.c -o program

# Release build — absolute maximum performance (not always portable)
cc -O3 -march=native -flto -DNDEBUG source.c -o program

# Smallest binary
cc -Os -s -ffunction-sections -fdata-sections \
   -Wl,--gc-sections source.c -o program

# Security-hardened build
cc -Wall -Wextra -O2 \
   -fstack-protector-strong \
   -D_FORTIFY_SOURCE=2 \
   -Wl,-z,relro -Wl,-z,now \
   source.c -o program

# Check if code compiles for multiple standards
for std in c89 c99 c11 c17; do
    echo "Testing $std..."
    cc -std=$std -Wall -Wextra -fsyntax-only source.c && echo "OK"
done
```

---

## C++ — C++ Compiler

### What is `c++`?

`c++` is the POSIX-standard name for the system C++ compiler.
On most Linux systems it points to G++. On macOS it points to Clang++.
Using `c++` instead of `g++` makes your code more portable.

```bash
# Check what c++ actually is on your system
c++ --version
ls -la $(which c++)
readlink -f $(which c++)
```

---

### Basic compilation

```bash
# Compile a single file to an executable
c++ source.cpp -o program

# Compile multiple files
c++ main.cpp utils.cpp parser.cpp -o program

# Compile to object file only (no linking)
c++ -c source.cpp -o source.o

# Link object files into an executable
c++ main.o utils.o -o program

# Compile and link with libraries
c++ source.cpp -o program -lpthread

# Print the default search paths
c++ -v -x c++ /dev/null -o /dev/null 2>&1
```

---

### Warning flags (C++)

| Flag | What it enables |
|------|----------------|
| `-Wall` | Most useful warnings. Always use this. |
| `-Wextra` | Additional warnings not covered by -Wall. |
| `-Werror` | Treat all warnings as errors. |
| `-Wpedantic` | Strict ISO C++ compliance warnings. |
| `-Wshadow` | Warn when a variable shadows another. |
| `-Wconversion` | Warn on implicit type conversions. |
| `-Wsign-conversion` | Warn on implicit signed/unsigned conversions specifically. |
| `-Wnull-dereference` | Warn on possible null pointer dereference. |
| `-Wformat=2` | Extra format string security checks. |
| `-Wduplicated-cond` | Warn on duplicate conditions in if/else-if chains (GCC). |
| `-Wduplicated-branches` | Warn when if/else branches have identical bodies (GCC). |
| `-Wlogical-op` | Warn on suspicious uses of logical operators (GCC). |
| `-Wuseless-cast` | Warn when a cast is to the same type (GCC). |
| `-Wold-style-cast` | Warn when a C-style cast is used in C++ code. |
| `-Woverloaded-virtual` | Warn when a derived class function hides a virtual function. |
| `-Wnon-virtual-dtor` | Warn when a class with virtual functions has a non-virtual destructor. |
| `-Wmisleading-indentation` | Warn when indentation does not match block structure. |

**Recommended for C++ development:**
```bash
c++ -Wall -Wextra -Werror -Wpedantic -Wshadow \
    -Wconversion -Wsign-conversion -Wold-style-cast \
    -Wnon-virtual-dtor -Woverloaded-virtual \
    source.cpp -o program
```

---

### C++ standard flags

| Flag | Standard | Key features added |
|------|----------|--------------------|
| `-std=c++98` | ISO C++ 1998 | Original standard |
| `-std=c++03` | ISO C++ 2003 | Bug fixes to c++98 |
| `-std=c++11` | ISO C++ 2011 | `auto`, lambdas, `nullptr`, move semantics, `constexpr`, range-for |
| `-std=c++14` | ISO C++ 2014 | Generic lambdas, `std::make_unique`, relaxed `constexpr` |
| `-std=c++17` | ISO C++ 2017 | Structured bindings, `if constexpr`, `std::optional`, `std::variant`, `std::filesystem` |
| `-std=c++20` | ISO C++ 2020 | Concepts, ranges, coroutines, modules, `std::span`, three-way comparison |
| `-std=c++23` | ISO C++ 2023 | `std::print`, `std::expected`, `std::flat_map`, `std::mdspan` |
| `-std=gnu++17` | C++17 + GNU extensions | Common default on Linux |

```bash
# Compile with a specific C++ standard
c++ -std=c++98 -Wall -Wextra source.cpp -o program
c++ -std=c++20 -Wall -Wextra source.cpp -o program

# Check which standard your compiler defaults to
c++ -dM -E -x c++ - < /dev/null | grep "__cplusplus"
# 201703L = C++17, 202002L = C++20
```

---

### Optimisation flags (C++)

Same flags as the C compiler — see the CC optimisation section above.
Additional C++-specific flags:

| Flag | Effect |
|------|--------|
| `-fno-exceptions` | Disable C++ exception support. Smaller binary, faster code, breaks `try/catch`. |
| `-fno-rtti` | Disable run-time type information (`dynamic_cast`, `typeid`). Smaller binary. |
| `-fvisibility=hidden` | Hide all symbols by default. Useful when building shared libraries. |
| `-fvisibility-inlines-hidden` | Hide inline function symbols. Reduces shared library size. |

```bash
# Performance build without exceptions/RTTI (embedded or game-like contexts)
c++ -std=c++98 -O2 -fno-exceptions -fno-rtti -DNDEBUG source.cpp -o program

# Maximum performance
c++ -std=c++98 -O3 -march=native -flto -DNDEBUG source.cpp -o program
```

---

### Debug flags (C++)

Same as CC — see above. Additional C++-specific notes:

```bash
# Debug C++ with sanitisers
c++ -std=c++98 -g3 -O0 -fno-omit-frame-pointer \
    -fsanitize=address,leak,undefined \
    source.cpp -o program

# Debug STL usage (very slow, development only — GCC/libstdc++ specific)
c++ -std=c++98 -g3 -O0 -D_GLIBCXX_DEBUG \
    -D_GLIBCXX_DEBUG_PEDANTIC source.cpp -o program

# Debug with Clang's libstdc++ checker
c++ -std=c++98 -g3 -O1 -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG source.cpp -o program
```

---

### Sanitiser flags (C++)

Same flags as C — see the CC sanitiser section above. Notes specific to C++:

```bash
# Full sanitiser suite for C++
c++ -std=c++98 -Wall -Wextra -g3 \
    -fsanitize=address,leak,undefined \
    -fno-omit-frame-pointer \
    source.cpp -o program

# Catch iterator invalidation and STL misuse (GCC only)
c++ -std=c++98 -g3 -O0 \
    -D_GLIBCXX_DEBUG \
    -fsanitize=address,undefined \
    source.cpp -o program
```

---

### Preprocessor (C++)

```bash
# Define macros
c++ -DDEBUG -DVERSION='"2.0.0"' source.cpp -o program

# Show all predefined macros for C++
c++ -std=c++98 -dM -E -x c++ - < /dev/null

# Show which headers are included and from where
c++ -H source.cpp -o /dev/null 2>&1 | head -40

# Preprocess only
c++ -E source.cpp -o source_preprocessed.cpp

# Check what __cplusplus resolves to
echo | c++ -std=c++98 -dM -E -x c++ - | grep __cplusplus
```

---

### Linker flags (C++)

Same as CC — see above. C++-specific notes:

```bash
# When mixing C and C++ object files, always link with c++ (not cc)
# cc does not link the C++ standard library by default
cc -c main.c -o main.o
c++ -c util.cpp -o util.o
c++ main.o util.o -o program      # Use c++ to link — adds -lstdc++ automatically

# Explicitly link the C++ standard library (if needed)
cc source.o -o program -lstdc++ -lm

# Link with specific C++ libraries
c++ source.cpp -o program -lboost_system
c++ source.cpp -o program -lpthread

# Show which C++ standard library is being used
c++ -v source.cpp -o /dev/null 2>&1 | grep "lstdc\|lc++"
```

---

### Static analysis and inspection (C++)

```bash
# Syntax check only
c++ -std=c++98 -fsyntax-only -Wall -Wextra source.cpp

# Generate assembly
c++ -std=c++98 -S -O2 source.cpp -o source.s

# Demangle C++ symbol names
nm program | c++filt
objdump -d program | c++filt

# Check for undefined behaviour without running
# (requires clang — invoke as 'clang++' or set c++ to clang++)
# clang++ --analyze source.cpp

# Print the size of the compiled sections
size program

# Inspect template instantiations (verbose output)
c++ -std=c++98 -ftemplate-backtrace-limit=0 source.cpp -o program

# Show how many template instantiations were created
c++ -std=c++98 -ftime-report source.cpp -o program 2>&1 | grep template

# Reduce template error messages
c++ -std=c++98 -ftemplate-depth=50 source.cpp -o program

# Show preprocessed output with line markers
c++ -E -dD source.cpp
```

---

### Useful flag combinations (C++)

```bash
# Development build — maximum error detection
c++ -std=c++98 -Wall -Wextra -Werror -Wpedantic \
    -Wshadow -Wconversion -Wsign-conversion \
    -Wold-style-cast -Wnon-virtual-dtor \
    -g3 -O0 -fno-omit-frame-pointer \
    -fsanitize=address,leak,undefined \
    source.cpp -o program

# Release build — standard performance
c++ -std=c++98 -O2 -DNDEBUG source.cpp -o program

# Release build — maximum performance
c++ -std=c++98 -O3 -march=native -flto -DNDEBUG source.cpp -o program

# Smallest binary (no exceptions, no RTTI)
c++ -std=c++98 -Os -fno-exceptions -fno-rtti -s \
    -ffunction-sections -fdata-sections \
    -Wl,--gc-sections source.cpp -o program

# Debug STL containers
c++ -std=c++98 -g3 -O0 -D_GLIBCXX_DEBUG \
    -fsanitize=address,undefined \
    source.cpp -o program

# Build a shared library
c++ -std=c++98 -O2 -shared -fPIC \
    -fvisibility=hidden source.cpp -o libmylib.so
```

---

## Make

### Makefile anatomy

```makefile
# ─────────────────────────────────────────────
# Variables
# ─────────────────────────────────────────────
CC       = cc
CXX      = c++
CFLAGS   = -Wall -Wextra -Werror
CXXFLAGS = -Wall -Wextra -Werror -std=c++98
NAME     = myprogram
SRCS     = main.c utils.c
OBJS     = $(SRCS:.c=.o)

# ─────────────────────────────────────────────
# Default target — runs when you type 'make'
# ─────────────────────────────────────────────
all: $(NAME)

# Link: build the final binary from object files
$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

# Compile: build each .o from its .c
# $<  = the first prerequisite (the .c file)
# $@  = the target name (the .o file)
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Remove object files
clean:
	rm -f $(OBJS)

# Remove object files and the binary
fclean: clean
	rm -f $(NAME)

# Full rebuild
re: fclean all

# Targets that are not files — always run when requested
.PHONY: all clean fclean re
```

---

### Running make

```bash
# Run the default target (all)
make

# Run a specific target
make clean
make fclean
make re

# Run with N parallel jobs (faster for large projects)
make -j4
make -j$(nproc)         # Use all CPU cores

# Show what would be run without actually running it (dry run)
make --dry-run
make -n

# Force rebuild of everything regardless of timestamps
make --always-make
make -B

# Run from a different directory without changing into it
make -C /path/to/project
make -C /path/to/project clean

# Use a different Makefile
make -f MyMakefile
make -f MyMakefile clean

# Pass a variable from the command line (overrides Makefile value)
make CFLAGS="-Wall -O2"
make NAME=mytool

# Suppress command echoing (quiet mode)
make -s

# Show all rules and variables make knows about
make -p 2>/dev/null | less

# Enable tracing of remake decisions
make --trace

# Print the database and exit (do not build anything)
make -p -q 2>/dev/null | less
```

---

### Automatic variables

| Variable | Value |
|----------|-------|
| `$@` | The full target name |
| `$<` | The first prerequisite only |
| `$^` | All prerequisites, deduplicated, space-separated |
| `$+` | All prerequisites including duplicates |
| `$*` | The stem matched by `%` in a pattern rule |
| `$?` | All prerequisites that are newer than the target |
| `$(@D)` | The directory part of `$@` |
| `$(@F)` | The file part of `$@` (without directory) |
| `$(<D)` | The directory part of `$<` |
| `$(<F)` | The file part of `$<` |
| `$(*D)` | The directory part of `$*` |
| `$(*F)` | The file part of `$*` |

---

### Variable assignment operators

| Operator | Behaviour |
|----------|-----------|
| `=` | Recursive (lazy) assignment. Expanded when used, not when defined. |
| `:=` | Simple (immediate) assignment. Expanded when defined. Use this by default. |
| `::=` | Same as `:=`. POSIX portable form. |
| `?=` | Set only if the variable is not already defined. |
| `+=` | Append to the existing value. |
| `!=` | Assign the output of a shell command. |

```makefile
# Lazy — CC is expanded every time COMPILE is used
COMPILE  = $(CC) $(CFLAGS)

# Immediate — SRCS is expanded now, at definition time
SRCS    := $(wildcard src/*.c)

# Append
CFLAGS  += -g3

# Set only if not already defined (can be overridden on command line)
CC      ?= cc

# Shell command
DATE    != date +%Y-%m-%d
# or
DATE    := $(shell date +%Y-%m-%d)
```

---

### Common Makefile patterns

```makefile
# ── Pattern rule ──────────────────────────────
# Compile every .c to a .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# ── Automatic dependency generation ───────────
# -MMD: write a .d file alongside the .o with header dependencies
# -MP:  add a phony target for each header to prevent errors on deletion
DEPS := $(OBJS:.o=.d)
-include $(DEPS)

%.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# ── Find all .c files recursively ─────────────
SRCS := $(shell find src -name "*.c")
OBJS := $(SRCS:.c=.o)

# ── Silent build with custom messages ─────────
%.o: %.c
	@echo "  CC    $<"
	@$(CC) $(CFLAGS) -c $< -o $@

# ── Multi-directory sources ───────────────────
SRC_DIRS := src src/parser src/lexer
SRCS     := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
OBJS     := $(patsubst %.c,%.o,$(SRCS))

# ── Object files in a separate directory ──────
SRC_DIR := src
OBJ_DIR := obj
SRCS    := $(wildcard $(SRC_DIR)/*.c)
OBJS    := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# ── Conditional flags ─────────────────────────
# Add debug flags if DEBUG=1 is passed on command line: make DEBUG=1
ifeq ($(DEBUG),1)
    CFLAGS += -g3 -O0 -fsanitize=address,undefined
else
    CFLAGS += -O2 -DNDEBUG
endif

# ── Coloured output ───────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RESET  := \033[0m

%.o: %.c
	@printf "$(GREEN)  CC$(RESET)    %s\n" $<
	@$(CC) $(CFLAGS) -c $< -o $@

# ── Print a variable value ────────────────────
# Usage: make print-SRCS
print-%:
	@echo "$* = $($*)"

# ── Phony target to run the program ──────────
run: $(NAME)
	./$(NAME)

# ── Phony target to run with sanitisers ───────
san: CFLAGS += -g3 -O0 -fsanitize=address,leak,undefined
san: re
	./$(NAME)

# ── Phony target for valgrind ─────────────────
valgrind: $(NAME)
	valgrind --leak-check=full --track-origins=yes \
	         --show-leak-kinds=all ./$(NAME)
```

---

### Make built-in functions

```makefile
# ── String functions ──────────────────────────
$(subst from,to,text)          # Replace 'from' with 'to' in text
$(patsubst %.c,%.o,$(SRCS))   # Pattern substitution
$(strip $(SRCS))               # Remove leading/trailing whitespace
$(filter %.c,$(FILES))         # Keep only .c files
$(filter-out %.o,$(FILES))     # Remove all .o files
$(sort $(SRCS))                # Sort and deduplicate
$(word 2,$(SRCS))              # Get the 2nd word
$(words $(SRCS))               # Count words
$(firstword $(SRCS))           # First word
$(lastword $(SRCS))            # Last word
$(dir src/foo.c)               # Extracts 'src/'
$(notdir src/foo.c)            # Extracts 'foo.c'
$(basename src/foo.c)          # Extracts 'src/foo'
$(suffix src/foo.c)            # Extracts '.c'
$(addprefix pre/,foo bar)      # Adds prefix: 'pre/foo pre/bar'
$(addsuffix .c,foo bar)        # Adds suffix: 'foo.c bar.c'
$(join a b,c d)                # Joins lists: 'ac bd'

# ── File functions ────────────────────────────
$(wildcard src/*.c)            # Expand glob — returns matching files
$(realpath ../path)            # Canonical absolute path
$(abspath ../path)             # Absolute path (does not check existence)
$(shell command)               # Run a shell command and capture output

# ── Conditional functions ─────────────────────
$(if condition,then,else)
$(or val1,val2,val3)           # First non-empty value
$(and val1,val2,val3)          # All non-empty or empty

# ── foreach ───────────────────────────────────
$(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))

# ── error and warning ─────────────────────────
$(error Fatal: missing source files)
$(warning This is just a warning)
$(info Building $(NAME)...)
```

---

### 42 School required Makefile (C)

```makefile
# ════════════════════════════════════════════
# 42 School — Standard Makefile Template (C)
# ════════════════════════════════════════════

NAME     = program_name

CC       = cc
CFLAGS   = -Wall -Wextra -Werror
INC      = -I include

SRC_DIR  = src
OBJ_DIR  = obj

SRCS     = $(wildcard $(SRC_DIR)/*.c)
OBJS     = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

# ─── Targets ─────────────────────────────────

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
```

---

### 42 School required Makefile (with library)

```makefile
# ════════════════════════════════════════════
# 42 School — Makefile with libft dependency
# ════════════════════════════════════════════

NAME     = program_name

CC       = cc
CFLAGS   = -Wall -Wextra -Werror
INC      = -I include -I libft/include

LIBFT    = libft/libft.a
LIBFT_DIR = libft

SRC_DIR  = src
OBJ_DIR  = obj

SRCS     = $(wildcard $(SRC_DIR)/*.c)
OBJS     = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

# ─── Targets ─────────────────────────────────

all: $(LIBFT) $(NAME)

$(LIBFT):
	$(MAKE) -C $(LIBFT_DIR)

$(NAME): $(OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(OBJS) -L$(LIBFT_DIR) -lft -o $(NAME)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)
	$(MAKE) -C $(LIBFT_DIR) clean

fclean: clean
	rm -f $(NAME)
	$(MAKE) -C $(LIBFT_DIR) fclean

re: fclean all

.PHONY: all clean fclean re
```

---

### Advanced Makefile — full production template (C)

```makefile
# ════════════════════════════════════════════
# Full Production Makefile — C Project
# ════════════════════════════════════════════

NAME     := myprogram
VERSION  := 1.0.0

CC       := cc
CFLAGS   := -Wall -Wextra -Werror -std=c17
INC      := -I include

SRC_DIR  := src
OBJ_DIR  := obj

# Collect all .c files recursively under SRC_DIR
SRCS     := $(shell find $(SRC_DIR) -name "*.c")
OBJS     := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
DEPS     := $(OBJS:.o=.d)

# ─── Build mode ────────────────────────────
# Usage: make           → release
#        make DEBUG=1   → debug + sanitisers
#        make SAN=1     → sanitisers only
ifeq ($(DEBUG),1)
    CFLAGS += -g3 -O0 -fno-omit-frame-pointer \
              -fsanitize=address,leak,undefined
    BUILD  := debug
else ifeq ($(SAN),1)
    CFLAGS += -g3 -O1 -fno-omit-frame-pointer \
              -fsanitize=address,leak,undefined
    BUILD  := sanitise
else
    CFLAGS += -O2 -DNDEBUG
    BUILD  := release
endif

# ─── Colours ───────────────────────────────
BOLD   := \033[1m
GREEN  := \033[0;32m
BLUE   := \033[0;34m
YELLOW := \033[0;33m
RED    := \033[0;31m
RESET  := \033[0m

# ─── Targets ───────────────────────────────

all: $(NAME)

-include $(DEPS)

$(NAME): $(OBJS)
	@printf "$(BOLD)$(GREEN)  LD$(RESET)    $@\n"
	@$(CC) $(CFLAGS) $(OBJS) -o $@
	@printf "$(BOLD)$(BLUE)  Built: $(NAME) [$(BUILD)]$(RESET)\n"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	@printf "$(GREEN)  CC$(RESET)    $<\n"
	@$(CC) $(CFLAGS) $(INC) -MMD -MP -c $< -o $@

clean:
	@printf "$(YELLOW)  Removing objects...$(RESET)\n"
	@rm -rf $(OBJ_DIR)

fclean: clean
	@printf "$(RED)  Removing $(NAME)...$(RESET)\n"
	@rm -f $(NAME)

re: fclean all

run: $(NAME)
	@./$(NAME)

# Run with sanitisers
san:
	@$(MAKE) SAN=1 re
	@./$(NAME)

# Valgrind memory check
valgrind: $(NAME)
	valgrind --leak-check=full --track-origins=yes \
	         --show-leak-kinds=all --error-exitcode=1 \
	         ./$(NAME)

# Print any variable: make print-SRCS
print-%:
	@printf "$(BOLD)$*$(RESET) = $($*)\n"

# Show help
help:
	@echo "Targets:"
	@echo "  all       Build the program (default)"
	@echo "  clean     Remove object files"
	@echo "  fclean    Remove objects and binary"
	@echo "  re        Full rebuild"
	@echo "  run       Build and run"
	@echo "  san       Build with sanitisers and run"
	@echo "  valgrind  Run under valgrind"
	@echo "  print-X   Print the value of variable X"
	@echo ""
	@echo "Options:"
	@echo "  DEBUG=1   Build with debug symbols and sanitisers"
	@echo "  SAN=1     Build with sanitisers (optimised)"

.PHONY: all clean fclean re run san valgrind print-% help
```

---

### Debugging Makefiles

```bash
# Print the value of a variable during the build
# Add to Makefile: print-%: ; @echo $* = $($*)
make print-SRCS
make print-CFLAGS
make print-OBJS

# Show the full make database (all built-in and user rules, all variables)
make -p 2>/dev/null | less

# Check whether a target is up to date (exit code: 0=up-to-date, 1=needs rebuild, 2=error)
make -q target
echo $?

# Trace what make is doing (shows why each target is rebuilt)
make --trace

# Show each command before running it
make --print-data-base --dry-run 2>/dev/null | head -100

# Verify Makefile syntax without running (dry run)
make -n

# Run only a subtree of dependencies
make --old-file=somefile.c    # Treat file as up to date

# Increase verbosity of make itself
make --debug=all 2>&1 | less

# Check for circular dependencies
make --debug=basic 2>&1 | grep circular
```

---

### Make special targets

```makefile
# Never treat these as file targets — always run when requested
.PHONY: all clean fclean re run test

# If make is interrupted, do not leave partial targets behind
.DELETE_ON_ERROR:

# Do not print 'Entering directory' / 'Leaving directory' messages
MAKEFLAGS += --no-print-directory

# Suppress implicit rules for speed (large projects)
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Set the default shell
SHELL := /bin/bash

# Fail immediately if a pipe command fails (not just the last one)
SHELL := /bin/bash -o pipefail

# Export all variables to sub-make processes
export CC CFLAGS NAME

# Mark intermediate files — make will not warn about them being deleted
.INTERMEDIATE: $(OBJS)

# Keep intermediate files (do not delete .o files after building)
.PRECIOUS: $(OBJ_DIR)/%.o

# Run a target in parallel safely
.NOTPARALLEL: fclean
```

---

### Quick reference — most used commands

```bash
# ── Compile ──────────────────────────────────
cc -Wall -Wextra -Werror source.c -o program           # 42 standard
cc -Wall -Wextra -Werror -g3 -O0 source.c -o program  # Debug build
cc -Wall -Wextra -Werror -O2 -DNDEBUG source.c -o program  # Release build

# ── Sanitisers ───────────────────────────────
cc -g3 -fsanitize=address,leak,undefined source.c -o program
c++ -std=c++98 -g3 -fsanitize=address,leak,undefined source.cpp -o program

# ── C++ ──────────────────────────────────────
c++ -std=c++98 -Wall -Wextra -Werror source.cpp -o program
c++ -std=c++98 -Wall -Wextra -Werror -g3 -O0 source.cpp -o program

# ── Make ─────────────────────────────────────
make                   # Build default target
make -j$(nproc)        # Build in parallel
make clean             # Remove object files
make fclean            # Remove objects and binary
make re                # Full rebuild
make -n                # Dry run — show commands without running
make -C /path          # Run make in another directory
make DEBUG=1           # Pass a variable override
make print-SRCS        # Print a Makefile variable (with print-% target)

# ── Inspect binaries ─────────────────────────
ldd ./program          # Show shared library dependencies
nm ./program           # Show symbol table
nm ./program | c++filt # Demangle C++ symbols
objdump -d ./program   # Disassemble
readelf -a ./program   # Full ELF information
size ./program         # Show section sizes
file ./program         # Show file type and architecture
strings ./program      # Print readable strings from binary

# ── Preprocessor ─────────────────────────────
cc -E source.c                           # Run preprocessor only
cc -dM -E - < /dev/null                  # List all predefined macros
cc -std=c17 -dM -E - < /dev/null        # Predefined macros for a specific standard
cc -H source.c -o /dev/null 2>&1        # Show which headers are included
cc -M source.c                           # Show all dependencies (including system)
cc -MM source.c                          # Show dependencies (excluding system headers)

# ── Dependency generation ─────────────────────
cc -MMD -MP -c source.c -o source.o     # Write .d dependency file alongside .o

# ── Assembly output ───────────────────────────
cc -S source.c -o source.s              # Generate assembly
cc -S -O2 source.c -o source.s         # Optimised assembly
cc -S -O0 -fverbose-asm source.c       # Assembly with comments

# ── Library management ────────────────────────
cc source.c -o program -lm             # Link math library
cc source.c -o program -lpthread       # Link POSIX threads
cc -c source.c -o source.o             # Compile to object file
ar rcs libmylib.a source.o             # Create static library
cc -shared -fPIC source.c -o lib.so    # Create shared library
cc source.c -o program -L. -lmylib    # Link against local library

# ── Sanitiser environment variables ──────────
ASAN_OPTIONS=halt_on_error=1 ./program
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 ./program
LSAN_OPTIONS=verbosity=1 ./program

# ── Compiler info ─────────────────────────────
cc --version                            # Compiler version
cc -v -x c /dev/null -o /dev/null      # Full compiler info and search paths
cc -print-multiarch                     # Multiarch tuple
cc -print-search-dirs                  # Library search paths