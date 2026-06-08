# Git Cheatsheet — native git commands only.
# No aliases required. Works on any machine with git installed.
# Uses: git (version control).

---

## Setup

```bash
# Set identity (required before first commit)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git commit --amend --reset-author --no-edit

# Set default editor
git config --global core.editor vim

# Set default branch name for new repos
git config --global init.defaultBranch main

# Save credentials so you are not asked every time
git config --global credential.helper store

# Show all configuration
git config --list
git config --global --list

# Show a specific value
git config user.name

# Edit the global config file directly
git config --global --edit

Starting a repository

Bash

# Initialise a new repository in the current directory
git init

# Clone an existing repository
git clone https://github.com/user/repo.git

# Clone into a specific directory
git clone https://github.com/user/repo.git my-directory

# Clone only the most recent commit (shallow clone — faster, less data)
git clone --depth 1 https://github.com/user/repo.git

# Clone a single specific branch
git clone https://github.com/user/repo.git -b branch-name --single-branch

# Clone a branch into a specific directory
git clone https://github.com/user/repo.git -b branch-name path/to/directory

Staging and committing

Bash

# Show working tree status
git status
git status --short --branch    # Compact format with branch info

# Stage a specific file
git add filename

# Stage all changes (new, modified, deleted)
git add --all
git add -A

# Stage only already-tracked files (skip new untracked files)
git add -u

# Stage changes interactively (choose which hunks to stage)
git add --patch
git add -p

# Stage all .c files
git add *.c

# Unstage a staged file (keep changes in working tree)
git restore --staged filename
git reset HEAD filename         # Older equivalent

# Discard changes in working tree (DESTRUCTIVE — cannot be undone)
git restore filename
git checkout -- filename        # Older equivalent

# Remove a file from both git and the filesystem
git rm filename

# Remove a file from git index only (keep it on disk)
git rm --cached filename

# Commit staged changes (opens editor)
git commit

# Commit with inline message
git commit --message "feat: add parser"
git commit -m "feat: add parser"

# Commit with a title and a longer description
git commit -m "feat: add parser" -m "Handles edge cases for empty input"

# Amend the last commit (opens editor to change message and content)
git commit --amend

# Amend the last commit without changing the message
git commit --amend --no-edit

# Amend the author of the last commit
git commit --amend --author "Name <email@example.com>"

Viewing history

Bash

# Full log (most recent first)
git log

# One line per commit
git log --oneline

# Visual graph with all branches
git log --oneline --graph --decorate --all

# Log with file change statistics
git log --stat

# Log with short statistics (files changed, insertions, deletions)
git log --shortstat

# Log with actual patch (diff) for each commit
git log --patch
git log -p

# Log for a specific file (follow renames)
git log --follow --oneline filename

# Show only the last N commits
git log -n 5
git log -5

# Show commits by a specific author
git log --author="Name"

# Show commits after a date
git log --since="2024-01-01"
git log --since="1 week ago"
git log --since="1 days ago"

# Show commits before a date
git log --before="2024-06-01"

# Show commits whose message matches a pattern
git log --grep="fix"

# Show commits that added or removed a specific string
git log -S "function_name" --oneline

# Show commits that match a regex pattern in the diff
git log -G "regex_pattern" --oneline

# Show commits in branch-a that are not in branch-b
git log branch-b..branch-a

# Show a specific commit
git show abc1234

# Show what changed in the last commit
git show HEAD

# Show who last modified each line of a file
git blame filename

# Show blame ignoring whitespace changes
git blame -w filename

# Show blame for a specific line range
git blame -L 10,20 filename

# Show all references (branches, tags, stashes)
git for-each-ref

# Show all recorded movements of HEAD (useful for recovery)
git reflog

# Show files tracked by git
git ls-files

# Show untracked files not covered by .gitignore
git ls-files --others --exclude-standard

# Show the contents of a file at a specific commit
git show HEAD:filename
git show abc1234:src/main.c

# Show the repository root directory
git rev-parse --show-toplevel

Branches

Bash

# List local branches (* marks current)
git branch

# List all branches (local and remote)
git branch --all
git branch -a

# List branches and show their upstream and last commit
git branch --verbose --verbose
git branch -vv

# Create a new branch
git branch branch-name

# Switch to an existing branch
git switch branch-name
git checkout branch-name           # Older equivalent

# Create and switch in one command
git switch --create branch-name
git checkout -b branch-name        # Older equivalent

# Create a branch based on a remote branch
git checkout origin/main -b branch-name

# Create a branch with no commit history (orphan branch)
git checkout --orphan branch-name

# Rename the current branch
git branch --move new-name
git branch -m new-name

# Delete a merged branch (safe)
git branch --delete branch-name
git branch -d branch-name

# Force delete a branch (even if not merged)
git branch --delete --force branch-name
git branch -D branch-name

# Delete a remote branch
git push origin --delete branch-name

Remote repositories

Bash

# List configured remotes
git remote --verbose
git remote -v

# Add a remote
git remote add origin https://github.com/user/repo.git

# Remove a remote
git remote remove origin

# Fetch all remotes (download but do not merge)
git fetch --all

# Fetch and remove stale remote-tracking references
git fetch --all --prune

# Update the list of remote branches
git remote update origin --prune
git remote update origin -p

# Pull (fetch + merge or rebase depending on config)
git pull

# Pull from a specific remote and branch
git pull origin main

# Pull and rebase instead of merge
git pull --rebase

# Push current branch to its upstream
git push

# Push a specific branch to a specific remote
git push origin branch-name

# Push and set upstream for a new branch
git push --set-upstream origin branch-name
git push -u origin branch-name

# Force push (DANGEROUS — rewrites remote history)
# Only use on your own branches that no one else has checked out
git push --force

# Safer force push — fails if the remote was updated since your last fetch
git push --force-with-lease

Merging and rebasing

Bash

# Merge another branch into the current branch
git merge branch-name

# Merge without fast-forward (always creates a merge commit)
git merge --no-ff branch-name

# Merge without committing (inspect before you commit)
git merge --no-commit branch-name

# Abort a merge in progress
git merge --abort

# Cherry-pick a single commit onto the current branch
git cherry-pick abc1234

# Cherry-pick a range of commits (A must be older than B)
# The ^ includes commit A itself
git cherry-pick abc1234^..def5678

# Rebase the current branch onto another branch
git rebase branch-name

# Rebase the last N commits interactively
git rebase --interactive HEAD~N
git rebase -i HEAD~N

# Interactive rebase — commands available in the editor:
#   pick   — use commit as-is
#   reword — use commit, edit the message
#   edit   — use commit, stop to amend files or message
#   squash — combine with the previous commit (keep both messages)
#   fixup  — combine with the previous commit (discard this message)
#   drop   — remove the commit entirely

# Rebase only commits in branch-a that are not in branch-b onto branch-c
git rebase --onto branch-c branch-b branch-a

# Continue after resolving a conflict during rebase
git rebase --continue

# Abort a rebase in progress
git rebase --abort

Undoing things

Bash

# Unstage all staged changes (keep working tree as-is)
git restore --staged .
git reset HEAD

# Unstage a specific file (keep working tree as-is)
git reset HEAD filename

# Undo the last commit — keep changes staged
git reset --soft HEAD~1

# Undo the last commit — keep changes in working tree, unstaged (default)
git reset --mixed HEAD~1
git reset HEAD~1

# Undo the last commit and discard all changes (DESTRUCTIVE)
git reset --hard HEAD~1

# Reset to a specific commit (DESTRUCTIVE — discards everything after it)
git reset --hard abc1234

# Summary of reset modes:
# --soft   moves HEAD only
# --mixed  moves HEAD and resets the staging area (default)
# --hard   moves HEAD, resets staging area, and resets working tree

# Create a new commit that reverses a specific commit (safe — no history rewrite)
# Use this on shared branches instead of reset
git revert abc1234

# Revert the last commit
git revert HEAD

# Discard all uncommitted changes and untracked files
git clean -fd             # Remove untracked files and directories
git clean -fdx            # Also remove files ignored by .gitignore
git clean -fX             # Remove only ignored files
git clean -n              # Dry run — show what would be deleted without deleting
git clean -nd             # Dry run including directories

Stash

Bash

# Save current changes to the stash (staged and unstaged)
git stash

# Stash including new untracked files (but not .gitignore entries)
git stash -u

# Save with a description
git stash save "work in progress on parser"

# List all stashes
git stash list

# Apply the most recent stash (keep it in the stash list)
git stash apply

# Apply the most recent stash and remove it from the list
git stash pop

# Apply a specific stash by index
git stash apply stash@{2}
git stash pop stash@{2}

# Show the contents of a stash
git stash show
git stash show --patch stash@{0}

# Create a branch from a stash (useful when stash conflicts with current work)
git stash branch branch-name stash@{1}

# Drop a specific stash
git stash drop stash@{0}

# Clear all stashes
git stash clear

Diffs

Bash

# Diff between working tree and staging area (unstaged changes)
git diff

# Diff between working tree and the last commit
git diff HEAD

# Diff between staging area and last commit (staged changes)
git diff --staged
git diff --cached

# Diff between two commits
git diff abc1234 def5678

# Diff between two branches
git diff main feature-branch

# Diff a specific file between two branches
git diff main feature-branch -- filename

# Show only filenames that changed (not the content)
git diff --name-only

# Show filenames with change status (A=added, M=modified, D=deleted)
git diff --name-status

# Show diff with colour (explicit — usually on by default)
git diff --color

# Ignore whitespace changes
git diff --ignore-all-space

Tags

Bash

# List tags
git tag

# Create a lightweight tag at HEAD
git tag v1.0

# Create an annotated tag (includes message, author, date)
git tag --annotate v1.0 --message "Release version 1.0"
git tag -a v1.0 -m "Release version 1.0"

# Tag a specific commit
git tag v0.9 abc1234

# Show the details and diff of a tag
git show v1.0

# Push a single tag to remote
git push origin v1.0

# Push all local tags to remote
git push --tags
git push origin --tags

# Fetch tags from remote
git fetch --tags

# Delete a local tag
git tag --delete v1.0

# Delete a remote tag
git push origin --delete v1.0

Searching

Bash

# Search for a string in all tracked files
git grep "pattern"

# Search with line numbers shown
git grep -n "pattern"

# Search in a specific branch without switching to it
git grep "pattern" branch-name

# Search with heading (filename printed once above matches)
git grep --heading --line-number "pattern"

# Find which commit introduced a string
git log --all -S "pattern" --oneline

# Find which commit changed a line matching a regex
git log --all -G "regex_pattern" --oneline

# Find commits whose message matches a pattern
git log --grep="pattern" --oneline

# Binary search for the commit that introduced a bug
git bisect start
git bisect bad              # Mark the current commit as bad
git bisect good v1.0        # Mark a known-good commit or tag
# Git checks out a midpoint commit — test it, then mark it:
git bisect good             # This commit is fine
git bisect bad              # This commit has the bug
# Git narrows it down automatically until it finds the culprit
git bisect reset            # Return to HEAD when done

Patches

Bash

# Generate a diff patch from the last N commits on a branch
git log -n -p branch-name > diff.patch

# Generate a diff patch from staged changes
git diff --cached > diff.patch

# Check if a patch applies cleanly (no output means no conflicts)
git apply --check diff.patch

# Show which files a patch would change
git apply --stat diff.patch

# Apply a patch (stages changes but does not commit)
git apply diff.patch

# Generate format-patch files with commit metadata (one file per commit)
git format-patch -n branch-name          # Last N commits on branch
git format-patch abc1234..def5678        # Range of commits (inclusive)
git format-patch -1 abc1234              # Single commit
git format-patch abc1234                 # All commits after abc1234
git format-patch --root abc1234          # All commits from root to abc1234

# Apply a format-patch file (preserves commit message and author)
git am 0001-fix-parser.patch

# Apply all patches in the current directory in order
git am ./*.patch

# Abort a failed am session
git am --abort

# Continue after resolving a conflict during am
git am --resolved

Bundles

A bundle packages commits into a single file that can be transferred without a network.
Unlike a tar archive, it only includes what has been committed and tracked.

Bash

# Bundle the full master branch history
git bundle create repo.bundle HEAD master

# Clone from a bundle (works exactly like cloning from a URL)
git clone repo.bundle

# Bundle only the last 10 commits
git bundle create repo.bundle HEAD~10

# Bundle a range of commits
git bundle create repo.bundle HEAD~10..HEAD
git bundle create repo.bundle abc1234..def5678
git bundle create repo.bundle origin/master..master

# Bundle commits on master that are not yet on origin/master
git bundle create repo.bundle master ^origin/master

.gitignore patterns

gitignore

# Ignore a specific file
secret.txt

# Ignore all .log files anywhere in the repo
*.log

# Ignore a directory and everything inside it
build/

# Ignore a file only at the root of the repo (not in subdirectories)
/config.local

# Ignore all .txt files except README.txt
*.txt
!README.txt

# Ignore all .o files in any directory
**/*.o

# Force-add a file that is covered by .gitignore
# git add -f filename

# Check what is being ignored and why
git check-ignore -v filename
git status --ignored

Common workflows
Start a new feature branch

Bash

git switch main
git pull
git switch --create feature/my-feature
# ... make changes ...
git add --all
git commit -m "feat: add my feature"
git push -u origin feature/my-feature

Squash the last N commits into one

Bash

git rebase -i HEAD~N
# In the editor: leave the first line as 'pick', change the rest to 'fixup'

Recover a deleted branch

Bash

# Find the commit hash from the reflog
git reflog
# Re-create the branch at that commit
git checkout -b branch-name abc1234

Undo a pushed commit safely

Bash

# Use revert — it adds a new commit that undoes the change
# Safe to use on shared branches because it does not rewrite history
git revert abc1234
git push

Keep a feature branch up to date with main

Bash

git switch feature/my-feature
git fetch origin
git rebase origin/main
# Resolve any conflicts, then:
git rebase --continue
git push --force-with-lease

Find which commit broke something

Bash

git bisect start
git bisect bad                  # Current state is broken
git bisect good v1.0            # This tag was working
# Test each commit git checks out, then run:
git bisect good                 # or: git bisect bad
# Repeat until git identifies the culprit commit
git bisect reset

Quick reference

text

SETUP        git config --global user.name "Name"
             git config --global user.email "email"

INIT         git init                    git clone <url>

STAGE        git add filename            git add -A
             git restore --staged file   git rm --cached file

COMMIT       git commit -m "msg"         git commit --amend --no-edit

LOG          git log --oneline           git log --oneline --graph --all
             git log --follow filename   git log --author="Name"
             git log -S "string"         git blame -L 10,20 filename

BRANCH       git switch -c name          git branch -d name
             git branch -vv              git branch -a

REMOTE       git fetch --all --prune     git pull --rebase
             git push -u origin name     git push --force-with-lease

MERGE        git merge --no-ff branch    git cherry-pick abc1234
             git rebase -i HEAD~N        git rebase --onto c b a

UNDO         git restore filename        git reset --soft HEAD~1
             git reset --hard HEAD~1     git revert abc1234
             git clean -fd               git clean -n

STASH        git stash                   git stash pop
             git stash list              git stash drop stash@{0}

DIFF         git diff                    git diff --staged
             git diff main feature       git diff --name-only

TAG          git tag -a v1.0 -m "msg"   git push origin v1.0
             git tag --delete v1.0       git push origin --delete v1.0

SEARCH       git grep -n "pattern"       git log --grep="pattern"
             git bisect start/good/bad/reset

PATCH        git format-patch -N branch  git am patch.patch
BUNDLE       git bundle create out.bundle HEAD master