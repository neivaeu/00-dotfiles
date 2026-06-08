---
name: Broken Configuration
about: Report a dotfile configuration that stopped working or behaves unexpectedly
title: "[BROKEN] <tool>: <short description>"
labels: broken-config
assignees: ''
---

## Which configuration is broken?

**File:** <!-- `vim/.vimrc` (Example: change to the actual broken file) -->
**Tool:** <!-- `vim` (Example: vim, zsh, bash, git, vscode, starship) -->

---

## What should happen?

<!-- When I press `<C-n>` inside Vim, the NERDTree file explorer side panel should open. (Example: replace with your expected behavior) -->

---

## What actually happens?

<!-- When I press `<C-n>`, nothing happens, and I get an error at the bottom of the screen saying "E492: Not an editor command: NERDTreeToggle". (Example: replace with the actual problem) -->

---

## Steps to reproduce

<!-- 
1. Open the terminal. (Example)
2. Run `vim` to open the editor. (Example)
3. Press the keyboard shortcut `<C-n>`. (Example)
4. Observe the error message at the bottom. (Example)
-->
1. 
2. 
3. 

---

## Environment

| Field          | Value                                                         |
|----------------|---------------------------------------------------------------|
| OS             | <!-- Ubuntu 22.04 LTS (Example) -->                           |
| Shell          | <!-- zsh 5.9 (Example) -->                                    |
| Tool version   | <!-- vim 9.0.1378 (Example) -->                               |
| Tool path      | <!-- output of `which <tool>` (Example: /usr/bin/vim) -->     |
| Install method | <!-- dotfiles: bootstrap.sh, GNU stow, or manual (Example) -->|

---

## Error output

<!-- Example error output: E492: Not an editor command: NERDTreeToggle -->
```text